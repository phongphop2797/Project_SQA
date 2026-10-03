#!/usr/bin/env bash
# =============================================================================
# Symflower x Defects4J experiment runner
# วนทำทีละ bug: checkout(buggy+fixed) -> symflower generate -> run tests
#   -> เทียบ fail(buggy)/pass(fixed) -> coverage -> บันทึก CSV + logs
#
# ใช้: bash run_symflower_lang.sh [bug_start] [bug_end] [Round1|Round2] [package|class]
# ตัวอย่าง:
#   bash run_symflower_lang.sh 1 1 Round1 package   # ทดสอบ bug 1
#   bash run_symflower_lang.sh 1 5 Round1 package   # วน Lang 1-5
# =============================================================================
set -u

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH="$JAVA_HOME/bin:$HOME/defects4j/framework/bin:$PATH"

BASE="$HOME/sqa-project"
PROJ="Lang"
WS="$BASE/workspaces"
ROUND="${3:-Round1}"          # Result_Round1 / Result_Round2
SCOPE="${4:-package}"         # package = ทั้ง package ของ bug | class = เฉพาะคลาสที่ถูกแก้
MEM=4096                      # symflower memory limit (MB)

RES="$BASE/Symflower/Result_$ROUND"
TESTOUT="$BASE/Symflower/Test/bug"
mkdir -p "$WS" "$RES" "$BASE/Symflower/Test"

CSV="$RES/lang_results.csv"
[ -f "$CSV" ] || echo "round,scope,project,bug_id,n_test_files,n_generated_lines,fail_buggy,fail_fixed,detected,stmt_cov,branch_cov,gen_time_sec,notes" >> "$CSV"

echo "== Config: round=$ROUND scope=$SCOPE mem=${MEM}MB ==" | tee -a "$RES/run_info.txt"
echo "started: $(date)" >> "$RES/run_info.txt"

# metadata ของทุก bug (ครั้งเดียว) — output เป็น CSV ที่ค่าคร่อมด้วย double quote
META_CSV="$RES/lang_meta.csv"
[ -s "$META_CSV" ] || defects4j query -p "$PROJ" -q "bug.id,classes.modified,tests.trigger" > "$META_CSV" 2>"$RES/query_error.log"

# ชื่อไฟล์ log ของ bugs ที่รันวันนี้
BugsList="$(seq "${1:-1}" "${2:-5}")"

get_failing() { # parse "Failing tests:" จาก log defects4j test
  awk '/^Failing tests:/{f=1;next} f && /::/{gsub(/^[ \t]+-[ \t]+/,""); print $1; if(!/::/)f=0}' "$1" | sort -u
}

for N in $BugsList; do
  echo "===== [$ROUND/$SCOPE] Bug $N : $(date +%H:%M:%S) ====="
  WB="$WS/${PROJ,,}_${N}b"; WF="$WS/${PROJ,,}_${N}f"
  rm -rf "$WB" "$WF"

  # --- 1) checkout ---
  defects4j checkout -p "$PROJ" -v "${N}b" -w "$WB" > "$RES/bug${N}_checkout_b.log" 2>&1 \
    || { echo "bug $N: checkout buggy FAIL (ดู $RES/bug${N}_checkout_b.log)"; echo "$ROUND,$SCOPE,$PROJ,$N,-,-,-,-,-,-,-,-,checkout_b_fail" >> "$CSV"; continue; }
  defects4j checkout -p "$PROJ" -v "${N}f" -w "$WF" > "$RES/bug${N}_checkout_f.log" 2>&1 \
    || { echo "bug $N: checkout fixed FAIL"; echo "$ROUND,$SCOPE,$PROJ,$N,-,-,-,-,-,-,-,-,checkout_f_fail" >> "$CSV"; continue; }

  # --- 2) target ที่จะให้ symflower ทำ (อ่าน CSV ด้วย python3 เพราะค่าคร่อมด้วย quote) ---
  MCLASSES=$(python3 -c "
import csv
with open('$META_CSV') as f:
    for row in csv.reader(f):
        if row and row[0]=='$N':
            print(row[1]); print(row[2]); break
")
  CLASSES=$(echo "$MCLASSES" | sed -n 1p)
  TRIGGERS=$(echo "$MCLASSES" | sed -n 2p | tr ',' '\n' | sed 's/^ *//;s/ *$//' | grep '::' | sort -u)
  FIRSTCLASS=$(echo "$CLASSES" | cut -d, -f1 | tr -d ' ')
  PKGPATH=$(echo "$FIRSTCLASS" | tr '.' '/')          # org/apache/.../NumberUtils (no .java)
  PKGDIR="${PKGPATH%/*}"
  if [ "$SCOPE" = "class" ]; then
    TARGET="src/main/java/$PKGPATH.java"
  else
    TARGET="src/main/java/$PKGDIR"
    # package ใหญ่เกิน (เช่นคลาสอยู่ root package) → ย้ายไป class scope กันบานปลายเป็นทั้ง project
    NJ=$(find "$WB/$TARGET" -maxdepth 1 -name "*.java" 2>/dev/null | wc -l)
    if [ "$NJ" -gt 10 ]; then
      echo "bug $N: package มี $NJ ไฟล์ (>10) → ใช้ class scope แทน"
      TARGET="src/main/java/$PKGPATH.java"
    fi
  fi
  echo "bug $N: modified=[$CLASSES] target=$TARGET"

  # --- 3) ซ่อน pom.xml (plain-Java mode) — ใช้ --java-test-framework=JUnit4 ให้ตรงกับ build ของ project ---
  [ -f "$WB/pom.xml" ] && mv "$WB/pom.xml" "$WB/pom.xml.bak"
  [ -f "$WF/pom.xml" ] && mv "$WF/pom.xml" "$WF/pom.xml.bak"

  # --- 4) symflower สร้าง test (จับเวลา) ---
  cd "$WB" || continue
  T0=$(date +%s)
  symflower unit-tests --memory-limit="$MEM" --java-test-framework=JUnit4 "$TARGET" > "$RES/bug${N}_symflower.log" 2>&1
  GEN_TIME=$(( $(date +%s) - T0 ))
  N_GEN=$(grep -cE 'generated unit test file|updated unit test file' "$RES/bug${N}_symflower.log" || true)

  # --- 5) ย้าย test ไป src/test/java ---
  while IFS= read -r f; do
    d="src/test/java/${f#src/main/java/}"
    mkdir -p "$(dirname "$d")"; mv "$f" "$d"
  done < <(find src/main/java -name "*SymflowerTest.java" 2>/dev/null)
  NFILES=$(find src/test/java -name "*SymflowerTest.java" | wc -l)
  NLINES=$(find src/test/java -name "*SymflowerTest.java" -exec cat {} + 2>/dev/null | grep -c '@Test' || true)
  # เก็บสำเนา test เข้า Symflower/Test/bugN
  rm -rf "${TESTOUT}${N}"; mkdir -p "${TESTOUT}${N}"
  find src/test/java -name "*SymflowerTest.java" -exec cp --parents {} "${TESTOUT}${N}/" \;

  # --- 6) รันบน buggy ---
  defects4j test > "$RES/bug${N}_test_buggy.log" 2>&1 || true
  FAILB=$(get_failing "$RES/bug${N}_test_buggy.log")

  # --- 7) คัดลอก test เดียวกันไป fixed แล้วรัน ---
  (cd "$WB" && find src/test/java -name '*SymflowerTest.java' -print0 | tar --null -cf - -T -) | (cd "$WF" && tar -xf -)
  (cd "$WF" && defects4j test > "$RES/bug${N}_test_fixed.log" 2>&1) || true
  FAILF=$(get_failing "$RES/bug${N}_test_fixed.log")

  # --- 8) fault detection: fail บน buggy + pass บน fixed + ไม่ใช่ trigger test ของ developer ---
  ALLDET=$(comm -23 <(echo "$FAILB") <(echo "$FAILF"))
  if [ -n "$TRIGGERS" ]; then
    DETECTED=$(echo "$ALLDET" | grep -vxF -f <(echo "$TRIGGERS") || true)
  else
    DETECTED="$ALLDET"
  fi
  echo "$DETECTED" > "$RES/bug${N}_detected_tests.txt"

  # --- 9) coverage บน buggy ---
  (cd "$WB" && defects4j coverage > "$RES/bug${N}_coverage.log" 2>&1) || true
  STMT=$(grep -oE 'Line coverage: [0-9]+(\.[0-9]+)?%'      "$RES/bug${N}_coverage.log" | grep -oE '[0-9]+(\.[0-9]+)?%' | head -1)
  BRCH=$(grep -oE 'Condition coverage: [0-9]+(\.[0-9]+)?%' "$RES/bug${N}_coverage.log" | grep -oE '[0-9]+(\.[0-9]+)?%' | head -1)
  [ -z "$STMT" ] && STMT="see_log"; [ -z "$BRCH" ] && BRCH="see_log"

  # --- 10) บันทึก CSV (ถ้า compile suite พัง ให้ note ไว้ว่า compile_fail) ---
  NB=$(echo "$FAILB" | grep -c '::' || true)
  NF=$(echo "$FAILF" | grep -c '::' || true)
  ND=$(echo "$DETECTED" | grep -c '::' || true)
  NOTE=ok
  grep -q "Cannot compile test suite" "$RES/bug${N}_test_buggy.log" 2>/dev/null && NOTE=compile_fail
  echo "$ROUND,$SCOPE,$PROJ,$N,$NFILES,$NLINES,$NB,$NF,$ND,$STMT,$BRCH,$GEN_TIME,$NOTE" >> "$CSV"

  echo "bug $N done: files=$NFILES tests=$NLINES failB=$NB failF=$NF detected=$ND cov=$STMT/$BRCH time=${GEN_TIME}s"
done

echo "finished: $(date)" >> "$RES/run_info.txt"
echo "==== เสร็จ — ผลอยู่ที่ $CSV ===="
cat "$CSV"

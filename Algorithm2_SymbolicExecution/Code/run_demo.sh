#!/usr/bin/env bash
# =============================================================================
# run_demo.sh — Demo สด: Symflower x Defects4J (Lang bug 1) ใช้เวลา ~5 นาที
# ใช้: bash run_demo.sh          (รันทั้งชุด)
#      bash run_demo.sh clean    (ล้าง workspace demo)
# จุดประสงค์: โชว์ครบวงจร checkout → generate → รัน buggy/fixed → สรุปผล
# =============================================================================
set -e
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH="$JAVA_HOME/bin:$HOME/defects4j/framework/bin:$PATH"
WS=/tmp/demo_symflower_lang1b
WF=/tmp/demo_symflower_lang1f
PKG=src/main/java/org/apache/commons/lang3/math

banner() { echo; echo "=================================================="; echo "  $1"; echo "=================================================="; }

[ "$1" = "clean" ] && { rm -rf $WS $WF; echo "cleaned"; exit 0; }

banner "ขั้น 1/6 — Checkout Lang-1b (โค้ด buggy จริงจาก Defects4J)"
rm -rf $WS $WF
defects4j checkout -p Lang -v 1b -w $WS | tail -2

banner "ขั้น 2/6 — ซ่อน pom.xml (plain-Java mode — เหตุผล: รายงานหัวข้อ 6 ข้อ 5)"
mv $WS/pom.xml $WS/pom.xml.bak

banner "ขั้น 3/6 — Symflower สร้าง test (symbolic execution, package math)"
cd $WS
symflower unit-tests --memory-limit=4096 --java-test-framework=JUnit4 $PKG 2>&1 | tail -6 || true
echo "--- ไฟล์ test ที่สร้าง ---"
find src/main/java -name "*SymflowerTest.java"
echo "--- ตัวอย่างเนื้อหา (2 test แรก) ---"
head -20 $(find src/main/java -name "*SymflowerTest.java" | head -1) || true

banner "ขั้น 4/6 — ย้าย test เข้า src/test/java แล้วรันบนโค้ด buggy"
while IFS= read -r f; do d="src/test/java/${f#src/main/java/}"; mkdir -p "$(dirname "$d")"; mv "$f" "$d"; done < <(find src/main/java -name "*SymflowerTest.java")
defects4j test 2>&1 | tail -4 || true

banner "ขั้น 5/6 — รัน test ชุดเดิมบนโค้ด FIXED (เวอร์ชันอ้างอิง)"
rm -rf $WF && defects4j checkout -p Lang -v 1f -w $WF > /dev/null 2>&1
(cd $WF && mv pom.xml pom.xml.bak 2>/dev/null || true)
(cd $WB && find src/test/java -name '*SymflowerTest.java' -print0 | tar --null -cf - -T -) | (cd $WF && tar -xf -)
(cd $WF && defects4j test 2>&1 | tail -4) || true

banner "ขั้น 6/6 — สรุปผล Demo (จุดพูด)"
cat << "EOF"
จุดพูด:
1. Symflower สร้าง test ได้จริงจาก symbolic execution (20 tests ใน ~1 นาที)
2. แต่ test ที่สร้าง "ยืนยันพฤติกรรมของโค้ด buggy" เพราะ oracle มาจากการ execute โค้ดตัวเอง
   → ผ่านบน buggy และผ่านบน fixed = จับ bug ไม่ได้ (ตรง funnel ชั้นที่ 3 ในรายงาน)
3. ตัวที่ fail บน buggy คือ dev trigger test (TestLang747) ของ developer — รู้คำตอบที่ถูก
4. เทียบกับ AI track: AI ได้ bug report เป็น oracle จึงเขียน assert ตาม "ค่าที่ถูก" และจับได้
5. ขยายผล: ทำซ้ำแบบอัตโนมัติครบ 854 bugs / 17 projects (FINAL_TABLE.md)
EOF
echo "Demo จบ — ล้างด้วย: bash run_demo.sh clean"

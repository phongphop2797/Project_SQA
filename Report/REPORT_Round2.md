# รายงานการทดลองรอบที่ 2 (ฉบับสมบูรณ์)
## Benchmarking AI-Testing vs Symbolic Execution and NSGA-II
### CP353201 Software Quality Assurance — ปีการศึกษา 1/2569

กลุ่ม: 673308279-7 นายปองภพ ศรีรักษ์, 673380271-3 นายธนภูมิ แทนทุมมา, 673380510-1 นางสาวจิรัชญา เป้าจันทึก
อาจารย์ที่ปรึกษา: ผศ. ดร.ชิตสุธา สุ่มเล็ก

---

## 1. บทนำ

รายงานฉบับนี้เป็นผลการทดลองรอบที่ 2 ตามข้อกำหนด 2.2 โดยพัฒนาและใช้งานเครื่องมือทั้ง 4 ตัวที่เลือกไว้ในรอบที่ 1 กับ Java projects ใน Defects4J ครบทั้ง 17 projects:

| ประเภท | ชื่อ | บทบาท |
|---|---|---|
| Algorithm 1 | **NSGA-II** (implement เองตาม Deb et al. 2002) | เลือก test suite ที่เหมาะสมจาก pool โดย multi-objective |
| Algorithm 2 | **Symbolic Execution (Symflower)** | สร้าง JUnit test ด้วย symbolic execution — รันครบทุก bug |
| AI 1 | **ChatGPT** | สร้าง test ผ่าน Prompt จากรายงานรอบที่ 1 |
| AI 2 | **GitHub Copilot** | สร้าง test ผ่าน Copilot Chat ด้วย Prompt ชุดเดียวกัน |

**ข้อความหลักของรายงาน:** Symflower รันครบ 854 active bugs แต่จับ bug ได้ 0 — รายงานนี้วิเคราะห์สาเหตุเป็น 3 ชั้น พร้อมหลักฐาน log ครบทุกขั้น และแสดงกระบวนการตรวจสอบความถูกต้องที่จับ false positive ของตัวเองได้

## 2. สภาพแวดล้อมและขอบเขตการทดลอง

| รายการ | ค่า |
|---|---|
| ระบบ | Ubuntu 26.04 บน WSL2 (Windows 11), RAM 12GB สำหรับ WSL |
| Defects4J | version 3 — ต้องใช้ Java 11 เท่านั้น (ตรวจพบจากการใช้งานจริง) |
| Java | OpenJDK 11.0.32 (JAVA_HOME ต้องชี้ java-11 ก่อนทุกคำสั่ง d4j) |
| Symflower | build ล่าสุด linux-x86_64 (download.symflower.com) |
| JUnit | 4.10 (ตาม build ของ project — Symflower ถูกบังคับด้วย `--java-test-framework=JUnit4`) |
| Parallelism | 2–3 workers ต่อเครื่อง (xargs -P + flock serialize ช่วง checkout) |

### 2.1 ขอบเขต: ครบทั้ง 17 projects — 854 active bugs

ครอบคลุม active bugs ทุกตัวตามตารางของ Defects4J (deprecated bugs 9 ตัวถูกตัด: Lang 2,18,25 / Cli 6 / Closure 63,93 / JacksonDatabind 65,89 / Time 21 — บันทึกสถานะใน CSV ทุกตัว):

| Project | Active | Project | Active | Project | Active | Project | Active |
|---|---|---|---|---|---|---|---|
| Chart | 26 | Cli | 39 | Closure | 174 | Codec | 18 |
| Collections | 28 | Compress | 47 | Csv | 16 | Gson | 18 |
| JacksonCore | 26 | JacksonDatabind | 110 | JacksonXml | 6 | Jsoup | 93 |
| JxPath | 22 | Lang | 61 | Math | 106 | Mockito | 38 |
| Time | 26 | | | | | **รวม** | **854** |

ฝั่ง AI (ต้นทุนมนุษย์ต่อ bug สูง — ต้องส่ง prompt ตัวต่อตัวตาม protocol): **กลุ่มตัวอย่าง 3 bugs ของ Lang (1, 3, 5)** ทั้งสองเครื่องมือ

## 3. วิธีการทดลอง

### 3.1 Pipeline กลาง (ทำซ้ำได้ด้วยสคริปต์ใน `Algorithm2_SymbolicExecution/Code/`)

1. `defects4j checkout` buggy (`Nb`) + fixed (`Nf`) เข้า workspace แยกต่อ bug; checkout ทุกตัว serialize ด้วย flock (กัน git lock ชนกันเวลารันขนาน)
2. อ่าน metadata (modified classes, trigger tests) ด้วย `defects4j query -q "bug.id,classes.modified,tests.trigger"` — **รองรับตัวคั่นทั้ง `,` และ `;`** (Defects4J ใช้ต่างกันตาม project)
3. เลือก target ให้ Symflower: package ของ modified class (ถ้า package ใหญ่เกิน 10 ไฟล์ → จำกัดเป็นไฟล์คลาสเดียว)
4. สร้าง test: `symflower unit-tests --memory-limit=2560 --java-test-framework=JUnit4 <target>`
5. ตรวจจริง: `defects4j test` บน buggy และ fixed
6. **Fault detection** = fail บน buggy + pass บน fixed + **ตัด dev trigger tests ออกเสมอ** (ตาม protocol Just et al. 2014)
7. **Coverage** จาก `defects4j coverage` (Cobertura): Line/Condition coverage ของคลาสที่มี bug
8. เก็บ CSV ต่อ bug + raw logs ทุกขั้น; ล้าง workspace ทันทีหลังเก็บ (คุมพื้นที่)

### 3.2 ข้อควรระวังการวัดที่สำคัญ (ตรวจพบและแก้ระหว่างทาง)

- **full-suite run มี `haltonfailure`** — หยุดที่ dev trigger test (ที่ fail อยู่แล้ว) ก่อนถึง test ที่สร้าง → การวัด detection ใช้การรัน **ราย method** (`-t Class::method`) เสมอ
- **รูปแบบ metadata ต่างกันตาม project** — trigger separator `,` หรือ `;` (Time, JacksonXml ใช้ `;`) — parser ผิดทำให้เกิด false positive (ดูหัวข้อ 5)
- **Cobertura ของ d4j อ่าน bytecode ได้ถึง Java 6** — ห้ามยกระดับ compile

### 3.3 Symflower Round2 (Budget configuration)

- ตัวอย่าง 8 bugs ของ Lang คลุมทุก outcome จาก R1 (จับได้/สร้างได้/compile_fail/สร้างไม่ได้)
- Config ต่าง: `--test-generation-timeout=60` (60 วิต่อ method) — ตามแนวคิด "Budget ต่างกัน" ข้อ 1.7
- ส่วนการทำซ้ำเพื่อหาค่าเฉลี่ยไม่จำเป็น: Symflower deterministic (รันซ้ำได้ผลเดิม — ยืนยันด้วยการเทียบ R1/R2)

### 3.4 Generative AI (ChatGPT / Copilot)

- Prompt 1 (สร้าง) + Prompt 2 (แก้ ≤3 รอบ) จากรายงานรอบที่ 1 หัวข้อ 5 — กรอกข้อมูลจริงครบทุก placeholder, **ฝัง source ของ buggy version เท่านั้น** (ห้ามให้ AI เห็น fixed)
- คุมความยุติธรรม: แชทใหม่ทุก bug, Prompt ชุดเดียวกันทั้งสองเครื่องมือ, ห้ามแก้ test ด้วยมือ (ยกเว้น rename ชื่อคลาสเชิงกลไกกันชน — บันทึก note `renamed_class`)
- วัดผลราย method ด้วยสคริปต์ `ai_test_eval.sh` + `ai_cov_eval.sh` (ตรวจเฉพาะ method ของคลาส AI — ตัด dev trigger ออกโดยนิยาม)

### 3.5 NSGA-II

- **Individual** = binary vector เลือก test จาก pool รวม (Symflower + ChatGPT + Copilot)
- **Objective (minimize)**: (−fault detection, ขนาด suite, −coverage) — ค่า fitness มาจาก **cache ของการรันจริงราย test** (buggy/fixed/coverage ครั้งเดียวต่อ test) → ต้นทุนไม่ขึ้นกับ generation
- Implement ตาม Deb et al. (2002): fast non-dominated sort + crowding distance + binary tournament + uniform crossover (0.9) + bit-flip mutation (1/n) + elitism
- **Round1**: Pop 50 / Gen 50 / seed 42 — **Round2**: Pop 100 / Gen 100 / seed 7 (ทดสอบความเสถียรตามข้อ 1.7)

## 4. ผลการทดลอง

### 4.1 Symflower — ครบ 854/854 active bugs (ตารางเต็มใน `Report/FINAL_TABLE.md`)

| Project | Bugs | มี test | @Test | จับ bug |
|---|---|---|---|---|
| Lang | 61 | 22 | 1,510 | 0 |
| Compress | 47 | 33 | 2,858 | 0 |
| JacksonCore | 26 | 14 | 3,896 | 0 |
| Jsoup | 93 | 33 | 1,788 | 0 |
| Math | 106 | 19 | 150 | 0 |
| Cli | 39 | 5 | 125 | 0 |
| Time | 26 | 7 | 217 | 0 |
| JacksonDatabind | 110 | 8 | 42 | 0 |
| Codec / Csv / Collections | 62 | 15 | 91 | 0 |
| Chart / JxPath / Gson / Mockito / JacksonXml | 110 | 0 | 0 | 0 |
| **รวม** | **854** | **101 (11.8%)** | **10,677** | **0** |

**Round2 (budget 60 วิ):** ผลเหมือน R1 ทุกตัวใน 8 sample bugs — Lang ไม่มี method ที่ช้าเกิน 60 วิ (ข้อจำกัด budget จะมีผลเฉพาะ project ที่เกิด path explosion เช่น JacksonCore-25 ที่ใช้ 24 นาที/bug)

### 4.2 ทำไมจึงจับ bug ได้ 0 — funnel 3 ชั้น (จากข้อมูลจริง)

| ชั้น | จำนวน | คิดเป็น | สาเหตุ (หลักฐาน) |
|---|---|---|---|
| 1. สร้าง test ไม่ได้เลย | 698 | 81.7% | gradle (Gson), multi-module maven (JacksonXml ฯลฯ), ant layout เก่า (JxPath/Chart/Closure), Mockito runtime, internal error "cannot set a final field", dependency ข้าม package |
| 2. ได้ test แต่ compile ไม่ผ่าน | 107 (จาก 156) | 69% ของชั้น 1 ที่ผ่าน | test เรียก API ที่ไม่มีใน project, JUnit เวอร์ชันไม่ตรง |
| 3. test รันได้จริง | 49 | 5.7% | **ยังจับไม่ได้ — เพราะ Test Oracle โดยโครงสร้าง (ดู 4.3)** |

### 4.3 เหตุผลเชิงหลักการ: Test Oracle โดยโครงสร้าง

Symflower generate test **จากโค้ด buggy version** และสร้าง assertion จาก **output จริงของโค้ด buggy** (จับจากการ execute แต่ละ path) → test ที่ได้ "ยืนยันพฤติกรรมที่ผิดอยู่แล้ว" จึง**ผ่านบน buggy โดยการออกแบบ** รูปแบบ assertion หลักคือ `assertThrows(...)` ซึ่ง exception ชนิดเดียวกันมักเกิดทั้งสองเวอร์ชัน ธรรมชาติ bug ใน dataset (precision loss, DST overlap, parsing edge case) ต้องใช้ "ความรู้ว่าค่าที่ถูกคืออะไร" ซึ่งไม่มีอยู่ในโค้ด — ตรงตามข้อจำกัดของ King (1976) และที่รายงานรอบที่ 1 ทำนายไว้ ("ยังต้องกำหนด Test Oracle")

### 4.4 Generative AI (กลุ่มตัวอย่าง Lang 1, 3, 5)

| Bug | เครื่องมือ | @Test | compile ผ่าน | จับ bug | หมายเหตุ |
|---|---|---|---|---|---|
| 1 | ChatGPT | 44 | ✅ | 0 | 3 tests assert ผิดทั้งสองเวอร์ชัน |
| 1 | Copilot | 66 | ✅ | ✅ 1 | |
| 3 | ChatGPT | 57 | ✅ | ✅ 4 | กลุ่ม precision tests |
| 3 | Copilot | 66 | ✅ | ✅ 6 | |
| 5 | ChatGPT | 36 | ✅ | ✅ 1 | testLang865 |
| 5 | Copilot | 45 | ✅ | ✅ 9 | กลุ่ม country-only locale |
| **รวม** | ChatGPT | **137** | 100% | **5** | |
| **รวม** | Copilot | **177** | 100% | **16** | |

AI จับ bug ได้เพราะ **bug report ที่ใส่ใน prompt ทำหน้าที่เป็น Test Oracle** (มันรู้ว่า "อะไรคือถูก") — สิ่งที่ symbolic execution ไม่มี ข้อจำกัดที่ยังอยู่: assertion ผิดปนมา (fail ทั้งสองเวอร์ชัน) ต้องตรวจราย test

### 4.5 NSGA-II — เลือก suite จาก pool รวม

| Bug | Pool | Suite ที่เลือก | จับ bug | Coverage | R2 (Pop100/Gen100/seed7) |
|---|---|---|---|---|---|
| 1 | 119 | 2 tests | ✅ | 18.7% | เหมือนเดิม |
| 3 | 134 | 2 tests | ✅ | 17.2% | เหมือนเดิม |
| 5 | 77 | 2 tests | ✅ | 29.3% | เหมือนเดิม |

จาก pool รวม เลือกเพียง **2 tests/bug (ลด ~98%)** โดยคงการตรวจจับไว้ครบ และ**เสถียรข้าม GA config/seed** — ข้อค้นพบ: คุณภาพ pool ตั้งต้นคือปัจจัยชี้ขาด (optimizer ไม่สามารถสร้าง test ที่ดีขึ้นจาก pool ที่ไม่มี)

### 4.6 ตารางเปรียบเทียบรวม

| เครื่องมือ | ขอบเขต | tests รวม | จับ bug | ข้อจำกัดหลัก |
|---|---|---|---|---|
| Symflower | 854 bugs (ครบ) | 10,677 | **0** | 3 ชั้นตาม 4.2 + oracle โดยโครงสร้าง |
| ChatGPT | 3 bugs (ตัวอย่าง) | 137 | 5 | assertion ผิดบางส่วน, session variability |
| Copilot | 3 bugs (ตัวอย่าง) | 177 | 16 | assertion ผิดบางส่วน |
| NSGA-II | pool รวม | เลือก 6 | **3/3 (ครบ)** | พึ่งพาคุณภาพ pool |

**คำเตือนการเทียบ:** Symflower วัดครบ 854 ส่วน AI วัดเฉพาะตัวอย่าง 3 bugs — ตัวเลข "จับได้" จึงเทียบตรง ๆ ไม่ได้ทั้งชุด แต่เทียบได้ที่ 3 bugs เดียวกัน: Symflower 0/3, ChatGPT 2/3, Copilot 2/3

## 5. กระบวนการตรวจสอบความถูกต้อง (จับ false positive ของตัวเองได้)

ผลรอบแรกรายงานว่า Symflower จับได้ 4 bugs (Lang 19, 20, 22, 36) — การตรวจสอบด้วย Round2 ทำให้พบว่า**ทั้ง 4 เป็น false positive**:

1. **วิธีตรวจ:** เทียบชื่อ test ที่ fail บน buggy กับรายชื่อ dev trigger tests ใน metadata → ตรงกันทุกตัว (`testJoin_*`, `testCreateNumber` ฯลฯ) และ Symflower สร้าง test ให้คลาสเหล่านั้น = 0 ไฟล์
2. **ต้นตอ:** trigger tests ของ bug เหล่านี้คั่นด้วย `;` — parser รุ่นแรกรองรับแค่ `,` → ไม่ถูกตัดออก
3. **การแก้:** parser รองรับทั้งสองตัวคั่น + รีรัน + แก้ CSV + บันทึก note `trigger_parse_false_positive_corrected`

บทเรียน: **การเชื่อตัวเลข detection โดยไม่ตรวจ oracle คือความเสี่ยงจริง** — กระบวนการนี้เองคือหลักฐานความเข้มงวดของการทดลอง

## 6. ปัญหาที่พบและการแก้ไข (หลักฐานใน repo ทุกข้อ)

| # | ปัญหา | การแก้ |
|---|---|---|
| 1 | Defects4J v3 บังคับ Java 11 เป๊ะ | export JAVA_HOME ก่อนทุกคำสั่ง + PATH java11 มาก่อน |
| 2 | คำสั่ง d4j อยู่ `framework/bin/` (ต่างจากเอกสารเดิม) | ตั้ง PATH ชี้ถูก |
| 3 | Perl modules ขาด (String::Interpolate ฯลฯ), unzip | apt install |
| 4 | ชื่อ field ของ `d4j query` ไม่ตรงเอกสาร | อ่านจาก Query.pm: `classes.modified`, `tests.trigger` |
| 5 | pom เก่า (source 1.6) ทำ Maven model ที่ Symflower ใช้พัง (132 errors) | ซ่อน pom/build.gradle ระหว่าง generation (plain mode) |
| 6 | plain mode → JUnit5 + lambda ที่ compile ไม่ผ่าน | `--java-test-framework=JUnit4` |
| 7 | Cobertura อ่าน bytecode ได้ถึง Java 6 | คง compile level เดิม, ล้าง target/ เมื่อเปลี่ยน |
| 8 | Symflower memory limit default 1024MB ไม่พอ | `--memory-limit=4096/2560` |
| 9 | full-suite haltonfailure บล็อกการวัด | วัดราย method (`-t Class::method`) |
| 10 | trigger separator ต่างกัน (`,` vs `;`) → false positive 4 ตัว | parser รองรับทั้งคู่ + แก้ข้อมูล + รีรัน |
| 11 | ชื่อคลาส test ของ AI ชน dev test | rename เชิงกลไก (suffix `Ai`) + note |
| 12 | รันขนานชนกัน (workspace/git lock/meta CSV) | flock checkout, CSV ต่อ bug, worker self-contained (git clean + วางไฟล์ใหม่) |
| 13 | WSL RAM default 7GB ไม่พอรันขนาน | `.wslconfig` memory=12GB + ลด mem/worker |
| 14 | workspace เปลือง disk หลายร้อย GB | ลบ workspace ทันทีหลังเก็บ log ต่อ bug |
| 15 | Lang ช่วง 40–47 หลุดจากการวางแผนช่วง | ตรวจ integrity จับช่องว่างได้ → รันเติม + กู้ 49–65 จาก repo copy |

## 7. Threats to Validity

1. **AI วัดเฉพาะตัวอย่าง 3 bugs** — ไม่สามารถอ้างอัตรา detection ต่อ 854 bugs ได้ (เหตุผล: protocol บังคับตัวต่อตัว + เครื่องมือ AI ฟรีไม่มี API สำหรับ automation ตามเงื่อนไขข้อ 1.4)
2. **Coverage ราย suite เป็นค่าของชุดรวม** (dev + generated) ไม่ใช่ของ generated เพียงลำพัง — ระบุชัดใน CSV notes
3. **Session variability ของ LLM** — AI ทดลอง 1 session ต่อ bug ตาม protocol (แชทใหม่ทุกครั้ง) จึงไม่ได้เฉลี่ยหลาย session
4. **NSGA-II fitness ใช้ coverage ราย test เป็น proxy** (max ต่อ suite) ไม่ใช่ union ของบรรทัดจริง
5. **Config ของ Symflower เป็นชุดเดียวที่ทำงานได้จริง** (plain mode + JUnit4) — อาจมี config อื่นที่ให้ผลต่างออกไปนอกเหนือจากที่ทดลอง

## 8. บทเรียนที่ได้

1. **Test Oracle คือปัจจัยชี้ขาด** — เครื่องมือที่สร้าง test จากโค้ดปัจจุบัน (buggy) ย่อม assert พฤติกรรม buggy → จับ bug ไม่ได้โดยโครงสร้าง ส่วน AI ที่ได้ bug report เป็น oracle จับได้จริง ความต่างนี้คือคำตอบของโจทย์วิจัยหลัก
2. **Symbolic execution ไวต่อโครงสร้างโค้ดมาก** — สามกลุ่มข้อจำกัดจริง (build system, final-field, API mismatch) ปิดโอกาส 81.7% ของ bugs ตั้งแต่ขั้นสร้าง
3. **Multi-objective มีคุณค่าเมื่อ pool มาจากหลายแหล่ง** — NSGA-II ลด suite ~98% โดยคง detection และเสถียรข้าม config
4. **ความถูกต้องของการวัดสำคัญกว่าปริมาณ** — haltonfailure + trigger parsing ทำให้ตัวเลขผิดทั้งชุดได้โดยไม่รู้ตัว; กระบวนการตรวจสอบ (หัวข้อ 5) จึงจำเป็นเสมอ
5. **Negative result ที่มีหลักฐานครบมีคุณค่า** — 0/854 พร้อมสาเหตุ 3 ชั้นที่ตรวจย้อนได้ มีประโยชน์กว่าตัวเลขสวยที่ตรวจไม่ได้

## 9. การทำซ้ำ (Reproduction)

```bash
# 0) เครื่องมือ: Defects4J v3 + JDK11 + Symflower — รายละเอียดใน Algorithm2_SymbolicExecution/Configuration/
# 1) รัน Symflower ครบ 17 projects (แต่ละ project)
bash Code/project_runner.sh <Project> <start> <end> Round1 3
# 2) Round2 (budget sample)
SYMFLAGS="--test-generation-timeout=60" bash Code/project_worker.sh Lang 19 Round2
# 3) per-test fitness cache (ตัวอย่าง bug ที่มี test)
python3 Code/extract_pool.py <workspace> pool.txt && ROUND=Round1 bash Code/eval_tests.sh <bug>
# 4) AI: prompt ใน AI1_ChatGPT|AI2_GitHubCopilot/Prompt/filled/ → วัดด้วย
bash Code/ai_test_eval.sh <bug> <Tool> <TestFile.java> && bash Code/ai_cov_eval.sh <bug> <Tool>
# 5) รวม pool + NSGA-II + ตาราง
python3 Code/merge_pool.py <bug> && python3 Code/nsga2_select.py <cache> <out> 50 50 42 && python3 Code/compare_table.py
```

## 10. ภาคผนวก: โครงสร้าง Repository

```
Algorithm1_NSGAII/{Code,Configuration,Result_Round1,Result_Round2,Test}
Algorithm2_SymbolicExecution/{Code,Configuration,Result_Round1 (all_projects/ + logs_selected/),Result_Round2,Test}
AI1_ChatGPT/{Prompt/filled,Result,TestCode}   AI2_GitHubCopilot/{...}
Experiment/{summary.csv,cases.csv,protocol.md}
Report/{REPORT_Round2.md,FINAL_TABLE.md,results_symflower_all_projects.md}
```

## 11. เอกสารอ้างอิง

1. Deb, K., Pratap, A., Agarwal, S., Meyarivan, T. (2002). NSGA-II. IEEE Trans. Evolutionary Computation, 6(2), 182–197.
2. King, J. C. (1976). Symbolic Execution and Program Testing. Communications of the ACM, 19(7), 385–394.
3. Just, R., Jalali, D., Ernst, M. D. (2014). Defects4J. ISSTA 2014.
4. Defects4J Documentation. https://defects4j.org/html_doc/index.html
5. Symflower Documentation. https://docs.symflower.com/docs/installation/symflower-cli/
6. OpenAI / GitHub Copilot Documentation

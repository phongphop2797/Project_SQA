# รายงานสรุปผล — Symflower x Defects4J (ส่วนของ นายปองภพ ศรีรักษ์ 673380279-7)

ขอบเขตของ branch นี้: เฉพาะงาน Symbolic Execution (Symflower) ครบ 17 projects / 854 active bugs — ส่วน NSGA-II และ AI เป็นของสมาชิกท่านอื่น (branch jiratchaya_673380510-1 และ thanaphumi_673380271-3)

## 1) ตารางผลครบ 17 projects (ตรวจ integrity ตาม active bug ids แล้ว)

จาก Algorithm2_SymbolicExecution/Result_Round1/FINAL_TABLE.md:

| Project | Bugs | มี test | @Test | จับ bug |
|---|---|---|---|---|
| Chart | 26 | 0 | 0 | 0 |
| Cli | 39 | 5 | 125 | 0 |
| Closure | 174 | 0 | 0 | 0 |
| Codec | 18 | 5 | 64 | 0 |
| Collections | 28 | 4 | 9 | 0 |
| Compress | 47 | 33 | 2858 | 0 |
| Csv | 16 | 6 | 18 | 0 |
| Gson | 18 | 0 | 0 | 0 |
| JacksonCore | 26 | 14 | 3896 | 0 |
| JacksonDatabind | 110 | 8 | 42 | 0 |
| JacksonXml | 6 | 0 | 0 | 0 |
| Jsoup | 93 | 33 | 1788 | 0 |
| JxPath | 22 | 0 | 0 | 0 |
| Lang | 61 | 22 | 1510 | 0 |
| Math | 106 | 19 | 150 | 0 |
| Mockito | 38 | 0 | 0 | 0 |
| Time | 26 | 7 | 217 | 0 |
| **รวม** | **854** | **101** | **10,677** | **0** |

## 2) Round 2 — Budget configuration (60 วินาที/method)

ตัวอย่าง 8 bugs ของ Lang (คลุมทุก outcome จาก Round 1) — ผลเหมือน Round 1 ทุกกรณี: Lang ไม่มี method ที่ใช้เวลาเกิน 60 วินาที ไฟล์ผล: Algorithm2_SymbolicExecution/Result_Round2/

## 3) ข้อจำกัดเชิงโครงสร้างที่พิสูจน์แล้ว (กลุ่ม build system)

- gradle (Gson), multi-module maven (JacksonXml และส่วนใหญ่ของ JacksonDatabind), ant layout เก่า (JxPath/Chart/Closure), Mockito (runtime mocking) — สร้าง test ได้ 0 ทั้งกลุ่ม
- internal error: cannot set a final field (NumberUtils และคลาสจำนวนมาก)
- compile fail จาก test ที่เรียก API ไม่ตรง project (เช่น Lang 8-11)

## 4) กรณีศึกษา Reverse-Direction (สร้าง test จาก fixed -> รันบน buggy)

4 กรณี: Lang-1/3 (ติดชั้น generation — NumberUtils สร้างไม่ได้), Lang-30 (209 tests บน StringUtils จริง แต่ exploration ไม่ถึงเงื่อนไข trigger testReplaceEach_Type), Lang-11 (19 tests เช่นเดียวกัน) — ยืนยันว่าข้อจำกัดมี 2 มิติ: oracle และ search space

## 5) หลักฐานและการทำซ้ำ

- Code/: project_runner.sh, project_worker.sh, run_demo.sh, symbolic_lang1_hex.py (ของกลุ่ม), DEMO_Symflower.md, README_Code.md
- Configuration/: symflower_config.md (Java 11, plain mode, JUnit4, memory limit)
- Result_Round1/: all_projects/ (CSV ครบ), logs_selected/ (log ครบ 854 bugs), FINAL_TABLE.md
- Result_Round2/: budget sample
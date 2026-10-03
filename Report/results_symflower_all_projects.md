# Symflower × Defects4J — ผลการทดลองครบ 13 projects (366 active bugs)

อัปเดต: 28 กันยายน 2026 | วิธีวัด: ตาม REPORT_Round2.md หัวข้อ 3 (fail บน buggy + pass บน fixed + ตัด dev trigger, วัดราย method ที่จำเป็น)

## ตารางผลรวม

| Project | Build | Bugs ตรวจ | Bugs มี test | @Test รวม | จับ bug (id) |
|---|---|---|---|---|---|
| Lang | ant | 56 (1–65, ตัด deprecated 2,18,25,48) | 22 | 1,510 | **4** (19, 20, 22, 36) |
| Compress | ant | 47 | 33 | 2,858 | 0 |
| JacksonCore | maven | 26 | 14 | 3,896 | 0 |
| Cli | ant | 39 | 5 | 125 | 0 |
| Time | ant | 26 (ตัด 21) | 7 | 217 | 0 |
| Collections | ant | 28 | 4 | 9 | 0 |
| Codec | ant | 18 | 5 | 64 | 0 |
| Csv | maven | 16 | 6 | 18 | 0 |
| Mockito | ant | 38 | 0 | 0 | 0 |
| Gson | gradle | 18 | 0 | 0 | 0 |
| JxPath | ant (layout เก่า) | 22 | 0 | 0 | 0 |
| Chart | ant (เก่า) | 26 | 0 | 0 | 0 |
| JacksonXml | maven multi-module | 6 | 0 | 0 | 0 |
| **รวม** | | **366** | **101** | **8,697** | **4** |

Wave 5 กำลังรัน: Jsoup (93), Math (106), JacksonDatabind (110), Closure (174) = อีก 483 bugs

## ข้อสังเกตเชิงระบบ (จากข้อมูลจริง 366 bugs)

1. **กลุ่มที่ Symflower ทำงานได้ดี:** ant/maven มาตรฐาน single-module ที่ dependency เป็น JDK ล้วน (Lang, Compress, JacksonCore, Cli)
2. **กลุ่มข้อจำกัดจริงของเครื่องมือ (0 test ทั้ง project):**
   - gradle (Gson) — plain mode อ่าน dependency จาก gradle cache ไม่ได้
   - multi-module maven (JacksonXml) — ตามโมดูลพี่น้องไม่ได้
   - ant layout เก่า (JxPath: src/java, Chart: โครงสร้าง 2000s) + Mockito (runtime mocking ต้องมี mock engine ใน test)
3. **รูปแบบการจับ bug ของ Symflower:** จับได้เฉพาะเมื่อ (a) คลาสที่มี bug ถูก generate สำเร็จ และ (b) bug เป็นชนิดที่ symbolic execution เห็นความต่างของ path ได้ — ทั้ง 4 bugs ของ Lang เป็น hex/precision parsing ที่ตรงจุดแข็ง boundary analysis
4. **เวลา generation:** 1 วินาที (JacksonCore-16) ถึง ~24 นาที (JacksonCore-25, path explosion) — มีค่าเฉลี่ยราย project ใน CSV

## หลักฐานประกอบ (ใน repo)

- `Algorithm2_SymbolicExecution/Result_Round1/<project>_results.csv` — ตารางต่อ project
- `Symflower/Result_Round1/<proj>_bug<N>_*.log` — raw logs (checkout/symflower/test_buggy/test_fixed/coverage)
- `Symflower/Configuration/symflower_config.md` — configuration + ข้อจำกัดที่พบ + บทเรียน parser (`;` separator, multi-class bugs)

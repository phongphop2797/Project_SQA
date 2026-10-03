# Bounded symbolic path generation: Defects4J Lang-1

## วิธีทดลอง

ใช้ `SymbolicExecution/Code/symbolic_lang1_hex.py` อ่านเงื่อนไขแยก
เส้นทางเลขฐานสิบหกใน `NumberUtils.createNumber` ของ Lang-1b
แล้วแก้ข้อจำกัดแบบช่วงจำนวนเต็มเพื่อสร้างค่าที่ขอบเขตของแต่ละเส้นทาง
ไฟล์ `paths.json` เก็บ input, ช่วงค่าที่แก้ได้, expected value และ
SHA-256 ของซอร์สที่ใช้

วิธีนี้วิเคราะห์เฉพาะ hex branch ของเมธอดเดียว ไม่ใช่ symbolic
execution engine ที่วิเคราะห์ Java ทั้งคลาสหรือทั้งโปรเจกต์
สร้าง JUnit 4 จำนวน 24 tests แล้วรันชุดเดียวกันด้วย Defects4J
บน Lang-1f และ Lang-1b โดยไม่แก้ production source

## ผลลัพธ์

| เวอร์ชัน | Line coverage | Condition coverage | ผลการทดสอบ |
|---|---:|---:|---|
| Lang-1f (fixed) | 54/380 (14.2%) | 30/350 (8.6%) | ผ่านทั้ง 24 เคส |
| Lang-1b (buggy) | 49/375 (13.1%) | 18/338 (5.3%) | ล้มเหลว 6 เคส |

เคสที่ล้มเหลวบน buggy อยู่บริเวณขอบเขต Integer/Long:
`0x80000000`, `0xFFFFFFFF`, `-0x80000001`,
`-0xFFFFFFFF`, `0xFFFFFFFFFFFFFFFF` และ
`-0xFFFFFFFFFFFFFFFF` จึงตรวจพบ LANG-747

จำนวน 6 คือจำนวน test ที่ล้มเหลวจากบั๊กเดียว ไม่ใช่
fault detection rate ของ Defects4J ทั้ง dataset

## ไฟล์หลัก

- `NumberUtilsSymbolicHexTest.java`: ชุด JUnit ที่สร้าง
- `paths.json`: ข้อจำกัด เส้นทาง และ input ที่ได้
- `Lang-1-symbolic-hex.1.tar.bz2`: archive สำหรับ Defects4J
- `1f_test.log`, `1b_test.log`: ผลการทดสอบ
- `*_coverage_summary.csv`, `*_coverage.log`: ผล coverage
- `*_failing_tests.txt`: รายละเอียด test ที่ล้มเหลว

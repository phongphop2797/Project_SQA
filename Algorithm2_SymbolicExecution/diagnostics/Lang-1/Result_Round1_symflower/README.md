# Symflower Symbolic Execution: Lang-1, Round 1

ใช้ Symflower v51292 สร้าง JUnit 4 tests จาก IEEE754rUtils.java
ใน Defects4J Lang-1f โดยใช้ test style แบบ basic ได้ 12 tests
เก็บไฟล์ที่สร้างโดยเครื่องมือไว้ใน raw/ โดยไม่แก้ไข assertion

นำ test suite ไปรันผ่าน Defects4J:
- Lang-1f: ผ่าน 12 tests
- Lang-1b: ผ่าน 12 tests จึงไม่ตรวจพบ LANG-747

เมื่อวัดเฉพาะ IEEE754rUtils ได้ line coverage 28/57 (49.1%)
และ condition coverage 20/40 (50.0%) เท่ากันทั้งสองเวอร์ชัน

เมื่อวัด NumberUtils ซึ่งเป็นคลาสที่แก้บั๊ก LANG-747 ได้ 0 coverage
ทั้งสองเวอร์ชัน ผล coverage ของ IEEE754rUtils จึงไม่ใช่
coverage ของคลาสที่มีบั๊ก และไม่ควรเทียบเป็นตัวเลขช่องเดียวกัน
กับชุดทดสอบ NumberUtils ของเครื่องมืออื่น

Symflower รายงาน analysis errors บางส่วน แม้สร้าง 12 tests ได้
ดู generation.log และ ieee754r_attempt/generation.log ประกอบ

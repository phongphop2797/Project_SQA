# Symflower: ทดลองสร้าง test สำหรับ NumberUtils.createNumber

สถานะ: สร้าง test ไม่สำเร็จ (0 tests) จึงไม่มี coverage จากรอบนี้

นำ NumberUtils.java จาก Defects4J Lang-1f มาวิเคราะห์ใน Maven workspace
ขนาดเล็ก โดยตรวจ SHA-256 แล้วว่าไฟล์เหมือนต้นฉบับทุก byte และ
Maven compile ผ่าน จุดประสงค์คือแยกปัญหาจากการวิเคราะห์ Commons Lang
ทั้งโปรเจกต์

Symflower พบเมธอด createNumber แต่สร้าง 0 tests รายละเอียดใน
generation.log ระบุ unknown function, unknown import และ unsupported
type จึงไม่นำรอบนี้ไปคำนวณ coverage หรือ fault detection

ผลที่สร้าง test ได้จริงอยู่ใน Result_Round1/Lang-1/run-01 ซึ่ง
ทดสอบ IEEE754rUtils ไม่ใช่คลาสที่มีบั๊ก LANG-747

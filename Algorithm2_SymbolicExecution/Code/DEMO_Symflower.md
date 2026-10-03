# DEMO — Symflower x Defects4J (แผนการสาธิต ~5 นาที)

## วิธีรันสด (Terminal ใน WSL)

```bash
bash ~/sqa-project/Symflower/Code/run_demo.sh
```

ระบบจะพาเดินครบ 6 ขั้นพร้อม banner กำกับ — ผู้พูดใช้ "จุดพูด" ด้านล่างประกอบแต่ละขั้น

## สคริปต์การพูดต่อขั้น

| ขั้น | สิ่งที่เกิดขึ้นบนจอ | จุดพูด |
|---|---|---|
| 1 | `defects4j checkout Lang-1b` | "นี่คือโค้ดจริงของ Apache Commons Lang ที่มี bug จริงจาก Defects4J — framework มาตรฐานงานวิจัย test generation" |
| 2 | `mv pom.xml pom.xml.bak` | "เราซ่อน pom เพราะ pom ปี 2009 กำหนด Java 6 ทำให้ Maven model ที่เครื่องมือใช้พัง — หนึ่งใน 15 ปัญหาที่เราแก้" |
| 3 | Symflower log + ไฟล์ test | "symbolic execution วิเคราะห์ path แล้วคำนวณ input — ได้ 20 tests ใน ~1 นาที สังเกต input แบบ boundary: null, -1, MIN_VALUE" |
| 4 | `Failing tests: 1` | "test ที่ fail ตัวเดียวคือ test ของ developer เอง (TestLang747) — test ที่ Symflower สร้างผ่านหมด เพราะ assertion มาจากพฤติกรรม buggy เอง" |
| 5 | รันบน fixed — ผลเหมือนเดิม | "ยืนยันว่าไม่ใช่เรื่องบังเอิญ: test ของเครื่องมือผ่านทั้งสองเวอร์ชัน = จับ bug ไม่ได้" |
| 6 | จุดพูดสรุป | "นี่คือ funnel ชั้นที่ 3 — และเหตุผลที่ AI จับได้: bug report ที่เราใส่ใน prompt คือ oracle ที่บอก 'ค่าที่ถูก'" |

## ผลที่ควรเห็น (Backup — ถ้า demo สดมีปัญหา ใช้ข้อมูลจริงจากรอบทดลอง)

### ขั้น 3 — log จริงจาก Result_Round1
```
src/main/java/org/apache/commons/lang3/math/IEEE754rUtils.java: generated unit test file
Analyzed 3 out of 3 source files
Generated 68 tests
```

### ขั้น 4 — รันบน buggy
```
Running ant (compile.tests).......... OK
Running ant (run.dev.tests).......... OK
Failing tests: 1
  - org.apache.commons.lang3.math.NumberUtilsTest::TestLang747
```

### ขั้น 5 — รันบน fixed
```
Failing tests: 0   (test ของ Symflower ผ่านทั้งสองเวอร์ชัน → detection = 0)
```

### ตารางรวม (FINAL_TABLE.md) — ตัวเลขปิดท้าย
```
854 active bugs / 17 projects — 10,677 tests สร้างได้ — จับ bug 0
(เทียบ AI: ChatGPT 5, Copilot 16 จากกลุ่มตัวอย่าง 3 bugs ที่มี bug report เป็น oracle)
```

## Q&A ที่ควรเตรียมคำตอบ

1. **"ทำไมไม่ generate จาก fixed version?"** — เพราะในสถานการณ์จริงเราไม่มี fixed version (มันคือสิ่งที่ยังไม่ถูกแก้); และ protocol ตาม Defects4J ใช้ buggy เป็น input
2. **"ทำไมไม่ใช้ dev tests เป็น oracle ให้ Symflower?"** — dev tests คือสิ่งที่เราใช้วัด (trigger tests) ถ้าเอามาใช้ generate จะเป็น data leakage
3. **"0 detected แปลว่าเครื่องมือไม่มีประโยชน์?"** — ไม่ใช่: ได้ test 10,677 ตัวที่เพิ่ม coverage (เช่น Lang-1 coverage 98.1% ของคลาสบั๊ก) แต่มันวัด "ความครอบคลุม" ไม่ใช่ "การหา defect" — ต่างมิติกับ AI
4. **"รันทั้ง 854 ใช้เวลาเท่าไหร่?"** — ~2-3 วันเครื่องแบบขนาน 3 workers (จากจังหวะจริง 1 วินาที–24 นาทีต่อ bug)

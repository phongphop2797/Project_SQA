# Symflower Configuration

## สภาพแวดล้อม
- Defects4J v3 (framework/bin/defects4j), JDK 11 (JAVA_HOME=java-11-openjdk-amd64) — Defects4J บังคับ Java 11
- symflower build ล่าสุดจาก download.symflower.com (linux-x86_64)
- scope: package ที่ประกอบด้วย modified classes ของแต่ละ bug (จาก defects4j query: classes.modified)

## ค่าที่ใช้ (Round1)
- symflower unit-tests --memory-limit=4096 --java-test-framework=JUnit4 <target-package>
- ซ่อน pom.xml ระหว่าง generation (โหมด plain Java) เพราะ pom เดิมกำหนด source/target 1.6 ทำให้ maven model ที่ symflower ใช้ resolve dependency ไม่ได้ (132 errors)
- --java-test-framework=JUnit4 เพราะ build ของ Lang (ant + junit4, compile.source=1.6) — ค่า automatic จะได้ JUnit5 ซึ่ง compile ไม่ผ่าน (ไม่มี org.junit.jupiter บน classpath และใช้ lambda ที่ -source 1.6 ไม่รองรับ)

## การวัดผล
- Fault detection: test ต้อง fail บน buggy version + pass บน fixed version + ตัด trigger tests ของ developer (เอาชื่อจาก d4j query: tests.trigger)
- Coverage: defects4j coverage (Cobertura) — รายงาน Line coverage (= statement) และ Condition coverage (= branch) — ห้ามยก compile เป็น 1.8 เพราะ Cobertura ของ d4j อ่าน bytecode ได้ถึง v50 (Java 6)
- เวลา generation: จับด้วย date +%s รอบคำสั่ง symflower

## ข้อจำกัดที่พบ (บันทึกใส่รายงานได้)
- symflower "cannot set a final field" internal error กับบางคลาส (เช่น Fraction) → ไม่สร้างไฟล์ test ให้คลาสนั้น
- Lang bug 2 เป็น deprecated bug (ไม่มีใน active list) → สคริปต์จะบันทึก checkout fail

## ข้อควรระวังการวัด (update)
- full-suite run ของ d4j มี haltonfailure → หยุดที่ dev trigger test (ที่ fail อยู่แล้ว) ก่อนถึง test ที่สร้าง
  → การวัด fault detection ที่ถูกต้องต้องรันราย method ด้วย -t Class::method (ดู NSGA-II/Code/eval_tests.sh และ ai_test_eval.sh)
- ตัวเลข fail_buggy/detected ใน lang_results.csv อ้างอิงจาก per-method runs (cache ใน NSGA-II/Result_Round1/cache_bugN.csv)
- ค่า coverage ใน CSV มาจาก full-suite coverage run (รวม dev tests) จึงเป็นค่าของชุดรวม ไม่ใช่ของ generated tests เพียงลำพัง

## ผล Round2 (class scope)
- สร้าง test ได้ 0 ทุก bug: การชี้ไฟล์เดียวทำให้ Symflower resolve import/ฟังก์ชันจากไฟล์อื่นและ build context ไม่ได้ (unknown import/function/field)
- ข้อสรุป: package scope (Round1) คือขอบเขตเล็กที่สุดที่ Symflower วิเคราะห์ได้ — scope เล็กกว่านั้นเร็วขึ้นมาก (8-48s) แต่ให้ผลว่างเปล่า

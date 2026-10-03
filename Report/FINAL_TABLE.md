# ตารางสรุปสมบูรณ์ (แก้ไขแล้ว) — Symflower x Defects4J ครบ 17 projects (854 active bugs)

ผลการตรวจสอบความถูกต้องรอบสุดท้าย: det ของ Lang 19,20,22,36 จากรอบแรกเป็น false positive (dev trigger tests ที่ parser ตัดไม่หมดเพราะคั่นด้วย ;) — แก้ไขแล้ว

**ผลจริง: Symflower จับ bug ได้ 0 จาก 854 bugs**

| Project | Bugs ตรวจ | Bugs มี test | @Test รวม | จับ bug |
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
| **รวม** | **854** | | **10,677** | **0** |

Round2 (budget 60s, ตัวอย่าง 8 bugs ของ Lang): ผลเหมือน R1 ทุกตัว — Lang ไม่มี method ที่ช้าเกิน 60 วิ

แผนผังข้อจำกัดที่พิสูจน์แล้ว: gradle (Gson), multi-module maven (JacksonXml ฯลฯ), ant layout เก่า (JxPath/Chart/Closure), Mockito runtime, final-field internal error (Fraction ฯลฯ), compile_fail จาก API ที่สร้างไม่ตรง project
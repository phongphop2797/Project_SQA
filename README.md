# Project_SQA — Symflower x Defects4J (branch: Phongphop673380279-7)

ผลงานส่วน Symflower (Symbolic Execution) ของโปรเจกต์ CP353201 SQA: Benchmarking AI-Testing vs Symbolic Execution and NSGA-II

## สรุปผล
- ครบ **17 projects / 854 active bugs** ของ Defects4J (ตรวจ integrity ตามตาราง active แล้ว)
- สร้าง test ได้ **10,677 @Test** (101/854 bugs มี test)
- **จับ bug: 0** — วิเคราะห์ด้วย funnel 3 ชั้น (สร้างไม่ได้ 81.7% → compile fail → test oracle โดยโครงสร้าง)
- Round2: budget 60s (ผลเดิม) + NSGA-II config stability

## โครงสร้าง
- `Algorithm2_SymbolicExecution/Code/` — สคริปต์ runner ทุก project + `run_demo.sh` (demo สด ~5 นาที) + `DEMO_Symflower.md` (สคริปต์พูด)
- `Algorithm2_SymbolicExecution/Configuration/` — configuration + ข้อจำกัด
- `Algorithm2_SymbolicExecution/Result_Round1/` — CSV ผลตรวจแล้วทุก project (`all_projects/`) + logs
- `Algorithm2_SymbolicExecution/Result_Round2/` — budget sample
- FINAL_TABLE.md (ผลครบ 17 projects) — รายงานเต็มอยู่บน branch Phongphop673380279-7

## Demo
```bash
bash Algorithm2_SymbolicExecution/Code/run_demo.sh
```

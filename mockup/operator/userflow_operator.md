นี่คือร่างเนื้อหาสำหรับไฟล์ `design.md` ที่สรุปโครงสร้าง **User Flow ของ Service Operator** สำหรับแพลตฟอร์ม **CareDee** โดยเน้นความชัดเจนของเงื่อนไขทางธุรกิจ (Business Logic) และข้อกำหนดทางเทคนิคครับ

---

# 📋 Service Operator User Flow Design - CareDee Platform

เอกสารฉบับนี้อธิบายลำดับขั้นตอนการปฏิบัติงาน (Workflow) ของผู้ดูแลระบบในส่วนของ Service Operator ตั้งแต่การเข้าสู่ระบบจนถึงการตรวจสอบรายงานขั้นสุดท้าย

## 1. Login & Security Layer

**เป้าหมาย:** เพื่อรักษาความปลอดภัยของข้อมูลสุขภาพและข้อมูลส่วนบุคคลในระบบ

* **Entry Point:** Web Portal Login
* **Authentication:** บังคับใช้ Two-Factor Authentication (2FA)
* **Security Logic (Decision Point 1):**
* **Success:** เข้าสู่ Dashboard (ข้อมูล Refresh ทุก 60 วินาที)
* **Failure:** หากกรอกผิดติดต่อกัน 5 ครั้ง ระบบทำการ **Account Lockout** เป็นเวลา 15 นาที พร้อมส่ง Notification แจ้งเตือน



---

## 2. Caregiver Management (The Gatekeeper)

**เป้าหมาย:** คัดกรองและอนุมัติบุคลากรเข้าสู่ Marketplace

* **Verification Workflow:**
1. ตรวจสอบสถานะใบรับรองจาก Training Provider (ต้องเป็น "Certified" เท่านั้น)
2. ตรวจสอบความครบถ้วนของเอกสาร (KYC) และทักษะเฉพาะทาง


* **Decision Point 2 (Approval):**
* **Approve:** สถานะเปลี่ยนเป็น **Active** และ Profile ปรากฏบน Marketplace ทันที
* **Reject/Suspend:** ระบุเหตุผลในระบบ และส่ง Feedback ให้ผู้ดูแลแก้ไข



---

## 3. Operational Control & Scheduling

**เป้าหมาย:** จัดการความต่อเนื่องของบริการและแก้ไขปัญหาหน้างาน

* **Monitoring:** ตรวจสอบระบบป้องกันการจองซ้อน (Conflict Detection)
* **Decision Point 3 (Incident Management):**
* **Normal:** ระบบรันอัตโนมัติ
* **Issue Found:** Operator ทำการ "จัดสรรงานแทน" (Re-assignment)


* **Constraint:** ทุกการเปลี่ยนแปลงตารางงานโดย Operator **ต้องระบุเหตุผลและผู้อนุมัติ** เพื่อจัดเก็บใน Audit Trail

---

## 4. Quality Assurance & Dispute Resolution

**เป้าหมาย:** รักษามาตรฐานการบริการและให้ความเป็นธรรมแก่ผู้ดูแล

* **Real-time Tracking:** ติดตาม Care Report จากหน้างาน
* **Appeal Process (Decision Point 4):**
* การพิจารณาคำอุทธรณ์คะแนนรีวิว (Review Appeal)
* **SLA:** กรณีอุทธรณ์สำเร็จ ต้องดำเนินการแก้ไขคะแนนภายใน **3 วันทำการ**



---

## 5. Settlement & Audit Trail

**เป้าหมาย:** สรุปยอดทางการเงินและจัดเก็บประวัติเพื่อการตรวจสอบ

* **Revenue Analysis:** ตรวจสอบรายได้สุทธิหลังหัก Commission (Auto-calculate)
* **Reporting (Decision Point 5):**
* รองรับไฟล์ CSV และ XLSX
* **Performance Requirement:** ไฟล์ต้องถูก Generate ภายใน **10 วินาที** โดยมีความถูกต้องของข้อมูล 100%


* **System Exit:** Logout พร้อมบันทึก **Audit Trail** (เก็บรักษาข้อมูลไว้อย่างน้อย 3 ปี ตามกฎหมาย/ข้อกำหนด)

---

## 💡 Operator Logic Summary Table

| จุดตัดสินใจ (Decision Point) | เงื่อนไขสำคัญ (Key Condition) | ผลลัพธ์ (Result) |
| --- | --- | --- |
| **Login Validation** | ผิด < 5 ครั้ง | เข้าสู่ Dashboard / ระงับการเข้าถึง 15 นาที |
| **Caregiver Verification** | ใบเซอร์ฯ ต้องมาจากสถาบันที่รับรอง | Active / Pending |
| **Schedule Conflict** | มีปัญหาการจองซ้อน/เหตุฉุกเฉิน | จัดสรรงานแทน (ต้องระบุเหตุผล) |
| **Appeal Verdict** | ข้อมูลรีวิวไม่เป็นความจริง | ปรับคะแนนภายใน 3 วันทำการ |
| **Report Export** | ตรงตามเกณฑ์ที่เลือก | ได้ไฟล์ CSV/XLSX ภายใน 10 วินาที |

---

*Last Updated: 2026-05-11*
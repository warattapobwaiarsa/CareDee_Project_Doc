# CareDee Project Changelog

เอกสารฉบับนี้ใช้สำหรับบันทึกประวัติการแก้ไข สร้าง หรืออัปเดตไฟล์ในโปรเจกต์ CareDee เพื่อรักษา Context และความต่อเนื่องในการทำงานข้าม Session (AI Agent Memory)

---

## [2026-05-15] - Mockup Version 2 (Thai SPA Implementation)

### Added (สร้างใหม่)
- `mockup/css/design.css`: สร้างไฟล์ CSS กลาง อ้างอิงจาก `design.md` (CareDee Design Foundation) เพื่อจัดการเรื่อง Colors, Typography (IBM Plex Sans Thai / Inter), Spacing และ Layout Classes
- `mockup/adminv2.html`: หน้า Mockup สำหรับ Admin Portal (Version 2)
- `mockup/operatorv2.html`: หน้า Mockup สำหรับ Operator Portal (Version 2)
- `mockup/trainingv2.html`: หน้า Mockup สำหรับ Training Institute Portal (Version 2)
- `CHANGELOG.md`: ไฟล์บันทึกประวัติการเปลี่ยนแปลง
- `GEMINI.md`: ไฟล์คำสั่งโครงการ (Enforcing Changelog Policy)

### Changed (แก้ไข/อัปเดต)
- **Localization (ภาษา):** อัปเดตเนื้อหาใน `adminv2.html`, `operatorv2.html`, และ `trainingv2.html` ให้ใช้ภาษาไทย 100%
- **SPA Navigation (Interactive Sidebar):** 
  - เพิ่ม JavaScript function `switchView()` เพื่อสลับเนื้อหาโดยไม่โหลดหน้าใหม่
  - อัปเดต `design.css` เพิ่มคลาส `.content-view` และ `.active-view`
- **Mock Data Expansion (ข้อมูลจำลอง):** เพิ่มข้อมูลตัวเลข กราฟ และสถานะระบบให้ครอบคลุมทุก Module ของทั้ง 3 Portal
- **Micro-Interactions (ลูกเล่นการคลิก):**
  - **Admin:** ระบบยืนยัน PIN โอนเงิน, ตรวจสอบ KYC (Alert), จัดการ PDPA (Prompt), ดู Logs
  - **Operator:** ขั้นตอนการเพิ่มผู้ดูแลใหม่, ระบบ Smart Re-assign
  - **Training:** **ระบบ Dual-Mode Import** (สลับระหว่างอัปโหลดไฟล์ และกรอกมือแบบ Real-time)

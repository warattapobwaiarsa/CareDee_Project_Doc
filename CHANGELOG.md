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
- **Micro-Interactions (ลูกเล่นการคลิกเชิงลึก):**
  - **Admin:** อัปเกรดจาก alert/prompt เป็น **Custom HTML Modals** ทั้งหมด (ระบบตรวจสอบ KYC, กรอก PIN โอนเงิน, จัดการคำร้อง PDPA และดู Logs) พร้อมระบบ Validation ตรวจสอบการกรอกข้อมูลที่จำเป็น
  - **Operator:** อัปเกรดเป็น **Custom Modals** (ฟอร์มเพิ่มผู้ดูแลพร้อมช่องกรอกข้อมูลบังคับ, ระบบ Smart Re-assign พร้อม Loader จำลองการประมวลผล, และห้องสนทนา Dispute แบบสมจริง)
  - **Training:** อัปเกรดเป็น **Custom Modals** (แจ้งเตือนอัปโหลดสำเร็จ, ฟอร์มปฏิเสธการยืนยันพร้อมระบุเหตุผล, และฟอร์มออกใบรับรองรายบุคคล) พร้อมระบบ Dual-Mode Import และการแจ้งเตือน Toast สำหรับรายการที่ทำสำเร็จ

## [2026-05-15] - Final Data Perfection for Client Presentation

### Changed (แก้ไข/อัปเดต)
- **Data Perfection (ความสมบูรณ์ของข้อมูล):** ปรับปรุงข้อมูลในทุกหน้า (Views) ของทั้ง 3 Portal ให้สมบูรณ์และสมจริงที่สุดเพื่อใช้ในการนำเสนอลูกค้า
  - **Admin:** เพิ่มรายละเอียดในหน้าจัดการสิทธิ์, ข้อมูลการเงินแบบละเอียด (Gross/Net/Pending), รายการอุทธรณ์รีวิวพร้อมเหตุผล, และกราฟวิเคราะห์ Monthly Growth Rate
  - **Operator:** เพิ่มรายละเอียดสถานะทีม (Available/On-duty), ข้อมูลเคสรายงานสุขภาพหน้างาน (Care Feed), รายการข้อพิพาทพร้อมปุ่มส่งเรื่องให้ Admin และกราฟ Revenue Growth
  - **Training:** เพิ่มกราฟหลักสูตรยอดนิยม (Course Popularity), บทวิเคราะห์เชิงลึกในหน้า Market Demand, และรายการใบรับรองดิจิทัลที่สามารถกดดูตัวอย่างได้
- **UI Consistency:** ตรวจสอบและปรับปรุงความสอดคล้องของ Font, Badges และ Buttons ในทุกไฟล์ให้เป็นมาตรฐานเดียวกัน

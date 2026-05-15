# รายละเอียดฟีเจอร์และฟังก์ชันการใช้งานของ CareDee Portals (Interactive SPA Prototypes)

เอกสารฉบับนี้สรุปรายละเอียดการออกแบบและฟังก์ชันการใช้งานของระบบ CareDee ทั้ง 3 ส่วน (Admin, Operator, Training) ตามที่ปรากฏในไฟล์ Mockup SPA เวอร์ชันล่าสุด ซึ่งได้รับการพัฒนาให้เป็น **Interactive Prototype** ที่สามารถกดใช้งานได้จริงตาม Business Logic และ User Flow

---

## 1. CareDee Admin Portal (Platform Control Center)
**ไฟล์:** `mockup/admin/admin_portal_spa.html`  
**กลุ่มเป้าหมาย:** ผู้ดูแลระบบระดับสูงสุด (Platform Admin)

### ฟังก์ชัน Interactive ที่ใช้งานได้:
- **Functional Search & Filtering:** ค้นหาข้อมูลในตารางและกรองตามหน่วยงาน (Agency Filter) ได้แบบ Real-time
- **Action Simulations:** ปุ่ม "อนุมัติ", "ระงับสิทธิ์", และ "ลบ" ทำงานพร้อม Animation และการอัปเดตสถานะจำลอง
- **Interactive Dashboards:** ลิงก์จาก Dashboard ไปยังส่วนจัดการผู้ใช้ และระบบจำลอง Uptime Chart
- **Maintenance Simulation:** ระบบประกาศ Global Banner แจ้งปิดปรับปรุงระบบที่แสดงผลทุกหน้า

### รายละเอียดหน้าจอ (View Sections):
1.  **หน้าหลัก (Dashboard):**
    - **Metrics Cards:** แสดงจำนวนรายการจองวันนี้, รายได้รวมเดือนนี้ และจำนวนรายการรออนุมัติ (Pending) พร้อม Trend การเปลี่ยนแปลง
        - *ตัวอย่าง:* "รายการจองวันนี้: 42 รายการ (↑ 12% จากเมื่อวาน)", "รายได้รวม: ฿ 154,200"
    - **รายการรออนุมัติล่าสุด:** ตารางสรุปรายชื่อผู้สมัครใหม่ (Caregiver/Operator) ให้กดอนุมัติได้ทันที
        - *ตัวอย่าง:* รายชื่อ "สมชาย ใจดี" (Caregiver) สถานะ "รอตรวจ", "บริบาลไทย จำกัด" (Operator) สถานะ "รอเอกสาร"
2.  **จัดการผู้ดูแล/ผู้ให้บริการ (Users):**
    - ตารางรายชื่อที่แสดงสถานะการยืนยันใบรับรอง (Verified) และประวัติการยอมรับ PDPA (Consent Date)
        - *ตัวอย่าง:* การแยกประเภท "Independent Caregiver" vs "Agency Staff", การแสดงผล "✓ Verified" สีเขียวสำหรับผู้ที่มีวุฒิบัตรตรงตามเกณฑ์
    - **Bulk Actions:** แถบจัดการข้อมูลจำนวนมาก (Batch Approval) เมื่อเลือกหลายรายการ
    - **Evidence Modal:** ป๊อปอัพตรวจสอบเอกสารหลักฐานแบบละเอียด
3.  **จัดการการเงิน (Finance):**
    - สรุปยอด Gross, Commission (10%), ยอดรอโอน และยอดโอนสำเร็จ
    - **Payout Queue:** รายการรอโอนเงินคืนให้ผู้ให้บริการพร้อมปุ่มดู **Breakdown** (แจกแจง Gross - Fee)
        - *ตัวอย่าง:* เคส #BK-9915 ยอด Gross ฿ 1,800 หัก Commission ฿ 180 คงเหลือยอดโอนสุทธิ ฿ 1,620
4.  **คุณภาพรีวิว & อุทธรณ์ (Reviews):**
    - **Auto-Moderation:** ระบบเบลอคำหยาบ (Masking) ในรีวิวอัตโนมัติ (คลิกเพื่อดูต้นฉบับ)
    - **Evidence Viewer:** ดูหลักฐานประกอบการอุทธรณ์ เช่น แชท หรือรูปถ่าย เพื่อตัดสินเคส
5.  **รายงานระบบ (Reports):**
    - **Interactive Heatmap:** แสดงพื้นที่ที่มีความต้องการสูง (Demand vs Supply) แบบ Visual
        - *ตัวอย่าง:* สีแดงเข้มในโซน "บางนา-สมุทรปราการ" บ่งบอกว่ามีคนค้นหาบริการสูงแต่คนดูแลในพื้นที่ไม่เพียงพอ
    - **Custom Range Filter:** เลือกช่วงวันที่เพื่อกรองข้อมูลรายงานและส่งออก (Monthly/Audit)
6.  **นโยบาย & PDPA (Privacy & Consent):**
    - **Policy Broadcast:** หน้าต่างจัดการการประกาศเปลี่ยนนโยบายและส่ง Re-consent ให้ผู้ใช้
    - **Access Log:** บันทึกประวัติการเข้าถึงข้อมูลส่วนบุคคล (Audit Trail) ตามกฎหมาย
7.  **เฝ้าระวังระบบคลาวด์ (Cloud Monitoring):**
    - **Service Health:** ตรวจสอบสถานะ API, Payment Gateway และ Uptime History (24 ชม.)
    - **Incident Link:** จำลองการดูรายละเอียดข้อผิดพลาดทางเทคนิค (Technical Alert Detail)

---

## 2. CareDee Operator Portal (Service Operator Portal)
**ไฟล์:** `mockup/operator/operator_portal_spa.html`  
**กลุ่มเป้าหมาย:** หัวหน้าศูนย์บริการ / เอเจนซี่ (Operator)

### ฟังก์ชัน Interactive ที่ใช้งานได้:
- **Onboarding Tracker:** ระบบจำลองการ "Verify Side-by-Side" ร่วมกับสถาบันฝึกอบรม พร้อมอัปเดต Step Progress
- **Smart Scheduling Resolution:** ฟังก์ชัน "Smart Re-assign" เพื่อจำลองการแก้ปัญหาตารางงานซ้อน (Conflict) โดยอัตโนมัติ
- **Report Escalation:** ระบบจำลองการส่งแจ้งเตือนด่วน (Medical Escalation) จากหน้างาน
- **Live Sync Simulation:** ตัวบ่งชี้สถานะ Online/Offline และการอัปเดตเวลา Last Sync

### รายละเอียดหน้าจอ (Pages):
1.  **หน้าหลัก (Dashboard):**
    - **Team Summary:** สรุปงานในมือ, Utilization Rate และคะแนนรีวิวเฉลี่ยของทีม
    - **Quick Actions:** รายการงานด่วน เช่น ตารางซ้อน หรือเคสอุทธรณ์ที่ใกล้หมดเวลา SLA
2.  **จัดการทีมผู้ดูแล (Team Management):**
    - **Matching Engine Config:** ปรับแต่งค่าน้ำหนักการจับคู่งาน (Distance vs Skill) พร้อมบันทึกค่าจำลอง
    - **TI Inbound Check:** ปุ่มดึงข้อมูลชุดใหม่จากสถาบันฝึกอบรมพร้อม Loading Simulation
3.  **ตารางงาน & การจอง (Schedule Control):**
    - **Master Timeline:** กราฟแสดงคิวงานของผู้ดูแลทุกคนในศูนย์ (Timeline Grid)
    - **Scheduling Audit Log:** บันทึกประวัติการแก้ไขตารางงานที่อัปเดตตามการกระทำของผู้ใช้
4.  **ติดตามรายงานหน้างาน (Care Reports):**
    - **Live Feed:** รายงานสุขภาพและกิจกรรมที่ผู้ดูแลบันทึกเข้ามา (Activity List)
    - **Geofence Alerts:** การแจ้งเตือนกรณีเช็กอินนอกพิกัดสถานที่ทำงาน
5.  **ข้อร้องเรียน & อุทธรณ์ (Disputes & Resolution):**
    - **SLA Alerts:** แจ้งเตือนเวลาที่เหลือในการจัดการเคส (3 วัน) และการ Lock เคสที่หมดอายุ
    - **Resolution Flow:** กระบวนการยอมรับคำอุทธรณ์และส่งเรื่องต่อให้ Admin แพลตฟอร์ม
6.  **รายงาน & รายได้ (Analytics):**
    - **Settlement Logic:** ตารางสรุปยอดโอนคืน (Gross - 15% GP = Net)
    - **Export Tools:** ระบบจำลองการสร้างไฟล์รายงานสรุปผล PDF และ Excel

---

## 3. CareDee Training Portal (Academy Interface)
**ไฟล์:** `mockup/training/training_portal_spa.html`  
**กลุ่มเป้าหมาย:** เจ้าหน้าที่สถาบันฝึกอบรม (Training Institute)

### ฟังก์ชัน Interactive ที่ใช้งานได้:
- **Advanced Import Wizard:** กระบวนการนำเข้าข้อมูล 3 ขั้นตอน (Upload -> Processing -> Mapping) พร้อม Progress Bar
- **Dual Input Method:** สลับโหมดการนำเข้าระหว่างการอัปโหลดไฟล์ (XLSX/CSV) และการกรอกข้อมูลเอง (Manual Entry)
- **Certificate Lifecycle:** ระบบจัดการใบรับรอง (ต่ออายุ/เพิกถอน) พร้อม Modal ระบุเหตุผลและบันทึก Audit Log
- **Market Intelligence Links:** ลิงก์ดูแนวทางหลักสูตรที่ให้ข้อมูลวิเคราะห์ตลาดตาม Demand จริง

### รายละเอียดหน้าจอ (Pages):
1.  **ภาพรวมสถาบัน (Dashboard):**
    - **Connectivity Stats:** จำนวนผู้อบรมที่เชื่อมโยงบัญชีกับ CareDee แล้ว vs รอสมัคร
    - **Course-Demand Fit:** กราฟวิเคราะห์ความต้องการตลาดเทียบกับหลักสูตรที่เปิดสอน
2.  **นำเข้าข้อมูล (Import Wizard):**
    - **Conflict Resolution:** หน้าจอ Preview เพื่อแก้ไขข้อมูลที่ผิดพลาด (Inline Edit) หรือจับคู่บัญชีด้วยตนเอง (Manual Match)
    - **Bulk Invite:** ระบบจำลองการส่ง SMS/Email คำเชิญให้ผู้ที่จบการศึกษา
3.  **จัดการใบรับรอง (Certificate Management):**
    - **Bulk UI:** การเลือกหลายรายการเพื่อพิมพ์ใบรับรองดิจิทัลหรือดำเนินการอื่นๆ พร้อมกัน
    - **Digital Preview:** จำลองการเปิดดูไฟล์วุฒิบัตรต้นฉบับ
4.  **สถิติตลาดแรงงาน (Market Intelligence):**
    - **Unmet Demand:** วิเคราะห์คำค้นหาที่ "ไม่พบผู้ดูแล" เพื่อช่วยสถาบันวางแผนเปิดหลักสูตรใหม่
    - **Heatmap:** แผนที่แสดงพื้นที่ขาดแคลนแรงงานแบ่งตามโซน (เช่น กรุงเทพฯ ปริมณฑล)
5.  **การตรวจสอบ & เกณฑ์ (Verification):**
    - **Verification Queue:** รับคำขอตรวจสอบวุฒิการศึกษาจากผู้สมัครอิสระ พร้อมปุ่ม Confirm/Reject
    - **Audit Log (PDPA):** บันทึกประวัติการตรวจสอบทุกรายการพร้อม IP Address และ Metadata จำลอง
6.  **โปรไฟล์สถาบัน & KYC:**
    - ระบบจัดการข้อมูลติดต่อและอัปโหลดเอกสารยืนยันตัวตนสถาบันพร้อมปุ่มดูไฟล์จำลอง

---

## สรุปรายการ Gaps Analysis (สิ่งที่เติมเต็มจากเอกสาร SRS v1.2)
ในการพัฒนา Mockup นี้ ได้มีการเติมฟีเจอร์ที่ขาดหายไปเพื่อให้ตรงตามข้อกำหนดทางธุรกิจ ดังนี้:
1. **Gap 1 (Evidence Viewer):** ส่วนแสดงหลักฐานสำหรับตัดสินเคสอุทธรณ์ (ใน Admin & Operator)
2. **Gap 2 (Custom Date Range):** การเลือกช่วงวันที่ในหน้ารายงาน
3. **Gap 3 (Bulk Actions):** การจัดการข้อมูลจำนวนมาก (Batch Approval/Action) ในทุก Portal
4. **Gap 4 (Payout Breakdown):** การแจงรายละเอียดเงินโอนเพื่อความโปร่งใส (Net Payout Logic)
5. **Gap 5 (Policy Preview/Broadcast):** การควบคุมและประกาศนโยบาย PDPA
6. **Gap 6 (Technical Incident Link):** การเชื่อมโยงบันทึกข้อผิดพลาดทางเทคนิคในหน้า Cloud

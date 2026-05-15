# User Flow: CareDee Operator Portal (Version 2)

เอกสารฉบับนี้อธิบายลำดับการใช้งาน (User Flow) ของผู้ให้บริการ (Operator) ซึ่งเน้นการบริหารจัดการทีมผู้ดูแล การจัดตารางงาน และการควบคุมคุณภาพการให้บริการในสังกัด

---

## 1. ผังการทำงานภาพรวม (Main Flow Diagram)

<div style="background-color: white; padding: 20px; border-radius: 8px;">

```mermaid
%%{init: { 'theme': 'base', 'themeVariables': { 'darkMode': false, 'background': '#ffffff', 'mainBkg': '#ffffff', 'clusterBkg': '#ffffff', 'clusterBorder': '#000000', 'lineColor': '#000000', 'primaryColor': '#ffffff', 'primaryTextColor': '#000000', 'primaryBorderColor': '#000000' }, 'themeCSS': 'svg { background-color: white !important; } .node rect, .node circle, .node ellipse, .node polygon, .node path, .cluster rect { fill: white !important; stroke: black !important; stroke-width: 2px !important; } text, tspan { fill: black !important; color: black !important; font-weight: bold !important; } .edgePath .path { stroke: black !important; stroke-width: 2px !important; } .edgeLabel rect { fill: white !important; } .label { color: black !important; }' } }%%
graph TD
    Start([เข้าสู่ระบบ Operator]) --> Dashboard[0. Dashboard ภาพรวม]
    
    Dashboard --> Nav{เลือกดำเนินการ}
    
    Nav -- จัดการทีม --> Team[1. Caregiver Management]
    Nav -- ตารางงาน --> Schedule[2. Schedule & Booking]
    Nav -- รายงานหน้างาน --> Reports[3. Care Report Tracking]
    Nav -- ข้อร้องเรียน --> Disputes[4. Dispute & Resolution]
    Nav -- วิเคราะห์รายได้ --> Analytics[5. Analytics & Reporting]

    %% 1. Team Management Flow
    subgraph "1. การบริหารจัดการทีม"
        Team --> Inbound[ตรวจสอบคำขอจาก TI]
        Inbound --> VerifyDoc{ตรวจเอกสาร Side-by-Side}
        VerifyDoc -- เอกสารครบ --> ApproveCG([อนุมัติรับเข้าทีม])
        VerifyDoc -- ไม่ครบ --> RejectCG([ปฏิเสธคำขอ])
        Team --> MatchWeight[ปรับน้ำหนักการจับคู่ - AI Weight]
    end

    %% 2. Schedule Flow
    subgraph "2. ตารางงานและการจอง"
        Schedule --> Timeline[ตรวจสอบ Master Timeline]
        Timeline --> Conflict{ตรวจพบตารางซ้อน?}
        Conflict -- พบปัญหา --> Reassign[Smart Re-assign ผู้ดูแลใหม่]
        Conflict -- ปกติ --> MonitorBK[ติดตามสถานะบุ๊กกิ้ง]
        Reassign --> Timeline
    end

    %% 3. Care Report Flow
    subgraph "3. การติดตามรายงานหน้างาน"
        Reports --> LiveFeed[ติดตาม Live Feed รายงานสุขภาพ]
        LiveFeed --> HealthAlert{พบความเสี่ยงสุขภาพ?}
        HealthAlert -- พบความเสี่ยง --> Emergency[แจ้งประสานงานด่วน/โทรหาญาติ]
        HealthAlert -- ปกติ --> GeotagCheck[ตรวจสอบพิกัด Geotag]
    end

    %% 4. Dispute Flow
    subgraph "4. การจัดการข้อพิพาท"
        Disputes --> AppealQueue[รายการอุทธรณ์รีวิวจากผู้ดูแล]
        AppealQueue --> SLA_Check{ตรวจสอบ SLA 72 ชม.}
        SLA_Check -- เกินเวลา --> Locked([ล็อกเคส - สิ้นสุดอุทธรณ์])
        SLA_Check -- ภายในเวลา --> ReviewEvidence[ดูหลักฐานแชท/Log]
        ReviewEvidence --> Resolve{ผลการพิจารณา}
        Resolve -- ยอมรับ --> ProposeAdmin[เสนอเรื่องให้ Admin ลบรีวิว]
        Resolve -- ปฏิเสธ --> MaintainReview[คงสถานะรีวิวเดิม]
    end
```

</div>

---

## 2. รายละเอียดขั้นตอนการทำงาน (Detailed Workflows)

### 0. Dashboard (ภาพรวมการปฏิบัติงาน)
- **จุดประสงค์:** ติดตาม "ชีพจร" ของทีมในสังกัดแบบ Real-time
- **ข้อมูลสำคัญ:** Utilization Rate ของทีม, รายได้สุทธิหลังหัก GP 15%, และการแจ้งเตือนเหตุการณ์ฉุกเฉิน (Critical Alert)
- **Feature สำคัญ:** ระบบ **Real-time Sync Indicator** แสดงสถานะการเชื่อมต่อข้อมูล (Online/Offline) และเวลา Last Sync ตลอดเวลา

### 1. จัดการทีมผู้ดูแล (Caregiver Management)
- **การรับผู้ดูแลใหม่:** ตรวจสอบรายชื่อที่ส่งมาจากสถาบันฝึกอบรม (TI Inbound) พร้อมระบบ **Side-by-Side Verification** (ตรวจเอกสารต้นฉบับเทียบกับข้อมูลในระบบ)
- **Decision:** อนุมัติ (Verify) หรือ ปฏิเสธ (Reject) ตามความถูกต้องของเอกสาร โดยมีการอัปเดต Step Progress จำลอง
- **AI Matching Config:** Operator สามารถปรับน้ำหนัก (Weighting) ระหว่าง "ระยะทาง" และ "คะแนนรีวิว" เพื่อให้ระบบแนะนำผู้ดูแลที่เหมาะสมที่สุด

### 2. ตารางงาน & การจอง (Schedule & Booking)
- **Master Schedule:** ดูผังเวลาการทำงานของผู้ดูแลทุกคนในรูปแบบ Timeline Grid
- **Scheduling Audit Log:** ทุกการแก้ไขตารางงานจะถูกบันทึกประวัติ (Audit Trail) เพื่อตรวจสอบย้อนหลังได้ว่าใครเป็นคนปรับเปลี่ยน
- **Conflict Management (Decision):** หากเกิดกรณีตารางงานซ้อน ระบบจะใช้ "Smart Re-assign" เพื่อหาผู้ดูแลคนอื่นที่เหมาะสมแทนที่ทันที

### 3. ติดตามรายงานหน้างาน (Care Report Tracking)
- **Live Feed:** รายงานกิจกรรมสุขภาพ (Vitals) และรูปภาพส่งตรงจากหน้างานในรูปแบบ Activity List
- **Emergency Action (Decision):** ระบบจำลองการส่งแจ้งเตือนด่วน (**Medical Escalation**) หากตรวจพบความผิดปกติของสัญญาณชีพ
- **Geofence Verification:** ตรวจสอบว่าผู้ดูแลเข้างานในรัศมีที่กำหนดหรือไม่ (ป้องกันการทุจริตเวลา)

### 4. ข้อร้องเรียน & อุทธรณ์รีวิว (Dispute Resolution)
- **SLA Control (Decision):** ระบบมีการนับถอยหลัง 3 วันทำการ (72 ชม.) และจะทำการล็อกเคส (Locked) โดยอัตโนมัติหากเกินกำหนด
- **Appeal Decision:** ตรวจสอบหลักฐานแชท (Chat Snippet) และพิกัด Log เพื่อตัดสินอุทธรณ์
- **Integration:** คำร้องที่อนุมัติแล้วจะส่งต่อให้ System Admin เป็นผู้ดำเนินการลบออกจากระบบเป็นขั้นตอนสุดท้าย

### 5. รายงาน & รายได้ (Analytics & Reporting)
- **Settlement Logic:** ตรวจสอบยอดเงินโอนคืน (Net Payout) ตามสูตร **Gross - 15% GP = Net**
- **Export Tools:** ระบบจำลองการสร้างไฟล์รายงานสรุปผลในรูปแบบ PDF และ XLSX เพื่อนำเสนอผู้บริหาร

---
*จัดทำขึ้นอ้างอิงจาก Mockup Version 2 (Operator Portal SPA) และ Gaps Analysis ใน PORTAL_DOCUMENTATION.md*

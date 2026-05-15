# User Flow: CareDee Admin Portal (Version 2)

เอกสารฉบับนี้อธิบายลำดับการใช้งาน (User Flow) ของผู้บริหารระบบแพลตฟอร์ม (System Admin / Platform Operator) ซึ่งเป็นศูนย์กลางในการควบคุมความปลอดภัย การเงิน และความน่าเชื่อถือของแพลตฟอร์มทั้งหมด

---

## 1. ผังการทำงานภาพรวม (Main Flow Diagram)

<div style="background-color: white; padding: 20px; border-radius: 8px;">

```mermaid
%%{init: { 'theme': 'base', 'themeVariables': { 'darkMode': false, 'background': '#ffffff', 'mainBkg': '#ffffff', 'clusterBkg': '#ffffff', 'clusterBorder': '#000000', 'lineColor': '#000000', 'primaryColor': '#ffffff', 'primaryTextColor': '#000000', 'primaryBorderColor': '#000000' }, 'themeCSS': 'svg { background-color: white !important; } .node rect, .node circle, .node ellipse, .node polygon, .node path, .cluster rect { fill: white !important; stroke: black !important; stroke-width: 2px !important; } text, tspan { fill: black !important; color: black !important; font-weight: bold !important; } .edgePath .path { stroke: black !important; stroke-width: 2px !important; } .edgeLabel rect { fill: white !important; } .label { color: black !important; }' } }%%
graph TD
    Start([เข้าสู่ระบบ Admin]) --> Dashboard[0. Dashboard ชีพจรระบบ]
    
    Dashboard --> Nav{เลือกโมดูลควบคุม}
    
    Nav -- จัดการบัญชี --> Users[1. User & Provider Mgmt]
    Nav -- การเงิน --> Finance[2. Finance & Revenue]
    Nav -- ควบคุมเนื้อหา --> Reviews[3. Review & Appeals]
    Nav -- รายงานสรุปผล --> Reports[4. System Reports]
    Nav -- นโยบาย/PDPA --> PDPA[5. PDPA Control]
    Nav -- เฝ้าระวังเทคนิค --> Cloud[6. Cloud Monitoring]

    %% 1. User Management Flow
    subgraph "1. การจัดการบัญชีและสิทธิ์"
        Users --> VerifyKYC[ตรวจสอบหลักฐาน KYC]
        VerifyKYC --> VerifyDecision{ผลการตรวจ}
        VerifyDecision -- ถูกต้อง --> Approve([อนุมัติเข้าสู่ Marketplace])
        VerifyDecision -- ไม่ถูกต้อง --> Reject([ปฏิเสธคำขอ])
        Users --> Suspend[ระบุเหตุผล/Re-auth เพื่อระงับสิทธิ์]
    end

    %% 2. Finance Flow
    subgraph "2. การเงินและรายได้"
        Finance --> PayoutQueue[ตรวจสอบรายการรอโอน]
        PayoutQueue --> Breakdown[ดู Transaction Breakdown]
        Breakdown --> PayoutAuth{ยืนยันการโอน - ใส่ PIN}
        PayoutAuth -- สำเร็จ --> ExecPayout([ส่งคำสั่ง Batch Payout])
        Finance --> GlobalFee[ตั้งค่า GP/Commission แพลตฟอร์ม]
    end

    %% 3. Content Control Flow
    subgraph "3. การรักษาคุณภาพและอุทธรณ์"
        Reviews --> MaskedCheck[ตรวจสอบคำหยาบ/สแปม]
        MaskedCheck --> ModDecision{การดำเนินการ}
        ModDecision -- กู้คืน --> RestoreReview([เผยแพร่รีวิวอีกครั้ง])
        ModDecision -- ลบถาวร --> DeleteReview([ลบออกจากฐานข้อมูล])
        Reviews --> ResolveAppeal[ตัดสินอุทธรณ์จาก Operator]
    end

    %% 5. PDPA & Policy Flow
    subgraph "5. นโยบายและ PDPA"
        PDPA --> NewPolicy[ร่างนโยบายเวอร์ชันใหม่]
        NewPolicy --> PolicyPreview[ตรวจสอบเนื้อหา - Preview]
        PolicyPreview --> Broadcast([ประกาศ Re-consent ทั้งระบบ])
        PDPA --> DSR_Queue[จัดการคำร้องขอลบ/เข้าถึงข้อมูล]
    end

    %% 6. Technical Flow
    subgraph "6. การเฝ้าระวังและประกาศด่วน"
        Cloud --> ServiceStatus[ตรวจสอบสถานะ API/Gateway]
        ServiceStatus --> Incident{พบระบบขัดข้อง?}
        Incident -- ใช่ --> AlertDetail[Technical Alert Detail - ดู Log ข้อผิดพลาด]
        AlertDetail --> GlobalBanner([ประกาศ Maintenance Banner])
        Incident -- ไม่พบ --> UptimeMonitor[ติดตาม SLA รายนาที]
    end
```

</div>

---

## 2. รายละเอียดขั้นตอนการทำงาน (Detailed Workflows)

### 0. Dashboard (ศูนย์กลางการควบคุม)
- **จุดประสงค์:** ติดตามความเสถียรของระบบ (System Uptime) และรายการด่วนที่ต้องดำเนินการ
- **ข้อมูลสำคัญ:** ยอดจองรวมทั้งแพลตฟอร์ม, อัตรา Availability, และคิวรออนุมัติล่าสุด
- **Strategic Tool:** ระบบ Maintenance Broadcaster สำหรับส่งข้อความประกาศถึงผู้ใช้ทุกกลุ่มทันที (พร้อมระบบ Preview ก่อนประกาศจริง)

### 1. การจัดการบัญชีผู้ใช้ (User & Provider Management)
- **KYC Verification:** ตรวจสอบเอกสารตัวตน (ID Card) และใบเซอร์ (Certs) ที่เชื่อมโยงจาก TI ผ่าน API
- **Decision:** การอนุมัติ (Approve) หรือระงับสิทธิ์ (Suspend) จะต้องมีการใส่รหัสผ่านแอดมิน (**Double Confirmation**) และระบุ Reason Code เพื่อบันทึก Audit Log ทุกครั้ง
- **Bulk Action:** แถบจัดการข้อมูลจำนวนมาก (Batch Approval) เพื่อประสิทธิภาพสูงสุดในการจัดการผู้ใช้หลายรายการพร้อมกัน

### 2. การจัดการการเงิน (Finance & Revenue)
- **Payout Management:** ตรวจสอบยอดสุทธิที่ต้องโอนคืนให้ผู้ดูแล/Operator (Gross - GP = Net)
- **Transaction Breakdown:** ดูรายละเอียดที่มาของยอดเงิน (Payout Breakdown) เพื่อความโปร่งใสก่อนโอน
- **Decision (Security):** การโอนเงินคืน (Payout) ต้องผ่านระบบ PIN Verification และบันทึก Audit Log ตามมาตรฐาน PF-FIN-001

### 3. คุณภาพรีวิว & อุทธรณ์ (Review Quality & Appeals)
- **Auto-Moderation:** ระบบจะบังคับใช้ Masking (เบลอ) ข้อความที่ไม่สุภาพโดยอัตโนมัติเพื่อให้แอดมินคลิกตรวจสอบ
- **Evidence Viewer:** แอดมินตรวจสอบหลักฐานแชทหรือรูปภาพประกอบก่อนตัดสินผลการอุทธรณ์
- **Appeal SLA (Decision):** แอดมินต้องตัดสินผลการอุทธรณ์รีวิวจากผู้ดูแลภายใน 3 วันทำการ (72 ชม.)

### 4. รายงานระบบ (System Reports & Insights)
- **Strategic Insights:** ดูแผนที่ความร้อน (**Interactive Heatmap**) ของพื้นที่ที่ Demand สูงแต่ Supply ต่ำ เพื่อวางแผนขยายการตลาด
- **Financial Reconciliation:** ตรวจสอบส่วนต่างของยอดโอนในระบบกับยอด Settled จริงจากธนาคาร
- **Custom Reporting:** สามารถกำหนดช่วงเวลา (**Custom Date Range**) และประเภทไฟล์ (PDF/XLSX) เพื่อส่งออกรายงานผู้บริหาร

### 5. นโยบาย & PDPA (Privacy Control Center)
- **Consent Versioning:** จัดการเวอร์ชันของนโยบายความเป็นส่วนตัวและ Terms of Use
- **Audit Trail Context:** ระบบบันทึกประวัติการเข้าถึงข้อมูลส่วนบุคคล (Access Log) ตามกฎหมาย PDPA
- **Broadcast Decision:** เมื่อเปลี่ยนกฎหมาย สามารถสั่ง Trigger Re-consent เพื่อบังคับให้ผู้ใช้ทุกคนกดยอมรับใหม่ก่อนเข้าใช้งาน

### 6. เฝ้าระวังระบบคลาวด์ (Cloud Monitoring)
- **Service Health:** ตรวจสอบสถานภาพของ Main API, SMS Gateway และ Payment Gateway แบบรายวินาที
- **Incident Analysis:** ลิงก์ดูรายละเอียดข้อผิดพลาดทางเทคนิค (**Technical Alert Detail**) เพื่อวินิจฉัยปัญหาเบื้องต้น
- **Emergency Action:** หากระบบล่ม แอดมินสามารถกดประกาศ Maintenance Banner (สีแดง) ซึ่งจะแสดงผล "ทุกหน้าแแอป" ทันที

---
*จัดทำขึ้นอ้างอิงจาก Mockup Version 2 (Admin Portal SPA) และ Gaps Analysis ใน PORTAL_DOCUMENTATION.md*

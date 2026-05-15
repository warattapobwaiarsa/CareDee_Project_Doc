# User Flow: CareDee Training Institute Portal (Version 2)

เอกสารฉบับนี้อธิบายลำดับการใช้งาน (User Flow) ของระบบสถาบันการอบรม (Training Institute Portal) โดยครอบคลุมกระบวนการตั้งแต่การนำเข้าข้อมูล จนถึงการบริหารจัดการใบรับรองและการวิเคราะห์ตลาด

---

## 1. ผังการทำงานภาพรวม (Main Flow Diagram)

<div style="background-color: white; padding: 20px; border-radius: 8px;">

```mermaid
%%{init: { 'theme': 'base', 'themeVariables': { 'darkMode': false, 'background': '#ffffff', 'mainBkg': '#ffffff', 'clusterBkg': '#ffffff', 'clusterBorder': '#000000', 'lineColor': '#000000', 'primaryColor': '#ffffff', 'primaryTextColor': '#000000', 'primaryBorderColor': '#000000' }, 'themeCSS': 'svg { background-color: white !important; } .node rect, .node circle, .node ellipse, .node polygon, .node path, .cluster rect { fill: white !important; stroke: black !important; stroke-width: 2px !important; } text, tspan { fill: black !important; color: black !important; font-weight: bold !important; } .edgePath .path { stroke: black !important; stroke-width: 2px !important; } .edgeLabel rect { fill: white !important; } .label { color: black !important; }' } }%%
graph TD
    Start([เข้าสู่ระบบสถาบัน]) --> Dashboard[0. แดชบอร์ดภาพรวม]
    
    Dashboard --> NavImport{เลือกเมนู}
    
    NavImport -- นำเข้าข้อมูล --> Import[1. Bulk Import]
    NavImport -- จัดการใบรับรอง --> CertManage[2. Certificate Management]
    NavImport -- สถิติตลาด --> MarketIntel[3. Market Intelligence]
    NavImport -- มาตรฐานการตรวจสอบ --> VerifyStandard[4. Verification & Standards]
    NavImport -- โปรไฟล์สถาบัน --> Profile[5. Profile & KYC]

    %% 1. Import Flow
    subgraph "1. กระบวนการนำเข้าข้อมูล (Advanced Import Wizard)"
        Import --> Choice{เลือกวิธีนำเข้า}
        Choice -- Bulk --> Upload[อัปโหลดไฟล์ CSV/XLSX]
        Choice -- Manual --> ManualInput[กรอกข้อมูลรายบุคคล]
        Upload --> Processing[Processing & Mapping]
        ManualInput --> Processing
        Processing --> Validate{ตรวจสอบความถูกต้อง}
        Validate -- มีข้อผิดพลาด --> EditFile[แก้ไขข้อมูล Inline Edit]
        EditFile --> Processing
        Validate -- ถูกต้อง --> MatchUser{ตรวจสอบบัญชี CareDee}
        MatchUser -- ไม่พบสมาชิก --> Invite[ส่ง Bulk Invite / Digital Badge]
        MatchUser -- พบสมาชิก --> Preview[พรีวิวข้อมูลขั้นสุดท้าย]
        Invite --> Preview
        Preview --> ConfirmImport([ยืนยันและบันทึกข้อมูล])
    end

    %% 2. Cert Management Flow
    subgraph "2. การจัดการใบรับรอง"
        CertManage --> SearchCert[ค้นหาด้วยเลขที่ใบเซอร์/ID]
        SearchCert --> SelectAction{เลือกดำเนินการ}
        SelectAction -- ต่ออายุ --> Renew[Renew - ระบุวันหมดอายุใหม่]
        SelectAction -- เพิกถอน --> RevokeModal[Revoke - ระบุเหตุผล/หลักฐาน]
        SelectAction -- พิมพ์/ดาวน์โหลด --> PrintCert[Digital Certificate Preview]
        Renew --> UpdateSuccess([บันทึกสำเร็จ & บันทึก Audit Log])
        RevokeModal --> UpdateSuccess
        PrintCert --> UpdateSuccess
    end

    %% 4. Verification Flow
    subgraph "4. มาตรฐานการตรวจสอบ (Verification Queue)"
        VerifyStandard --> Queue[รายการรอตรวจสอบจาก Operator]
        Queue --> ViewEvidence[ดูไฟล์หลักฐาน/ใบเซอร์ต้นฉบับ]
        ViewEvidence --> Decision{ผลการตรวจสอบ}
        Decision -- ผ่าน --> ConfirmVerify[กด Confirm - อัปเดตสถานะทันที]
        Decision -- ไม่ผ่าน --> RejectModal[ระบุเหตุผลการปฏิเสธ]
        ConfirmVerify --> AuditLog([บันทึก Audit Log - IP/Metadata])
        RejectModal --> AuditLog
    end
```

</div>

---

## 2. รายละเอียดขั้นตอนการทำงาน (Detailed Workflows)

### 0. แดชบอร์ด (Dashboard)
- **จุดประสงค์:** แสดงภาพรวมสถานะสถาบัน และวิเคราะห์ความสอดคล้องของหลักสูตรกับตลาด
- **ข้อมูลสำคัญ:** Connectivity Stats (จำนวนผู้อบรมที่เชื่อมต่อบัญชี), ดัชนีความต้องการตลาดแรงงาน (Course-Demand Fit)
- **Decision Point:** วิเคราะห์คำค้นหาที่ "ไม่พบผู้ดูแล" เพื่อนำไปพัฒนาเป็นหลักสูตรใหม่ในอนาคต

### 1. นำเข้าข้อมูลการอบรม (Advanced Import Wizard)
- **ขั้นตอนการทำงาน:**
    1. **Choice:** สลับโหมดได้ระหว่าง **Bulk Upload** (XLSX/CSV) และ **Manual Entry** (กรอกเอง)
    2. **Processing & Mapping:** ระบบจัดโครงสร้างข้อมูลและตรวจสอบความซ้ำซ้อน
    3. **Validation (Decision):** ตรวจสอบรูปแบบข้อมูล หากผิดสามารถใช้ **Inline Edit** แก้ไขบนหน้าจอได้ทันที
    4. **Matching & Invite:** ตรวจสอบบัญชีในระบบ หากไม่พบ สามารถส่งคำเชิญ (Invite) เพื่อรับ **Digital Badge** อัตโนมัติเมื่อสมัครสมาชิก
    5. **Confirmation:** ตรวจสอบความถูกต้องขั้นสุดท้ายผ่าน Progress Bar 3 ขั้นตอนก่อนบันทึก

### 2. จัดการใบรับรอง (Certificate Management)
- **ขั้นตอนการทำงาน:**
    1. ค้นหาใบรับรองแบบละเอียด พร้อมระบบกรองสถานะ (Active/Expiring/Revoked)
    2. **Actions (Decision):**
        - **Renew:** สำหรับต่ออายุใบรับรอง
        - **Revoke:** สำหรับเพิกถอนในกรณีตรวจพบการทุจริต (ต้องระบุเหตุผลและบันทึก Audit Log)
        - **Print/Preview:** เปิดดูวุฒิบัตรดิจิทัล (**Digital Certificate Preview**)
- **Bulk UI:** สามารถเลือกหลายรายการเพื่อดำเนินการพร้อมกัน (Batch Action)

### 3. สถิติตลาดแรงงาน (Market Intelligence)
- **ขั้นตอนการทำงาน:**
    1. ดูแผนที่ความร้อน (**Interactive Heatmap**) ของพื้นที่ที่ขาดแคลนผู้ดูแลตามโซนต่างๆ
    2. **Unmet Demand Analysis:** วิเคราะห์ทักษะที่ตลาดต้องการแต่ยังไม่มีผู้ดูแลเพียงพอ
    3. **Curriculum Adjustment:** นำข้อมูลความต้องการจริงมาปรับปรุงหลักสูตรให้ทันสมัย

### 4. มาตรฐานการตรวจสอบ (Verification & Standards)
- **ขั้นตอนการทำงาน:**
    1. รับคำร้องขอตรวจสอบใบรับรองจาก Operator ในรูปแบบ **Verification Queue**
    2. **Review:** ตรวจสอบไฟล์ภาพวุฒิบัตรต้นฉบับเทียบกับฐานข้อมูลของสถาบัน
    3. **Decision:**
        - **Confirm:** ยืนยันความถูกต้อง (ผู้ดูแลจะได้สถานะ Verified ทันที)
        - **Reject:** ปฏิเสธการยืนยัน (ต้องระบุเหตุผล)
    4. **Audit Log:** บันทึก Metadata และ IP Address ของผู้ตรวจสอบเพื่อความโปร่งใส (PDPA Compliance)

### 5. โปรไฟล์สถาบัน & KYC (Institute Profile)
- **ขั้นตอนการทำงาน:**
    1. จัดการข้อมูลสถาบันและช่องทางการติดต่อ
    2. อัปโหลดเอกสารยืนยันตัวตนสถาบัน (KYC) เพื่อรักษาสถานะ **Verified Institute** และสร้างความเชื่อมั่นบนแพลตฟอร์ม

---
*จัดทำขึ้นอ้างอิงจาก Mockup Version 2 (Training Portal SPA) และ Gaps Analysis ใน PORTAL_DOCUMENTATION.md*

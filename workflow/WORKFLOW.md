# CareDee Platform Workflows

เอกสารชุดนี้แสดงผังการทำงาน (Workflows) ของแพลตฟอร์ม CareDee โดยเริ่มจากภาพรวมระบบ และตามด้วยมุมมองแยกตามบทบาทของผู้ใช้งานทั้ง 5 กลุ่ม

---

## 1. System Overview (ภาพรวมระบบแคร์ดี)

Sequence diagram นี้แสดงการไหลของข้อมูลทั้งหมดผ่านทั้ง 5 บทบาท และ 10 โมดูลหลักของระบบ โดยเน้นการทำงานในรูปแบบ Platform Ecosystem ที่เชื่อมโยงผู้มีส่วนได้ส่วนเสียเข้าด้วยกันอย่างครบวงจร

```mermaid
%%{init: { 'theme': 'base', 'themeVariables': { 'darkMode': false, 'background': '#ffffff', 'mainBkg': '#ffffff', 'primaryColor': '#ffffff', 'primaryTextColor': '#000000', 'primaryBorderColor': '#000000', 'lineColor': '#000000', 'secondaryColor': '#ffffff', 'tertiaryColor': '#ffffff', 'actorBkg': '#ffffff', 'actorTextColor': '#000000', 'actorLineColor': '#000000', 'participantBkg': '#ffffff', 'participantTextColor': '#000000', 'participantBorderColor': '#000000', 'signalColor': '#000000', 'signalTextColor': '#000000', 'labelTextColor': '#000000', 'loopTextColor': '#000000', 'noteBkgColor': '#ffffff', 'noteTextColor': '#000000', 'activationBkgColor': '#ffffff', 'activationBorderColor': '#000000', 'sequenceNumberColor': '#000000' }, 'themeCSS': 'svg { background-color: white !important; background: white !important; } rect, circle, path, line, polygon, .labelBox, .cluster rect, .actor, .participant, .note, .activation { fill: white !important; stroke: black !important; stroke-width: 2px !important; } text, tspan, .loopText, .messageText, .noteText, .sequenceNumber { fill: black !important; color: black !important; font-weight: bold !important; font-size: 14px !important; } .cluster rect { stroke-dasharray: 0 !important; }' } }%%
sequenceDiagram
    autonumber
    
    box white CareDee Platform Ecosystem (ระบบนิเวศแคร์ดี)
        actor C as Customer
        actor CG as Caregiver
        actor TI as Training Provider
        actor OP as Operator
        actor AD as Admin
        participant TI_Int as TI Interface (10)
        participant UM as User Mgmt (1)
        participant MK as Marketplace (2)
        participant MT as Matching (3)
        participant BK as Booking (4)
        participant PM as Payment (5)
        participant CR as Care Report (6)
        participant RR as Rating & Review (7)
        participant NT as Notification (8)
        participant Portal as Op/Admin Portal (9)
    end

    %% Pre-requisite
    TI->>TI_Int: Upload Certification Data
    TI_Int->>UM: Verify Credentials
    UM->>MK: Update Caregiver Profile Status
    
    %% Phase 1 & 2
    C->>MK: Search for caregiver
    MK->>MT: Request ranked matches
    MT-->>C: Display results
    C->>BK: Select & request booking
    BK->>PM: Process payment
    PM-->>BK: Payment success
    BK->>NT: Alert caregiver
    NT-->>CG: Booking received
    
    alt Caregiver Accepts
        CG->>BK: Accept booking
        BK->>NT: Notify Customer (Success)
    else Caregiver Rejects or Timeout
        BK->>MT: Trigger Auto-rematch
        MT-->>C: Suggest new caregiver
        Note over BK, PM: If no match found, trigger refund
        BK->>PM: Request refund
    end
    
    %% Phase 3
    CG->>CR: Check-in & log activities
    CR->>NT: Trigger real-time report
    NT-->>C: View care report
    CG->>CR: Check-out
    
    %% Phase 4
    C->>RR: Submit review
    
    %% Dashboard Aggregation
    CR->>Portal: Activity Data
    PM->>Portal: Revenue Data
    RR->>Portal: Rating Data
    Portal->>OP: Show Workforce Dashboard
    Portal->>AD: Show System Audit
```

**คำอธิบายทีละขั้นตอน (Step-by-step Explanation):**
*   **เตรียมความพร้อม (Pre-requisite):**
    *   **Step 1-2:** สถาบันฝึกอบรม (TI) อัปโหลดข้อมูลใบเซอร์ (10) เพื่อให้ระบบ User Mgmt (1) ตรวจสอบความถูกต้องของข้อมูล
    *   **Step 3:** ระบบ User Mgmt (1) ส่งสถานะการตรวจสอบไปยัง Marketplace (2) เพื่อยืนยันตัวตนผู้ดูแล
*   **Phase 1 & 2: ค้นหาและจอง (Search & Book):**
    *   **Step 4-6:** ลูกค้า (C) ค้นหาผู้ดูแลผ่าน Marketplace (2) ซึ่งจะเรียก Matching (3) ให้แสดงผลลัพธ์ที่เรียงลำดับตามความเหมาะสม
    *   **Step 7-9:** ลูกค้า (C) เลือกผู้ดูแลและทำการจอง (4) ระบบจะส่งไปที่ Payment (5) เพื่อประมวลผลการชำระเงินและแจ้งกลับเมื่อสำเร็จ
    *   **Step 10-11:** ระบบจอง (4) แจ้งเตือนผ่าน Notification (8) ไปยังผู้ดูแล (CG) ว่ามีงานใหม่
    *   **Step 12-15 (เงื่อนไขการรับงาน):** หากผู้ดูแล (CG) ยอมรับงาน (12) ระบบจะแจ้งผลสำเร็จให้ลูกค้าทราบ (13) แต่หากปฏิเสธหรือหมดเวลา ระบบจะสั่ง Matching (3) ให้หาคนใหม่ (14) หรือสั่งคืนเงินผ่าน Payment (5) ในกรณีที่ไม่พบผู้ดูแลคนใหม่ (15)
*   **Phase 3: การให้บริการ (Service Delivery):**
    *   **Step 16-18:** ผู้ดูแล (CG) กด Check-in และบันทึกกิจกรรมผ่าน Care Report (6) ระบบจะยิงแจ้งเตือน (8) ให้ลูกค้า (C) ติดตามรายงานแบบ Real-time
    *   **Step 19:** ผู้ดูแล (CG) กด Check-out เมื่อสิ้นสุดการให้บริการ
*   **Phase 4: หลังการให้บริการ:**
    *   **Step 20:** ลูกค้า (C) ส่งคะแนนและรีวิวผ่านระบบ Rating & Review (7)
*   **สรุปผล (Aggregation):**
    *   **Step 21-25:** ระบบ Care Report (6), Payment (5) และ Rating (7) ส่งข้อมูลกิจกรรม รายได้ และคะแนน (21-23) เข้าสู่ Portal (9) เพื่อแสดงผล Dashboard ให้ Operator (24) และ Admin (25) ตรวจสอบคุณภาพและระบบงานตามลำดับ

---

## 2. Customer View (มุมมองผู้รับบริการ)

มุ่งเน้นการเดินทางของผู้รับบริการ (User Journey) ตั้งแต่การเริ่มต้นเข้าใช้งาน การค้นหาจนถึงการประเมินผล เพื่อความสะดวก รวดเร็ว และความสบายใจของครอบครัว

```mermaid
%%{init: { 'theme': 'base', 'themeVariables': { 'darkMode': false, 'background': '#ffffff', 'mainBkg': '#ffffff', 'primaryColor': '#ffffff', 'primaryTextColor': '#000000', 'primaryBorderColor': '#000000', 'lineColor': '#000000', 'secondaryColor': '#ffffff', 'tertiaryColor': '#ffffff', 'actorBkg': '#ffffff', 'actorTextColor': '#000000', 'actorLineColor': '#000000', 'participantBkg': '#ffffff', 'participantTextColor': '#000000', 'participantBorderColor': '#000000', 'signalColor': '#000000', 'signalTextColor': '#000000', 'labelTextColor': '#000000', 'loopTextColor': '#000000', 'noteBkgColor': '#ffffff', 'noteTextColor': '#000000', 'activationBkgColor': '#ffffff', 'activationBorderColor': '#000000', 'sequenceNumberColor': '#000000' }, 'themeCSS': 'svg { background-color: white !important; background: white !important; } rect, circle, path, line, polygon, .labelBox, .cluster rect, .actor, .participant, .note, .activation { fill: white !important; stroke: black !important; stroke-width: 2px !important; } text, tspan, .loopText, .messageText, .noteText, .sequenceNumber { fill: black !important; color: black !important; font-weight: bold !important; font-size: 14px !important; } .cluster rect { stroke-dasharray: 0 !important; }' } }%%
sequenceDiagram
    autonumber

    box white Customer Journey (เส้นทางผู้รับบริการ)
        actor C as Customer
        participant Auth as Auth System
        participant UM as User Mgmt (1)
        participant MK as Marketplace (2)
        participant MT as Matching (3)
        participant BK as Booking (4)
        participant PM as Payment (5)
        participant CR as Care Report (6)
        participant RR as Rating & Review (7)
        participant NT as Notification (8)
    end

    %% Authentication & Onboarding
    C->>Auth: Sign Up / Login (OTP/Social)
    Auth-->>C: Access Token Issued
    C->>UM: Setup Patient Profile & Address
    UM-->>C: Profile Saved Successfully

    %% Service Search
    C->>MK: Search for caregiver (filters)
    MK->>MT: Find best match
    MT-->>C: Display ranked profiles
    
    %% Booking & Payment
    C->>BK: Request booking
    BK->>PM: Prompt for payment
    C->>PM: Process digital payment
    alt Payment Success
        PM-->>C: Issue Receipt
        PM->>BK: Confirm Payment
    else Payment Failure
        PM-->>C: Payment Failed Alert
        C->>PM: Retry Payment / Cancel
    end

    %% Service Execution
    loop During Service
        CR->>NT: Trigger update
        NT-->>C: Receive real-time Care Report
    end
    
    %% Post-Service
    C->>RR: Submit rating and review
```

**คำอธิบายทีละขั้นตอน (Step-by-step Explanation):**
*   **Step 1-2 (Authentication):** ลูกค้า (C) ลงทะเบียนหรือเข้าสู่ระบบผ่าน Auth System (เช่น OTP หรือ Social Login) และได้รับ Token เพื่อเข้าใช้งาน
*   **Step 3-4 (Onboarding):** ลูกค้าตั้งค่าข้อมูลผู้ป่วย (Patient Profile) เช่น อาการ โรคประจำตัว และระบุที่อยู่สำหรับการรับบริการในระบบ User Mgmt (1)
*   **Step 5-7 (Search):** ลูกค้า (C) ค้นหาผู้ดูแลผ่าน Marketplace (2) โดยระบุเงื่อนไขที่ต้องการ ซึ่งระบบ Matching (3) จะแสดงโปรไฟล์ผู้ดูแลที่เหมาะสมที่สุด
*   **Step 8-9 (Booking):** ลูกค้า (C) เลือกผู้ดูแลและกดจอง (4) ระบบจะส่งไปยัง Payment (5) เพื่อให้ลูกค้าชำระเงิน
*   **Step 10-11 (Payment):** ลูกค้า (C) ดำเนินการชำระเงิน และระบบจะออกใบเสร็จ (Receipt) เมื่อสำเร็จ
*   **Step 12-13 (Loop):** ระหว่างการให้บริการ ระบบ Care Report (6) จะส่งรายงานสุขภาพและกิจกรรมให้ลูกค้า (C) ติดตามแบบ Real-time ผ่าน Notification (8)
*   **Step 14:** เมื่อจบงาน ลูกค้า (C) ส่งคะแนนและรีวิวผ่านระบบ Rating & Review (7) เพื่อให้คะแนนผู้ดูแลในระบบต่อไป

---

## 3. Caregiver View (มุมมองผู้ดูแล)

เน้นการเริ่มต้นเป็นผู้ดูแลในระบบ การจัดการตารางงาน การลงบันทึกการปฏิบัติงานที่ง่าย และความโปร่งใสของรายได้

```mermaid
%%{init: { 'theme': 'base', 'themeVariables': { 'darkMode': false, 'background': '#ffffff', 'mainBkg': '#ffffff', 'primaryColor': '#ffffff', 'primaryTextColor': '#000000', 'primaryBorderColor': '#000000', 'lineColor': '#000000', 'secondaryColor': '#ffffff', 'tertiaryColor': '#ffffff', 'actorBkg': '#ffffff', 'actorTextColor': '#000000', 'actorLineColor': '#000000', 'participantBkg': '#ffffff', 'participantTextColor': '#000000', 'participantBorderColor': '#000000', 'signalColor': '#000000', 'signalTextColor': '#000000', 'labelTextColor': '#000000', 'loopTextColor': '#000000', 'noteBkgColor': '#ffffff', 'noteTextColor': '#000000', 'activationBkgColor': '#ffffff', 'activationBorderColor': '#000000', 'sequenceNumberColor': '#000000' }, 'themeCSS': 'svg { background-color: white !important; background: white !important; } rect, circle, path, line, polygon, .labelBox, .cluster rect, .actor, .participant, .note, .activation { fill: white !important; stroke: black !important; stroke-width: 2px !important; } text, tspan, .loopText, .messageText, .noteText, .sequenceNumber { fill: black !important; color: black !important; font-weight: bold !important; font-size: 14px !important; } .cluster rect { stroke-dasharray: 0 !important; }' } }%%
sequenceDiagram
    autonumber

    box white Caregiver Workflow (ขั้นตอนงานของผู้ดูแล)
        actor CG as Caregiver
        actor C as Customer
        participant Auth as Auth System
        participant UM as User Mgmt (1)
        participant BK as Booking (4)
        participant CR as Care Report (6)
        participant NT as Notification (8)
        participant PM as Payment (5)
    end

    %% Authentication & KYC Onboarding
    CG->>Auth: Sign Up / Login
    Auth-->>CG: Access Granted
    CG->>UM: Submit KYC (ID, Certs, Background Check)
    UM->>UM: Admin Review Process
    UM-->>CG: Profile status updated (Verified/Rejected)

    alt Profile Verified
        CG->>BK: Set Availability & Ready for jobs
    else Profile Rejected
        CG->>UM: Update / Submit missing documents
    end

    %% Job Acceptance
    NT-->>CG: Receive new job request
    CG->>BK: Confirm availability & accept job
    
    %% Service Delivery
    alt On-time Check-in
        CG->>CR: Check-in (Start Service via GPS)
    else Late / No-show
        CR->>NT: Alert Customer & Operator
        BK->>MT: Trigger Auto-rematch
    end
    loop During Service
        CG->>CR: Log vitals, activities, attach media
    end
    CG->>CR: Check-out (End Service)
    
    %% Payment & Payout
    C->>CR: Review & Approve Final Report
    CR->>PM: Trigger Payout
    PM-->>CG: Receive automated payout
```

**คำอธิบายทีละขั้นตอน (Step-by-step Explanation):**
*   **Step 1-2 (Authentication):** ผู้ดูแล (CG) ลงทะเบียนและเข้าสู่ระบบ
*   **Step 3-5 (Onboarding & KYC):** ผู้ดูแลส่งเอกสารยืนยันตัวตน (KYC) เช่น บัตรประชาชน, ใบรับรองการฝึกอบรม และประวัติอาชญากรรม เพื่อให้ Admin ตรวจสอบ เมื่อผ่านการอนุมัติ สถานะจะเปลี่ยนเป็น "Verified"
*   **Step 6-7 (Availability):** ผู้ดูแลที่ผ่านการตรวจสอบแล้ว (Verified) สามารถตั้งค่าเวลาว่าง (Availability) เพื่อเริ่มรับงานผ่านระบบ Booking (4)
*   **Step 8-9 (Job Acceptance):** เมื่อมีงานที่ตรงสเปก ระบบจะส่ง Notification (8) แจ้งเตือน และผู้ดูแลกดตอบรับงาน
*   **Step 10 (Check-in):** เมื่อถึงหน้างาน ผู้ดูแลกด Check-in ผ่าน Care Report (6) เพื่อบันทึกเวลาและพิกัด GPS
*   **Step 11 (Loop):** ระหว่างงาน ผู้ดูแลบันทึกข้อมูลสุขภาพ กิจกรรม และแนบสื่อต่างๆ ผ่าน Care Report (6)
*   **Step 12 (Check-out):** เมื่อเสร็จงาน กด Check-out (End Service) เพื่อส่งรายงานฉบับสุดท้าย
*   **Step 13-15 (Payout):** เมื่อลูกค้า (C) อนุมัติรายงาน ระบบจะส่งคำสั่งไปยัง Payment (5) เพื่อโอนเงินให้ผู้ดูแลโดยอัตโนมัติ

---

## 4. Operator View (มุมมองผู้ให้บริการ)

มุ่งเน้นการบริหารจัดการทีมผู้ดูแล (Workforce Management) การควบคุมคุณภาพ และการวิเคราะห์รายได้ของหน่วยงาน

```mermaid
%%{init: { 'theme': 'base', 'themeVariables': { 'darkMode': false, 'background': '#ffffff', 'mainBkg': '#ffffff', 'primaryColor': '#ffffff', 'primaryTextColor': '#000000', 'primaryBorderColor': '#000000', 'lineColor': '#000000', 'secondaryColor': '#ffffff', 'tertiaryColor': '#ffffff', 'actorBkg': '#ffffff', 'actorTextColor': '#000000', 'actorLineColor': '#000000', 'participantBkg': '#ffffff', 'participantTextColor': '#000000', 'participantBorderColor': '#000000', 'signalColor': '#000000', 'signalTextColor': '#000000', 'labelTextColor': '#000000', 'loopTextColor': '#000000', 'noteBkgColor': '#ffffff', 'noteTextColor': '#000000', 'activationBkgColor': '#ffffff', 'activationBorderColor': '#000000', 'sequenceNumberColor': '#000000' }, 'themeCSS': 'svg { background-color: white !important; background: white !important; } rect, circle, path, line, polygon, .labelBox, .cluster rect, .actor, .participant, .note, .activation { fill: white !important; stroke: black !important; stroke-width: 2px !important; } text, tspan, .loopText, .messageText, .noteText, .sequenceNumber { fill: black !important; color: black !important; font-weight: bold !important; font-size: 14px !important; } .cluster rect { stroke-dasharray: 0 !important; }' } }%%
sequenceDiagram
    autonumber

    box white Operator Dashboard (แดชบอร์ดผู้ให้บริการ)
        actor OP as Operator
        participant Portal as Operator Portal (9)
        participant BK as Booking (4)
        participant CR as Care Report (6)
        participant RR as Rating & Review (7)
        participant PM as Payment (5)
    end

    BK->>Portal: Update caregiver schedules
    CR->>Portal: Feed real-time activity logs
    RR->>Portal: Feed customer complaints/reviews
    PM->>Portal: Feed revenue data
    Portal-->>OP: Display Workforce Dashboard
    OP->>Portal: Manage schedules & resolve issues
    alt Dispute Resolved
        OP->>PM: Release Escrow Payout
    else Refund Required
        OP->>PM: Trigger Refund to Customer
    end
```

**คำอธิบายทีละขั้นตอน (Step-by-step Explanation):**
*   **Step 1:** ระบบ Booking (4) ส่งข้อมูลตารางงานและการเปลี่ยนแปลงตารางงานของผู้ดูแลเข้าสู่ Operator Portal (9)
*   **Step 2:** ระบบ Care Report (6) ส่งบันทึกกิจกรรมแบบ Real-time ของผู้ดูแลทุกคนเข้าสู่ Portal (9)
*   **Step 3:** ระบบ Rating & Review (7) ส่งข้อมูลการร้องเรียนและรีวิวจากลูกค้าเข้าสู่ Portal (9)
*   **Step 4:** ระบบ Payment (5) ส่งข้อมูลรายได้และการเงินเข้าสู่ Portal (9)
*   **Step 5:** Operator Portal (9) ประมวลผลและแสดงข้อมูลทั้งหมดในรูปแบบ Workforce Dashboard ให้ Operator (OP) เห็นภาพรวม
*   **Step 6:** Operator (OP) ใช้ข้อมูลบน Portal (9) ในการจัดการตารางงานและแก้ไขปัญหาการปฏิบัติงานต่างๆ

---

## 5. Admin View (มุมมองผู้ดูแลระบบ)

มุ่งเน้นการรักษาความมั่นคงปลอดภัยของข้อมูล (Security) การกำหนดสิทธิ์ (RBAC) และการปฏิบัติตามกฎหมาย PDPA

```mermaid
%%{init: { 'theme': 'base', 'themeVariables': { 'darkMode': false, 'background': '#ffffff', 'mainBkg': '#ffffff', 'primaryColor': '#ffffff', 'primaryTextColor': '#000000', 'primaryBorderColor': '#000000', 'lineColor': '#000000', 'secondaryColor': '#ffffff', 'tertiaryColor': '#ffffff', 'actorBkg': '#ffffff', 'actorTextColor': '#000000', 'actorLineColor': '#000000', 'participantBkg': '#ffffff', 'participantTextColor': '#000000', 'participantBorderColor': '#000000', 'signalColor': '#000000', 'signalTextColor': '#000000', 'labelTextColor': '#000000', 'loopTextColor': '#000000', 'noteBkgColor': '#ffffff', 'noteTextColor': '#000000', 'activationBkgColor': '#ffffff', 'activationBorderColor': '#000000', 'sequenceNumberColor': '#000000' }, 'themeCSS': 'svg { background-color: white !important; background: white !important; } rect, circle, path, line, polygon, .labelBox, .cluster rect, .actor, .participant, .note, .activation { fill: white !important; stroke: black !important; stroke-width: 2px !important; } text, tspan, .loopText, .messageText, .noteText, .sequenceNumber { fill: black !important; color: black !important; font-weight: bold !important; font-size: 14px !important; } .cluster rect { stroke-dasharray: 0 !important; }' } }%%
sequenceDiagram
    autonumber

    box white System Administration (การบริหารจัดการระบบ)
        actor AD as Admin
        participant Portal as Admin Portal (9)
        participant UM as User Mgmt (1)
        participant All as All Other Modules
    end

    AD->>UM: Configure Role-Based Access Control
    alt KYC Verification Flow
        AD->>UM: Review Documents
        alt Documents Valid
            UM->>Portal: Update Caregiver to "Verified"
        else Documents Invalid
            UM->>Portal: Flag for follow-up/Reject
        end
    end
    UM->>Portal: Log access audits
    All->>Portal: Feed system performance metrics
    Portal-->>AD: Display System Health & Audit Dashboard
    AD->>Portal: Generate compliance reports (PDPA)
```

**คำอธิบายทีละขั้นตอน (Step-by-step Explanation):**
*   **Step 1:** Admin (AD) กำหนดสิทธิ์การเข้าถึงข้อมูลรายโมดูลผ่านระบบ User Mgmt (1) (Role-Based Access Control)
*   **Step 2:** ระบบ User Mgmt (1) ส่งประวัติการเข้าใช้งาน (Access Audits) เข้าสู่ Portal (9)
*   **Step 3:** ทุกโมดูลในระบบ ส่งข้อมูลประสิทธิภาพและการทำงาน (System Performance Metrics) เข้าสู่ Portal (9)
*   **Step 4:** Admin Portal (9) แสดงผล Dashboard สุขภาพของระบบ (System Health) และประวัติการตรวจสอบให้ Admin (AD) เห็น
*   **Step 5:** Admin (AD) ใช้ Portal (9) ในการสร้างรายงานการปฏิบัติตามกฎหมาย (เช่น PDPA Compliance Reports)

---

## 6. Training Institute View (มุมมองสถาบันฝึกอบรม)

เน้นการยระดับมาตรฐานบุคลากรและการใช้ข้อมูลเพื่อพัฒนาหลักสูตรให้ตรงกับความต้องการของตลาด

```mermaid
%%{init: { 'theme': 'base', 'themeVariables': { 'darkMode': false, 'background': '#ffffff', 'mainBkg': '#ffffff', 'primaryColor': '#ffffff', 'primaryTextColor': '#000000', 'primaryBorderColor': '#000000', 'lineColor': '#000000', 'secondaryColor': '#ffffff', 'tertiaryColor': '#ffffff', 'actorBkg': '#ffffff', 'actorTextColor': '#000000', 'actorLineColor': '#000000', 'participantBkg': '#ffffff', 'participantTextColor': '#000000', 'participantBorderColor': '#000000', 'signalColor': '#000000', 'signalTextColor': '#000000', 'labelTextColor': '#000000', 'loopTextColor': '#000000', 'noteBkgColor': '#ffffff', 'noteTextColor': '#000000', 'activationBkgColor': '#ffffff', 'activationBorderColor': '#000000', 'sequenceNumberColor': '#000000' }, 'themeCSS': 'svg { background-color: white !important; background: white !important; } rect, circle, path, line, polygon, .labelBox, .cluster rect, .actor, .participant, .note, .activation { fill: white !important; stroke: black !important; stroke-width: 2px !important; } text, tspan, .loopText, .messageText, .noteText, .sequenceNumber { fill: black !important; color: black !important; font-weight: bold !important; font-size: 14px !important; } .cluster rect { stroke-dasharray: 0 !important; }' } }%%
sequenceDiagram
    autonumber

    box white Training & Certification (การฝึกอบรมและรับรอง)
        actor TI as Training Provider
        participant TI_Int as TI Interface (10)
        participant UM as User Mgmt (1)
        participant MT as Matching (3)
    end

    TI->>TI_Int: Upload graduate certifications
    alt Certification Verification
        TI_Int->>UM: Verify data integrity
        alt Valid Data
            UM->>UM: Update caregiver badges/status
        else Invalid Data
            UM-->>TI: Reject upload with errors
        end
    end
    MT->>TI_Int: Feed market demand statistics
    TI_Int-->>TI: Display required skills in market
    TI->>TI_Int: Adjust curriculum based on data
```

**คำอธิบายทีละขั้นตอน (Step-by-step Explanation):**
*   **Step 1:** สถาบันฝึกอบรม (TI) อัปโหลดข้อมูลการสำเร็จการศึกษาและใบเซอร์ผ่าน TI Interface (10)
*   **Step 2:** TI Interface (10) ตรวจสอบและอัปเดตข้อมูลประวัติผู้ดูแลในระบบ User Mgmt (1) เพื่อยืนยันคุณภาพ
*   **Step 3:** Matching Engine (3) ส่งข้อมูลสถิติความต้องการทักษะในตลาด (Market Demand) กลับไปยัง TI Interface (10)
*   **Step 4:** TI Interface (10) แสดงผลข้อมูลทักษะที่เป็นที่ต้องการของตลาดให้สถาบันฝึกอบรม (TI) ทราบ
*   **Step 5:** สถาบันฝึกอบรม (TI) นำข้อมูลที่ได้รับไปปรับปรุงหลักสูตรการสอน (Curriculum) ให้สอดคล้องกับความต้องการจริงของตลาดแรงงาน

---

## 7. Booking State Machine (สถานะการจอง)

เพื่อความถูกต้องในการเขียนโปรแกรม สถานะย่อยของการจอง (Booking) ถูกกำหนดไว้ดังนี้:

| State | Description | Next Possible State(s) |
| :--- | :--- | :--- |
| `Pending_Payment` | ลูกค้ากดจองแต่ยังไม่ได้ชำระเงิน | `Pending_Acceptance`, `Cancelled` |
| `Pending_Acceptance` | ชำระเงินสำเร็จ ระบบกำลังรอผู้ดูแลกดยืนยันรับงาน | `Confirmed`, `Auto_Rematching`, `Cancelled_Refunded` |
| `Auto_Rematching` | ผู้ดูแลปฏิเสธหรือหมดเวลา ระบบกำลังจับคู่คนใหม่ให้ | `Pending_Acceptance`, `Cancelled_Refunded` |
| `Confirmed` | ผู้ดูแลรับงานแล้ว รอเวลาเริ่มให้บริการ | `In_Progress`, `Cancelled_Refunded` |
| `In_Progress` | ผู้ดูแลกด Check-in และเริ่มให้บริการ | `Awaiting_Final_Approval` |
| `Awaiting_Final_Approval` | ผู้ดูแลกด Check-out และส่งรายงานฉบับสุดท้าย | `Completed`, `Disputed` |
| `Completed` | ลูกค้ากด Approve รายงานและระบบโอน Payout สำเร็จ | - |
| `Cancelled_Refunded` | การจองถูกยกเลิกและระบบคืนเงินให้ลูกค้าเรียบร้อย | - |
| `Disputed` | เกิดข้อพิพาทระหว่างลูกค้าและผู้ดูแล (รอดำเนินการโดย Operator) | `Completed`, `Cancelled_Refunded` |

---

## 8. Notification Matrix (ตารางการแจ้งเตือน)

กำหนดประเภทและช่องทางการแจ้งเตือนสำหรับ Event สำคัญใน Workflow:

| Event | Target | Channel | Content / Purpose |
| :--- | :--- | :--- | :--- |
| **New Job Request** | Caregiver | Push | แจ้งเตือนงานใหม่และรายละเอียดเบื้องต้น |
| **Payment Success** | Customer | Email / Push | ยืนยันการชำระเงินและส่ง E-Receipt |
| **Booking Confirmed** | Customer | Push | แจ้งว่าผู้ดูแลตอบรับงานแล้ว |
| **Check-in/Out** | Customer | Push | แจ้งสถานะการเริ่มและจบงานของผู้ดูแล |
| **Real-time Report** | Customer | Push | แจ้งเตือนเมื่อมีบันทึกกิจกรรมใหม่ใน Care Report |
| **Approval Required**| Customer | Push / SMS | แจ้งให้ลูกค้าตรวจสอบรายงานฉบับสุดท้ายเพื่อปิดงาน |
| **Payout Success** | Caregiver | Push | แจ้งเตือนเมื่อเงินค่าตอบแทนถูกโอนเข้าบัญชี |
| **Auto-Rematch Alert**| Customer | Push | แจ้งว่าระบบกำลังหาคนใหม่ให้กรณีคนเดิมไม่ว่าง |
| **Refund Processed** | Customer | Email | แจ้งยืนยันการคืนเงินสำเร็จ |


นี่คือข้อมูลสรุป Design System ของ **CareDee** ในรูปแบบ Markdown ที่คุณสามารถนำไปใช้งานต่อได้ทันทีครับ

---

# 🎨 CareDee Design System Foundation (2026)

เอกสารนี้รวบรวมองค์ประกอบพื้นฐานด้านการออกแบบของ CareDee เพื่อสร้างความสม่ำเสมอและประสบการณ์ที่ดีแก่ผู้ใช้งาน โดยเฉพาะกลุ่มผู้สูงอายุและครอบครัว

---

## 1. Colors (ระบบสี)

### **Brand Colors (สีหลักของแบรนด์)**

สะท้อนตัวตนที่เป็นกึ่งการแพทย์แต่เข้าถึงง่าย และให้ความรู้สึกอบอุ่นเหมือนคนในครอบครัว

| Name | Hex Code | Description |
| --- | --- | --- |
| **Primary 600** | `#007A8C` | สีเขียวอมฟ้า (Teal) หลักของแบรนด์ |
| **Primary 100** | `#E0F2F4` | สีเขียวอมฟ้าอ่อน สำหรับพื้นหลังหรือองค์ประกอบรอง |
| **Secondary 500** | `#FF9F43` | สีส้มสะท้อนความอบอุ่น |
| **Secondary 100** | `#FFF3E6` | สีส้มอ่อน |

### **Semantic Colors (สีเชิงความหมาย)**

สื่อสารสถานะต่างๆ ของระบบ

| Status | Hex Code | usage |
| --- | --- | --- |
| **Success** | `#28C76F` | การจองสำเร็จ, การดำเนินการเสร็จสิ้น |
| **Warning** | `#FF9F43` | ข้อควรระวัง, การแจ้งเตือน |
| **Error** | `#EA5455` | ข้อผิดพลาด, การปฏิเสธ |
| **Info** | `#00CFE8` | ข้อมูลทั่วไป |

### **Neutral Colors (สีกลาง)**

เน้นค่า Contrast ที่อ่านง่ายเป็นพิเศษสำหรับผู้สูงอายุ

| Name | Hex Code | Usage |
| --- | --- | --- |
| **White** | `#FFFFFF` | พื้นหลังหลัก |
| **Neutral 100** | `#F8F8F8` | พื้นหลังรอง, Surface |
| **Neutral 300** | `#B9B9C3` | เส้นขอบ, ตัวอักษรที่ไม่เน้น |
| **Neutral 600** | `#6E6B7B` | ข้อความรอง (Secondary Text) |
| **Neutral 900** | `#1E1E1E` | ข้อความหลัก (Primary Text / Heading) |

### **Interactive & Surface**

* **Pressed:** `#006675`
* **Surface (Neutral 100):** `#F8F8F8`

---

## 2. Typography (ระบบตัวอักษร)

เราใช้ฟอนต์ที่อ่านง่ายและมีความทันสมัย

* **Thai Typography:** `IBM Plex Sans Thai`
* **English Typography:** `Inter`

### **Display Series (สำหรับหัวข้อขนาดใหญ่)**

| Level | Font Size | Line Height | Letter Spacing |
| --- | --- | --- | --- |
| **Display 2xl** | 72px (4.5rem) | 90px | -2% |
| **Display xl** | 60px (3.75rem) | 72px | -2% |
| **Display lg** | 48px (3.0rem) | 60px | -2% |
| **Display md** | 36px (2.25rem) | 44px | -2% |
| **Display sm** | 30px (1.875rem) | 38px | 0% |
| **Display xs** | 24px (1.5rem) | 32px | 0% |

### **Text Series (สำหรับเนื้อหาทั่วไป)**

| Level | Font Size | Line Height |
| --- | --- | --- |
| **Text xl** | 20px (1.25rem) | 30px |
| **Text lg** | 18px (1.125rem) | 28px |
| **Text md** | 16px (1.0rem) | 24px |
| **Text sm** | 14px (0.875rem) | 20px |
| **Text xs** | 12px (0.75rem) | 18px |

*หมายเหตุ: ทุกระดับรองรับ Weight ทั้ง Regular, Medium, Semibold และ Bold*

---

## 3. Spacing System (ระบบระยะห่าง)

ใช้ระบบ 4px และ 8px Grid เป็นพื้นฐานในการจัดวาง Layout

| Step | Rem | Pixels |
| --- | --- | --- |
| **1** | 0.25rem | 4px |
| **2** | 0.5rem | 8px |
| **3** | 0.75rem | 12px |
| **4** | 1.0rem | 16px |
| **5** | 1.25rem | 20px |
| **6** | 1.5rem | 24px |
| **8** | 2.0rem | 32px |
| **10** | 2.5rem | 40px |
| **12** | 3.0rem | 48px |
| **16** | 4.0rem | 64px |
| **20** | 5.0rem | 80px |
| **24** | 6.0rem | 96px |
| **32** | 8.0rem | 128px |

---

## 4. Design Guidelines in Figma

* **Organization:** ใช้ Headers ในการจัดกลุ่ม Component เพื่อให้ง่ายต่อการค้นหา
* **Documentation:** เพิ่มพื้นที่สำหรับเขียน Notes และบริบท (Context) ของงานดีไซน์เพื่อให้ทีมพัฒนาเข้าใจตรงกัน

---

## 5. Portal Components & Architecture (Single Page Application)

เพื่อให้ Prototype พอร์ทัลมีความทันสมัยและตอบสนองได้รวดเร็วเหมือนแอปพลิเคชันจริง เราใช้สถาปัตยกรรม **SPA** ดังนี้:

### **View Management (การสลับหน้าจอ)**
*   **Logic:** ใช้ CSS `display: none/block` ควบคุมโดยฟังก์ชัน `switchView(id)` หรือ `showPage(id)` ใน JavaScript
*   **Benefits:** รักษา State ของข้อมูล (เช่น ข้อมูลที่คีย์ค้างไว้) และช่วยให้การเปลี่ยนหน้าไม่มีรอยต่อ (Instant Transitions)

### **Safety & Compliance UI Patterns**
*   **Double Confirmation (High Risk):** สำหรับการลบข้อมูล (Delete), ระงับสิทธิ์ (Suspend) หรืออนุมัติการเงิน (Payout) จะมี Modal ยืนยันซ้ำเสมอ พร้อมช่องใส่รหัสผ่าน/PIN จำลอง
*   **Sync Group:** ใน Header จะมีกลุ่มข้อมูล `sync-indicator` (จุดกะพริบ) และ `sync-time` (Timestamp) เพื่อสร้างความเชื่อมั่นว่าข้อมูลที่เห็นเป็นข้อมูลล่าสุด
*   **PDPA Evidence:** ตารางจัดการผู้ใช้ต้องมีคอลัมน์ `Consent Timestamp` เพื่อแสดงความโปร่งใสในการจัดการข้อมูลส่วนบุคคล
*   **Audit Timeline:** การบันทึก Log กิจกรรมสำคัญจะแสดงผลในรูปแบบเส้นเวลา (Vertical Timeline) เพื่อให้แอดมินหรือ Operator ตรวจสอบย้อนหลังได้ง่าย

---

© 2026 CareDee Design Foundation
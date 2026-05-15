# CareDee Design Foundation
> © 2026 CareDee Design Foundation

---

## 🎨 Colors

### Brand Colors (สีหลักของแบรนด์)

สีที่สะท้อนถึงตัวตนของ CareDee คือสีเขียวอมฟ้า (Teal) ที่ให้ความรู้สึกเป็นกึ่งการแพทย์แต่ยังเข้าถึงง่าย และสีส้มอ่อนที่ให้ความรู้สึกอบอุ่นเหมือนคนในครอบครัว

| Token | HEX | Description |
|-------|-----|-------------|
| Primary 600 | `#007A8C` | สีเขียวอมฟ้าหลัก |
| Primary 100 | `#E0F2F4` | สีเขียวอมฟ้าอ่อน |
| Secondary 500 | `#FF9F43` | สีส้มหลัก |
| Secondary 100 | `#FFF3E6` | สีส้มอ่อน |

---

### Semantic Colors (สีเชิงความหมาย)

สีที่สื่อสารสถานะต่างๆ ของระบบ เช่น การจองสำเร็จ หรือแจ้งเตือนข้อผิดพลาด

| Token | HEX | Usage |
|-------|-----|-------|
| Success | `#28C76F` | การดำเนินการสำเร็จ |
| Warning | `#FF9F43` | คำเตือน |
| Error | `#EA5455` | ข้อผิดพลาด |
| Info | `#00CFE8` | ข้อมูลทั่วไป |

---

### Neutral Colors (สีกลางสำหรับพื้นหลังและข้อความ)

เนื่องจาก CareDee ต้องรองรับกลุ่มผู้ใช้ที่เป็นผู้สูงอายุ หรือครอบครัว การใช้ Contrast ของตัวอักษรที่อ่านง่าย จึงสำคัญ

| Token | HEX | Description |
|-------|-----|-------------|
| White | `#FFFFFF` | พื้นหลังสีขาว |
| Neutral 100 | `#F8F8F8` | พื้นหลังอ่อน |
| Neutral 300 | `#B9B9C3` | เส้นขอบ / Placeholder |
| Neutral 600 | `#6E6B7B` | ข้อความรอง |
| Neutral 900 | `#1E1E1E` | ข้อความหลัก |

---

### Interactive & Surface (สีสำหรับการตอบโต้)

| Token | HEX | Usage |
|-------|-----|-------|
| Pressed | `#006675` | สีเมื่อกดปุ่ม |
| Surface | `#F8F8F8` | พื้นผิว Neutral 100 |

---

## 🔤 Typography

### Thai Typography — IBM Plex Sans Thai

```
กขฃคฅฆงจฉชซฌญฎฏฐฒณดตถทธนบปผฝพฟภมยรฤลฦวศษสหฬอฮ
๐๑๒๓๔๕๖๗๘๙ ๆๅ฿
สระ: อะอาอุึอูอิอีอึอือ่อ้อ๊อ๋อ์อำเแโใไ
```

> ตัวอย่าง: นายสังฆภัณฑ์ เฮงพิทักษ์ฝั่ง ผู้เฒ่าซึ่งมีอาชีพเป็นฅนขายฃวด ถูกตำรวจปฏิบัติการจับฟ้องศาล ฐานลักนาฬิกาคุณหญิงฉัตรชฎา ฌานสมาธิ

---

### English Typography — Inter

```
ABCDEFGHIJKLMNOPQRSTUVWXYZ
abcdefghijklmnopqrstuvwxyz
0123456789 !@#$%^&*()
```

---

### Type Scale

#### Display

| Style | Size | Line Height | Letter Spacing | Weights |
|-------|------|-------------|----------------|---------|
| Display 2xl | 72px / 4.5rem | 90px / 5.625rem | -2% | Regular · Medium · Semibold · Bold |
| Display xl | 60px / 3.75rem | 72px / 4.5rem | -2% | Regular · Medium · Semibold · Bold |
| Display lg | 48px / 3rem | 60px / 3.75rem | -2% | Regular · Medium · Semibold · Bold |
| Display md | 36px / 2.25rem | 44px / 2.75rem | -2% | Regular · Medium · Semibold · Bold |
| Display sm | 30px / 1.875rem | 38px / 2.375rem | — | Regular · Medium · Semibold · Bold |
| Display xs | 24px / 1.5rem | 32px / 2rem | — | Regular · Medium · Semibold · Bold |

#### Text

| Style | Size | Line Height | Weights |
|-------|------|-------------|---------|
| Text xl | 20px / 1.25rem | 30px / 1.875rem | Regular · Medium · Semibold · Bold |
| Text lg | 18px / 1.125rem | 28px / 1.75rem | Regular · Medium · Semibold · Bold |
| Text md | 16px / 1rem | 24px / 1.5rem | Regular · Medium · Semibold · Bold |
| Text sm | 14px / 0.875rem | 20px / 1.25rem | Regular · Medium · Semibold · Bold |
| Text xs | 12px / 0.75rem | 18px / 1.125rem | Regular · Medium · Semibold · Bold |

#### Body

| Style | Size | Line Height | Letter Spacing | Weights |
|-------|------|-------------|----------------|---------|
| Body Large | 60px / 3.75rem | 4.625rem | -2% | Regular · Medium · Semibold · Bold |
| Body Base | 60px / 3.75rem | 4.625rem | -2% | Regular · Medium · Semibold · Bold |
| Body Small | 60px / 3.75rem | 4.625rem | -2% | Regular · Medium · Semibold · Bold |

#### Label

| Style | Font | Size | Line Height |
|-------|------|------|-------------|
| Description Small | IBM Plex Sans Thai (400) | 14px | 16px |

---

## 📐 Spacing

ระบบ Spacing อ้างอิงจาก base 16px

| Token | rem | px |
|-------|-----|----|
| 1 | 0.25rem | 4px |
| 2 | 0.5rem | 8px |
| 3 | 0.75rem | 12px |
| 4 | 1rem | 16px |
| 5 | 1.25rem | 20px |
| 6 | 1.5rem | 24px |
| 8 | 2rem | 32px |
| 10 | 2.5rem | 40px |
| 12 | 3rem | 48px |
| 16 | 4rem | 64px |
| 20 | 5rem | 80px |
| 24 | 6rem | 96px |
| 32 | 8rem | 128px |
| 40 | 10rem | 160px |
| 48 | 12rem | 192px |
| 56 | 14rem | 224px |
| 64 | 16rem | 256px |

# Project: CareDee Platform (แพลตฟอร์มแคร์ดี)

CareDee is an end-to-end digital platform designed to connect care seekers (Customers) with qualified caregivers, managed by Service Operators and supported by Training Providers. The platform aims to provide a reliable, transparent, and scalable ecosystem for the care economy in Thailand.

## Core Mandates & Engineering Standards

- **Compliance:** Rigorously adhere to the **Personal Data Protection Act (PDPA)**. Ensure all personal and health-related data is encrypted (Application-level) and handled with explicit consent.
- **Architecture:** Follow a **Modular Architecture** (Presentation, Business Logic, Data layers). Design with future microservices transition in mind.
- **Testing:** Maintain a minimum **Unit Test Coverage of 80%**. Use static code analysis tools as part of the validation process.
- **Security:** Use **TLS 1.3+** for transit and **AES-256** for data at rest. Implement **Two-Factor Authentication (2FA)** for Admin and Operator portals.
- **Inter-Module Communication:** Prefer **RESTful APIs** or **GraphQL**. Direct database access between modules is prohibited.
- **Reliability:** The system must target **99.9% availability**. Implement daily automated backups and a 4-hour disaster recovery plan.
- **Usability:** The interface must be primarily in **Thai**, following Universal Design principles to accommodate elderly users.

## Technology Stack

- **Frontend:**
  - Mobile: Android (11+), iOS (15+).
  - Web: Modern browsers (Chrome, Edge, Safari - latest 3 versions).
- **Backend:** API-based (REST/GraphQL), HTTPS, JWT for authentication.
- **Database:** Relational (e.g., PostgreSQL) with JSONB for semi-structured care reports.
- **Infrastructure:** Cloud-based (SEA region) with auto-scaling and load balancing.

## Key Modules (10 Main Modules)

1. **User Management & Access Control:** Registration, identity verification, login, role-based access control (RBAC), and audit logging.
2. **Marketplace & Search:** Caregiver profiles, availability, and filtering.
3. **Matching Engine:** Intelligent matching based on skills, distance, and ratings.
4. **Booking & Scheduling:** Real-time scheduling, confirmation, and collision prevention.
5. **Payment & Revenue Management:** Secure payment gateway integration, commission deduction, and payouts.
6. **Care Report System:** Digital daily care activity logging with media attachments.
7. **Rating & Review System:** Post-service feedback with content moderation and appeals.
8. **Notification System:** Multi-channel alerts (Push, SMS, Email, LINE).
9. **Operator & Admin Portal:** Workforce management, dashboards, and system audit logs.
10. **Training Institute Interface:** Certification verification and market skill statistics.

## Interaction Guidelines

- When proposing changes, ensure they align with the **Agile Development** cycle described in the SRS.
- Always consider the **three-phase implementation plan**: Pilot, Expansion, and Scale.
- For UI/UX tasks, prioritize accessibility for the elderly and consistency with the "Human Interface Guidelines".
- If a technical decision impacts PDPA or PCI DSS compliance, flag it immediately.

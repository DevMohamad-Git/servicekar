# ServiceKar

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.38+-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?style=for-the-badge&logo=dart)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=for-the-badge)

**🧰 The magical notebook for technicians; managing customers, services, invoices, and debts — even without internet**

</div>

---

## 📋 Table of Contents

### Part 1: Project-Specific

- [Overview](#overview)
- [Key Features](#key-features)
- [Technical Challenges](#technical-challenges)
- [Technical Specifications](#technical-specifications)
- [Database Structure](#database-structure)

### Part 2: Architecture and Coding Standards

- [Project Architecture](#project-architecture)
- [Code Generation](#code-generation)
- [Coding Guidelines](#coding-guidelines)
- [Presentation Layer Rules](#presentation-layer-rules)
- [Naming Conventions](#naming-conventions)
- [Main Packages](#main-packages)

---

# Part 1: Project-Specific

## Overview

**ServiceKar** is a mobile application for mobile technicians — electricians, plumbers, boiler technicians, home appliance repairers, auto mechanics, and more — that manages their workflow from the moment a customer calls to settlement and later follow-ups. This app replaces paper notebooks and forgettable planners, delivering three simple principles:

1. **Fast registration with a few clicks (Quick Select):** Instead of typing long descriptions, technicians define their frequently used services in advance and create an invoice in under 20 seconds.
2. **Red List of Debtors (Debt Tracker):** A prioritized list of customers who have not paid, along with a “polite reminder SMS” button.
3. **Customer Work Memory (Customer History):** By searching a phone number, the full history of previous jobs for that customer is displayed.

> ⚠️ **Note:** This application follows an **Offline-First** approach, and all operations — customer registration, service registration, PDF invoice generation, and debt calculation — are performed without an internet connection. Server connection is only used for cloud backup and online payment links in the paid version.

### Target Users

- Electricians and building electrical technicians
- Plumbers and facility technicians
- Boiler and water heater technicians
- Home appliance repairers — washing machines, dishwashers, refrigerators
- Mobile mechanics and auto repairers
- Air conditioner and HVAC technicians
- Computer and digital equipment repairers
- Home service providers

## Key Features

| Feature | Description |
| --- | --- |
| 🔴 **Red List of Debtors** | Displays debtor customers by priority, with a single button to send a polite reminder SMS — ready-to-use formal text + card number |
| 📞 **Smart Customer Directory** | Customer list with search and tagging — e.g., bad payer, boiler customer, washing machine customer — plus a complete profile for each customer |
| 📜 **Complete Customer History** | View all previous jobs, replaced parts, and technical notes to prevent misunderstandings and unjustified warranty claims |
| 🧾 **PDF Invoice Generation** | Offline generation of a professional PDF invoice immediately after service registration |
| 💰 **Financial Balance Management** | Automatic balance calculation: `Balance = Σ Payments − Σ Invoices` — negative = debtor, zero = settled, positive = creditor |
| 📡 **Fully Offline Functionality** | Database stored on the phone; all calculations and PDF generation are performed without internet |
| 🖐️ **Large and Readable User Interface** | Large buttons and text for use in low light, basements, and boiler rooms |

---

## Technical Challenges

| Challenge | Solution |
| --- | --- |
| **Fully Offline Functionality** | A NoSQL database — Isar/Hive — on the phone as the Single Source of Truth; all calculations and PDF generation are done without a server |
| **One-Way Sync for Backup** | In V1, synchronization is backup-only, not two-way, to avoid the “sync swamp” and prevent loss of technician trust. Local data always has priority |
| **Data Entry Barrier** | Pre-filled databases for different trades — plumbers, electricians, boiler technicians, etc. The app should not be delivered empty |
| **Service Photo Compression** | Before/after repair photos must be compressed before storage to avoid wasting storage space and internet bandwidth |
| **Date Conflict in Service Registration** | A gentle warning if the selected service date is in the future: “The selected date is in the future. Are you sure?” |
| **Zero Invoice — Warranty** | Ability to issue an invoice with a final amount of zero only for history tracking, without generating a payment link |
| **Payment Greater Than Debt** | If a customer pays more than their debt — advance payment/deposit — their balance becomes positive, and it is automatically deducted from the next invoice |

---

## Technical Specifications

| Specification | Requirement |
| --- | --- |
| Android Min SDK | 5.0+ (API 21) |
| iOS Min Version | 12.0+ |
| Local Database | Isar — recommended — or Hive; very fast NoSQL |
| Backend — Optional V1 | Appwrite — only for cloud backup |
| PDF Generation | `pdf` + `printing` packages — fully offline |

---

## Database Structure

The application uses **Isar** — or Hive — as the local NoSQL database. All entities are stored on the phone and are synced with the server only for cloud backup.

### Entities
```text
Customer
─────────────────
id
name
phone (primary mobile number)
phoneLandline (optional)
address
location (geo lat/lng)
tags (e.g., bad payer, boiler customer)
description
createdAt

Service
─────────────────
id
customerId
title (e.g., full service, pump replacement)
description
serviceType (repair/installation/periodic service)
laborCost
partsCost
totalAmount
receivedAmount (cash/card amount received at the moment)
serviceDate
reminderDate (next service reminder, e.g., 6 months)
attachments (before/after photos)
createdAt

Invoice
─────────────────
id
customerId
serviceIds (one or more)
items[{type, title, price, qty}]
totalAmount
discount (percentage or fixed amount)
paidAmount
remainingAmount
status (unpaid / settled / voided)
note (e.g., warranty terms)
pdfPath (path to the generated PDF file)
paymentLink (paid version, nullable)
createdAt
voidedAt (if voided)

Payment
─────────────────
id
invoiceId
amount
method (cash / card-to-card / online)
trackingNumber (optional tracking number)
paymentDate
note

Inventory (Parts — paid version)
─────────────────
id
name
purchasePrice
salePrice
stock

### Relationships

text
Customer
│
│  1:N
│
Service ──────── (one or more) ──────── Invoice
│                                 │
│                                 │  1:N
│                                 │
└───────────────────────────── Payment

### Customer Financial Balance Formula

text
Balance = Σ Payments − Σ Invoices

  Balance < 0  →  Debtor (displayed in red)
  Balance = 0  →  Settled
  Balance > 0  →  Creditor (has credit, deducted from the next invoice)

> ⚠️ **Note:** The local database is always the Single Source of Truth. Server synchronization in V1 is backup-only and one-way, and it is enabled in the paid version.

---

# Part 2: Architecture and Coding Standards

> **This section defines reusable coding standards and architectural patterns.**

## Project Architecture

This project follows **Clean Architecture**, with a dedicated UseCase layer in the Domain layer for each feature. Feature methods are invoked through UseCases, which coordinate repository calls.

text
lib/
├── config/                     # App configuration
│   ├── l10n/                   # Localization files (.arb)
│   ├── routes/                 # Router configuration (auto_route)
│   └── themes/                 # colors.dart, font_sizes.dart, etc.
│
├── core/                       # Core utilities
│   ├── constants/              # Project constants
│   ├── database/               # Database configuration (Isar)
│   ├── enums/                  # Core enums (ServiceType, PaymentMethod, ...)
│   ├── environment/            # Flavors (dev.dart, prod.dart)
│   ├── errors/                 # Global failures
│   ├── extensions/             # Dart extensions
│   ├── interceptors/           # Dio interceptors (paid version)
│   ├── services/               # Core services (PdfService, SyncService, SmsService)
│   ├── usecases/               # Base UseCase interface
│   └── utils/                  # Helpers (app_helper for BottomSheet, Dialog)
│
├── gen/                        # FlutterGen output (fonts, assets)
│
├── injection/                  # Dependency injection
│   ├── global_providers.dart   # Global providers (repositories, data_sources, services)
│   └── feature_injection/      # Providers for each feature
│       └── [feature]_providers.dart
│
├── features/                   # Features (Domain + Data layers)
│   ├── shared/                 # Shared across features
│   │   ├── data/
│   │   ├── domain/
│   │   ├── models/
│   │   └── models/
│   │
│   ├── customer/               # Customer management feature
│   │   ├── data/
│   │   │   ├── data_sources/
│   │   │   │   ├── local/
│   │   │   │   └── model/
│   │   │   │   └── repositories/
│   │   │   └── domain/
│   │   │       ├── entities/
│   │   │       ├── failures/
│   │   │       ├── repositories/
│   │   │       └── usecases/
│   │   │
│   │   ├── service/            # Service registration feature (similar structure to customer)
│   │   ├── invoice/            # Invoice and PDF generation feature
│   │   ├── payment/            # Payment registration and settlement feature
│   │   ├── debt/               # Red list of debtors and follow-up feature
│   │   ├── inventory/          # Mobile inventory feature (paid version)
│   │   └── dashboard/          # Dashboard and financial widgets
│   │
│   └── presentation/               # Presentation layer
│       ├── shared/
│       │   ├── components/         # Reusable UI components
│       │   ├── widgets/            # Shared widgets
│       │   ├── modals/             # Shared bottom sheets
│       │   ├── decorators/         # PageDecorator, BottomSheetDecorator
│       │   └── logic/              # Global Presentation providers (core_providers)
│       │
│       └── [page_name]/
│           ├── pages/              # CustomerListPage, ServiceRegistrationPage, InvoicePage, ...
│           ├── widgets/
│           ├── logic/
│           └── modals/

### Provider Organization

| Provider Location | Scope | Contents |
| --- | --- | --- |
| `injection/global_providers.dart` | Global — all layers | Repositories, DataSources, Services — PdfService, SyncService, SmsService |
| `presentation/shared/logic/core_providers.dart` | Presentation layer only | Shared UI state providers |
| `injection/feature_injection/[feature]_providers.dart` | Feature-specific | Scoped feature providers — UseCases |

---

## Code Generation

Run these commands **only when needed** — after modifying files that require code generation:

bash
# 1. Generate Freezed, Riverpod, AutoRoute, Isar, etc.
dart run build_runner build -d

# 2. Generate localization files
flutter gen-l10n

# 3. Generate assets (fonts, images, etc.)
fluttergen

> ⚠️ **Important:** Do not run `flutter build apk` or `flutter run`. The code generation commands above are the only executable build-related commands.

---

## Coding Guidelines

### Core Principles

| Principle | Description |
| --- | --- |
| **SSoT** | The local database — Isar — is the Single Source of Truth |
| **Single Responsibility** | Each class/function does only one thing |
| **Separation of Concerns** | Clear boundaries between layers |
| **SOLID** | All SOLID principles are applied |
| **Clean Code** | Code must be readable, maintainable, and testable |
| **Offline-First** | All logic runs on the phone; the server is only for backup/payment |

### Function Rules

| Rule | Details |
| --- | --- |
| Single Task | Each function does **only one thing** |
| Parameter Limit | More than 2 parameters → create a parameter model, e.g., `RegisterServiceParams` |
| Naming | Descriptive names are preferred over short names |

dart
// ✅ Correct: one function, one task
Future<void> registerCustomer() async { ... }
Future<void> calculateBalance() async { ... }

// ❌ Wrong: one function, multiple tasks
Future<void> registerCustomerAndCreateInvoice() async { ... }

### Technical Rules

| Rule | Details |
| --- | --- |
| Environment | Use `dev.dart` and `prod.dart` flavors |
| Helpers | Place helper functions in `core/utils/app_helper` |
| Data Classes | **Always** use freezed to create data classes and params classes |
| Riverpod Providers | **Never** use Either as the return type — handle failures internally |
| Either Handling | **Always** use the `.fold()` method — **never** use `isLeft`/`isRight` |
| UseCase Coupling | UseCases **must not** directly call repositories of other features — use that feature’s UseCase instead |
| SMS Service | In the free version, messages are sent via the phone’s GSM capability (`url_launcher`); in the paid version, via a dedicated SMS panel |
| PDF Generation | Always offline using the `pdf` + `printing` packages; `pdfPath` is stored in Invoice |
| Sync | In V1, sync is one-way only — Backup only; local state always has priority |


نکته کوچک: در فهرست مطالب، چند بخش مثل `Presentation Layer Rules`، `Naming Conventions` و `Main Packages` آمده‌اند، اما در محتوای قابل مشاهده فایل تا خط 345 هنوز متن آن‌ها وجود ندارد.
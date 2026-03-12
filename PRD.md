# Product Requirements Document
# Aegis-Vault — Local-First AI Document Intelligence Platform

**Version:** 1.0  
**Status:** Draft  
**Last Updated:** 2026-03-12

---

## Executive Summary

Aegis-Vault is a desktop application that processes, summarizes, and redacts sensitive documents (PDF/DOCX) entirely on local hardware using quantized LLMs. It is designed for mid-sized law firms, CA practices, and private medical clinics operating under strict data privacy regulations (India's DPDP Act, GDPR, HIPAA) that legally prohibit uploading client data to public cloud AI services.

**Core Value Proposition:** "Summarize 100-page case files and redact PII in seconds. 100% offline. Zero risk of DPDP or HIPAA fines."

---

## 1. Problem Statement

Professionals handling sensitive data — lawyers, chartered accountants, and healthcare providers — are legally blocked from using public cloud LLMs. They need the speed of AI but require the security of an air-gapped system. The demand for local-first, privacy-compliant AI is one of the most lucrative bottlenecks in software today.

### Target Market

| Segment | Profile | Why They Buy |
|---|---|---|
| **Primary** | Mid-sized law firms (10–50 staff) | Case file summarization, PII redaction, compliance |
| **Primary** | CA practices (5–20 staff) | Financial document analysis, client data protection |
| **Secondary** | Private medical clinics | Patient record summarization, HIPAA/DPDP compliance |

> **Out of Scope:** Solo practitioners (insufficient budget) and enterprise firms (multi-year sales cycles).

---

## 2. Goals & Success Metrics

| Goal | Metric | Target |
|---|---|---|
| Product-market fit | Paying customers in Month 1 | ≥ 5 firms |
| Retention | Monthly churn rate | < 5% |
| Core performance | Time to summarize 50-page PDF | < 60 seconds |
| Security | Data exfiltration incidents | 0 |
| Revenue | MRR at Month 6 | ₹3,00,000+ |

---

## 3. Tech Stack

### 3.1 Frontend
- **Framework:** Flutter (cross-platform desktop — Windows, macOS)
- **State Management:** Riverpod or Bloc (strict dependency injection)
- **Rationale:** High-performance, aesthetically polished UI; single codebase for all platforms

### 3.2 Backend / Engine
- **Language:** Rust
- **Responsibilities:** PDF/DOCX parsing, text chunking, local LLM orchestration
- **Rationale:** Maximum CPU/GPU efficiency; memory safety; ideal for heavy I/O

### 3.3 AI Engine
- **Runtime:** `llama.cpp` or `candle` Rust bindings
- **Models:** Llama-3-8B-Instruct (`.gguf` quantized) or specialized local Mistral variant
- **Delivery:** Bundled with installer (large) or downloaded on first launch (small installer)

### 3.4 Local Database
- **Option A:** Isar Database (Flutter-native, fast)
- **Option B:** SQLite (widely supported fallback)
- **Scope:** Audit logs, document metadata — **no document content persisted unencrypted**

### 3.5 Bridge
- **Library:** `flutter_rust_bridge` (FFI between Flutter and Rust backend)

### 3.6 Payments & Licensing
- **India:** Razorpay API
- **International:** Stripe
- **License Validation:** Cryptographic key generator with offline validation via locally cached, time-stamped tokens

---

## 4. User Flow

```
Launch App
    │
    ├─ [Internet Available] ──► Ping server, validate license key
    │
    └─ [Offline] ──────────────► Use cached validation token (valid for 30 days)
            │
            ▼
    Dashboard ("The Vault")
    ├─ Recent files
    ├─ Hours saved counter
    ├─ Demo Mode toggle
    └─ Drag-and-drop zone
            │
            ▼
    Document Ingested (PDF / DOCX)
            │
            ▼
    Rust Engine Processing
    ├─ Parse & chunk text
    └─ Pass chunks to local LLM with system prompt
            │
            ▼
    Review Interface
    ├─ Side-by-side: Original vs. Redacted/Summarized
    └─ User approves
            │
            ▼
    Export to Secure PDF
```

---

## 5. Feature Specifications

### 5.1 Authentication & Licensing

- On launch, app checks for valid license key
- **Online:** Pings license server to validate subscription tier
- **Offline:** Falls back to locally cached, cryptographically signed validation token
- Token valid for **30 days** without internet connection
- App locks (read-only mode) if token is expired and no internet is available
- License validation logic implemented in Rust to prevent easy bypassing

### 5.2 Dashboard — "The Vault"

- Drag-and-drop zone for PDF/DOCX files
- Recently processed documents list
- Running total of "Hours Saved" (estimated time vs. manual review)
- Demo Mode toggle (persistent in header/settings)
- Account/subscription status indicator

### 5.3 Demo Mode

| State | Behavior |
|---|---|
| **OFF** | Reads from `LocalDatabaseRepository`; processes real documents |
| **ON** | Instantly swaps to `MockDataRepository`; UI populates with fake "Acme Corp vs. State" legal documents and pre-generated AI summaries |

- Real data must **never** bleed into the UI when Demo Mode is active
- Toggle must be instantaneous — no app restart required
- Enables live demos at client offices without exposing real client data

### 5.4 Document Processing Engine

- **Supported Formats:** PDF, DOCX
- **System Prompt Template (Legal):** `"Extract key arguments and redact all names/addresses."`
- **System Prompt Template (Medical):** `"Summarize clinical findings and redact all patient identifiers."`
- Text chunked and streamed to local LLM asynchronously
- Progress indicator shown during processing

### 5.5 Review & Export Interface

- Side-by-side view: original document (left) vs. processed output (right)
- Redacted content shown as `[REDACTED]` blocks
- User can manually un-redact individual blocks before exporting
- Export to password-protected PDF
- Optional: custom watermarking (Firm tier only)

### 5.6 Audit Log

- Every document processed is logged locally: filename, timestamp, action type, processing duration
- Log is non-editable (append-only)
- Can be exported as CSV for compliance reporting

---

## 6. Data Layer Architecture

```
DocumentRepository (interface)
        │
        ├── LocalDatabaseRepository
        │       └── Reads/writes to Isar or SQLite
        │
        └── MockDataRepository
                └── Returns hardcoded fake legal/CA documents
                    and pre-generated AI summaries
```

- A global `isDemoMode` boolean controls which repository is injected at runtime
- The UI is **repository-agnostic** — it only interacts with the `DocumentRepository` interface
- Switching `isDemoMode` triggers an instant, seamless UI state reset

---

## 7. Pricing

| Tier | Price | Features |
|---|---|---|
| **Pro** | ₹4,999 / month | Unlimited local processing, standard legal & CA models, single device |
| **Firm** | ₹14,999 / month | Up to 5 devices, priority model updates, custom watermarking, priority support |

### License Heartbeat Mechanism

1. User purchases via web portal (Next.js + Razorpay/Stripe)
2. Receives a unique License Key
3. Desktop app requires internet **once every 30 days** to validate key and pull model updates
4. Between validations, the app runs fully offline using a cached signed token

---

## 8. Development Batches

### Batch 1 — Core Architecture & State
- Set up Flutter desktop project
- Integrate Rust backend via `flutter_rust_bridge`
- Initialize Isar/SQLite
- Implement `DocumentRepository` interface and both implementations (`LocalDatabaseRepository`, `MockDataRepository`)
- Wire `isDemoMode` toggle to swap repositories without restart

### Batch 2 — Rust LLM Engine
- Build Rust functions to parse PDFs and DOCX files
- Implement text chunking pipeline
- Initialize and query a local `.gguf` model (`llama.cpp` or `candle`)
- Stream generated responses back to Flutter asynchronously

### Batch 3 — Flutter UI & Bridge
- Connect Flutter UI to Rust backend via bridge
- Build drag-and-drop document ingestion interface
- Implement loading/progress states
- Build side-by-side document review viewer

### Batch 4 — Demo Mode & Mocking
- Hardcode mock data assets (fake legal cases, CA documents, AI summaries)
- Wire Demo Mode toggle to instantly clear UI state and load `MockDataRepository`
- Validate that real data is completely isolated when Demo Mode is active

### Batch 5 — Licensing & Security
- Build lightweight web frontend for purchase flow (Next.js)
- Integrate Razorpay (India) and Stripe (international)
- Implement Rust-based cryptographic license key validation
- Build 30-day offline token caching and expiry logic
- Expose license status to Flutter for UI locking

### Batch 6 — Optimization & Packaging
- Performance profiling and LLM inference optimization
- Package for Windows and macOS with code signing
- Implement model weight bundler or first-launch downloader
- Final QA pass: edge cases, large files, GPU vs. CPU fallback

---

## 9. Security Requirements

| Requirement | Implementation |
|---|---|
| No data leaves the device | All LLM inference runs locally; no cloud API calls during document processing |
| Encrypted local storage | Audit logs and metadata encrypted at rest using platform keychain |
| License validation hardened | Rust-based cryptographic check; not bypassable by editing config files |
| Demo/real data isolation | `MockDataRepository` is a fully separate code path; no shared state with real data layer |
| Exported PDFs | Password protection option on all exports |

---

## 10. Go-to-Market

- **Channel:** LinkedIn outreach targeting "Managing Partners" and "Principal CAs" in major hubs (Kolkata, Mumbai, Delhi)
- **Conversion tactic:** Offer a live, offline demo on the prospect's own test documents at their office — proving no data ever leaves their machine
- **Proof points:** DPDP Act compliance, HIPAA alignment, zero cloud dependency

---

## 11. Out of Scope (v1.0)

- Cloud sync or backup of processed documents
- Web or mobile versions
- Multi-language document support
- Integration with case management systems (e.g., Clio, MyCase)
- Collaborative review (multi-user editing of redacted output)

---

*Document Owner: Product Team | Next Review: Prior to Batch 1 kickoff*
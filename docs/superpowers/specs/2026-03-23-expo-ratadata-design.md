# Ratadata Expo MVP — Design Spec

## Goal

Deploy Ratadata shooting log app to a physical phone without Apple Developer Program ($99/yr). Uses Expo + EAS to build and install directly via Expo Go or development build.

## Scope

**MVP feature parity with the native iOS app:**
- Session CRUD with all fields (date, type, sport type, role, shots, weather, results, hit factor, comp score, distance, notes)
- Weapon CRUD (name, type, caliber, ERVA, purchase date, notes)
- Range CRUD (name, address, coordinates, website, phone, notes)
- Instructor management (select existing or create new)
- Shot counter with quick-add buttons (+10, +25, +50, +100, reset)
- Sport type mapping per weapon type
- Drawn signature capture
- Photo import (no video in v1)
- PDF diary export with signature images
- Dashboard with hero card, stats, quick actions, recent sessions
- Statistics (cumulative shots, monthly volume, hit factor trend, comp scores, sessions by type, per-weapon breakdown, range usage)
- Finnish UI throughout

**Not in MVP:**
- Video import
- Cloud sync / backup (future)
- Android-specific polish

## Architecture

### Tech Stack
- **Framework:** Expo SDK 53 + Expo Router (file-based routing)
- **Database:** expo-sqlite with Drizzle ORM (type-safe, migration-friendly)
- **State:** React Context for DB provider, local component state for forms
- **Charts:** react-native-chart-kit or victory-native
- **Signature:** react-native-signature-canvas
- **PDF:** expo-print (HTML-to-PDF)
- **Photos:** expo-image-picker
- **Maps:** react-native-maps (range location picker)
- **Storage:** expo-file-system (photos on disk, filenames in DB)

### File Structure
```
mobile-app/
├── app/
│   ├── _layout.tsx                 # Root layout (DB provider, fonts)
│   ├── (tabs)/
│   │   ├── _layout.tsx             # Tab bar (5 tabs)
│   │   ├── index.tsx               # Dashboard
│   │   ├── diary.tsx               # Session list
│   │   ├── weapons.tsx             # Weapon list
│   │   ├── ranges.tsx              # Range list
│   │   └── stats.tsx               # Statistics
│   ├── sessions/
│   │   ├── [id].tsx                # Session detail
│   │   └── form.tsx                # Session create/edit form
│   ├── weapons/
│   │   ├── [id].tsx                # Weapon detail
│   │   └── form.tsx                # Weapon form
│   └── ranges/
│       ├── [id].tsx                # Range detail
│       └── form.tsx                # Range form
├── db/
│   ├── schema.ts                   # Drizzle table definitions
│   ├── client.ts                   # SQLite connection + migrations
│   └── queries.ts                  # Typed query helpers
├── components/
│   ├── ui/                         # Generic UI (cards, buttons, badges)
│   ├── charts/                     # Chart components
│   ├── SignatureCapture.tsx         # Signature drawing modal
│   └── PDFExport.tsx               # PDF generation logic
├── constants/
│   ├── Colors.ts                   # Theme colors (matches iOS app)
│   ├── SportTypeMapping.ts         # Weapon type → sport types
│   └── Enums.ts                    # SessionType, SessionRole, WeaponType
└── lib/
    ├── dateFormatters.ts           # Finnish date formatting
    └── mediaStorage.ts             # Photo save/load/delete helpers
```

### Database Schema (Drizzle + SQLite)

Tables mirror the SwiftData models:
- **weapons**: id, name, type, caliber, erva, purchaseDate, notes, createdAt, updatedAt
- **shooting_ranges**: id, name, address, latitude, longitude, website, phoneNumber, notes, createdAt, updatedAt
- **instructors**: id, name, createdAt
- **sessions**: id, date, numberOfShotsFired, type, sportType, role, weather, result, hitFactor, compScore, distanceToTarget, notes, signature (base64), instructorName, weaponId (FK), rangeId (FK), instructorId (FK), createdAt, updatedAt
- **session_photos**: id, sessionId (FK), fileName, createdAt

### PDF Export

Uses `expo-print` to render an HTML template to PDF. The HTML template replicates the current A4 landscape layout:
- Logo header with filter summary
- Column table: Date, Type, Weapon, Shots, Instructor, Signature
- Signature images embedded as base64 data URIs
- Finnish text throughout

### Signature Capture

Full-screen modal using `react-native-signature-canvas`:
- Landscape orientation via expo-screen-orientation
- Clear / Save / Cancel buttons
- Exports as base64 PNG, stored in session record
- Displayed in session detail and embedded in PDF

### Theme

Matches the iOS app exactly:
- Primary: #667EEA → #764BA2
- Accent: #F093FB → #F5576C
- Success: #11998E → #38EF7D
- Warning: #F2994A → #F2C94C
- Danger: #EB3349 → #F45C43
- Session type colors and weapon type colors carry over

## Deployment

1. `npx expo install` — install dependencies
2. `npx expo start` — dev server, scan QR with Expo Go on phone
3. For full native features: `npx eas build --profile development --platform ios` → install dev build
4. No Apple Developer account needed for Expo Go testing
5. For distribution without App Store: EAS internal distribution or ad-hoc builds

## Out of Scope

- Unit/integration tests (future)
- Android polish
- Cloud backup/sync
- Video import
- Web deployment

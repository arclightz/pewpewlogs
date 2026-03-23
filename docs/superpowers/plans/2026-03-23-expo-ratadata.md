# Ratadata Expo MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a deployable Expo React Native version of the Ratadata shooting log app with full feature parity (sessions, weapons, ranges, instructors, signature capture, PDF export, statistics).

**Architecture:** File-based routing with Expo Router, local SQLite database via expo-sqlite with Drizzle ORM, React Context for database access, and HTML-to-PDF export via expo-print.

**Tech Stack:** Expo SDK 53, TypeScript, expo-sqlite, Drizzle ORM, expo-router, expo-print, expo-image-picker, react-native-signature-canvas, react-native-chart-kit, expo-screen-orientation

**Spec:** `docs/superpowers/specs/2026-03-23-expo-ratadata-design.md`

---

## File Structure

```
mobile-app/
├── app/
│   ├── _layout.tsx                    # Root layout — DB provider, fonts, Stack
│   ├── (tabs)/
│   │   ├── _layout.tsx                # Bottom tab bar (5 tabs)
│   │   ├── index.tsx                  # Dashboard screen
│   │   ├── diary.tsx                  # Session list screen
│   │   ├── weapons.tsx                # Weapon list screen
│   │   ├── ranges.tsx                 # Range list screen
│   │   └── stats.tsx                  # Statistics screen
│   ├── sessions/
│   │   ├── [id].tsx                   # Session detail screen
│   │   └── form.tsx                   # Session create/edit form
│   ├── weapons/
│   │   ├── [id].tsx                   # Weapon detail screen
│   │   └── form.tsx                   # Weapon create/edit form
│   └── ranges/
│       ├── [id].tsx                   # Range detail screen
│       └── form.tsx                   # Range create/edit form
├── db/
│   ├── schema.ts                      # Drizzle table definitions
│   ├── client.ts                      # SQLite connection + migration runner
│   └── queries.ts                     # CRUD query helpers (typed)
├── components/
│   ├── ui/
│   │   ├── Card.tsx                   # Glass-style card wrapper
│   │   ├── GradientButton.tsx         # Primary action button
│   │   ├── Badge.tsx                  # Colored badge/tag
│   │   ├── StatCard.tsx               # Summary stat card (gradient bg)
│   │   ├── SectionHeader.tsx          # Icon + title header
│   │   ├── DetailRow.tsx              # Label-value row for detail screens
│   │   └── EmptyState.tsx             # Empty state placeholder
│   ├── charts/
│   │   ├── CumulativeShotsChart.tsx   # Line chart — total shots over time
│   │   ├── MonthlyShotsChart.tsx      # Bar chart — shots per month
│   │   ├── HitFactorChart.tsx         # Line chart — HF trend
│   │   ├── CompScoreChart.tsx         # Line chart — competition scores
│   │   └── SessionTypeChart.tsx       # Pie/donut — sessions by type
│   ├── SignatureCapture.tsx           # Full-screen signature modal
│   └── PDFExport.tsx                  # HTML template + expo-print logic
├── constants/
│   ├── Colors.ts                      # Theme colors (update existing)
│   ├── Theme.ts                       # Gradients, shadows, radii
│   ├── Enums.ts                       # SessionType, SessionRole, WeaponType
│   └── SportTypeMapping.ts            # Weapon type → sport types map
├── context/
│   └── DatabaseContext.tsx             # React Context providing DB instance
├── lib/
│   ├── dateFormatters.ts              # Finnish locale date formatting
│   └── mediaStorage.ts               # Photo save/load/delete via expo-file-system
└── assets/
    └── images/
        ├── ratadata.png               # Full logo (copy from static_assets)
        └── ratadata_logo.png          # Shield-only icon
```

---

### Task 1: Install Dependencies and Configure Project

**Files:**
- Modify: `mobile-app/package.json`
- Modify: `mobile-app/app.json`
- Create: `mobile-app/assets/images/ratadata.png` (copy)
- Create: `mobile-app/assets/images/ratadata_logo.png` (copy)

- [ ] **Step 1: Install required packages**

Run in `mobile-app/` directory:
- expo install: expo-sqlite expo-image-picker expo-print expo-sharing expo-file-system expo-screen-orientation expo-linear-gradient
- npm install: drizzle-orm react-native-signature-canvas react-native-chart-kit react-native-svg
- npm install -D: drizzle-kit

- [ ] **Step 2: Update app.json**

Set name to "Ratadata", slug to "ratadata", orientation to "default", icon to ratadata.png, scheme to "ratadata". Add bundleIdentifier "com.ratadata.app". Add plugins: expo-router, expo-sqlite, expo-screen-orientation, expo-splash-screen (with black bg and shield logo), expo-image-picker (with Finnish permission text).

- [ ] **Step 3: Copy logo assets from static_assets/**

Copy `ratadata.png` and `ratadata_logo.png` to `assets/images/`.

- [ ] **Step 4: Verify project starts**

Run `npx expo start` and confirm dev server starts without errors.

- [ ] **Step 5: Commit**

Message: `chore: configure Expo project for Ratadata with dependencies`

---

### Task 2: Constants — Enums, Colors, Theme, Sport Type Mapping

**Files:**
- Create: `mobile-app/constants/Enums.ts`
- Create: `mobile-app/constants/Theme.ts`
- Create: `mobile-app/constants/SportTypeMapping.ts`
- Modify: `mobile-app/constants/Colors.ts`

- [ ] **Step 1: Create Enums.ts**

Port all enums from the Swift app. Use `as const` objects with Finnish labels:
- SessionType: kilpailu, harjoitus, harjoituskilpailu, kuivaharjoittelu, seuranViikkokisa, valmennus, muuMerkinta
- SessionRole: ampuja, valmentaja, rataAmmunnanJohtaja, tuomari, radanrakentaja, muuRooli
- WeaponType: pistooli, kivaari, haulikko, revolveri, pcc, ilmaAse, deaktivoitu, muu, yhdistelmaase, merkinantoase, kaasuase

Export key and value types for each.

- [ ] **Step 2: Create SportTypeMapping.ts**

Port the full weapon-type-to-sport-types mapping from `ios/PewPewLogs/Ratadata/Utilities/SportTypeMapping.swift`. Export a `getSportTypes(weaponType)` function.

- [ ] **Step 3: Update Colors.ts and create Theme.ts**

Colors.ts: primary (#667EEA), primaryEnd (#764BA2), accent (#F093FB), accentEnd (#F5576C), success (#11998E), successEnd (#38EF7D), warning (#F2994A), warningEnd (#F2C94C), danger (#EB3349), dangerEnd (#F45C43). Plus light/dark scheme colors, sessionType color map, weaponType color map.

Theme.ts: cardRadius (16), badgeRadius (8), smallRadius (10), cardShadow style object.

- [ ] **Step 4: Commit**

Message: `feat: add enums, colors, theme, and sport type mapping constants`

---

### Task 3: Database Schema and Client

**Files:**
- Create: `mobile-app/db/schema.ts`
- Create: `mobile-app/db/client.ts`
- Create: `mobile-app/db/queries.ts`
- Create: `mobile-app/context/DatabaseContext.tsx`

- [ ] **Step 1: Create Drizzle schema (db/schema.ts)**

Tables: weapons, shooting_ranges, instructors, sessions, session_photos. Use sqliteTable from drizzle-orm/sqlite-core. Sessions has foreign keys to weapons, shooting_ranges, instructors. session_photos has FK to sessions with cascade delete. All tables have createdAt/updatedAt as ISO text.

- [ ] **Step 2: Create database client (db/client.ts)**

Open database with expo-sqlite openDatabaseSync('ratadata.db'). Enable WAL and foreign keys. Create drizzle instance. Export a runMigrations() function that runs CREATE TABLE IF NOT EXISTS for all tables.

- [ ] **Step 3: Create query helpers (db/queries.ts)**

Export typed CRUD functions for each table: getAll, getById, insert, update, delete. Plus `findOrCreateInstructor(name)` helper. Export inferred Select types for each table.

- [ ] **Step 4: Create DatabaseContext (context/DatabaseContext.tsx)**

React Context that runs migrations on mount and exposes a `ready` boolean. Children render only after migrations complete.

- [ ] **Step 5: Commit**

Message: `feat: add SQLite database schema, client, queries, and context provider`

---

### Task 4: Utility Libraries

**Files:**
- Create: `mobile-app/lib/dateFormatters.ts`
- Create: `mobile-app/lib/mediaStorage.ts`

- [ ] **Step 1: Create Finnish date formatters**

Functions: shortDate ("23.3.2026"), longDate ("23. maaliskuuta 2026"), monthYear ("maaliskuu 2026"), shortMonthDay ("23 maalis"), toISODate (Date to "YYYY-MM-DD"), parseDate (ISO string to Date). Use Finnish month names.

- [ ] **Step 2: Create media storage helpers**

Uses expo-file-system. Functions: ensureMediaDir(), savePhoto(uri) returns fileName, getPhotoUri(fileName) returns full path, deleteMedia(fileNames[]).

- [ ] **Step 3: Commit**

Message: `feat: add Finnish date formatters and media storage helpers`

---

### Task 5: Reusable UI Components

**Files:**
- Create: `mobile-app/components/ui/Card.tsx`
- Create: `mobile-app/components/ui/GradientButton.tsx`
- Create: `mobile-app/components/ui/Badge.tsx`
- Create: `mobile-app/components/ui/StatCard.tsx`
- Create: `mobile-app/components/ui/SectionHeader.tsx`
- Create: `mobile-app/components/ui/DetailRow.tsx`
- Create: `mobile-app/components/ui/EmptyState.tsx`

- [ ] **Step 1: Create all UI components**

Match iOS app visual style using Colors and Theme constants. Support light/dark mode via useColorScheme.
- Card: rounded-corner view with shadow and semi-transparent background
- GradientButton: full-width button with LinearGradient background (expo-linear-gradient)
- Badge: small colored tag with rounded corners
- StatCard: compact card with gradient bg, icon, value, label
- SectionHeader: icon + title row
- DetailRow: icon + label + value horizontal row
- EmptyState: centered icon + title + subtitle + optional action button

- [ ] **Step 2: Commit**

Message: `feat: add reusable UI components (Card, Badge, StatCard, etc.)`

---

### Task 6: Root Layout and Tab Navigation

**Files:**
- Modify: `mobile-app/app/_layout.tsx`
- Modify: `mobile-app/app/(tabs)/_layout.tsx`
- Create: `mobile-app/app/(tabs)/diary.tsx` (placeholder)
- Create: `mobile-app/app/(tabs)/weapons.tsx` (placeholder)
- Create: `mobile-app/app/(tabs)/ranges.tsx` (placeholder)
- Create: `mobile-app/app/(tabs)/stats.tsx` (placeholder)
- Modify: `mobile-app/app/(tabs)/index.tsx` (placeholder dashboard)
- Delete: `mobile-app/app/(tabs)/explore.tsx`
- Delete: `mobile-app/components/HelloWave.tsx`
- Delete: `mobile-app/components/ParallaxScrollView.tsx`

- [ ] **Step 1: Update root layout with DatabaseProvider**

Wrap app in DatabaseProvider. Add Stack screens for: (tabs), sessions/[id], sessions/form, weapons/[id], weapons/form, ranges/[id], ranges/form.

- [ ] **Step 2: Update tab layout with 5 tabs**

Tabs: Etusivu (home-outline/home), Päiväkirja (book-outline/book), Aseet (shield-outline/shield), Radat (location-outline/location), Tilastot (stats-chart-outline/stats-chart). Use Ionicons from @expo/vector-icons. Tint: #667EEA.

- [ ] **Step 3: Create placeholder screens and delete starter content**

Each tab renders a centered title text. Remove explore.tsx, HelloWave.tsx, ParallaxScrollView.tsx.

- [ ] **Step 4: Verify all 5 tabs render**

- [ ] **Step 5: Commit**

Message: `feat: set up 5-tab navigation with DatabaseProvider`

---

### Task 7: Weapon CRUD (List, Detail, Form)

**Files:**
- Modify: `mobile-app/app/(tabs)/weapons.tsx`
- Create: `mobile-app/app/weapons/[id].tsx`
- Create: `mobile-app/app/weapons/form.tsx`

- [ ] **Step 1: Build weapon list screen**

FlatList of weapons from DB. Each row: name, type badge (colored), caliber. Search bar. Empty state when no weapons. Header button to add (navigates to form). Tap navigates to detail.

- [ ] **Step 2: Build weapon detail screen**

Hero header with weapon type color. Cards: basic info (name, type, caliber, ERVA), additional (purchase date, notes), usage (session count query), metadata. Edit/delete buttons.

- [ ] **Step 3: Build weapon form screen**

Fields: name (required, TextInput), type (picker/dropdown from WeaponType enum), caliber, ERVA toggle (Switch), purchase date (date picker), notes. Save disabled until name filled. Receives `id` search param for edit mode (loads existing data).

- [ ] **Step 4: Verify full CRUD flow**

- [ ] **Step 5: Commit**

Message: `feat: add weapon list, detail, and form screens`

---

### Task 8: Range CRUD (List, Detail, Form)

**Files:**
- Modify: `mobile-app/app/(tabs)/ranges.tsx`
- Create: `mobile-app/app/ranges/[id].tsx`
- Create: `mobile-app/app/ranges/form.tsx`

- [ ] **Step 1: Build range list, detail, and form**

Same pattern as weapons. List: name + address. Detail: info card (name, address, lat/lng display, website, phone), usage stats, metadata. Form: name (required), address, lat, lng, website, phone, notes. No interactive map in v1.

- [ ] **Step 2: Verify full CRUD flow**

- [ ] **Step 3: Commit**

Message: `feat: add range list, detail, and form screens`

---

### Task 9: Signature Capture Component

**Files:**
- Create: `mobile-app/components/SignatureCapture.tsx`

- [ ] **Step 1: Build signature capture modal**

Full-screen Modal using react-native-signature-canvas. Lock to landscape via expo-screen-orientation on open, restore portrait on close. Three buttons: Tyhjennä (clear canvas), Peruuta (cancel, dismiss), Tallenna (export base64 PNG, pass via onSave callback, dismiss). White canvas background, black ink.

- [ ] **Step 2: Test signature capture**

May require dev build if react-native-signature-canvas uses native modules not in Expo Go.

- [ ] **Step 3: Commit**

Message: `feat: add signature capture modal with landscape orientation`

---

### Task 10: Session CRUD (List, Detail, Form)

**Files:**
- Modify: `mobile-app/app/(tabs)/diary.tsx`
- Create: `mobile-app/app/sessions/[id].tsx`
- Create: `mobile-app/app/sessions/form.tsx`

- [ ] **Step 1: Build session form**

Most complex screen. Sections:
1. Mandatory: date picker, range picker (from DB), type picker (SessionType), weapon picker (from DB), sport type picker (filtered by weapon via SportTypeMapping), shot counter (TextInput + quick-add buttons +10/+25/+50/+100 + reset), role picker, weather input
2. Optional (collapsible): result, hit factor, comp score, distance, notes
3. Instructor: dropdown of existing + text input for new
4. Signature: button opens SignatureCapture, preview of captured, delete button
5. Photos: expo-image-picker button, thumbnail previews with delete
6. Submit: disabled until valid (weapon + range + sport type + min shots)

On save: findOrCreateInstructor, insert/update session, save photos, navigate back.

- [ ] **Step 2: Build session list**

SectionList grouped by monthYear. Each row: sport type title, date, type badge, shot count, weapon name. Search. Header export button + add button.

- [ ] **Step 3: Build session detail**

Hero header (session type gradient). Cards: basic info, weapon/range/instructor, optional fields, signature image, photo gallery (horizontal ScrollView), metadata. Edit/delete in header.

- [ ] **Step 4: Verify full session CRUD with signature and photos**

- [ ] **Step 5: Commit**

Message: `feat: add session list, detail, and form with signature and photos`

---

### Task 11: PDF Export

**Files:**
- Create: `mobile-app/components/PDFExport.tsx`
- Modify: `mobile-app/app/(tabs)/diary.tsx` (add export UI)

- [ ] **Step 1: Build PDF HTML template and generation**

Function that takes sessions array and returns HTML string for A4 landscape PDF:
- Header: base64-encoded shield logo, "Ratadata Ampumapäiväkirja", subtitle, date, count, filter summary
- Table: Pvm, Tyyppi, Ase, Lauk., Ohjaaja/valvoja, Allekirjoitus columns
- Signatures as base64 img tags
- Alternating row colors, blue header
- CSS page-break rules

Use expo-print printToFileAsync, then expo-sharing shareAsync.

- [ ] **Step 2: Add export button and filter modal to diary**

Export button in header. Bottom sheet/modal: date range toggle + pickers, weapon filter, instructor filter. Preview count. Generate + share.

- [ ] **Step 3: Verify PDF output**

- [ ] **Step 4: Commit**

Message: `feat: add PDF diary export with filters and signature images`

---

### Task 12: Dashboard Screen

**Files:**
- Modify: `mobile-app/app/(tabs)/index.tsx`

- [ ] **Step 1: Build dashboard**

1. Hero card: logo (100pt), welcome text, total shots badge, gradient bg
2. Stats row: 3 StatCards (sessions, weapons, ranges)
3. Quick actions: 3 rows linking to session/weapon/range forms
4. Recent sessions: last 3, with type stripe, date, sport type, shots, weapon

Shield logo in header.

- [ ] **Step 2: Verify with and without data**

- [ ] **Step 3: Commit**

Message: `feat: add dashboard with hero card, stats, quick actions, recent sessions`

---

### Task 13: Statistics Screen

**Files:**
- Modify: `mobile-app/app/(tabs)/stats.tsx`
- Create: `mobile-app/components/charts/CumulativeShotsChart.tsx`
- Create: `mobile-app/components/charts/MonthlyShotsChart.tsx`
- Create: `mobile-app/components/charts/HitFactorChart.tsx`
- Create: `mobile-app/components/charts/CompScoreChart.tsx`
- Create: `mobile-app/components/charts/SessionTypeChart.tsx`

- [ ] **Step 1: Build chart components**

Using react-native-chart-kit + react-native-svg:
- CumulativeShotsChart: LineChart with fill — cumulative shots
- MonthlyShotsChart: BarChart — shots per month
- HitFactorChart: LineChart with dots — HF trend over time
- CompScoreChart: LineChart — comp score % trend
- SessionTypeChart: colored legend list with proportional bars (avoid complex pie dependency)

- [ ] **Step 2: Build statistics screen**

Sections: 3 summary StatCards, cumulative shots, monthly volume, HF trend (if data exists), comp scores (if data), sessions by type, per-weapon ranked list, range usage bars.

- [ ] **Step 3: Verify charts render**

- [ ] **Step 4: Commit**

Message: `feat: add statistics screen with charts and analytics`

---

### Task 14: Final Polish and Testing

- [ ] **Step 1: End-to-end test**

Full flow: launch, create weapon, create range, create session (with signature + photos), view diary, view detail, export PDF, check statistics.

- [ ] **Step 2: Fix any issues**

- [ ] **Step 3: Test on physical device via Expo Go**

Note features requiring dev build.

- [ ] **Step 4: Final commit**

Message: `feat: complete Ratadata Expo MVP`

# PLAN: Rewrite PewPewLogs as a Standalone Native iOS App

## 1. Current Architecture Analysis

### What Exists Today
The current PewPewLogs is a **3-tier client-server application**:

| Layer | Technology | Description |
|-------|-----------|-------------|
| **Frontend** | Vue.js 3 + Vite + Tailwind CSS | SPA with router, composables, Leaflet maps |
| **Backend** | Node.js + Express.js | REST API with JWT auth, Mongoose ODM |
| **Database** | MongoDB 4.4 | Document store via Docker |
| **Mobile (WIP)** | Expo/React Native | Scaffold only – wraps web in a WebView, not functional |
| **Infra** | Docker Compose + Traefik | Reverse proxy with Let's Encrypt TLS |

### Data Model (4 entities)

```
User
├── id, name, email, password (bcrypt), createdAt

Weapon (belongs to User)
├── id, userId, name, type (enum), caliber, erva (bool), purchaseDate, notes
├── types: Pistooli, Kivääri, Haulikko, Revolveri, PCC, Ilma-ase, Deaktivoitu, Muu, Yhdistelmäase, Merkinantoase, Kaasuase

ShootingRange (belongs to User)
├── id, userId, name, address, location (GeoJSON Point [lng, lat]), notes, website, phoneNumber

Session (belongs to User, references Weapon & ShootingRange)
├── id, userId, date, range (ref), weapon (ref), numberOfShotsFired
├── type (enum: Kilpailu, Harjoitus, Harjoituskilpailu, Kuivaharjoittelu, Seuran viikkokisa, Valmennus, Muu merkintä)
├── sportType (string – dynamically filtered by weapon type), role (enum), weather
├── Optional: result, hitFactor, compScore, distanceToTarget, notes, photos[], signature
```

### Features Inventory
1. **Auth**: Register, Login, JWT token management, auto-logout on 401
2. **Dashboard**: Welcome screen with navigation cards
3. **Sessions (Päiväkirja)**: List (table + cards), expandable detail rows, create form with:
   - Weapon-type → sport-type cascading dropdown
   - Quick-add shot buttons (+10/+25/+50/+100)
   - "Save as template" (re-populates form)
   - Mandatory/optional field sections (collapsible)
4. **Weapons (Aseet)**: List, create form with Finnish enums
5. **Shooting Ranges (Ampumaradat)**: List with Leaflet mini-maps, create with:
   - Nominatim geocoding search
   - Interactive map (click/drag marker)
   - Reverse geocoding
6. **Statistics**: Overall stats (total sessions, shots, accuracy), per-weapon breakdown
7. **User Profile**: Account info, session/weapon counts, time since last session
8. **UI**: Dark theme, responsive (desktop table + mobile cards), bottom nav bar (mobile), sidebar (desktop)
9. **Planned (not implemented)**: Photo upload, signature drawing, progress graphs, data export, practice reminders

### Language
- UI text is **Finnish** throughout (labels, enums, validation messages)

---

## 2. Target Architecture: Standalone Native iOS App

### Technology Recommendation

| Concern | Recommendation | Rationale |
|---------|---------------|-----------|
| **Language** | Swift | First-class iOS citizen, best performance, full API access |
| **UI Framework** | SwiftUI | Modern declarative UI, native animations, Dark Mode support out of the box |
| **Min iOS Target** | iOS 17+ | Enables latest SwiftUI features (Observable macro, SwiftData, MapKit improvements) |
| **Architecture** | MVVM + Repository pattern | Clean separation, testable, standard Swift community pattern |
| **Navigation** | SwiftUI NavigationStack + TabView | Native tab bar + push navigation |

### Storage Recommendation: **SwiftData** (over raw SQLite or Core Data)

| Option | Pros | Cons | Verdict |
|--------|------|------|---------|
| **SwiftData** | Apple-native, Swift macros, zero boilerplate, Codable-like, CloudKit-ready, built on Core Data/SQLite | iOS 17+ only | ✅ **Recommended** |
| **GRDB.swift** (raw SQLite) | Full SQL control, lightweight, no Apple lock-in | More boilerplate, manual migrations | Good alternative if iOS 16 support needed |
| **Core Data** | Mature, powerful | Verbose, legacy API feel | Superseded by SwiftData |
| **Realm** | Easy, cross-platform | 3rd party dependency, MongoDB acquisition uncertainty | Not recommended |

**SwiftData is the best choice** because:
- Zero-config SQLite under the hood with full ACID compliance
- `@Model` macro gives you ORM-like syntax with native Swift types
- Built-in CloudKit sync capability for future multi-device/backup
- Automatic lightweight migrations
- Perfect integration with SwiftUI's `@Query` property wrapper

---

## 3. Data Model (SwiftData)

```swift
@Model class User {
    var name: String
    var email: String
    var passwordHash: String  // bcrypt via CryptoKit or swift-bcrypt
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade) var weapons: [Weapon]
    @Relationship(deleteRule: .cascade) var sessions: [Session]
    @Relationship(deleteRule: .cascade) var ranges: [ShootingRange]
}

@Model class Weapon {
    var name: String
    var type: WeaponType          // enum: Pistooli, Kivääri, etc.
    var caliber: String?
    var erva: Bool
    var purchaseDate: Date?
    var notes: String?
    var user: User?
    
    @Relationship(deleteRule: .nullify) var sessions: [Session]
}

@Model class ShootingRange {
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var notes: String?
    var website: String?
    var phoneNumber: String?
    var user: User?
    
    @Relationship(deleteRule: .nullify) var sessions: [Session]
}

@Model class Session {
    var date: Date
    var numberOfShotsFired: Int
    var type: SessionType          // enum
    var sportType: String
    var role: SessionRole          // enum
    var weather: String?
    var result: String?
    var hitFactor: Double?
    var compScore: Double?
    var distanceToTarget: Double?
    var notes: String?
    var photos: [Data]             // stored as image data blobs
    var signature: Data?           // stored as image data
    
    var weapon: Weapon?
    var range: ShootingRange?
    var user: User?
}
```

---

## 4. App Screen Map & Navigation

```
TabView (5 tabs)
├── 🏠 Dashboard (Etusivu)
│   └── Welcome message, quick-action cards → navigate to other tabs
│
├── 📋 Sessions (Päiväkirja)
│   ├── SessionListView — searchable, filterable list
│   │   ├── SessionDetailView — full session info (push)
│   │   └── SessionFormView — create/edit (sheet or push)
│   └── FAB → SessionFormView
│
├── 🔫 Weapons (Aseet)
│   ├── WeaponListView — list with type badges
│   │   └── WeaponDetailView (push)
│   └── FAB → WeaponFormView (sheet)
│
├── 🎯 Ranges (Ampumaradat)
│   ├── RangeListView — list with mini MapKit previews
│   │   └── RangeDetailView — full map + details (push)
│   └── FAB → RangeFormView (sheet) with MapKit + geocoding
│
├── 📊 Statistics (Tilastot)
│   ├── OverallStatsView — cards with totals
│   ├── PerWeaponStatsView — breakdown table
│   └── ProgressChartsView — Swift Charts (line, bar)
│
└── (More / Profile accessible via toolbar or Settings)
    ├── ProfileView — account info, counts
    ├── SettingsView — (future: export, reminders, CloudKit toggle)
    └── Login/Register (shown only when not authenticated)
```

---

## 5. Implementation Phases

### Phase 0: Project Setup (Day 1)
- [ ] Create Xcode project with SwiftUI App lifecycle
- [ ] Set up folder structure: `Models/`, `Views/`, `ViewModels/`, `Services/`, `Utilities/`
- [ ] Configure SwiftData `ModelContainer` in `@main App`
- [ ] Define all SwiftData `@Model` classes and enums
- [ ] Set up a `PreviewSampleData` container for SwiftUI previews
- [ ] Add app icon and launch screen assets

### Phase 1: Auth & User Management (Days 2–3)
- [ ] Implement `User` model with secure password storage (Keychain for credentials, or simplified single-user mode)
- [ ] Build `LoginView` and `RegisterView` (SwiftUI forms)
- [ ] Implement `AuthService` with Keychain token storage
- [ ] Add `@AppStorage`-based session persistence (auto-login)
- [ ] Gate all tabs behind authentication state

> **Design Decision — Single-user vs Multi-user:**  
> Since this is a **standalone** iOS app (no server), consider a **single-user** model where the app simply uses biometric auth (Face ID / Touch ID) or a PIN for privacy, with no registration flow. This is simpler and more native-feeling. The `User` data can be stored in Keychain. Multi-user registration makes more sense only if future CloudKit sharing is planned.  
> **Recommendation: Start with single-user + optional biometric lock.**

### Phase 2: Weapons CRUD (Days 3–4)
- [ ] `WeaponListView` with `@Query` sorted by name
- [ ] `WeaponFormView` (create + edit mode) with picker for `WeaponType` enum
- [ ] Swipe-to-delete with confirmation
- [ ] Search/filter by type
- [ ] Preview providers with sample data

### Phase 3: Shooting Ranges CRUD (Days 4–6)
- [ ] `RangeListView` with `@Query`, mini `Map` previews per row
- [ ] `RangeFormView` with:
  - MapKit `Map` with draggable annotation
  - `MKLocalSearch` for address lookup (replaces Nominatim)
  - Reverse geocoding via `CLGeocoder`
  - Current location via `CLLocationManager`
- [ ] `RangeDetailView` with full-size interactive map
- [ ] Swipe-to-delete

### Phase 4: Sessions CRUD (Days 6–9) — Core Feature
- [ ] `SessionListView` with `@Query`, grouped by month, searchable
- [ ] `SessionFormView`:
  - Date picker (Finnish locale)
  - Range picker (NavigationLink to picker or inline)
  - Weapon picker with type-based sport filtering (same cascading logic)
  - Quick-add shot stepper buttons (+10, +25, +50, +100)
  - Collapsible "optional fields" section
  - "Save as template" → store last-used values in `@AppStorage`
- [ ] `SessionDetailView` with all fields rendered
- [ ] Swipe-to-delete, edit via toolbar button

### Phase 5: Statistics (Days 9–11)
- [ ] `StatsView` with computed aggregates from `@Query`:
  - Total sessions, total shots, accuracy %
  - Per-weapon breakdown (table)
- [ ] Swift Charts integration:
  - Shots over time (line chart)
  - Sessions per month (bar chart)
  - Accuracy trend
- [ ] Filter by date range, weapon, sport type

### Phase 6: Profile & Settings (Day 11)
- [ ] `ProfileView`: name, email, session count, weapon count, days since last session
- [ ] `SettingsView`:
  - Biometric lock toggle
  - Data export (CSV via `ShareLink`)
  - About / version info

### Phase 7: Polish & Advanced Features (Days 12–14)
- [ ] Photo attachment for sessions (camera + photo library via `PhotosPicker`)
- [ ] Signature drawing canvas (`Canvas` view + `PKCanvasView` from PencilKit)
- [ ] Haptic feedback on key actions
- [ ] Empty state illustrations
- [ ] Accessibility audit (VoiceOver labels, Dynamic Type)
- [ ] Dark/Light mode verification (should be automatic with SwiftUI)
- [ ] App Store metadata prep

---

## 6. Key Technical Decisions

### Maps: MapKit (not Leaflet)
- Native iOS `Map` view with `Annotation` markers
- `MKLocalSearch` for address autocomplete (replaces Nominatim)
- `CLGeocoder` for reverse geocoding
- No third-party dependency needed

### Charts: Swift Charts
- Built into iOS 16+, native performance
- `BarMark`, `LineMark`, `PointMark` for all statistics visualizations

### Image Storage
- Photos stored as `Data` blobs in SwiftData (for simplicity)
- Alternatively, save to app's documents directory and store file paths
- **Recommendation**: Store thumbnails in SwiftData, full images on disk

### Localization
- All UI strings in Finnish (hardcoded initially)
- Structure with `String(localized:)` for future i18n support
- Finnish date formatting via `Locale(identifier: "fi_FI")`

### Auth for Standalone App
- No JWT or server auth needed
- Use **LocalAuthentication** framework (Face ID / Touch ID)
- Store user profile in SwiftData
- Optional PIN code fallback

---

## 7. Folder Structure

```
PewPewLogs/
├── PewPewLogsApp.swift              // @main, ModelContainer setup
├── Models/
│   ├── User.swift
│   ├── Weapon.swift
│   ├── ShootingRange.swift
│   ├── Session.swift
│   └── Enums/
│       ├── WeaponType.swift
│       ├── SessionType.swift
│       └── SessionRole.swift
├── Views/
│   ├── ContentView.swift            // TabView root
│   ├── Dashboard/
│   │   └── DashboardView.swift
│   ├── Sessions/
│   │   ├── SessionListView.swift
│   │   ├── SessionDetailView.swift
│   │   └── SessionFormView.swift
│   ├── Weapons/
│   │   ├── WeaponListView.swift
│   │   ├── WeaponDetailView.swift
│   │   └── WeaponFormView.swift
│   ├── Ranges/
│   │   ├── RangeListView.swift
│   │   ├── RangeDetailView.swift
│   │   └── RangeFormView.swift
│   ├── Statistics/
│   │   └── StatisticsView.swift
│   ├── Profile/
│   │   ├── ProfileView.swift
│   │   └── SettingsView.swift
│   └── Auth/
│       ├── LoginView.swift
│       └── RegisterView.swift
├── ViewModels/
│   ├── SessionViewModel.swift
│   ├── WeaponViewModel.swift
│   ├── RangeViewModel.swift
│   └── StatisticsViewModel.swift
├── Services/
│   ├── AuthService.swift            // Biometric + Keychain
│   ├── LocationService.swift        // CLLocationManager wrapper
│   └── ExportService.swift          // CSV/PDF generation
├── Utilities/
│   ├── SportTypeMapping.swift       // Weapon type → sport types
│   ├── DateFormatters.swift
│   └── PreviewSampleData.swift
├── Assets.xcassets/
└── Info.plist
```

---

## 8. Migration Path (Data Import)

For users with existing data in MongoDB:
1. Build a one-time **JSON export** endpoint in the current backend: `GET /api/export/all`
2. iOS app has an "Import Data" feature in Settings that:
   - Accepts a `.json` file via Files app / Share Sheet
   - Parses and inserts into SwiftData
3. Mapping: MongoDB `_id` → SwiftData auto-generated `PersistentIdentifier`

---

## 9. What Gets Dropped / Changed

| Current Feature | iOS App Equivalent |
|----------------|-------------------|
| Backend API server | **Eliminated** — all data local |
| MongoDB | **Replaced** by SwiftData (SQLite) |
| JWT authentication | **Replaced** by Face ID / Touch ID |
| Docker / Traefik | **Eliminated** |
| Leaflet maps | **Replaced** by native MapKit |
| Nominatim geocoding | **Replaced** by MKLocalSearch + CLGeocoder |
| Vue.js / Tailwind | **Replaced** by SwiftUI |
| Expo/React Native scaffold | **Eliminated** |
| SSO (Google, Facebook, GitHub) | **Dropped** (standalone app, no server) |

---

## 10. Estimated Timeline

| Phase | Description | Duration |
|-------|------------|----------|
| 0 | Project setup, models, previews | 1 day |
| 1 | Auth (biometric) | 1–2 days |
| 2 | Weapons CRUD | 1–2 days |
| 3 | Shooting Ranges + MapKit | 2–3 days |
| 4 | Sessions CRUD (core) | 3–4 days |
| 5 | Statistics + Charts | 2–3 days |
| 6 | Profile & Settings | 1 day |
| 7 | Polish, photos, export | 2–3 days |
| **Total** | | **~14–19 days** |

---

## 11. Open Questions for You

1. **Single-user or multi-user?** Recommend single-user with biometric lock. Server-less means no user accounts needed. Agree?
2. **CloudKit sync?** SwiftData supports iCloud sync with minimal code. Want this for multi-device support?
3. **Minimum iOS version?** iOS 17 recommended (for SwiftData + latest SwiftUI). iOS 16 possible but would require Core Data instead.
4. **Data migration?** Do you have existing production data in MongoDB that needs to be imported?
5. **App Store distribution?** Or personal/TestFlight only?
6. **Photo storage**: Inline in database (simple, limited) or file system (scalable)? Recommend hybrid: thumbnails in DB, originals on disk.

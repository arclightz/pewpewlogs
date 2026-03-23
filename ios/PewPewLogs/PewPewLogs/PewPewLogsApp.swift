import SwiftUI
import SwiftData

@main
struct PewPewLogsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Weapon.self,
            ShootingRange.self,
            Session.self,
        ])
    }
}

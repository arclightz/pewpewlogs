import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Etusivu", systemImage: "house.fill")
                }

            NavigationStack {
                SessionListView()
            }
            .tabItem {
                Label("Päiväkirja", systemImage: "book.fill")
            }

            NavigationStack {
                WeaponListView()
            }
            .tabItem {
                Label("Aseet", systemImage: "target")
            }

            NavigationStack {
                RangeListView()
            }
            .tabItem {
                Label("Radat", systemImage: "mappin.and.ellipse")
            }

            NavigationStack {
                StatisticsView()
            }
            .tabItem {
                Label("Tilastot", systemImage: "chart.bar.fill")
            }
        }
        .tint(Color(hex: "667EEA"))
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewSampleData.container)
}

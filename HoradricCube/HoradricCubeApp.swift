import SwiftUI
import SwiftData

@main
struct HoradricCubeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Gem.self)
    }
}

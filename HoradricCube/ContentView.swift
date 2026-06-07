import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        CubeView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Gem.self, inMemory: true)
}

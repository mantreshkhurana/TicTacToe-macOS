import SwiftUI

@main
struct TicTacToeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 612, height: 612)
        }
        .defaultSize(width: 612, height: 612)
        .windowResizability(.contentSize) // Prevent resizing
    }
}

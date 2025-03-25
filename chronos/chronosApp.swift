import SwiftUI
import SwiftData

@main
struct chronosApp: App {
    // Create a shared ModelContainer for the app
    let container: ModelContainer
    
    init() {
        #if DEBUG
        // Add macOS injection bundle loading
        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/macOSInjection.bundle")?.load()
        #endif
        
        do {
            // Initialize container with both Task and CalendarEvent models
            let schema = Schema([Task.self, CalendarEvent.self])
            let config = ModelConfiguration("chronos")
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Inject the container into the environment
                .modelContainer(container)
        }
    }
}

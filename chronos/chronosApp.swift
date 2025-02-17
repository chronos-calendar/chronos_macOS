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
            // Initialize container with Task model
            container = try ModelContainer(for: Task.self)
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

// End of file. No additional code.

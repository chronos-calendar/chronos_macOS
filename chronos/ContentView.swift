import SwiftUI
import SwiftData
import Inject

struct ContentView: View {
//    @ObserveInjection var inject

    var body: some View {
        NavigationView {
            TaskListView()
            
            Text("daddy chill")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
//        .enableInjection()

    }

}

#Preview {
    ContentView()
        .modelContainer(for: Task.self)
}

// End of file. No additional code.

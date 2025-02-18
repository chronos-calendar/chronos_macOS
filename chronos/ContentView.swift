import SwiftUI
import SwiftData
import Inject

struct ContentView: View {
    @ObserveInjection var inject

    var body: some View {
        HSplitView {
            
            VStack{
                TabsView()
                TaskListView()
                    .background(Color.white)
                

            }
                        Text("wait it works now")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .enableInjection()
        .background(Color.white)

    }


}

#Preview {
    ContentView()
        .modelContainer(for: Task.self)
}

// End of file. No additional code.

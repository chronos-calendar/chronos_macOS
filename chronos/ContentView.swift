import SwiftUI
import SwiftData
import Inject

struct ContentView: View {
    
    @ObserveInjection var inject
    @State private var selectedGroup: TaskGroup = .all

    var body: some View {
        HSplitView {
            VStack{
                TabsView(selectedTab: $selectedGroup)
                    .padding(.top, 20)
                TaskListView(selectedGroup: selectedGroup)
                    .background(Color.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            

        }
        .enableInjection()
        .background(Color.white)
        .onChange(of: selectedGroup) { newValue in
            print("Selected group changed to: \(newValue)")
        }
    }
}
//#Preview {
//    ContentView()
//        .modelContainer(for: Task.self)
//}

// End of file. No additional code.

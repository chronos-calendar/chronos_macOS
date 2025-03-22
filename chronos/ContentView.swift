import SwiftUI
import SwiftData
import Inject
import MijickCalendarView

struct ContentView: View {
    @ObserveInjection var inject
    @State private var selectedGroup: TaskGroup = .all
    @State private var selectedDate: Date? = nil
    @State private var selectedRange: MDateRange? = .init()

    var body: some View {
        HSplitView {
            // First pane - task list
            VStack {
                TabsView(selectedTab: $selectedGroup)
                    .padding(.top, 20)
                TaskListView(selectedGroup: selectedGroup)
                    .background(Color.white)

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            
            // Second pane - calendar view
//            MacOSCalendarView(selectedDate: $selectedDate)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color.white)
        }
        .enableInjection()
        .background(Color.white)
    }
}

#Preview {
    ContentView()
}


import SwiftUI
import SwiftData
import Inject

struct ContentView: View {
    @ObserveInjection var inject
    @State private var selectedGroup: TaskGroup = .all
    @State private var selectedDate: Date? = nil
    
    // Sample events for demonstration - you'll want to replace this with actual data from SwiftData
    @State private var events: [CalendarEvent] = [
        CalendarEvent(title: "Team Meeting", startTime: Date(), endTime: Date().addingTimeInterval(3600), isCompleted: false, type: .meeting),
        CalendarEvent(title: "Project Deadline", startTime: Date().addingTimeInterval(86400), endTime: Date().addingTimeInterval(90000), isCompleted: false, type: .deadline),
        CalendarEvent(title: "Review Code", startTime: Date().addingTimeInterval(172800), endTime: Date().addingTimeInterval(180000), isCompleted: false, type: .task)
    ]
    
    var body: some View {
        HSplitView {
            // First pane - task list (fixed width)
            VStack {
                TabsView(selectedTab: $selectedGroup)
                    .padding(.top, 20)
                TaskListView(selectedGroup: selectedGroup)
                    .frame(width: 300) 
                    .background(Color.white)
            }
            .frame(maxHeight: .infinity)
            .background(Color.white)
            
            // Second pane - Monthly Calendar (flexible width)
            VStack(alignment: .leading) {
                Text("Calendar")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .padding(.leading, 16)
                
                MonthlyCalendar(events: events)
                    .padding(16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
        .enableInjection()
        .background(Color.white)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Task.self, CalendarEvent.self])
}

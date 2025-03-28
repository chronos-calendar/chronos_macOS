import SwiftUI
import SwiftData
import Inject

struct ContentView: View {
    @ObserveInjection var inject
    @State private var selectedGroup: TaskGroup = .all
    @State private var selectedDate: Date? = nil
    @State private var showEventModal = false
    
    // Sample events for demonstration - you'll want to replace this with actual data from SwiftData
    @State private var events: [CalendarEvent] = [
        CalendarEvent(title: "Team Meeting", startTime: Date(), endTime: Date().addingTimeInterval(3600), isCompleted: false, type: .meeting),
        CalendarEvent(title: "Project Deadline", startTime: Date().addingTimeInterval(86400), endTime: Date().addingTimeInterval(90000), isCompleted: false, type: .deadline),
        CalendarEvent(title: "Review Code", startTime: Date().addingTimeInterval(172800), endTime: Date().addingTimeInterval(180000), isCompleted: false, type: .task)
    ]
    
    var body: some View {
        ZStack {
            HSplitView {
                // First pane - task list (resizable)
                VStack {
                    TabsView(selectedTab: $selectedGroup)
                    TaskListView(selectedGroup: selectedGroup)
                }
                .frame(maxHeight: .infinity)
                .background(Color(NSColor(red: 248/255, green: 247/255, blue: 242/255, alpha: 1)))

                
                // Second pane - Calendar (flexible width)
                CalendarView(events: events)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(NSColor(red: 248/255, green: 247/255, blue: 242/255, alpha: 1)))
            }
            .enableInjection()
            .background(Color(NSColor(red: 248/255, green: 247/255, blue: 242/255, alpha: 1)))
            
            if showEventModal {
                EventModal()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Task.self, CalendarEvent.self])
}

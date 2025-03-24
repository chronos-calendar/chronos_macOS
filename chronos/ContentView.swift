import SwiftUI
import SwiftData
import Inject

struct ContentView: View {
    @ObserveInjection var inject
    @State private var selectedGroup: TaskGroup = .all
    @State private var selectedDate: Date? = nil
    
    @State private var events: [CalendarEvent] = [
        CalendarEvent(title: "Team Meeting", startTime: Date(), endTime: Date().addingTimeInterval(3600), isCompleted: false, type: .meeting),
        CalendarEvent(title: "Project Deadline", startTime: Date().addingTimeInterval(86400), endTime: Date().addingTimeInterval(90000), isCompleted: false, type: .deadline),
        CalendarEvent(title: "Review Code", startTime: Date().addingTimeInterval(172800), endTime: Date().addingTimeInterval(180000), isCompleted: false, type: .task)
    ]
    
    private let taskListWidth: CGFloat = 300
    private let minCalendarWidth: CGFloat = 500
    
    var body: some View {
        HSplitView {
            VStack {
                TabsView(selectedTab: $selectedGroup)
                    .padding(.top, 20)
                TaskListView(selectedGroup: selectedGroup)
                    .frame(width: taskListWidth)
                    .background(Color.white)
            }
            .frame(maxHeight: .infinity)
            .background(Color.white)
            
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 1)
            
            VStack(alignment: .leading) {
                Text("Calendar")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .padding(.leading, 16)
                
                MonthlyCalendar(events: events)
                    .padding(16)
            }
            .frame(minWidth: minCalendarWidth, maxHeight: .infinity)
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

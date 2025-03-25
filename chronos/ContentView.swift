import SwiftUI
import SwiftData
import Inject

struct ContentView: View {
    @ObserveInjection var inject
    @State private var selectedGroup: TaskGroup = .all
    @State private var selectedDate: Date? = nil
    @State private var sidebarWidth: CGFloat = 300
    @State private var isDragging = false
    
    @State private var events: [CalendarEvent] = [
        CalendarEvent(title: "Team Meeting", startTime: Date(), endTime: Date().addingTimeInterval(3600), isCompleted: false, type: .meeting),
        CalendarEvent(title: "Project Deadline", startTime: Date().addingTimeInterval(86400), endTime: Date().addingTimeInterval(90000), isCompleted: false, type: .deadline),
        CalendarEvent(title: "Review Code", startTime: Date().addingTimeInterval(172800), endTime: Date().addingTimeInterval(180000), isCompleted: false, type: .task)
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar with task list
            VStack {
                TabsView(selectedTab: $selectedGroup)
                    .padding(.top, 20)
                TaskListView(selectedGroup: selectedGroup)
                    .frame(width: sidebarWidth)
                    .background(Color.white)
            }
            .frame(maxHeight: .infinity)
            .background(Color.white)
            
            // Resizable divider
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 1)
                .overlay(
                    Rectangle()
                        .fill(isDragging ? .blue.opacity(0.5) : .clear)
                        .frame(width: 8)
                        .contentShape(Rectangle())
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            isDragging = true
                            let newWidth = sidebarWidth + value.translation.width
                            sidebarWidth = min(max(200, newWidth), 400)
                        }
                        .onEnded { _ in
                            isDragging = false
                        }
                )
            
            // Calendar view
            VStack(alignment: .leading) {
                Text("Calendar")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .padding(.leading, 16)
                
                MonthlyCalendar(events: events)
                    .padding(16)
            }
            .frame(minWidth: 500, maxHeight: .infinity)
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

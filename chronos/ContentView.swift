import SwiftUI
import SwiftData
import Inject

struct ContentView: View {
    @ObserveInjection var inject
    @State private var selectedGroup: TaskGroup = .all
    @State private var selectedDate: Date? = nil
    @State private var sidebarWidth: CGFloat = 300
    @State private var isDragging = false
    
    // Sample events for demonstration - you'll want to replace this with actual data from SwiftData
    @State private var events: [CalendarEvent] = [
        CalendarEvent(title: "Team Meeting", startTime: Date(), endTime: Date().addingTimeInterval(3600), isCompleted: false, type: .meeting),
        CalendarEvent(title: "Project Deadline", startTime: Date().addingTimeInterval(86400), endTime: Date().addingTimeInterval(90000), isCompleted: false, type: .deadline),
        CalendarEvent(title: "Review Code", startTime: Date().addingTimeInterval(172800), endTime: Date().addingTimeInterval(180000), isCompleted: false, type: .task)
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            // First pane - task list (resizable)
            VStack {
                TabsView(selectedTab: $selectedGroup)
                TaskListView(selectedGroup: selectedGroup)
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
            
            // Second pane - Calendar (flexible width)
            CalendarView(events: events)
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

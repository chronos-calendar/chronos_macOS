import SwiftUI
import SwiftData
import Inject

struct ContentView: View {
    @ObserveInjection var inject
    @State private var selectedGroup: TaskGroup = .all
    @State private var selectedDate: Date? = nil
    @State private var showingEventModal = false
    
    @State private var events: [CalendarEvent] = [
        CalendarEvent(title: "Team Meeting", startTime: Date(), endTime: Date().addingTimeInterval(3600), isCompleted: false, type: .meeting),
        CalendarEvent(title: "Project Deadline", startTime: Date().addingTimeInterval(86400), endTime: Date().addingTimeInterval(90000), isCompleted: false, type: .deadline),
        CalendarEvent(title: "Review Code", startTime: Date().addingTimeInterval(172800), endTime: Date().addingTimeInterval(180000), isCompleted: false, type: .task)
    ]
    
    var body: some View {
        ZStack {
            HSplitView {
                VStack {
                    TabsView(selectedTab: $selectedGroup)
                    TaskListView(selectedGroup: selectedGroup)
                }
                .frame(maxHeight: .infinity)

                CalendarView(
                    events: events,
                    onDateSelected: {
                        showingEventModal = true
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .enableInjection()
            
            if showingEventModal {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showingEventModal = false
                    }
                
                EventModal()
                    .frame(width: 460)
                    .background(.white)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .padding()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Task.self, CalendarEvent.self])
}

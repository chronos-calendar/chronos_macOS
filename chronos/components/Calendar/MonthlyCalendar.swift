import SwiftUI
import MijickCalendarView
import SwiftData

struct MonthlyCalendar: View {
    @State private var selectedDate: Date? = Date()
    @State private var selectedRange: MDateRange? = nil
    let events: [CalendarEvent]
    
    var body: some View {
        MCalendarView(selectedDate: $selectedDate, selectedRange: $selectedRange, configBuilder: configureCalendar)
    }
    
    private func configureCalendar(_ config: CalendarConfig) -> CalendarConfig {
        config
            .daysHorizontalSpacing(8)
            .daysVerticalSpacing(8)
            .monthsBottomPadding(16)
            .monthsTopPadding(16)
            .dayView { date, isCurrentMonth, selectedDate, selectedRange in
                CustomDayView(
                    date: date,
                    isCurrentMonth: isCurrentMonth,
                    selectedDate: selectedDate,
                    selectedRange: selectedRange,
                    events: eventsForDate(date)
                )
            }
    }
    
    private func eventsForDate(_ date: Date) -> [CalendarEvent] {
        return events.filter { event in
            Calendar.current.isDate(event.startTime, inSameDayAs: date)
        }
    }
}

// Custom day view that integrates with the existing DayCell component
struct CustomDayView: DayView {
    let date: Date
    let isCurrentMonth: Bool
    let selectedDate: Binding<Date?>?
    let selectedRange: Binding<MDateRange?>?
    let events: [CalendarEvent]
    
    func createContent() -> AnyView {
        DayCell(date: date, events: events)
            .opacity(isCurrentMonth ? 1.0 : 0.4)
            .erased()
    }
}

// Extension to convert any View to AnyView (required by MijickCalendarView)
extension View {
    func erased() -> AnyView {
        AnyView(self)
    }
}

#Preview {
    MonthlyCalendar(
        events: [
            CalendarEvent(title: "Team Meeting", startTime: Date(), endTime: Date().addingTimeInterval(3600), isCompleted: false, type: .meeting),
            CalendarEvent(title: "Project Deadline", startTime: Date().addingTimeInterval(86400), endTime: Date().addingTimeInterval(90000), isCompleted: false, type: .deadline)
        ]
    )
}

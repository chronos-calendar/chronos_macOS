import SwiftUI
import SwiftData

// MARK: - Main Calendar View
struct MonthlyCalendar: View {
    // MARK: - Properties
    @State private var selectedDate: Date = Date()
    @State private var scrollOffset: CGFloat = 0
    @State private var currentMonthDate: Date = Date()
    
    // Calendar data source
    let events: [CalendarEvent]
    
    // Customization options
    var showMonthHeader: Bool = true
    var showWeekdayHeader: Bool = true
    var startDayOfWeek: Int = 1 // 1 = Monday, 7 = Sunday
    
    // Calendar configuration
    private let calendar = Calendar.current
    private let startDate = Calendar.current.date(byAdding: .month, value: -24, to: Date())! // 2 years in past
    private let endDate = Calendar.current.date(byAdding: .month, value: 60, to: Date())! // 5 years in future
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            let cellWidth = geometry.size.width / 7
            let cellHeight = cellWidth // Square cells
            
            VStack(spacing: 0) {
                // Month header (optional)
                if showMonthHeader {
                    CalendarMonthHeader(
                        currentMonthDate: $currentMonthDate,
                        onPreviousMonth: previousMonth,
                        onNextMonth: nextMonth
                    )
                }
                
                // Weekday header (optional)
                if showWeekdayHeader {
                    CalendarWeekdayHeader(
                        startDayOfWeek: startDayOfWeek,
                        cellWidth: cellWidth
                    )
                }
                
                // Calendar grid
                MonthCalendarGridView(
                    selectedDate: $selectedDate,
                    scrollOffset: $scrollOffset,
                    startDate: startDate,
                    endDate: endDate,
                    events: events,
                    cellWidth: cellWidth,
                    cellHeight: cellHeight
                )
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
        }
    }
    
    // MARK: - Methods
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentMonthDate) {
            currentMonthDate = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentMonthDate) {
            currentMonthDate = newDate
        }
    }
}



// MARK: - Preference Key for Scroll Tracking
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

// MARK: - Preview
#Preview {
    MonthlyCalendar(
        events: [
            CalendarEvent(title: "Team Meeting", startTime: Date(), endTime: Date().addingTimeInterval(3600), isCompleted: false, type: .meeting),
            CalendarEvent(title: "Project Deadline", startTime: Date().addingTimeInterval(86400), endTime: Date().addingTimeInterval(90000), isCompleted: false, type: .deadline)
        ]
    )
}

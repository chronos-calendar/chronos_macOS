import SwiftUI
import Foundation

// MARK: - Calendar Grid View
struct MonthCalendarGridView: View {
    // MARK: - Properties
    @Binding var selectedDate: Date
    @Binding var scrollOffset: CGFloat
    
    let startDate: Date
    let endDate: Date
    let events: [CalendarEvent]
    let cellWidth: CGFloat
    let cellHeight: CGFloat
    var shouldScrollToToday: Bool = true
    
    private let calendar = Calendar.current
    private let monthHeight: CGFloat = 5 * 100 // Approximate height of a month (5 rows * cell height)
    
    // State to track if initial scroll has completed
    @State private var initialScrollComplete = false
    @State private var todayWeekId: String = ""
    
    // MARK: - Body
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 0) {
                    // Generate weeks
                    ForEach(generateWeeks(), id: \.self) { week in
                        HStack(spacing: 0) {
                            // Generate days in week
                            ForEach(week, id: \.self) { date in
                                // Day cell
                                MonthDayCell(
                                    date: date,
                                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                    isToday: calendar.isDateInToday(date),
                                    isCurrentMonth: isInSameMonthYear(date, as: selectedDate),
                                    events: eventsForDate(date),
                                    cellWidth: cellWidth,
                                    cellHeight: cellHeight
                                )
                                .onTapGesture {
                                    selectedDate = date
                                }
                                .id(calendar.isDateInToday(date) ? "today" : nil)
                            }
                        }
                        .id(getWeekId(week[0]))
                        .onAppear {
                            // Store the ID of the week containing today for initial scrolling
                            if week.contains(where: { calendar.isDateInToday($0) }) {
                                todayWeekId = getWeekId(week[0])
                            }
                        }
                    }
                }
                .background(GeometryReader { proxy in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: proxy.frame(in: .named("scroll")).origin
                    )
                })
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value.y
            }
            .onAppear {
                // Immediately scroll to today's date when the view appears
                if shouldScrollToToday && !initialScrollComplete {
                    // Use a very short delay to ensure the view is laid out
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            proxy.scrollTo("today", anchor: .center)
                            initialScrollComplete = true
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    // Generate weeks centered around today's date
    private func generateWeeks() -> [[Date]] {
        let today = Date()
        
        // Find the start of the week containing today
        let todayWeekday = calendar.component(.weekday, from: today)
        let daysToSubtract = (todayWeekday - calendar.firstWeekday + 7) % 7
        guard let todayWeekStart = calendar.date(byAdding: .day, value: -daysToSubtract, to: today) else {
            return []
        }
        
        // Generate 2 weeks before today's week
        var allWeeks: [[Date]] = []
        var currentWeekStart = todayWeekStart
        
        // Add 2 weeks before today's week
        for _ in 0..<2 {
            guard let previousWeekStart = calendar.date(byAdding: .day, value: -7, to: currentWeekStart) else {
                break
            }
            currentWeekStart = previousWeekStart
            allWeeks.insert(generateWeek(from: currentWeekStart), at: 0)
        }
        
        // Add today's week
        allWeeks.append(generateWeek(from: todayWeekStart))
        
        // Add 2 weeks after today's week
        currentWeekStart = todayWeekStart
        for _ in 0..<2 {
            guard let nextWeekStart = calendar.date(byAdding: .day, value: 7, to: currentWeekStart) else {
                break
            }
            currentWeekStart = nextWeekStart
            allWeeks.append(generateWeek(from: currentWeekStart))
        }
        
        // Add more weeks as needed to reach startDate and endDate
        let firstWeekStart = allWeeks.first?[0] ?? todayWeekStart
        let lastWeekStart = allWeeks.last?[0] ?? todayWeekStart
        
        // Add more weeks before if needed
        var currentStart = firstWeekStart
        while currentStart > startDate {
            guard let previousWeekStart = calendar.date(byAdding: .day, value: -7, to: currentStart) else {
                break
            }
            currentStart = previousWeekStart
            allWeeks.insert(generateWeek(from: currentStart), at: 0)
        }
        
        // Add more weeks after if needed
        var currentEnd = lastWeekStart
        while let lastDay = calendar.date(byAdding: .day, value: 6, to: currentEnd), lastDay < endDate {
            guard let nextWeekStart = calendar.date(byAdding: .day, value: 7, to: currentEnd) else {
                break
            }
            currentEnd = nextWeekStart
            allWeeks.append(generateWeek(from: currentEnd))
        }
        
        return allWeeks
    }
    
    // Generate a single week starting from the given date
    private func generateWeek(from startDate: Date) -> [Date] {
        var week: [Date] = []
        var currentDate = startDate
        
        for _ in 0..<7 {
            week.append(currentDate)
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDay
            }
        }
        
        return week
    }
    
    // Generate a unique ID for each week for ScrollViewReader
    private func getWeekId(_ date: Date) -> String {
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return "\(year)-\(month)-\(day)"
    }
    
    // Check if date is in same month and year as reference date
    private func isInSameMonthYear(_ date: Date, as referenceDate: Date) -> Bool {
        return calendar.component(.month, from: date) == calendar.component(.month, from: referenceDate) &&
               calendar.component(.year, from: date) == calendar.component(.year, from: referenceDate)
    }
    
    // Get events for a specific date
    private func eventsForDate(_ date: Date) -> [CalendarEvent] {
        return events.filter { event in
            calendar.isDate(event.startTime, inSameDayAs: date)
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

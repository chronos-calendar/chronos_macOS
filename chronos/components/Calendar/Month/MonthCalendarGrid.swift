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
    
    private let calendar = Calendar.current
    
    // MARK: - Body
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                // Generate weeks
                ForEach(generateContinuousDays(), id: \.self) { week in
                    HStack(spacing: 0) {
                        // Generate days in week
                        ForEach(week, id: \.self) { date in
                            // Day cell
                            MonthDayCell(
                                date: date,
                                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                isToday: calendar.isDateInToday(date),
                                isCurrentMonth: isCurrentMonth(date),
                                events: eventsForDate(date),
                                cellWidth: cellWidth,
                                cellHeight: cellHeight
                            )
                            .onTapGesture {
                                selectedDate = date
                            }
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
    }
    
    // MARK: - Methods
    // Generate a continuous array of weeks with no gaps
    private func generateContinuousDays() -> [[Date]] {
        var weeks: [[Date]] = []
        var currentDate = startDate
        
        // Go to the first day of the first week
        let weekday = calendar.component(.weekday, from: currentDate)
        currentDate = calendar.date(byAdding: .day, value: -(weekday - 1), to: currentDate)!
        
        // Generate weeks until we reach endDate
        while currentDate < endDate {
            var week: [Date] = []
            
            // Add 7 days to form a week
            for _ in 0..<7 {
                week.append(currentDate)
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
            
            weeks.append(week)
        }
        
        return weeks
    }
    
    // Check if date is in current month
    private func isCurrentMonth(_ date: Date) -> Bool {
        let today = Date()
        return calendar.component(.month, from: date) == calendar.component(.month, from: today) &&
               calendar.component(.year, from: date) == calendar.component(.year, from: today)
    }
    
    // Get events for a specific date
    private func eventsForDate(_ date: Date) -> [CalendarEvent] {
        return events.filter { event in
            calendar.isDate(event.startTime, inSameDayAs: date)
        }
    }
}
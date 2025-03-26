import SwiftUI

// MARK: - Week Row Component
struct MonthWeekRow: View {
    // MARK: - Properties
    let week: [Date]
    let cellWidth: CGFloat
    let cellHeight: CGFloat
    @Binding var selectedDate: Date
    @Binding var visibleMonthDate: Date
    let events: [CalendarEvent]
    @Binding var visibleDates: Set<Date>
    
    private let calendar = Calendar.current
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 0) {
            ForEach(week, id: \.self) { date in
                MonthDayCell(
                    date: date,
                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                    isToday: calendar.isDateInToday(date),
                    isCurrentMonth: isInSameMonthYear(date, as: visibleMonthDate),
                    events: eventsForDate(date),
                    cellWidth: cellWidth,
                    cellHeight: cellHeight
                )
                .onTapGesture {
                    selectedDate = date
                }
                .onAppear {
                    // Track when this date becomes visible
                    visibleDates.insert(date)
                }
                .onDisappear {
                    // Remove date when it's no longer visible
                    visibleDates.remove(date)
                }
            }
        }
        .frame(height: cellHeight)
    }
    
    // MARK: - Helper Methods
    
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

// // MARK: - Preview
// #Preview {
//     MonthWeekRow(
//         week: Calendar.current.dateInterval(of: .weekOfMonth, for: Date())?.start.daysOfWeek ?? [],
//         cellWidth: 50,
//         cellHeight: 80,
//         selectedDate: .constant(Date()),
//         visibleMonthDate: .constant(Date()),
//         events: [],
//         visibleDates: .constant([])
//     )
// }

// // Helper extension for preview
// private extension Date {
//     var daysOfWeek: [Date] {
//         let calendar = Calendar.current
//         let weekday = calendar.component(.weekday, from: self)
//         let days = (0..<7).map { day -> Date in
//             let firstDayIndex = (weekday - calendar.firstWeekday + 7) % 7
//             return calendar.date(byAdding: .day, value: day - firstDayIndex, to: self) ?? self
//         }
//         return days
//     }
// } 
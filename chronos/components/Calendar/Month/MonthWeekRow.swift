import SwiftUI

struct MonthWeekRow: View {
    let week: [Date]
    let cellWidth: CGFloat
    let cellHeight: CGFloat
    @Binding var selectedDate: Date
    @Binding var visibleMonthDate: Date
    let events: [CalendarEvent]
    @Binding var visibleDates: Set<Date>
    var onDateSelected: () -> Void
    
    private let calendar = Calendar.current
    
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
                    cellHeight: cellHeight,
                    onDateSelected: onDateSelected
                )
                .onAppear {
                    visibleDates.insert(date)
                }
                .onDisappear {
                    visibleDates.remove(date)
                }
            }
        }
        .frame(height: cellHeight)
    }
    
    private func isInSameMonthYear(_ date: Date, as referenceDate: Date) -> Bool {
        return calendar.component(.month, from: date) == calendar.component(.month, from: referenceDate) &&
               calendar.component(.year, from: date) == calendar.component(.year, from: referenceDate)
    }
    
    private func eventsForDate(_ date: Date) -> [CalendarEvent] {
        return events.filter { event in
            calendar.isDate(event.startTime, inSameDayAs: date)
        }
    }
}

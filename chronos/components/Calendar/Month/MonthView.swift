import SwiftUI

extension Calendar {
    func weeks(for date: Date) -> [[Date]] {
        guard let monthInterval = self.dateInterval(of: .month, for: date),
              let monthFirstWeek = self.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = self.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1) else {
            return []
        }
        
        let dateFormatter = DateFormatter()
        var weeks: [[Date]] = []
        var currentWeek: [Date] = []
        
        // Enumerate dates from the start of first week to end of last week
        enumerateDates(
            startingAfter: monthFirstWeek.start - 1,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) { date, _, stop in
            guard let date = date else { return }
            
            if date > monthLastWeek.end {
                stop = true
                if !currentWeek.isEmpty {
                    weeks.append(currentWeek)
                }
                return
            }
            
            currentWeek.append(date)
            
            // If we've collected 7 days, start a new week
            if currentWeek.count == 7 {
                weeks.append(currentWeek)
                currentWeek = []
            }
        }
        
        return weeks
    }
}

struct MonthView: View {
    @State private var selectedDate: Date = Date()
    @State private var visibleMonthDate: Date = Date()
    @State private var visibleDates = Set<Date>()
    let events: [CalendarEvent]
    var onDateSelected: () -> Void
    
    private let calendar = Calendar.current
    private let daysInWeek = 7
    private let cellWidth: CGFloat = 100
    private let cellHeight: CGFloat = 100
    
    var weeks: [[Date]] {
        calendar.weeks(for: visibleMonthDate)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CalendarWeekdayHeader(startDayOfWeek: calendar.firstWeekday, cellWidth: cellWidth)
            
            ForEach(weeks, id: \.self) { week in
                MonthWeekRow(
                    week: week,
                    cellWidth: cellWidth,
                    cellHeight: cellHeight,
                    selectedDate: $selectedDate,
                    visibleMonthDate: $visibleMonthDate,
                    events: events,
                    visibleDates: $visibleDates,
                    onDateSelected: onDateSelected
                )
            }
        }
    }
}

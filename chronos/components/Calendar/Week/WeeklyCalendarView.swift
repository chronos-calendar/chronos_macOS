import SwiftUI

/// A high-level weekly calendar view, similar in style to "Amie's weekly calendar" UI.
struct WeeklyCalendarView: View {
    let events: [CalendarEvent]
    
    @State private var currentDate: Date = Date()
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
            header
            divider
            daysOfWeekHeader
            divider
            scrollableTimeline
        }
        .padding()
    }
}

// MARK: - Subviews
extension WeeklyCalendarView {
    /// The header with navigation controls
    private var header: some View {
        HStack {
            Text(weekRangeString)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            Spacer()
            
            Button(action: previousWeek) {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.plain)
            .foregroundColor(.black)
            
            Button(action: nextWeek) {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.plain)
            .foregroundColor(.black)
        }
    }
    
    /// A simple divider used between subviews
    private var divider: some View {
        Divider()
            .padding(.vertical, 4)
    }
    
    /// A horizontal row indicating each day of the current week
    private var daysOfWeekHeader: some View {
        HStack(spacing: 0) {
            // Time column spacer
            Text("")
                .frame(width: 50)
            
            // Days of the week
            ForEach(weekDates, id: \.self) { date in
                VStack(spacing: 2) {
                    Text(dayOfWeekFormatter.string(from: date)) // e.g. "Mon", "Tue"
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                    
                    Text("\(calendar.component(.day, from: date))") // e.g. 14, 15
                        .font(.headline)
                        .foregroundColor(.black)
                        .fontWeight(calendar.isDateInToday(date) ? .bold : .regular)
                        .multilineTextAlignment(.center)
                }
                // Give each day's header a flexible width, centered
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .background(
                    calendar.isDateInToday(date) ? Color.blue.opacity(0.1) : Color.clear
                )
            }
        }
    }
    
    /// The main scrollable portion of the view, containing time labels and daily columns
    private var scrollableTimeline: some View {
        ScrollView(showsIndicators: true) {
            ZStack(alignment: .topLeading) {
                HStack(spacing: 0) {
                    timeLabelsColumn
                    ForEach(weekDates.indices, id: \.self) { index in
                        DayColumnView(date: weekDates[index], allEvents: events)
                            // Each day column also gets flexible width
                            .frame(maxWidth: .infinity)
                            // Keep or restore any vertical line overlay if previously added:
                            .overlay(alignment: .trailing) {
                                if index < weekDates.count - 1 {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 1)
                                }
                            }
                    }
                }
                // The geometry-based red time indicator remains the same
                GeometryReader { proxy in
                    let now = Date()
                    let hourNow = calendar.component(.hour, from: now)
                    let minuteNow = calendar.component(.minute, from: now)
                    let offsetY = (CGFloat(hourNow) + CGFloat(minuteNow) / 60.0) * 50.0

                    Rectangle()
                        .fill(Color.red)
                        .frame(width: proxy.size.width - 50)
                        .frame(height: 2)
                        .offset(x: 50, y: offsetY)
                }
            }
        }
    }
    
    /// A vertically stacked column of time labels
    private var timeLabelsColumn: some View {
        VStack(spacing: 0) {
            ForEach(0..<24) { hour in
                let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date())!
                HStack {
                    Spacer()
                    Text(timeFormatter.string(from: date)) // e.g. "12 AM", "1 PM"
                        .font(.caption)
                        .foregroundColor(.black)
                        // ADD:
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(width: 40, alignment: .trailing)
                }
                .frame(height: 50)
            }
        }
        .frame(width: 50)
    }
}

// MARK: - Computed Properties & Helpers
extension WeeklyCalendarView {
    /// The array of days in the current week
    private var weekDates: [Date] {
        guard let startOfWeek = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)
        ) else {
            return []
        }
        
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: startOfWeek)
        }
    }
    
    /// A string representing the range of the current week, e.g. "Sep 10 - Sep 16, 2023"
    private var weekRangeString: String {
        guard let firstDay = weekDates.first, let lastDay = weekDates.last else { return "" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let firstString = formatter.string(from: firstDay)
        
        let secondFormatter = DateFormatter()
        // Only show the month if different from the first day
        secondFormatter.dateFormat = calendar.component(.month, from: firstDay) == calendar.component(.month, from: lastDay)
            ? "d, yyyy"
            : "MMM d, yyyy"
        let lastString = secondFormatter.string(from: lastDay)
        
        return "\(firstString) - \(lastString)"
    }
    
    /// Navigates to the previous week
    private func previousWeek() {
        if let previous = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate) {
            currentDate = previous
        }
    }
    
    /// Navigates to the next week
    private func nextWeek() {
        if let next = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) {
            currentDate = next
        }
    }
    
    /// Displays times in user's preferred 12/24 hour format automatically
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    /// Formatter for day-of-week labels (Mon, Tue, Wed, etc.)
    private var dayOfWeekFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "E"
        return f
    }
}

// MARK: - Day Column View
/// Displays an hourly grid for a single day's events
fileprivate struct DayColumnView: View {
    let date: Date
    let allEvents: [CalendarEvent]
    
    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<24) { hour in
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 50)
                    .overlay(
                        Rectangle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 1),
                        alignment: .top
                    )
                    .overlay(
                        HourEventsOverlay(events: eventsInHour(hour))
                    )
            }
        }
        .background(
            calendar.isDateInToday(date) ? Color.blue.opacity(0.04) : Color.clear
        )
        .frame(maxWidth: .infinity)
    }
    
    /// Filter events to only those in the chosen hour
    private func eventsInHour(_ hour: Int) -> [CalendarEvent] {
        allEvents.filter { event in
            calendar.isDate(event.startTime, inSameDayAs: date)
            && calendar.component(.hour, from: event.startTime) == hour
        }
    }
}

// MARK: - Hour Events Overlay
/// A small overlay that shows events within a given hour
fileprivate struct HourEventsOverlay: View {
    let events: [CalendarEvent]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(events, id: \.startTime) { event in
                Text(event.title)
                    .font(.system(size: 10))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(backgroundColor(for: event.type))
                    .cornerRadius(4)
                    .lineLimit(1)
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 4)
    }
    
    private func backgroundColor(for type: EventType) -> Color {
        switch type {
        case .meeting:
            return Color.blue.opacity(0.2)
        case .deadline:
            return Color.red.opacity(0.2)
        case .task, .reminder:
            return Color.green.opacity(0.2)
        }
    }
}

// MARK: - Preview (Optional)
/*
struct WeeklyCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyCalendarView(events: [
            CalendarEvent(
                title: "Meeting w/ Alex",
                startTime: Date().addingTimeInterval(3600 * 10), // 10 AM
                endTime: Date().addingTimeInterval(3600 * 11),
                isCompleted: false,
                type: .meeting
            ),
            CalendarEvent(
                title: "Project Deadline",
                startTime: Date().addingTimeInterval(3600 * 14), // 2 PM
                endTime: Date().addingTimeInterval(3600 * 15),
                isCompleted: false,
                type: .deadline
            )
        ])
    }
}
*/

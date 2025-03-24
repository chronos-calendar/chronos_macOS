import SwiftUI
import SwiftData

// MARK: - Main Calendar View
struct MonthlyCalendar: View {
    // MARK: - Properties
    @State private var selectedDate: Date = Date()
    @State private var initialScrollDone = false
    @State private var visibleMonthDate: Date = Date()
    @State private var todayWeekId: String = ""
    @State private var scrollPosition: String? = nil // Track exact scroll position
    @State private var isResizing: Bool = false // Flag to prevent scroll updates during resize
    
    // Calendar data source
    let events: [CalendarEvent]
    
    // Customization options
    var showMonthHeader: Bool = true
    var showWeekdayHeader: Bool = true
    var startDayOfWeek: Int = 1 // 1 = Monday, 7 = Sunday
    
    // Calendar configuration
    private let calendar = Calendar.current
    private let startDate = Calendar.current.date(byAdding: .year, value: -2, to: Date())! // 2 years in past
    private let endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())! // 1 year in future
    private let numberOfWeeksToShow: CGFloat = 6 // Show 6 weeks
    
    init(events: [CalendarEvent], showMonthHeader: Bool = true, showWeekdayHeader: Bool = true, startDayOfWeek: Int = 1) {
        self.events = events
        self.showMonthHeader = showMonthHeader
        self.showWeekdayHeader = showWeekdayHeader
        self.startDayOfWeek = startDayOfWeek
        
        // Pre-calculate the todayWeekId
        let today = Date()
        let weekday = Calendar.current.component(.weekday, from: today)
        let daysToSubtract = (weekday - Calendar.current.firstWeekday + 7) % 7
        if let startOfWeek = Calendar.current.date(byAdding: .day, value: -daysToSubtract, to: today) {
            let year = Calendar.current.component(.year, from: startOfWeek)
            let month = Calendar.current.component(.month, from: startOfWeek)
            let day = Calendar.current.component(.day, from: startOfWeek)
            self._todayWeekId = State(initialValue: "\(year)-\(month)-\(day)")
        }
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            // Safe calculation of dimensions to avoid negative values
            let availableWidth: CGFloat = max(geometry.size.width, 1) // Ensure minimum width
            let availableHeight = max(geometry.size.height, 1) // Ensure minimum height
            
            // Fixed dimensions for header components
            let headerHeight: CGFloat = showMonthHeader ? 40 : 0
            let weekdayHeaderHeight: CGFloat = showWeekdayHeader ? 30 : 0
            
            // Safe calculation of remaining space
            let calendarHeight = max(availableHeight - headerHeight - weekdayHeaderHeight, 1)
            let cellWidth = availableWidth / 7
            let cellHeight = max(calendarHeight / numberOfWeeksToShow, 1) // Ensure minimum cell height
            
            VStack(spacing: 0) {
                // Month header (optional)
                if showMonthHeader {
                    CalendarMonthHeader(
                        currentMonthDate: $visibleMonthDate
                    )
                    .padding(.bottom, 4)
                    .frame(height: headerHeight)
                }
                
                // Weekday header (optional)
                if showWeekdayHeader {
                    CalendarWeekdayHeader(
                        startDayOfWeek: startDayOfWeek,
                        cellWidth: cellWidth
                    )
                    .frame(height: weekdayHeaderHeight)
                }
                
                // Infinite scrolling calendar grid
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(generateAllWeeks(), id: \.self) { week in
                                WeekRow(
                                    week: week,
                                    cellWidth: cellWidth,
                                    cellHeight: cellHeight,
                                    selectedDate: $selectedDate,
                                    visibleMonthDate: $visibleMonthDate,
                                    events: events
                                )
                                .id(getWeekId(week[0]))
                                .onAppear {
                                    // Only update visible month when not resizing
                                    if !isResizing {
                                        let weekId = getWeekId(week[0])
                                        scrollPosition = weekId // Track current position
                                        
                                        if let firstDate = week.first, 
                                           !calendar.isDate(firstDate, equalTo: visibleMonthDate, toGranularity: .month) {
                                            let components = calendar.dateComponents([.year, .month], from: firstDate)
                                            if let firstDayOfMonth = calendar.date(from: components) {
                                                visibleMonthDate = firstDayOfMonth
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .onAppear {
                        if !initialScrollDone {
                            // Scroll to today's week on initial appearance
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                proxy.scrollTo(todayWeekId, anchor: .top)
                                scrollPosition = todayWeekId // Set initial position
                                initialScrollDone = true
                            }
                        }
                    }
                    .onChange(of: geometry.size) { oldSize, newSize in
                        // Lock position during resize
                        if initialScrollDone && scrollPosition != nil {
                            // Set resize flag to prevent scroll position updates
                            isResizing = true
                            
                            // Maintain exact scroll position during resize
                            DispatchQueue.main.async {
                                proxy.scrollTo(scrollPosition, anchor: .top)
                                
                                // Wait until scrolling completes to release resize lock
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    isResizing = false
                                }
                            }
                        }
                    }
                }
                .frame(height: calendarHeight)
                .onChange(of: selectedDate) { oldValue, newValue in
                    visibleMonthDate = newValue
                }
                .background(Color.white)
            }
            .frame(width: availableWidth, height: availableHeight)
            .background(Color.white)
        }
    }
    
    // MARK: - Helper Views
    private struct WeekRow: View {
        let week: [Date]
        let cellWidth: CGFloat
        let cellHeight: CGFloat
        @Binding var selectedDate: Date
        @Binding var visibleMonthDate: Date
        let events: [CalendarEvent]
        
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
                        cellHeight: cellHeight
                    )
                    .onTapGesture {
                        selectedDate = date
                    }
                }
            }
            .frame(height: cellHeight)
        }
        
        // Helper functions
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
    
    // Generate all weeks between start and end date in chronological order
    private func generateAllWeeks() -> [[Date]] {
        var allWeeks: [[Date]] = []
        var currentDate = startDate
        
        // Go to the first day of the first week
        let firstWeekday = calendar.component(.weekday, from: currentDate)
        let offsetToFirstDay = (firstWeekday - calendar.firstWeekday + 7) % 7
        currentDate = calendar.date(byAdding: .day, value: -offsetToFirstDay, to: currentDate)!
        
        // Generate weeks until we reach endDate
        while currentDate < endDate {
            let week = generateWeek(from: currentDate)
            allWeeks.append(week)
            
            // Move to next week
            currentDate = calendar.date(byAdding: .day, value: 7, to: currentDate)!
        }
        
        return allWeeks
    }
    
    // Generate a single week starting from the given date
    private func generateWeek(from startDate: Date) -> [Date] {
        var week: [Date] = []
        var currentDate = startDate
        
        for _ in 0..<7 {
            week.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
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

// MARK: - Preview
#Preview {
    MonthlyCalendar(
        events: [
            CalendarEvent(title: "Team Meeting", startTime: Date(), endTime: Date().addingTimeInterval(3600), isCompleted: false, type: .meeting),
            CalendarEvent(title: "Project Deadline", startTime: Date().addingTimeInterval(86400), endTime: Date().addingTimeInterval(90000), isCompleted: false, type: .deadline)
        ]
    )
}

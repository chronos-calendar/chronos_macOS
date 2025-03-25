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
    
    // Add these properties to track visible dates
    @State private var visibleDates: Set<Date> = []
    
    // Calendar data source
    let events: [CalendarEvent]
    
    // Customization options
    var showMonthHeader: Bool = true
    var showWeekdayHeader: Bool = true
    var startDayOfWeek: Int = 1 // 1 = Monday, 7 = Sunday
    
    // Update resize handling properties
    @State private var previousSize: CGSize = .zero
    @State private var isFirstAppearance = true
    
    // Calendar configuration
    private let calendar = Calendar.current
    private let startDate = Calendar.current.date(byAdding: .year, value: -2, to: Date())! // 2 years in past
    private let endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())! // 1 year in future
    private let numberOfWeeksToShow: CGFloat = 5 // Show 6 weeks
    
    // Add a new state to track when we're in the middle of a transition
    @State private var isTransitioning: Bool = false
    
    // Add this state property to track the month before transition
    @State private var preTransitionMonth: Date? = nil
    
    // Add this property to track continuous resizing
    @State private var isWindowResizing: Bool = false
    @State private var resizeDebounceTask: DispatchWorkItem? = nil
    
    // Add these properties for more robust position tracking
    @State private var visibleWeekOffsets: [String: CGFloat] = [:]
    @State private var lastStablePosition: (weekId: String, yOffset: CGFloat)? = nil
    @State private var resizeOperation: ResizeOperation = .none
    
    // First, add a property to store the actual visible week
    @State private var userVisibleWeek: String? = nil
    
    // Add this enum to track resize state
    private enum ResizeOperation {
        case none
        case resizing
        case fullscreenTransition
    }
    
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
            // Set minimums that match your screenshot dimensions
            let availableWidth: CGFloat = max(geometry.size.width, 300) // Minimum width from screenshot
            let availableHeight = max(geometry.size.height, 400) // Minimum height from screenshot
            
            // Fixed dimensions for header components
            let headerHeight: CGFloat = showMonthHeader ? 40 : 0
            let weekdayHeaderHeight: CGFloat = showWeekdayHeader ? 30 : 0
            
            // Safe calculation of remaining space
            let calendarHeight = max(availableHeight - headerHeight - weekdayHeaderHeight, 300) // Minimum calendar height
            let cellWidth = availableWidth / 7
            let cellHeight = max(calendarHeight / numberOfWeeksToShow, 50) // Minimum cell height
            
            VStack(spacing: 0) {
                // Month header - hide during transitions
                if showMonthHeader && !isTransitioning {
                    CalendarMonthHeader(
                        currentMonthDate: $visibleMonthDate
                    )
                    .padding(.bottom, 4)
                    .frame(height: headerHeight)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.2), value: isTransitioning)
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
                                MonthWeekRow(
                                    week: week,
                                    cellWidth: cellWidth,
                                    cellHeight: cellHeight,
                                    selectedDate: $selectedDate,
                                    visibleMonthDate: $visibleMonthDate,
                                    events: events,
                                    visibleDates: $visibleDates
                                )
                                .id(getWeekId(week[0]))
                                .onAppear {
                                    // Enhanced position tracking logic
                                    let weekId = getWeekId(week[0])
                                    
                                    // Always track scroll position
                                    if !isResizing {
                                        scrollPosition = weekId
                                        
                                        // Only update user's current view if not in transition
                                        if !isTransitioning && initialScrollDone {
                                            userVisibleWeek = weekId
                                        }
                                        
                                        // Update visible month only when stable
                                        if !isTransitioning && !isResizing && initialScrollDone {
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
                                // Position tracking overlay
                                .overlay(
                                    GeometryReader { geo -> Color in
                                        let frame = geo.frame(in: .named("calendarSpace"))
                                        let weekId = getWeekId(week[0])
                                        
                                        // Store precise vertical position when stable
                                        if !isResizing && initialScrollDone {
                                            DispatchQueue.main.async {
                                                visibleWeekOffsets[weekId] = frame.minY
                                            }
                                        }
                                        return Color.clear
                                    }
                                )
                            }
                        }
                    }
                    .onChange(of: geometry.size) { oldSize, newSize in
                        if initialScrollDone {
                            // Cancel any pending tasks
                            resizeDebounceTask?.cancel()
                            
                            // Lock in the exact week that should remain visible
                            let visibleWeekToMaintain = userVisibleWeek ?? scrollPosition ?? todayWeekId
                            
                            // Determine if this is a major size change
                            let isSignificantChange = abs(oldSize.width - newSize.width) > 100 || 
                                                     abs(oldSize.height - newSize.height) > 100
                            
                            // Minimal state setup for better performance
                            if resizeOperation == .none {
                                // Lock only what's necessary during resize
                                isResizing = true
                                preTransitionMonth = visibleMonthDate
                                resizeOperation = isSignificantChange ? .fullscreenTransition : .resizing
                                
                                // Only hide header during fullscreen transitions
                                isTransitioning = isSignificantChange
                                
                                // Lock the month to prevent header jitter
                                visibleMonthDate = preTransitionMonth ?? visibleMonthDate
                            }
                            
                            // Immediate position preservation - most critical step
                            proxy.scrollTo(visibleWeekToMaintain, anchor: .top)
                            
                            // Use a lightweight approach for normal resizing
                            // This dramatically improves performance while maintaining position
                            if !isSignificantChange {
                                // For normal resizing, use a more efficient cleanup approach
                                let task = DispatchWorkItem {
                                    // Store the week to maintain in a local variable for the closure
                                    let weekToMaintain = visibleWeekToMaintain
                                    
                                    // One final position correction
                                    proxy.scrollTo(weekToMaintain, anchor: .top)
                                    
                                    // Update month without changing scroll position
                                    updateVisibleMonthAccurate(forceCurrent: weekToMaintain)
                                    
                                    // Release locks all at once - more efficient
                                    isResizing = false
                                    resizeOperation = .none
                                    preTransitionMonth = nil
                                }
                                
                                resizeDebounceTask = task
                                // Ultra-short debounce for better native feel
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.03, execute: task)
                            } else {
                                // For major changes, we still need the more comprehensive approach
                                let task = DispatchWorkItem {
                                    // Store the week to maintain in a local variable for the closure
                                    let weekToMaintain = visibleWeekToMaintain
                                    
                                    // Final position lock
                                    proxy.scrollTo(weekToMaintain, anchor: .top)
                                    
                                    // Update the month header only once at the end
                                    updateVisibleMonthAccurate(forceCurrent: weekToMaintain)
                                    
                                    // Release all locks together for better performance
                                    DispatchQueue.main.async {
                                        isResizing = false
                                        isTransitioning = false
                                        resizeOperation = .none
                                        preTransitionMonth = nil
                                    }
                                }
                                
                                resizeDebounceTask = task
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: task)
                            }
                        }
                    }
                    // Modified initial appearance handler
                    .onAppear {
                        if !initialScrollDone {
                            isTransitioning = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                proxy.scrollTo(todayWeekId, anchor: .top)
                                scrollPosition = todayWeekId
                                userVisibleWeek = todayWeekId
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    proxy.scrollTo(todayWeekId, anchor: .top)
                                    lastStablePosition = (todayWeekId, 0)
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        initialScrollDone = true
                                        isTransitioning = false
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(height: calendarHeight)
                .onChange(of: selectedDate) { oldValue, newValue in
                    // Only update if not in transition
                    if !isTransitioning && !isResizing {
                        visibleMonthDate = newValue
                    }
                }
                .background(Color.white)
            }
            .frame(width: availableWidth, height: availableHeight)
            .background(Color.white)
        }
        .onChange(of: visibleDates) { _, _ in
            // Only update visible month when stable
            if !isTransitioning && !isResizing && initialScrollDone {
                updateVisibleMonth()
            }
        }
        .coordinateSpace(name: "calendarSpace")
        // Set explicit minimum frame size to match screenshot
        .frame(minWidth: 300, minHeight: 400)
    }
    
    // MARK: - Helper Views
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
    
    // Add this method to determine the most visible month
    private func updateVisibleMonth() {
        let datesByMonth: [Date: Int] = visibleDates.reduce(into: [:]) { counts, date in
            let components = calendar.dateComponents([.year, .month], from: date)
            if let monthStart = calendar.date(from: components) {
                counts[monthStart, default: 0] += 1
            }
        }
        
        if let (mostVisibleMonth, _) = datesByMonth.max(by: { $0.value < $1.value }) {
            visibleMonthDate = mostVisibleMonth
        }
    }
    
    // Add this improved method for more accurate month detection
    private func updateVisibleMonthAccurate(forceCurrent: String? = nil) {
        // If we have a specific week that should determine the month, use it
        if let currentWeekId = forceCurrent,
           let currentDate = parseWeekId(currentWeekId),
           let firstVisibleDate = calendar.date(byAdding: .day, value: 3, to: currentDate) { // Move to middle of week
            
            // Extract month from this date
            let components = calendar.dateComponents([.year, .month], from: firstVisibleDate)
            if let monthStart = calendar.date(from: components) {
                visibleMonthDate = monthStart
                return
            }
        }
        
        // Fallback: Use the most frequently visible month 
        // Give more weight to dates in the middle of screen
        var monthWeights: [Date: Double] = [:]
        
        for date in visibleDates {
            let components = calendar.dateComponents([.year, .month], from: date)
            if let monthStart = calendar.date(from: components) {
                // Give more weight to dates in current month
                let weight: Double = isInSameMonthYear(date, as: selectedDate) ? 1.5 : 1.0
                monthWeights[monthStart, default: 0] += weight
            }
        }
        
        if let (mostVisibleMonth, _) = monthWeights.max(by: { $0.value < $1.value }) {
            visibleMonthDate = mostVisibleMonth
        }
    }
    
    // Parse week ID back to date for better accuracy
    private func parseWeekId(_ weekId: String) -> Date? {
        let components = weekId.split(separator: "-")
        if components.count == 3,
           let year = Int(components[0]),
           let month = Int(components[1]),
           let day = Int(components[2]) {
            
            var dateComponents = DateComponents()
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = day
            
            return calendar.date(from: dateComponents)
        }
        return nil
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

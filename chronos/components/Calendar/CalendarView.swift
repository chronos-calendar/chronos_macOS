// File: MacOSCalendarView.swift
import SwiftUI

struct MacOSCalendarView: View {
    @Binding var selectedDate: Date?
    @State private var currentDate: Date
    @State private var visibleMonths: [Date] = []
    @State private var events: [Event]
    
    private let calendar = Calendar.current
    private let monthsToDisplay = 3
    
    init(selectedDate: Binding<Date?>, initialDate: Date = Date(), events: [Event] = sampleEvents) {
        self._selectedDate = selectedDate
        self._currentDate = State(initialValue: initialDate)
        self._events = State(initialValue: events)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CalendarHeaderView(
                currentDate: $currentDate,
                todayAction: { scrollToToday() }
            )
            
            ScrollViewReader { scrollProxy in
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        ForEach(visibleMonths, id: \.self) { month in
                            Section {
                                MonthView(
                                    currentDate: month,
                                    selectedDate: $selectedDate,
                                    events: eventsForMonth(month)
                                )
                                .id(month)
                                .onAppear {
                                    onMonthAppear(month)
                                }
                            } header: {
                                WeekdayHeaderView()
                            }
                        }
                    }
                }
                .onAppear {
                    setupInitialMonths()
                    // Use scrollProxy to scroll to the current month
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scrollToCurrentMonth(scrollProxy: scrollProxy)
                    }
                }
            }
        }
        .frame(minWidth: 800, minHeight: 600)
    }
    
    private func setupInitialMonths() {
        let startDate = calendar.date(byAdding: .month, value: -5, to: currentDate)!
        visibleMonths = (0..<12).compactMap { monthOffset in
            calendar.date(byAdding: .month, value: monthOffset, to: startDate)
        }
    }
    
    private func onMonthAppear(_ month: Date) {
        // When a month appears, check if we need to add more months
        if let firstVisibleMonth = visibleMonths.first,
           let lastVisibleMonth = visibleMonths.last {
            
            // Update current date to the visible month
            if calendar.isDate(month, equalTo: currentDate, toGranularity: .month) {
                currentDate = month
            }
            
            // Add months at the beginning if needed
            if calendar.isDate(month, equalTo: firstVisibleMonth, toGranularity: .day) {
                addMonthsAtBeginning()
            }
            
            // Add months at the end if needed
            if calendar.isDate(month, equalTo: lastVisibleMonth, toGranularity: .day) {
                addMonthsAtEnd()
            }
        }
    }
    
    private func addMonthsAtBeginning() {
        guard let firstMonth = visibleMonths.first else { return }
        
        let newMonths = (1...2).compactMap { offset in
            calendar.date(byAdding: .month, value: -offset, to: firstMonth)
        }.reversed()
        
        visibleMonths.insert(contentsOf: newMonths, at: 0)
    }
    
    private func addMonthsAtEnd() {
        guard let lastMonth = visibleMonths.last else { return }
        
        let newMonths = (1...2).compactMap { offset in
            calendar.date(byAdding: .month, value: offset, to: lastMonth)
        }
        
        visibleMonths.append(contentsOf: newMonths)
    }
    
    private func scrollToCurrentMonth(scrollProxy: ScrollViewProxy) {
        if let currentMonthDate = visibleMonths.first(where: {
            calendar.isDate($0, equalTo: currentDate, toGranularity: .month)
        }) {
            withAnimation {
                scrollProxy.scrollTo(currentMonthDate, anchor: .top)
            }
        }
    }
    
    private func scrollToToday() {
        let today = Date()
        currentDate = today
        
        // Ensure today's month is in the visible months
        if !visibleMonths.contains(where: {
            calendar.isDate($0, equalTo: today, toGranularity: .month)
        }) {
            let startOfMonth = calendar.startOfMonth(for: today)
            visibleMonths.append(startOfMonth)
            visibleMonths.sort()
        }
    }
    
    private func eventsForMonth(_ month: Date) -> [Event] {
        let startOfMonth = calendar.startOfMonth(for: month)
        guard let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return []
        }
        
        return events.filter { event in
            (event.date >= startOfMonth && event.date <= endOfMonth)
        }
    }
}

// File: CalendarHeaderView.swift
import SwiftUI

struct CalendarHeaderView: View {
    @Binding var currentDate: Date
    let todayAction: () -> Void
    
    var body: some View {
        HStack {
            Button("Today") {
                todayAction()
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Text(monthYearString(from: currentDate))
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "calendar")
            }
            .buttonStyle(.plain)
            
            Button(action: {}) {
                Image(systemName: "magnifyingglass")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.windowBackgroundColor))
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

// File: WeekdayHeaderView.swift
import SwiftUI

struct WeekdayHeaderView: View {
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .frame(maxWidth: .infinity)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            }
        }
        .background(Color(.windowBackgroundColor).opacity(0.8))
    }
}

// File: MonthView.swift
import SwiftUI

struct MonthView: View {
    let currentDate: Date
    @Binding var selectedDate: Date?
    let events: [Event]
    
    private let calendar = Calendar.current
    
    var body: some View {
        let daysInMonth = daysInMonth(for: currentDate)
        
        VStack(alignment: .leading) {
            Text(monthYearString(from: currentDate))
                .font(.headline)
                .padding(.leading)
                .padding(.top, 8)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            events: events.filter { calendar.isDate($0.date, inSameDayAs: date) },
                            isCurrentMonth: calendar.isDate(date, equalTo: currentDate, toGranularity: .month),
                            isSelected: selectedDate != nil && calendar.isDate(date, inSameDayAs: selectedDate!),
                            selectedDate: $selectedDate
                        )
                    } else {
                        Color.clear
                            .frame(height: 100)
                    }
                }
            }
        }
        .padding(.bottom, 16)
        .background(Color(.textBackgroundColor))
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func daysInMonth(for date: Date) -> [Date?] {
        var days: [Date?] = []
        
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return days
        }
        
        // Calculate the weekday of the first day (0 is Sunday, 1 is Monday, etc.)
        let firstDayWeekday = calendar.component(.weekday, from: firstDay) - 1
        
        // Add empty cells for days before the first day of the month
        for _ in 0..<firstDayWeekday {
            days.append(nil)
        }
        
        // Add the days of the month
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        
        // Fill out the last row with empty cells if needed
        let remainingCells = 42 - days.count // 6 rows of 7 days
        if remainingCells > 0 && remainingCells < 7 {
            for _ in 0..<remainingCells {
                days.append(nil)
            }
        }
        
        return days
    }
}

// File: DayCell.swift
import SwiftUI

struct DayCell: View {
    let date: Date
    let events: [Event]
    let isCurrentMonth: Bool
    let isSelected: Bool
    @Binding var selectedDate: Date?
    
    private let calendar = Calendar.current
    
    var body: some View {
        let isToday = calendar.isDateInToday(date)
        
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(calendar.component(.day, from: date))")
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundColor(isCurrentMonth ? (isToday ? .white : .primary) : .secondary)
                    .padding(6)
                    .background(isToday ? Color.blue : Color.clear)
                    .clipShape(Circle())
                
                Spacer()
            }
            .padding(.horizontal, 4)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(events) { event in
                        EventView(event: event)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                .padding(1)
        )
        .overlay(
            Rectangle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
        .onTapGesture {
            self.selectedDate = date
        }
    }
}

// File: EventView.swift
import SwiftUI

struct EventView: View {
    let event: Event
    
    var body: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(event.color)
                .frame(width: 4)
            
            Text(event.title)
                .font(.system(size: 11))
                .lineLimit(1)
            
            Spacer()
            
            if let time = event.timeString {
                Text(time)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 4)
        .background(event.color.opacity(0.1))
        .cornerRadius(4)
    }
}

// File: Models.swift
import SwiftUI

struct Event: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let date: Date
    let startTime: Date?
    let endTime: Date?
    let color: Color
    let isAllDay: Bool
    
    var timeString: String? {
        guard let startTime = startTime, !isAllDay else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: startTime)
    }
    
    // Required for Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }
}

// File: Extensions.swift
import Foundation

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        return self.date(from: self.dateComponents([.year, .month], from: date))!
    }
    
    func endOfMonth(for date: Date) -> Date {
        var components = DateComponents()
        components.month = 1
        components.day = -1
        return self.date(byAdding: components, to: self.startOfMonth(for: date))!
    }
}

extension Date: Comparable {
    public static func < (lhs: Date, rhs: Date) -> Bool {
        return lhs.compare(rhs) == .orderedAscending
    }
}

// File: SampleData.swift
import SwiftUI

// MARK: - Sample Data
let sampleEvents: [Event] = {
    let calendar = Calendar.current
    let now = Date()
    let colors: [Color] = [.blue, .red, .green, .orange, .purple, .pink]
    
    var events: [Event] = []
    
    // Generate events for the current month and adjacent months
    for month in -2...2 {
        let monthDate = calendar.date(byAdding: .month, value: month, to: now)!
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthDate)!.count
        
        for day in 1...daysInMonth {
            if let date = calendar.date(bySetting: .day, value: day, of: monthDate) {
                // Add 0-3 events per day
                let eventCount = Int.random(in: 0...3)
                for i in 0..<eventCount {
                    let hourOffset = i * 2
                    let isAllDay = i == 0 && Bool.random()
                    
                    var startTime: Date?
                    var endTime: Date?
                    
                    if !isAllDay {
                        startTime = calendar.date(bySettingHour: 8 + hourOffset, minute: 0, second: 0, of: date)
                        endTime = calendar.date(bySettingHour: 9 + hourOffset, minute: 0, second: 0, of: date)
                    }
                    
                    let event = Event(
                        title: eventTitle(for: day + i),
                        date: date,
                        startTime: startTime,
                        endTime: endTime,
                        color: colors[Int.random(in: 0..<colors.count)],
                        isAllDay: isAllDay
                    )
                    events.append(event)
                }
            }
        }
    }
    
    return events
}()

func eventTitle(for index: Int) -> String {
    let titles = [
        "Meeting", "Lunch", "Coffee", "Call", "Appointment",
        "Interview", "Conference", "Workshop", "Class", "Presentation",
        "Review", "Deadline", "Project", "Reminder", "Birthday"
    ]
    
    let descriptions = [
        "with team", "with client", "with boss", "weekly", "monthly",
        "progress", "planning", "follow-up", "check-in", "standup",
        "1-on-1", "sprint", "quarterly", "annual", "final"
    ]
    
    let title = titles[abs(index) % titles.count]
    let description = descriptions[abs(index + 5) % descriptions.count]
    
    return "\(title) \(description)"
}


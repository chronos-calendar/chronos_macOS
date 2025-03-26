//
//  DailyCalendar.swift
//  chronos
//
//  Created by Jaskaran Singh on 3/24/25.
//


import SwiftUI

// Main WeeklyCalendar view
struct WeeklyCalendar: View {
    let events: [CalendarEvent]
    @State private var currentDate = Date()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(monthYearString)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: previousWeek) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: nextWeek) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            
            // Days of week header
            CalendarWeekdayHeader(startDayOfWeek: 1, cellWidth: 60)
            
            // Timeline
            ScrollView {
                WeekTimeline(events: events, currentDate: currentDate)
            }
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }
    
    private func previousWeek() {
        if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentDate) {
            currentDate = newDate
        }
    }
    
    private func nextWeek() {
        if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentDate) {
            currentDate = newDate
        }
    }
}

// WeekTimeline View Component
private struct WeekTimeline: View {
    let events: [CalendarEvent]
    let currentDate: Date
    private let calendar = Calendar.current
    
    var body: some View {
        HStack(spacing: 0) {
            // Time labels
            VStack(spacing: 0) {
                ForEach(0..<24) { hour in
                    Text(String(format: "%d:00", hour))
                        .font(.caption)
                        .frame(height: 60, alignment: .top)
                        .padding(.top, 8)
                }
            }
            .frame(width: 60)
            
            // Day columns
            HStack(spacing: 0) {
                ForEach(weekDays, id: \.self) { date in
                    VStack(spacing: 0) {
                        // Date header
                        Text(dayFormatter.string(from: date))
                            .font(.subheadline)
                        Text("\(calendar.component(.day, from: date))")
                            .font(.title3)
                            .fontWeight(calendar.isDateInToday(date) ? .bold : .regular)
                        
                        // Day column
                        DayColumnView(date: date, events: eventsForDate(date))
                    }
                    .frame(maxWidth: .infinity)
                    .background(calendar.isDateInToday(date) ? Color.blue.opacity(0.1) : Color.clear)
                }
            }
        }
    }
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
    
    private var weekDays: [Date] {
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
        return (0..<7).map { calendar.date(byAdding: .day, value: $0, to: startOfWeek)! }
    }
    
    private func eventsForDate(_ date: Date) -> [CalendarEvent] {
        events.filter { event in
            calendar.isDate(event.startTime, inSameDayAs: date)
        }
    }
}

// DayColumn View Component
private struct DayColumnView: View {
    let date: Date
    let events: [CalendarEvent]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<24) { hour in
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 60)
                    .overlay(
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 1),
                        alignment: .top
                    )
                    .overlay(
                        EventOverlay(events: eventsInHour(hour))
                    )
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func eventsInHour(_ hour: Int) -> [CalendarEvent] {
        events.filter { event in
            let eventHour = Calendar.current.component(.hour, from: event.startTime)
            return eventHour == hour
        }
    }
}

// Event Overlay Component
private struct EventOverlay: View {
    let events: [CalendarEvent]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(events, id: \.startTime) { event in
                Text(event.title)
                    .lineLimit(1)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(eventBackground(for: event.type))
                    .cornerRadius(4)
            }
        }
        .padding(.horizontal, 4)
    }
    
    private func eventBackground(for type: EventType) -> Color {
        switch type {
        case .meeting:
            return .blue.opacity(0.2)
        case .deadline:
            return .red.opacity(0.2)
        case .task, .reminder:
            return .green.opacity(0.2)
        }
    }
}

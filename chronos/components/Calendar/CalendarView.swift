//
//  DailyCalendar.swift
//  chronos
//
//  Created by Jaskaran Singh on 3/24/25.
//

import SwiftUI

enum CalendarViewType {
    case monthly, weekly, daily
}

struct CalendarDropdownButton: View {
    let selectedViewType: CalendarViewType
    let action: (CalendarViewType) -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Menu {
            ForEach([CalendarViewType.monthly, .weekly, .daily], id: \.self) { type in
                Button(action: { action(type) }) {
                    if type == selectedViewType {
                        Label(type.title, systemImage: "checkmark")
                            .foregroundColor(.primary)
                    } else {
                        Text(type.title)
                            .foregroundColor(.gray)
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: selectedViewType.icon)
                    .foregroundColor(.blue)
                Text(selectedViewType.title)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHovered ? Color.gray.opacity(0.15) : Color.gray.opacity(0.1))
            )
            .onHover { hovering in
                isHovered = hovering
            }
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
    }
}

extension CalendarViewType {
    var title: String {
        switch self {
        case .monthly: return "Month View"
        case .weekly: return "Week View"
        case .daily: return "Day View"
        }
    }
    
    var icon: String {
        switch self {
        case .monthly: return "calendar"
        case .weekly: return "calendar.day.timeline.left"
        case .daily: return "clock"
        }
    }
}

struct CalendarView: View {
    let events: [CalendarEvent]
    var onDateSelected: () -> Void
    
    var body: some View {
        MonthView(
            events: events,
            onDateSelected: onDateSelected
        )
    }
}

struct DailyCalendar: View {
    let events: [CalendarEvent]
    
    var body: some View {
        Text("Daily Calendar View Coming Soon")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

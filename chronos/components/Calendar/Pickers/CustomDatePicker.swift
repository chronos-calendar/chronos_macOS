import SwiftUI

struct CustomDatePicker: View {
    @Binding var selectedDate: Date
    @Binding var isShowing: Bool
    @State private var currentMonth: Date
    @State private var pressedDay: Int? = nil
    
    init(selectedDate: Binding<Date>, isShowing: Binding<Bool>) {
        self._selectedDate = selectedDate
        self._isShowing = isShowing
        self._currentMonth = State(initialValue: selectedDate.wrappedValue)
    }
    
    private struct DayItem: Identifiable {
        let id: String
        let day: Int
        let date: Date?
        let isCurrentMonth: Bool
    }
    
    private func generateDayItems() -> [DayItem] {
        let calendar = Calendar.current
        var items: [DayItem] = []
        
        let days = calendar.range(of: .day, in: .month, for: currentMonth)!.count
        let firstWeekday = calendar.component(.weekday, from: currentMonth.startOfMonth()) - 1
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)!
        let daysInPreviousMonth = calendar.range(of: .day, in: .month, for: previousMonth)!.count
        
        // Previous month days
        for index in 0..<firstWeekday {
            let day = daysInPreviousMonth - firstWeekday + index + 1
            let date = calendar.date(from: DateComponents(
                year: calendar.component(.year, from: previousMonth),
                month: calendar.component(.month, from: previousMonth),
                day: day
            ))
            items.append(DayItem(id: "prev-\(day)", day: day, date: date, isCurrentMonth: false))
        }
        
        // Current month days
        for day in 1...days {
            let date = calendar.date(from: DateComponents(
                year: calendar.component(.year, from: currentMonth),
                month: calendar.component(.month, from: currentMonth),
                day: day
            ))
            items.append(DayItem(id: "current-\(day)", day: day, date: date, isCurrentMonth: true))
        }
        
        return items
    }
    
    // Custom month year formatter that doesn't add comma
    private func formatMonthYear() -> String {
        let month = currentMonth.formatted(.dateTime.month(.wide))
        let year = Calendar.current.component(.year, from: currentMonth)
        return "\(month) \(year)"
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Month and Year
            HStack {
                Text(formatMonthYear())
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                HStack(spacing: 16) {
                    Button {
                        withAnimation {
                            currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                        }
                    } label: {
                        Image(systemName: "chevron.up")
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        withAnimation {
                            currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                        }
                    } label: {
                        Image(systemName: "chevron.down")
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Days of week
            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(28)), count: 7), spacing: 4) {
                ForEach(generateDayItems()) { item in
                    if let date = item.date {
                        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                        let isToday = Calendar.current.isDateInToday(date)
                        
                        Button {
                            if item.isCurrentMonth {
                                pressedDay = item.day
                                withAnimation(.easeOut(duration: 0.2)) {
                                    selectedDate = date
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        isShowing = false
                                    }
                                }
                            }
                        } label: {
                            Text("\(item.day)")
                                .font(.system(size: 12))
                                .frame(width: 28, height: 28)
                                .foregroundColor(
                                    item.isCurrentMonth
                                        ? (isSelected || pressedDay == item.day ? .white : .primary)
                                        : .gray.opacity(0.5)
                                )
                                .background(
                                    ZStack {
                                        if isToday {
                                            Circle()
                                                .stroke(Color.red, lineWidth: 1)
                                        }
                                        if isSelected || pressedDay == item.day {
                                            Circle()
                                                .fill(Color.blue)
                                        }
                                    }
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(!item.isCurrentMonth)
                    }
                }
            }
        }
        .padding(12)
        .background(Color(nsColor: .windowBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.15), radius: 8)
        .frame(width: 240)
    }
}

import SwiftUI
import SwiftData

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

struct EventModal: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String = ""
    @State private var startDate: Date = .now
    @State private var endDate: Date = .now
    @State private var eventType: EventType = .task
    @State private var notifyMembers: Bool = false
    @State private var showNewParticipantField: Bool = false
    @State private var newParticipantEmail: String = ""
    @State private var isAddingNewMember = false
    @State private var newMemberName = ""
    @State private var location: String = ""
    @State private var showDatePicker = false
    @State private var selectedMonth = Date()
    
    @State private var participants: [Participant] = [
        Participant(name: "Adrian", initial: "A", color: .purple),
        Participant(name: "Luca", initial: "L", color: .orange),
        Participant(name: "Caleb", initial: "C", color: .blue)
    ]
    
    private var isToday: (Date) -> Bool = { date in
        Calendar.current.isDateInToday(date)
    }
    
    private func generateDayId(month: Int, day: Int) -> String {
        return "\(month)-\(day)"
    }
    
    private func formatDateForDisplay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d yyyy"
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background overlay for tap to dismiss
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Text("Create Event")
                        .font(.system(size: 28, weight: .semibold))
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .buttonStyle(.plain)
                }
                
                // Event Name
                VStack(alignment: .leading, spacing: 6) {
                    Text("Event Name")
                        .foregroundColor(Color(red: 90/255, green: 90/255, blue: 90/255, opacity: 0.9))
                        .fontWeight(.semibold)
                        .font(.system(size: 13))

                    ZStack(alignment: .leading) {
                        if title.isEmpty {
                            Text("Meeting")
                                .foregroundColor(Color(red: 90/255, green: 90/255, blue: 90/255, opacity: 0.9))
                                .padding(.horizontal, 8)
                        }
                        TextField("", text: $title)
                            .textFieldStyle(.plain)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.2))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(8)
                }
                
                // Date and Location row
                HStack(spacing: 12) {
                    // Date picker section
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Date")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 13))
                        
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) {
                                showDatePicker.toggle()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "calendar")
                                Text(formatDateForDisplay(startDate))
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .rotationEffect(.degrees(showDatePicker ? 180 : 0))
                            }
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Location field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Location")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 13))
                        HStack {
                            Image(systemName: "mappin")
                            TextField("Add location", text: $location)
                        }
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                // Time Start/End
                HStack(spacing: 12) {
                    // Time Start
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Time Start")
                            .foregroundColor(Color(red: 90/255, green: 90/255, blue: 90/255, opacity: 0.9))
                            .fontWeight(.semibold)
                            .font(.system(size: 13))

                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                                .foregroundColor(Color(red: 90/255, green: 90/255, blue: 90/255, opacity: 0.9))
                            Text("10:30 AM")
                                .foregroundColor(Color(red: 90/255, green: 90/255, blue: 90/255, opacity: 0.9))
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(Color(red: 90/255, green: 90/255, blue: 90/255, opacity: 0.9))
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                    }
                    
                    // Time End
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Time End")
                            .foregroundColor(Color(red: 90/255, green: 90/255, blue: 90/255, opacity: 0.9))
                            .fontWeight(.semibold)
                            .font(.system(size: 13))

                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                                .foregroundColor(Color(red: 90/255, green: 90/255, blue: 90/255, opacity: 0.9))
                            Text("11:45 AM")
                                .foregroundColor(Color(red: 90/255, green: 90/255, blue: 90/255, opacity: 0.9))
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(Color(red: 90/255, green: 90/255, blue: 90/255, opacity: 0.9))
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                    }
                }
                
                // Updated Participants section
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Participants")
                            .foregroundStyle(.secondary)
                        Text("\(participants.count)")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(participants) { participant in
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(participant.color)
                                        .frame(width: 24, height: 24)
                                        .overlay(
                                            Text(participant.initial)
                                                .foregroundStyle(.white)
                                                .font(.system(size: 12, weight: .medium))
                                        )
                                    Text("@\(participant.name)")
                                        .foregroundStyle(.primary)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white)
                                .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    
                    if isAddingNewMember {
                        HStack {
                            TextField("Enter member name...", text: $newMemberName)
                                .textFieldStyle(.plain)
                                .onSubmit {
                                    if !newMemberName.isEmpty {
                                        let newParticipant = Participant(
                                            name: newMemberName,
                                            initial: String(newMemberName.prefix(1).uppercased()),
                                            color: [.blue, .green, .orange, .purple].randomElement() ?? .blue
                                        )
                                        participants.append(newParticipant)
                                    }
                                    isAddingNewMember = false
                                    newMemberName = ""
                                }
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    } else {
                        Button(action: {
                            isAddingNewMember = true
                        }) {
                            HStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Image(systemName: "person.2.fill")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 12))
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Invite Team Members")
                                        .fontWeight(.medium)
                                    Text("Invite your teammates to this event")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.leading, 8)
                                
                                Spacer()
                                
                                Image(systemName: "plus")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    }
                }
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)

                // Notify Members Toggle with less spacing
                Toggle("Notify members", isOn: $notifyMembers)
                    .foregroundColor(Color(red: 90/255, green: 90/255, blue: 90/255, opacity: 0.9))
                    .toggleStyle(.checkbox)
                    .padding(.top, 4)
                                
                // Bottom Buttons
                HStack(spacing: 12) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .foregroundColor(.primary)
                    .buttonStyle(.plain)
                    
                    Button("Create Event") {
                        createEvent()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .buttonStyle(.plain)

                }
                .padding(.top, 8)
            }
            .padding(24)
            .frame(width: 460)
            .background(.white)
            .cornerRadius(16)
            
            // Date picker overlay
            if showDatePicker {
                ZStack {
                    // Invisible overlay to handle click-outside
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.2)) {
                                showDatePicker = false
                            }
                        }
                    
                    CustomDatePicker(selectedDate: $startDate, isShowing: $showDatePicker)
                        .position(x: 150, y: 280)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .transition(.opacity)
    }
    
    private func createEvent() {
        let event = CalendarEvent(
            title: title,
            startTime: startDate,
            endTime: endDate,
            isCompleted: false,
            isAllDay: false,
            type: eventType
        )
        
        modelContext.insert(event)
        dismiss()
    }
}

extension Date {
    func startOfMonth() -> Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
    }
}

#Preview {
    EventModal()
        .modelContainer(for: CalendarEvent.self, inMemory: true)
}

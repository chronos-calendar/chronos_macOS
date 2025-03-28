import SwiftUI
import SwiftData
import MapKit

struct EventModal: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String = ""
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var eventType: EventType = .task
    @State private var notifyMembers: Bool = false
    @State private var location: String = ""
    @State private var showStartDatePicker = false
    @State private var showEndDatePicker = false
    @State private var selectedMonth = Date()
    @State private var isAddingNewMember = false
    @State private var newMemberName = ""
    @State private var showNewParticipantField: Bool = false
    @State private var newParticipantEmail: String = ""
    @State private var showStartTimePicker = false
    @State private var showEndTimePicker = false
    
    @State private var participants: [Participant] = [
        
    ]
    
    @State private var searchResults: [MKLocalSearchCompletion] = []
    @StateObject private var searchCompleter = LocationSearchCompleter()
    
    // Initialize with a specific date
    init(initialDate: Date = .now) {
        let calendar = Calendar.current
        // Set the time components to the current time
        let now = Date()
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: now)
        
        // Combine the date from initialDate with the time from now
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: initialDate)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        dateComponents.second = timeComponents.second
        
        let combinedDate = calendar.date(from: dateComponents) ?? initialDate
        
        // Initialize the state properties
        _startDate = State(initialValue: combinedDate)
        _endDate = State(initialValue: combinedDate)
        _startTime = State(initialValue: combinedDate)
        _endTime = State(initialValue: combinedDate)
    }
    
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
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    searchCompleter.showResults = false
                    searchCompleter.results = []
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
                        .foregroundColor(.secondary)
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
                
                // Date and Time row
                HStack(spacing: 12) {
                    // Start Date
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Start Date")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 13))
                        
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) {
                                showStartDatePicker.toggle()
                                showEndDatePicker = false
                            }
                        } label: {
                            HStack {
                                Image(systemName: "calendar")
                                Text(formatDateForDisplay(startDate))
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .rotationEffect(.degrees(showStartDatePicker ? 180 : 0))
                            }
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundStyle(.primary)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // End Date
                    VStack(alignment: .leading, spacing: 6) {
                        Text("End Date")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 13))
                        
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) {
                                showEndDatePicker.toggle()
                                showStartDatePicker = false
                            }
                        } label: {
                            HStack {
                                Image(systemName: "calendar")
                                Text(formatDateForDisplay(endDate))
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .rotationEffect(.degrees(showEndDatePicker ? 180 : 0))
                            }
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundStyle(.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Time Start/End
                ZStack {
                    HStack(spacing: 12) {
                        TimePicker(title: "Time Start", selectedTime: $startTime)
                        TimePicker(title: "Time End", selectedTime: $endTime)
                    }
                }
                .zIndex(2) // Ensure time pickers are above other elements
                
                // Location
                VStack(alignment: .leading, spacing: 6) {
                    Text("Location or Video Call")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 13))

                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            // Change icon to support both location and video calls
                            Image(systemName: location.contains("http") ? "video" : "mappin")
                                .foregroundColor(.primary)
                            TextField("Add location or paste video call link", text: $location)
                                .textFieldStyle(.plain)
                                .font(.system(size: 14, weight: .medium))
                                .onChange(of: location) { _, newValue in
                                    // Only update queryFragment if search is enabled AND not a video call link
                                    if searchCompleter.shouldSearch && !newValue.contains("http") {
                                        searchCompleter.queryFragment = newValue
                                    } else if newValue.contains("http") {
                                        // If it's a video call link, disable location search
                                        searchCompleter.showResults = false
                                        searchCompleter.results = []
                                    }
                                }
                        }
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)

                        // --- Suggestions List ---
                        if searchCompleter.showResults && !searchCompleter.results.isEmpty {
                            ZStack {
                                // Background tap to dismiss (optional but good UX)
                                Color.clear
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        searchCompleter.showResults = false
                                        // Consider clearing results too if desired
                                         searchCompleter.results = []
                                    }

                                ScrollView {
                                    LazyVStack(alignment: .leading, spacing: 0) {
                                        ForEach(searchCompleter.results, id: \.self) { result in
                                            Button {
                                                // Updated implementation for handling suggestion selection
                                                // 1. Store the selected location
                                                let selectedLocation: String
                                                if !result.subtitle.isEmpty {
                                                    selectedLocation = "\(result.title), \(result.subtitle)"
                                                } else {
                                                    selectedLocation = result.title
                                                }
                                                
                                                // 2. Hide results immediately
                                                searchCompleter.showResults = false
                                                searchCompleter.results = []
                                                
                                                // 3. Disable search to prevent onChange handling
                                                searchCompleter.shouldSearch = false
                                                
                                                // 4. Update location text
                                                location = selectedLocation
                                                
                                                // 5. Re-enable search after a delay
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                    searchCompleter.shouldSearch = true
                                                }
                                            } label: {
                                                VStack(alignment: .leading) {
                                                    Text(result.title)
                                                        .font(.system(size: 14))
                                                        .foregroundColor(.primary)
                                                    if !result.subtitle.isEmpty {
                                                        Text(result.subtitle)
                                                            .font(.system(size: 12))
                                                            .foregroundColor(.secondary)
                                                    }
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 12)
                                            }
                                            .buttonStyle(.plain)

                                            if result != searchCompleter.results.last {
                                                Divider()
                                            }
                                        }
                                    }
                                }
                                .frame(maxHeight: 200)
                                .background(Color(nsColor: .windowBackgroundColor)) // Use appropriate background
                                .cornerRadius(8)
                                .shadow(color: .black.opacity(0.15), radius: 8)
                            }
                            // Add zIndex if needed to ensure suggestions appear above other elements
                            // .zIndex(1)
                        }
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
                            
                            // Add red circular X button
                            Button(action: {
                                isAddingNewMember = false
                                newMemberName = ""
                            }) {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Image(systemName: "xmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                            }
                            .buttonStyle(.plain)
                            .padding(.trailing, 8)
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
            
            // Date picker overlays
            if showStartDatePicker {
                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.2)) {
                                showStartDatePicker = false
                            }
                        }
                    
                    CustomDatePicker(selectedDate: $startDate, isShowing: $showStartDatePicker)
                        .position(x: 150, y: 280)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            if showEndDatePicker {
                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.2)) {
                                showEndDatePicker = false
                            }
                        }
                    
                    CustomDatePicker(selectedDate: $endDate, isShowing: $showEndDatePicker)
                        .position(x: 350, y: 280)
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

#Preview {
    EventModal()
        .modelContainer(for: CalendarEvent.self, inMemory: true)
}

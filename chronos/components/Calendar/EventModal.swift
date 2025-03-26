import SwiftUI
import SwiftData

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
    
    @State private var participants: [Participant] = [
        Participant(name: "Adrian", initial: "A", color: .purple),
        Participant(name: "Luca", initial: "L", color: .orange),
        Participant(name: "Caleb", initial: "C", color: .blue)
    ]
    
    var body: some View {
        ZStack {
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
                    // Date
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Date")
                            .foregroundColor(Color(red: 90/255, green: 90/255, blue: 90/255, opacity: 0.9))
                            .fontWeight(.semibold)
                            .font(.system(size: 13))

                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .foregroundColor(Color(red: 90/255, green: 90/255, blue: 90/255, opacity: 0.9))
                            Text(startDate.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                                .foregroundColor(Color(red: 90/255, green: 90/255, blue: 90/255, opacity: 0.9))
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(Color(red: 90/255, green: 90/255, blue: 90/255, opacity: 0.9))
                        }
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Location
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Location")
                            .foregroundColor(Color(red: 90/255, green: 90/255, blue: 90/255, opacity: 0.9))
                            .fontWeight(.semibold)
                            .font(.system(size: 13))

                        HStack(spacing: 8) {
                            Image(systemName: "mappin")
                                .foregroundColor(Color(red: 90/255, green: 90/255, blue: 90/255, opacity: 0.9))
                            TextField("Add location", text: $location)
                                .textFieldStyle(.plain)
                            if !location.isEmpty {
                                Button(action: { location = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
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

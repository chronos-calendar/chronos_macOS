import SwiftUI
import SwiftData

struct EventModal: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title: String = ""
    @State private var startDate: Date = .now
    @State private var endDate: Date = .now
    @State private var eventType: EventType = .task
    @State private var notifyMembers: Bool = false
    @State private var showNewParticipantField: Bool = false
    @State private var newParticipantEmail: String = ""
    
    @State private var participants: [Participant] = [
        Participant(name: "Adrian", initial: "A", color: .purple),
        Participant(name: "Luca", initial: "L", color: .orange),
        Participant(name: "Caleb", initial: "C", color: .blue)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
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
                }
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
            
            // Date
            VStack(alignment: .leading, spacing: 6) {
                Text("Date")
                    .foregroundColor(Color(red: 90/255, green: 90/255, blue: 90/255, opacity: 0.9))
                    .fontWeight(.semibold)
                    .font(.system(size: 13))

                ZStack(alignment: .leading) {
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
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
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
            
            // Participants
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Participants")
                        .foregroundStyle(.secondary)
                    Text("\(participants.count)")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        showNewParticipantField.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                            .font(.system(size: 20))
                    }
                    .buttonStyle(.plain)
                }
                
                // New Participant Input Field
                if showNewParticipantField {
                    HStack {
                        TextField("Enter email address", text: $newParticipantEmail)
                            .textFieldStyle(.plain)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                        
                        Button {
                            // Add participant logic will be added later
                            showNewParticipantField = false
                            newParticipantEmail = ""
                        } label: {
                            Text("Add")
                                .foregroundStyle(.blue)
                                .fontWeight(.medium)
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            showNewParticipantField = false
                            newParticipantEmail = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
                }
                
                HStack(spacing: 4) {
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
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(16)
                    }
                }
            }
            .padding(8)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            
            // Notify Members Toggle
            Toggle("Notify members", isOn: $notifyMembers)
                .foregroundColor(Color(red: 90/255, green: 90/255, blue: 90/255, opacity: 0.9))
                .toggleStyle(.checkbox)
            
            Spacer()
            
            // Bottom Buttons
            HStack {
                Spacer()
                Button("Create Event") {
                    createEvent()
                }
                .frame(width: 200)
                .padding(.vertical, 12)
                .background(Color.green) // Use Color.green for a solid green background
                .cornerRadius(12)
                .foregroundColor(.white) // Text color should be white
                Spacer()
            }
            .padding(.top, 20) // Optional: Add spacing above the button if necessary
        }
        .padding(24)
        .frame(width: 460)
        .background(.white)
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

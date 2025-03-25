import SwiftUI

struct EventModal: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var startDate: Date = .now
    @State private var endDate: Date = .now
    @State private var eventType: EventType = .task
    @State private var notifyMembers: Bool = false
    
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
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                    Menu {
                        ForEach(participants) { participant in
                            Button(action: {
                                // Add toggle selection logic here
                            }) {
                                HStack {
                                    Circle()
                                        .fill(participant.color)
                                        .frame(width: 16, height: 16)
                                        .overlay(
                                            Text(participant.initial)
                                                .foregroundStyle(.white)
                                                .font(.system(size: 10, weight: .medium))
                                        )
                                    Text(participant.name)
                                    Spacer()
                                    // Add checkmark for selected participants
                                }
                            }
                        }
                    }
                        
                        Divider()
                        
                        Button("Add New Participant") {
                            // Add new participant action
                        }
                    }
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
            
            // Invite Team Members
            HStack(spacing: 12) {
                HStack(spacing: -8) {
                    ForEach(0..<3) { _ in
                        Circle()
                            .fill(Color(nsColor: .controlBackgroundColor))
                            .frame(width: 24, height: 24)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundStyle(.blue)
                                    .font(.caption)
                            )
                    }
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Invite Team Members")
                        .fontWeight(.medium)
                    Text("Invite your teammates to this event")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("+")
                    .font(.system(size: 20))
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
            .cornerRadius(12)
            
            // Notify Members Toggle
            Toggle("Notify members", isOn: $notifyMembers)
                .toggleStyle(.checkbox)
            
            Spacer()
            
            // Bottom Buttons
            HStack(spacing: 12) {
                Button("Cancel") {
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(12)
                .foregroundStyle(.primary)
                
                Button("Create Event") {
                    // Add event creation logic if needed
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.black)
                .foregroundStyle(.white)
                .cornerRadius(12)
            }
        }
        .padding(24)
        .frame(width: 460)
        .background(.white)
    }
}

struct EventModal_Previews: PreviewProvider {
    static var previews: some View {
        EventModal()
    }
}

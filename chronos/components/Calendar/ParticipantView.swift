import SwiftUI

struct Participant: Identifiable {
    let id = UUID()
    let name: String
    let initial: String
    let color: Color
}

struct ParticipantView: View {
    let participant: Participant
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(participant.color)
                .frame(width: 24, height: 24)
                .overlay(
                    Text(participant.initial)
                        .foregroundStyle(.white)
                        .font(.caption)
                        .fontWeight(.medium)
                )
            Text("@\(participant.name)")
                .foregroundStyle(.secondary)
        }
    }
}

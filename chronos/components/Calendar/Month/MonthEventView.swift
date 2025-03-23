import SwiftUI

struct EventView: View {
    let event: CalendarEvent
    
    var body: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .frame(width: 4, height: 30)
                .foregroundColor(getEventColor(type: event.type))
            
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
        .background(getEventColor(type: event.type).opacity(0.1))
        .cornerRadius(4)
    }
    
    private func getEventColor(type: EventType) -> Color {
        switch type {
        case .meeting:
            return .blue
        case .deadline:
            return .red
        case .reminder:
            return .orange
        case .task:
            return .purple
        }
    }
}

#Preview {
    let sampleEvent = CalendarEvent(title: "Team Meeting", startTime: Date(), endTime: Date(), isCompleted: false)
    EventView(event: sampleEvent)
        .padding()
}

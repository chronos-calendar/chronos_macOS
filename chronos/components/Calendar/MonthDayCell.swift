import SwiftUI
import SwiftData

struct DayCell: View {
    let date: Date
    let events: [CalendarEvent]
    @State private var isHovered = false
    
    private var isCurrentDate: Bool {
        Calendar.current.isDate(date, inSameDayAs: Date())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Date number with conditional circle for current date
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isCurrentDate ? .white : .black)
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                    .fill(isCurrentDate ? .blue : .clear)
                )
                .padding(.bottom, 1)
                .padding(.leading, -4)  // Align more to the left
            
                .padding()           // Events list
            VStack(alignment: .leading, spacing: 2) {
                ForEach(events, id: \.title) { event in
                    EventView(event: event)
                        .padding(2)
                }   
            }
            
            Spacer() // Push everything to the top
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .background(
            RoundedRectangle(cornerRadius: 14)
            .fill(Color.white)
            .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .background(isHovered ? Color.gray.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

#Preview {
    DayCell(
        date: Date(),
        events: [
            CalendarEvent(title: "Assessment", startTime: Date(), endTime: Date().addingTimeInterval(3600), isCompleted: false),
            CalendarEvent(title: "Review", startTime: Date(), endTime: Date().addingTimeInterval(3600), isCompleted: true)
        ]
    )
}

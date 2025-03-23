// MARK: - Weekday Header Component
import SwiftUI
import Foundation

struct CalendarWeekdayHeader: View {
    let startDayOfWeek: Int
    let cellWidth: CGFloat
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { index in
                let weekdayIndex = (startDayOfWeek + index - 1) % 7 + 1
                Text(getWeekdayName(weekdayIndex))
                    .font(.system(size: 12))
                    .fontWeight(.medium)
                    .foregroundColor(.gray.opacity(0.8))
                    .frame(width: cellWidth, height: 30)
            }
        }
        .background(Color.white)
        .overlay(alignment: .bottom) {
            Divider().background(Color.gray.opacity(0.2))
        }
    }
    
    private func getWeekdayName(_ weekday: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        var components = DateComponents()
        components.weekday = weekday
        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date)
        }
        return ""
    }
}

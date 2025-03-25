import SwiftUI
import Foundation

struct CalendarMonthHeader: View {
    @Binding var currentMonthDate: Date
    
    var body: some View {
        HStack {
            Text(getFormattedDate(from: currentMonthDate))
                .foregroundColor(.black)
                .font(.system(size: 16, weight: .semibold))
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private func getFormattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}
import SwiftUI
import Foundation

struct CalendarMonthHeader: View {
    @Binding var currentMonthDate: Date
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void
    
    var body: some View {
        HStack {
            Text(getFormattedMonthYear())
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: onPreviousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                }
                
                Button(action: onNextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private func getFormattedMonthYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonthDate)
    }
}
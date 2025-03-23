import SwiftUI
import Foundation

struct MonthDayCell: View {
    // MARK: - Properties
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let events: [CalendarEvent]
    let cellWidth: CGFloat
    let cellHeight: CGFloat
    
    private let calendar = Calendar.current
    
    private var day: Int {
        calendar.component(.day, from: date)
    }
    
    private var isFirstDayOfMonth: Bool {
        calendar.component(.day, from: date) == 1
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Day number row
            HStack(alignment: .top) {
                Text(String(day))
                    .font(.system(size: 14))
                    .fontWeight(isToday ? .semibold : .regular)
                    .foregroundColor(dayNumberColor)
                    .padding(.top, 6)
                    .padding(.leading, 8)
                
                Spacer()
                
                // Month indicator for first day of month
                if isFirstDayOfMonth && !isCurrentMonth {
                    Text(getMonthAbbreviation())
                        .font(.system(size: 10))
                        .foregroundColor(.gray.opacity(0.8))
                        .padding(.top, 6)
                        .padding(.trailing, 8)
                }
            }
            
            // Events list
            
            Spacer()
        }
        .frame(width: cellWidth, height: cellHeight)
        .background(cellBackground)
        .overlay(cellBorder)
    }
    
    // MARK: - Computed Properties
    private var dayNumberColor: Color {
        if isToday {
            return .blue
        } else if isCurrentMonth {
            return .black
        } else {
            return .gray.opacity(0.6)
        }
    }
    
    private var cellBackground: some View {
        Group {
            if isToday {
                Color.blue.opacity(0.1)
            } else {
                Color.white
            }
        }
    }
    
    private var cellBorder: some View {
        Group {
            if isSelected && !isToday {
                Rectangle()
                    .stroke(Color.blue.opacity(0.5), lineWidth: 1)
            } else {
                Rectangle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
            }
        }
    }
    
    // MARK: - Methods
    private func getMonthAbbreviation() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
}

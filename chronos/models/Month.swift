import Foundation

struct MonthData: Identifiable, Equatable {
    let id: String
    let date: Date
    
    init(date: Date) {
        self.date = date
        let calendar = Calendar.current
        self.id = "\(calendar.component(.month, from: date))-\(calendar.component(.year, from: date))"
    }
    
    static func == (lhs: MonthData, rhs: MonthData) -> Bool {
        lhs.id == rhs.id
    }
}

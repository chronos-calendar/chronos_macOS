//
//  Event.swift
//  chronos
//
//  Created by Prasanth Dendukuri on 3/17/25.
//

import Foundation
import SwiftData

// Event type enum to categorize different events
enum EventType: String, Codable {
    case meeting
    case deadline
    case reminder
    case task
}

@Model
class CalendarEvent{
    var title: String
    var startTime: Date
    var endTime: Date
    var isCompleted: Bool
    var isAllDay: Bool
    var type: EventType
    
    var timeString: String? {
        if isAllDay {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: startTime)
    }
    
    init(title: String, startTime: Date, endTime: Date, isCompleted: Bool, isAllDay: Bool = false, type: EventType = .task){
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.isCompleted = isCompleted
        self.isAllDay = isAllDay
        self.type = type
    }
}

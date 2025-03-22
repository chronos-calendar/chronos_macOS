//
//  Event.swift
//  chronos
//
//  Created by Prasanth Dendukuri on 3/17/25.
//


import Foundation
import SwiftData


@Model
class CalendarEvent{
    var title: String
    var startTime: Date
    var endTime: Date
    var isCompleted: Bool
    
    init(title: String, startTime: Date, endTime: Date, isCompleted: Bool ){
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.isCompleted = isCompleted
    }
}

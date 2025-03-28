//
//  Task.swift
//  chronos
//
//  Created by Prasanth Dendukuri on 2/13/25.
//
import Foundation
import SwiftData
// Remove CoreData imports and implementation
// Add SwiftData model
@Model
class Task {
    var id: UUID
    var name: String
    var isCompleted: Bool
    var group: TaskGroup?

    init(name: String, isCompleted: Bool = false, group: TaskGroup = .inbox) {
        self.id = UUID()
        self.name = name
        self.isCompleted = isCompleted
        self.group = group
    }
}

enum TaskGroup: String, CaseIterable, Codable {
    case all, inbox, today, future
}

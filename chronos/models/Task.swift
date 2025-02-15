//
//  Task.swift
//  chronos
//
//  Created by Prasanth Dendukuri on 2/13/25.
//
import Foundation


struct Task: Identifiable {
    var id: UUID = UUID()
    var name: String
    var isCompleted: Bool = false
}

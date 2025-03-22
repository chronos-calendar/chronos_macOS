//
//  CalendarEventView.swift
//  chronos
//
//  Created by Prasanth Dendukuri on 3/17/25.
//

import SwiftUI

struct CalendarEventView: View {
    let event: CalendarEvent
    
    var body: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 9)
                .frame(width: 5, height: 25)
            
            Text(event.title)
                .font(.system(size: 11))
                .lineLimit(1)
            
            Spacer()
            
            Text(event.startTime, style: .time)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 4)
        .cornerRadius(4)
    }
}
#Preview {
    let sampleEvent = CalendarEvent(title: "Team Meeting", startTime: Date(), endTime: Date(), isCompleted: false)
    CalendarEventView(event: sampleEvent)
        .padding()
}

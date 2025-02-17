//
//  TaskList.swift
//  chronos
//
//  Created by Prasanth Dendukuri on 2/16/25.
//

import SwiftUI
import SwiftData
import Inject

struct TaskListView: View {
    
    
    @Query private var tasks: [Task]
    @State private var fillerText: String = ""
    @Environment(\.modelContext) var modelContext
    @ObserveInjection var inject
    @ObserveInjection var forceRedraw

    var body: some View {
        VStack {
            ZStack {
                // Gray background
                RoundedRectangle(cornerRadius: 10)
//                    .fill(Color.gray.opacity(0.1)) // Light gray background
                    .frame(width: 100, height: 40) // Match TextField height

                // TextField with placeholder
                ZStack(alignment: .leading) {
                    // Custom gray placeholder (only visible when fillerText is empty)
                    if fillerText.isEmpty {
                        Text("meeting @ 2pm")
                            .foregroundColor(Color.gray) // Placeholder text color
                            .padding(.horizontal, 25) // Align with input text
                    }
                    
                    // Actual TextField
                    TextField("", text: $fillerText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2)) // Gray background
                        )
                        .foregroundColor(Color.black.opacity(0.9)) // User input text color
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .onSubmit {
                            addTask(text: fillerText)
                        }

                }


            }
            .padding(.horizontal) // Adds some spacing from screen edge
            
            List {
                ForEach(tasks) { task in
                    TaskView(text: task.name)
                }
//                .onDelete(perform: deleteTasks)
            }
        }
        .navigationTitle("Tasks")
        .background(Color.white)
        .enableInjection()
       
    }
    @ObserveInjection var redraw


    
    private func addTask(text: String) {
        guard !fillerText.isEmpty else { return }
        
        let newTask = Task(name: text)
        modelContext.insert(newTask)
        fillerText = ""
    }
    
    
}

#Preview {
    TaskListView()
        .modelContainer(for: Task.self)
}

// End of file. No additional code.

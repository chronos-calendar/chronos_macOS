//
//  TaskList.swift
//  chronos
//
//  Created by Prasanth Dendukuri on 2/16/25.
//

import SwiftUI
import CoreData

struct TaskListView: View {
    
    @Query private var tasks: [Task]
    @State private var fillerText: String = ""
    var selectedGroup: TaskGroup

    private var filteredTasks: [Task] {
    switch selectedGroup {
    case .all:
        return tasks
    case .inbox, .today, .future:
        return tasks.filter { $0.group == selectedGroup }
    }
}

    

    @Environment(\.modelContext) var modelContext
    
    var body: some View {

        VStack(spacing: 0) {
            ZStack {
                // Gray background
                RoundedRectangle(cornerRadius: 10)
                   .fill(Color.gray.opacity(0.1)) // Light gray background
                    .frame(width: 100, height: 40) // Match TextField height

                // TextField with placeholder
                ZStack(alignment: .leading) {
                    // Custom gray placeholder (only visible when fillerText is empty)
                    if fillerText.isEmpty {
                        Text("meeting @ 2pm")
                            .foregroundColor(Color.gray) // Placeholder text color
                            .padding(.horizontal, 32)
                            
                    }
                    
                    // task name text field
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
            .padding(.horizontal)
            
            List {
                ForEach(filteredTasks) { task in
                    TaskView(
                            text: task.name,
                            onDelete: {
                                modelContext.delete(task)
                            }
                        )


                }
                .onDelete(perform: deleteTask)
            }
            .background(Color.white) // Set List background to white
            .scrollContentBackground(.hidden)


        }

        .background(Color.chronosBackground)

    }


    
    private func addTask(text: String) {
    guard !fillerText.isEmpty else { return }
    
    // When adding a task, always set its group to the current selected group
    // If we're in "all", use inbox as default
    let taskGroup = selectedGroup == .all ? .inbox : selectedGroup
    let newTask: Task = Task(name: text, group: taskGroup)
    modelContext.insert(newTask)
    fillerText = ""
    print("Current selectedGroup: \(selectedGroup), Added task '\(text)' to group '\(taskGroup)'")
}

    
    private func deleteTask(at offsets: IndexSet) {
            for index in offsets {
                let task = filteredTasks[index]
                modelContext.delete(task) // Delete the task from the model context
            }
        }


    
    
}

//#Preview {
//    TaskListView()
//        .modelContainer(for: Task.self)
//}

// End of file. No additional code.

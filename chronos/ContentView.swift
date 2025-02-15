import SwiftUI

struct ContentView: View {
    @State private var tasks: [Task] = []
    @State private var fillerText: String = ""
    var body: some View {
        NavigationView {
            VStack {
                TextField(
                    "meeting @ 2 pm",
                    text: $fillerText
                    
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit{
                    addTask(text: fillerText)
                }
                List {
                    ForEach($tasks) { task in
                        TaskView(text: fillerText)
                    }
                    .onDelete(perform: deleteTasks)
                }
            }
            .navigationTitle("Tasks")
            .background(Color.white)
        }
        .background(Color.white)

    }
    
    private func addTask(text: String) {
        
        guard !fillerText.isEmpty else { return }
        let newTask = Task(name: text)
                tasks.append(newTask)
//                fillerText = ""

    }

    private func deleteTasks(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
}

#Preview {
    ContentView()
}

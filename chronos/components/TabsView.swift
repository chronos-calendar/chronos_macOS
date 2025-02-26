    import SwiftUI
    import SwiftData

    struct TabsView: View {
        @Binding var selectedTab: TaskGroup
        @State private var hoverTab: TaskGroup? = nil
        
        // Query all tasks to calculate counts
        @Query private var tasks: [Task]
        
        let tabWidth: CGFloat = 45
        
        var body: some View {
            HStack(spacing: 0) {
                ForEach(TaskGroup.allCases, id: \.self) { group in
                    tabView(for: group)
                }
            }
            .padding(.horizontal)
            .frame(height: 40)
        }
        
        // Calculate count for a specific group
        private func count(for group: TaskGroup) -> Int {
            if group == .all {
                return tasks.count
            } else {
            return tasks.filter { $0.group == group }.count
        }
    }
    
    private func tabView(for group: TaskGroup) -> some View {
        Button(action: {
            selectedTab = group
        }) {
            VStack(spacing: 4) {
                HStack {
                    Text(group.rawValue.capitalized)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(selectedTab == group ? .black : .gray)
                        .frame(width: tabWidth, alignment: .center)
                    Text("\(count(for: group))")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(selectedTab == group ? .black : .gray)
                }
                RoundedRectangle(cornerRadius: 1)
                    .fill(selectedTab == group ? Color.blue : Color.clear)
                    .frame(height: 2)
                    .padding(.horizontal, 10)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(hoverTab == group ? Color.gray.opacity(0.2) : Color.clear)
        .onHover { hovering in
            hoverTab = hovering ? group : nil
        }
    }
}

// For preview purposes
struct TabsView_Previews: PreviewProvider {
    static var previews: some View {
        TabsView(selectedTab: .constant(.all))
    }
}

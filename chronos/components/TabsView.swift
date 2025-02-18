import SwiftUI

struct TabsView: View {
    @State private var selectedTab: Int = 0 // Track the selected tab
    @State private var hoverTab: Int? = nil // Track which tab is hovered
    let tabs = ["All", "Inbox", "Today", "Upcoming"] // Tab titles
    let counts = [2, 2, 0, 0] // Example counts for each tab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    selectedTab = index
                }) {
                    VStack(spacing: 4) { // Use VStack for title and indicator
                        HStack{
                            Text("\(tabs[index])")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedTab == index ? .black : .gray) // Highlight selected tab
                            Text("\(counts[index])")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(selectedTab == index ? .black : .gray) // Highlight selected tab
                        }
                        
                        
                        RoundedRectangle(cornerRadius: 1)
                            .fill(selectedTab == index ? Color.blue : Color.clear) // Blue indicator for selected tab
                            .frame(height: 2)
                            .padding(.horizontal, 10) // Match width to text
                    }
                }
                .buttonStyle(PlainButtonStyle()) // Remove button styling
                .frame(maxWidth: .infinity) // Distribute tabs evenly
                .background(hoverTab == index ? Color.gray.opacity(0.2) : Color.clear) // Hover background
                .onHover { hovering in
                    hoverTab = hovering ? index : nil // Track hover state
                }
            }
        }
        .padding(.horizontal) // Add horizontal padding to the entire HStack
        .frame(height: 40) // Set a fixed height for the tab bar
    }
}

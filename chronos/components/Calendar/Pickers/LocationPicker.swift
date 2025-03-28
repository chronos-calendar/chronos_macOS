import SwiftUI
import MapKit
import CoreLocation

struct LocationPicker: View {
    @Binding var location: String
    @State private var searchResults: [MKLocalSearchCompletion] = []
    @State private var showResults = false
    @State private var searchTerm = ""
    
    private let searchCompleter = MKLocalSearchCompleter()
    @StateObject private var completerDelegate = SearchCompleterDelegate()
    
    init(location: Binding<String>) {
        self._location = location
        searchCompleter.resultTypes = .address
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Location")
                .foregroundStyle(.secondary)
                .font(.system(size: 13))
            
            VStack(alignment: .leading, spacing: 0) {
                // Search field
                HStack(spacing: 8) {
                    Image(systemName: "mappin")
                        .foregroundColor(.primary)
                    TextField("Add location", text: $searchTerm)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14, weight: .medium))
                        .onChange(of: searchTerm) { _, newValue in
                            location = newValue
                            if !newValue.isEmpty {
                                searchCompleter.queryFragment = newValue
                                showResults = true
                            } else {
                                showResults = false
                            }
                        }
                }
                .padding(8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                
                // Search results
                if showResults && !searchResults.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(searchResults, id: \.self) { result in
                                Button(action: {
                                    searchTerm = result.title
                                    location = result.title
                                    showResults = false
                                }) {
                                    VStack(alignment: .leading) {
                                        Text(result.title)
                                            .font(.system(size: 14))
                                        if !result.subtitle.isEmpty {
                                            Text(result.subtitle)
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                }
                                .buttonStyle(.plain)
                                
                                if result != searchResults.last {
                                    Divider()
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                    .background(Color(nsColor: .windowBackgroundColor))
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.15), radius: 8)
                }
            }
        }
        .onAppear {
            searchCompleter.delegate = completerDelegate
            completerDelegate.onUpdate = { results in
                searchResults = results
            }
        }
    }
}

class SearchCompleterDelegate: NSObject, MKLocalSearchCompleterDelegate, ObservableObject {
    var onUpdate: (([MKLocalSearchCompletion]) -> Void)?
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        onUpdate?(completer.results)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer error: \(error)")
    }
}
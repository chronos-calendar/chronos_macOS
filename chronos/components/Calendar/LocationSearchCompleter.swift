import MapKit

class LocationSearchCompleter: NSObject, ObservableObject {
    @Published var results: [MKLocalSearchCompletion] = []
    @Published var showResults: Bool = false
    @Published var shouldSearch: Bool = true
    
    private let searchCompleter = MKLocalSearchCompleter()
    
    var queryFragment: String = "" {
        didSet {
            if shouldSearch && !queryFragment.isEmpty {
                searchCompleter.queryFragment = queryFragment
                showResults = true
            } else {
                showResults = false
                results = []
            }
        }
    }
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = [.pointOfInterest, .address, .query]
        searchCompleter.filterType = .locationsAndQueries
    }
    
    func disableSearch() {
        shouldSearch = false
        showResults = false
        results = []
        queryFragment = ""
    }
    
    func enableSearch() {
        shouldSearch = true
    }
}

extension LocationSearchCompleter: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Location search failed with error: \(error.localizedDescription)")
        results = []
    }
}

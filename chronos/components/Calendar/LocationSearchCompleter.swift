import MapKit

class LocationSearchCompleter: NSObject, ObservableObject {
    @Published var results: [MKLocalSearchCompletion] = []
    
    private let searchCompleter = MKLocalSearchCompleter()
    
    var queryFragment: String = "" {
        didSet {
            searchCompleter.queryFragment = queryFragment
            showResults = !queryFragment.isEmpty
        }
    }
    
    @Published var showResults: Bool = false
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        
        // Configure to include POIs and addresses
        searchCompleter.resultTypes = [.pointOfInterest, .address, .query]
        
        // Set filter type to include POIs
        searchCompleter.filterType = .locationsAndQueries
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

//
//  InsertLocationViewModel.swift
//  itinerarymaker
//
//  Created by Jovanna Melissa on 25/05/24.
//

import Foundation
import MapKit
import Combine

class InsertLocationViewModel: NSObject, ObservableObject {
    @Published var searchText = ""
    @Published var suggestions: [MKLocalSearchCompletion] = []
    
    private var cancellable: AnyCancellable?
    private var searchCompleter = MKLocalSearchCompleter()

    override init() {
        super.init()
        searchCompleter.delegate = self
        cancellable = $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink(receiveValue: { [weak self] query in
                self?.searchCompleter.queryFragment = query
            })
    }
}

extension InsertLocationViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.suggestions = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}



//
//  ContentView.swift
//  itinerarymaker
//
//  Created by Jovanna Melissa on 14/05/24.
//

import SwiftUI
import SwiftData
import MapKit

struct ContentView: View {
    @State private var route: MKRoute?
    @State private var totalTravelTime: TimeInterval = 0.0
    @State private var travelTime: String?
//    var destinations = [CLLocationCoordinate2D(latitude: 40.7484, longitude: -73.9857), CLLocationCoordinate2D(latitude: 40.8075, longitude: -73.9626), CLLocationCoordinate2D(latitude: 40.706001, longitude: -73.997002)]
    @State private var routes:[MKRoute?] = []
    @State private var searchQuery:String = ""
    @State private var searchResults:[MKMapItem]=[]
//    let park = CLLocationCoordinate2D(latitude: 40.7063, longitude: -74.1973)
    @State var source:CLLocationCoordinate2D?
    @State var finish:CLLocationCoordinate2D?
    @State var destinations:[CLLocationCoordinate2D?] = []
    @State private var selectedItem:MKMapItem?
    @State private var addressCoordinate:CLLocationCoordinate2D?
    @State private var timeTemp1 = 1000000.0

    var body: some View {
        NavigationStack{
            Map(selection: $selectedItem) {
//                Marker("Empire State Building", coordinate: .empireStateBuilding)
//                                .tint(.orange)
//                
//                            Annotation("Weequahic Park", coordinate: .weequahicPark){
//                                Circle()
//                            }
//                
//                            Annotation("Columbia University", coordinate: .columbiaUniversity){
//                                ZStack{
//                                    Circle()
//                                    Text("📚")
//                                }
//                            }
                
                ForEach(0..<routes.count, id: \.self) { index in
                        let route = routes[index]
                        MapPolyline(route!.polyline)
                            .stroke(Color.blue, lineWidth: 8)
                }
                
                ForEach(searchResults, id: \.self) { result in
                    Marker(item: result)
                }
                        
            }
            .ignoresSafeArea()
            .searchable(text: $searchQuery, placement: .navigationBarDrawer, prompt: "Locations")
            .onSubmit(of: .search) {
                self.search(for: searchQuery)
            }
//            .onAppear(perform: {
//                fetchRouteFrom(destinations: destinations)
//            })
//    
            .overlay(alignment: .bottom, content: {
                HStack {
                    if let travelTime {
                        Text("Travel time: \(travelTime)")
                            .padding()
                            .font(.headline)
                            .foregroundStyle(.black)
                            .background(.ultraThinMaterial)
                            .cornerRadius(15)
                    }
                }
            })
            .navigationTitle("Location Search")
        }
        
        Button(action: {fetchOptimizedRouteFrom(destinations: destinations, apiKey: "AIzaSyCPmcKGFLXqJQtlsstygllMmEV-tfdspJA")}, label: {
            Text("Start")
        })
    }
}

#Preview {
    ContentView()
}

extension ContentView {
    
    private func fetchOptimizedRouteFrom(destinations: [CLLocationCoordinate2D?], apiKey: String) {
        guard destinations.count > 1 else { return }
            
            let start = destinations[0]!
            let finish = destinations[destinations.count-1]!
            
            var waypoints = destinations[1..<destinations.count-1].compactMap { $0 }
            
            func coordinateToString(_ coordinate: CLLocationCoordinate2D) -> String {
                return "\(coordinate.latitude),\(coordinate.longitude)"
            }
            
            let origin = coordinateToString(start)
            let destination = coordinateToString(finish)
            let intermediates = waypoints.map { coordinateToString($0) }.joined(separator: "|")
        
            print("Origin: \(origin)")
            print("Destination: \(destination)")
            print("Intermediates: \(intermediates)")
            
            let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&waypoints=optimize:true|\(intermediates)&key=\(apiKey)"
            
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Network Error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("Error: No data received")
                    return
                }
                
                // Log the raw JSON response for debugging
                if let rawResponse = String(data: data, encoding: .utf8) {
                    print("Raw JSON response: \(rawResponse)")
                } else {
                    print("Error: Unable to convert data to String")
                    return
                }
                
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let routes = jsonResponse["routes"] as? [[String: Any]],
                       let route = routes.first,
                       let waypointOrder = route["waypoint_order"] as? [Int] {
                        
                        var orderedDestinations = [start]
                        orderedDestinations += waypointOrder.map { waypoints[$0] }
                        orderedDestinations.append(finish)
                        
                        DispatchQueue.main.async {
                            self.fetchRouteFrom(destinations: orderedDestinations)
                        }
                    } else {
                        print("Error: Invalid JSON structure")
                    }
                } catch {
                    print("Error: Unable to parse JSON response - \(error.localizedDescription)")
                }
            }
            
            task.resume()
    }
    
    private func fetchRouteFrom(destinations: [CLLocationCoordinate2D?]) {
        var previousLoc = destinations[0]
        
            for i in 1..<destinations.count {
                let request = MKDirections.Request()
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: previousLoc!))
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinations[i]!))
                request.transportType = .automobile
                request.requestsAlternateRoutes = true
                
                Task {
                            let result = try? await MKDirections(request: request).calculate()
                            if let route = result?.routes.first {
                                routes.append(route)
                                totalTravelTime += route.expectedTravelTime
                                getTravelTime()
                            }
                        }
                
                previousLoc = destinations[i]
            }
        
        
//        getTravelTime()
    }
    
    private func getTravelTime() {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        travelTime = formatter.string(from: totalTravelTime)
    }
    
    private func search(for query: String) {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.resultTypes = .pointOfInterest
//            request.region = MKCoordinateRegion(
//                center: park,
//                span: MKCoordinateSpan(
//                    latitudeDelta: 0.0125,
//                    longitudeDelta: 0.0125
//                )
//            )
            Task {
                let search = MKLocalSearch(request: request)
                let response = try? await search.start()
                searchResults = response?.mapItems ?? []
//                print(searchResults)
                addDestination(address: searchResults[0])
                print(destinations)
            }
        }
    
    private func addDestination(address:MKMapItem?){
        if let address{
            addressCoordinate = address.placemark.location?.coordinate
        }
        
        self.destinations.append(addressCoordinate)
    }
}

extension CLLocationCoordinate2D {
    static let weequahicPark = CLLocationCoordinate2D(latitude: 40.7063, longitude: -74.1973)
    static let empireStateBuilding = CLLocationCoordinate2D(latitude: 40.7484, longitude: -73.9857)
    static let columbiaUniversity = CLLocationCoordinate2D(latitude: 40.8075, longitude: -73.9626)
}

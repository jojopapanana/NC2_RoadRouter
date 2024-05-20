//
//  RouteAPI.swift
//  itinerarymaker
//
//  Created by Jovanna Melissa on 19/05/24.
//

import Foundation
import MapKit

class LocationViewModel: ObservableObject{
    @Published var routes:[MKRoute?] = []
    @Published var totalTravelTime:TimeInterval = 0.0
    @Published var travelTime: String?
    @Published var optimizedLocationNames:[String?] = []
    
    func fetchOptimizedRouteFrom(destinations: [CLLocationCoordinate2D?], apiKey: String, locationNames:[String?]) {
        guard destinations.count > 1 else { return }
            
            let start = destinations[0]!
            let finish = destinations[destinations.count-1]!
            
            let waypoints = destinations[1..<destinations.count-1].compactMap { $0 }
            
            func coordinateToString(_ coordinate: CLLocationCoordinate2D) -> String {
                return "\(coordinate.latitude),\(coordinate.longitude)"
            }
            
            let origin = coordinateToString(start)
            let destination = coordinateToString(finish)
            let intermediates = waypoints.map { coordinateToString($0) }.joined(separator: "|")
            
            let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&waypoints=optimize:true|\(intermediates)&key=\(apiKey)"
            
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                return
            }
            
        let task = URLSession.shared.dataTask(with: url) { [self] data, response, error in
                if let error = error {
                    print("Network Error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("Error: No data received")
                    return
                }
                
                // Log the raw JSON response for debugging
//                if let rawResponse = String(data: data, encoding: .utf8) {
//                    print("Raw JSON response: \(rawResponse)")
//                } else {
//                    print("Error: Unable to convert data to String")
//                    return
//                }
                
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let routes = jsonResponse["routes"] as? [[String: Any]],
                       let route = routes.first,
                       let waypointOrder = route["waypoint_order"] as? [Int] {
                        
                        var orderedDestinations = [start]
                        orderedDestinations += waypointOrder.map { waypoints[$0] }
                        orderedDestinations.append(finish)
                        print("order: \(orderedDestinations)")
                        
                        DispatchQueue.main.async {
                            self.optimizedLocationNames = [locationNames[0]]
                            // for loop untuk masukin nama address nya sesuai urutan yang udah optimized
                            for i in 0..<waypointOrder.count{
                                self.optimizedLocationNames.append(locationNames[waypointOrder[i]+1])
                            }
                            // untuk masukin nama address terakhir
                            self.optimizedLocationNames.append(locationNames[locationNames.count-1])
                            print("fixed names: \(optimizedLocationNames)")
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
    
    func fetchRouteFrom(destinations: [CLLocationCoordinate2D?]) {
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
                    DispatchQueue.main.async{
                        //DispatchQueue.main.async memastikan routes, totaltraveltime di update di main thread
                        self.routes.append(route)
                        self.totalTravelTime += route.expectedTravelTime
                        self.getTravelTime()
                    }
                }
            }
            
            previousLoc = destinations[i]
        }
    }
    
    func getTravelTime() {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        DispatchQueue.main.async{
            self.travelTime = formatter.string(from: self.totalTravelTime)
        }
    }
}
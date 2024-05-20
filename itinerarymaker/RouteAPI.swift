//
//  RouteAPI.swift
//  itinerarymaker
//
//  Created by Jovanna Melissa on 19/05/24.
//

import Foundation

class RouteAPI: ObservableObject{
    func fetchRoute(){
        let url = URL(string: "https://routes.googleapis.com/directions/v2:computeRoutes")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("YOUR_API_KEY", forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue("routes.optimizedIntermediateWaypointIndex", forHTTPHeaderField: "X-Goog-FieldMask")

        let parameters: [String: Any] = [
            "origin": [
                "address": "Adelaide,SA"
            ],
            "destination": [
                "address": "Adelaide,SA"
            ],
            "intermediates": [
                ["address": "Barossa+Valley,SA"],
                ["address": "Clare,SA"],
                ["address": "Connawarra,SA"],
                ["address": "McLaren+Vale,SA"]
            ],
            "travelMode": "DRIVE",
            "optimizeWaypointOrder": "true"
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error: Unable to serialize JSON")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Error: No data received")
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Response JSON: \(jsonResponse)")
                }
            } catch {
                print("Error: Unable to parse JSON response")
            }
        }

        task.resume()
    }
}

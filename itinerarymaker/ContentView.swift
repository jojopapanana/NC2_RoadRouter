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
//    @State private var totalTravelTime: TimeInterval = 0.0
//    @State private var travelTime: String?
//    @State private var routes:[MKRoute?] = []
    @State private var searchQuery:String = ""
    @State private var searchResults:[MKMapItem]=[]
    @State private var destinations:[CLLocationCoordinate2D?] = []
    @State private var selectedItem:MKMapItem?
    @State private var addressCoordinate:CLLocationCoordinate2D?
    @State private var locationNames:[String?]=[]
    @ObservedObject private var vm = LocationViewModel()

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
                
                ForEach(0..<vm.routes.count, id: \.self) { index in
                    let route = vm.routes[index]
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
            .overlay(alignment: .bottom, content: {
                HStack {
                    if let identifier = (vm.travelTime) {
                        Text("Travel time: \(identifier)")
                            .padding()
                            .font(.headline)
                            .foregroundStyle(.black)
                            .background(.ultraThinMaterial)
                            .cornerRadius(15)
                    }
                }
            })
            .navigationTitle("Search for Locations")
        }
        
        if(!locationNames.isEmpty){
            VStack{
                Text("Your selected locations:")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                List{
                    ForEach(locationNames, id:\.self){name in
                        Text(name!)
                    }
                    .onDelete(perform: { indexSet in
                        locationNames.remove(atOffsets: indexSet)
                    })
                }
                .padding()
            }
            .frame(maxHeight: 400)
        }
//            Text("Route Information")
//                .font(.title)
//                .fontWeight(.bold)
//            
//            ForEach(vm.optimizedLocationNames, id:\.self){index in
//                Text(index!)
//            }
        
        
        Button(action: {vm.fetchOptimizedRouteFrom(destinations: destinations, apiKey: "AIzaSyCPmcKGFLXqJQtlsstygllMmEV-tfdspJA", locationNames: locationNames)}, label: {
            ZStack{
                RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                    .fill(Color.button)
                Text("Start")
                    .foregroundStyle(Color.text)
                    .fontWeight(.semibold)
                    .font(.subheadline)
            }
        })
        .frame(width: 100, height: 50)
    }
}

#Preview {
    ContentView()
}

extension ContentView {
    private func search(for query: String) {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.resultTypes = .pointOfInterest
            Task {
                let search = MKLocalSearch(request: request)
                let response = try? await search.start()
                searchResults = response?.mapItems ?? []
                addDestination(address: searchResults[0])
                print(destinations)
                locationNames.append(searchResults[0].name)
            }
        }
    
    private func addDestination(address:MKMapItem?){
        if let address{
            addressCoordinate = address.placemark.location?.coordinate
        }
        
        self.destinations.append(addressCoordinate)
    }
}

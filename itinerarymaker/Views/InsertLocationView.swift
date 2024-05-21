//
//  InsertLocationView.swift
//  itinerarymaker
//
//  Created by Jovanna Melissa on 21/05/24.
//

import SwiftUI
import MapKit

struct InsertLocationView: View {
    @State private var route: MKRoute?
    @State private var searchQuery:String = ""
    @State private var searchResults:[MKMapItem]=[]
    @State var destinations:[CLLocationCoordinate2D?] = []
    @State private var selectedItem:MKMapItem?
    @State private var addressCoordinate:CLLocationCoordinate2D?
    @State var locationNames:[String?]=[]
    @ObservedObject private var vm = LocationViewModel()

    var body: some View {
        NavigationStack{
            Map(selection: $selectedItem) {
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
            
            NavigationLink{
                RouteResultView(destinations: destinations, locationNames: locationNames)
            } label: {
                ZStack{
                    RoundedRectangle(cornerRadius: 20.0)
                        .fill(Color.button)
                        Text("Start")
                        .foregroundStyle(Color.white)
                        .fontWeight(.semibold)
                        .font(.subheadline)
                        .shadow(radius: 10)
                }
                .frame(width: 100, height: 50)
            }
            .navigationTitle("Search for Locations")
        }
    }
}

#Preview {
    InsertLocationView()
}

extension InsertLocationView{
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
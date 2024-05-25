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
    @State private var mapPosition = MapCameraPosition.automatic
    @State private var addressCoordinate:CLLocationCoordinate2D?
    @State var locationNames:[String?]=[]
    @ObservedObject private var vm = LocationViewModel()
    

    var body: some View {
        NavigationStack{
            Map(position: $mapPosition, selection: $selectedItem) {
                ForEach(searchResults, id: \.self) { result in
                    Marker(item: result)
                }
            }
            .ignoresSafeArea()
            .searchable(text: $searchQuery, placement: .navigationBarDrawer, prompt: "Locations")
            .autocorrectionDisabled(true)
            .onSubmit(of: .search) {
                self.search(for: searchQuery)
            }
            
            if(!locationNames.isEmpty){
                ZStack{
                    Rectangle()
                        .fill(Color.background)
                    VStack{
                        Text("Your selected locations:")
                            .font(.system(size: 40.0))
                            .fontWeight(.bold)
                            .padding()
                        
                        List{
                            ForEach(locationNames, id:\.self){name in
                                Text(name!)
                                    .font(.system(size: 20.0))
                            }
                            .onDelete(perform: { indexSet in
                                locationNames.remove(atOffsets: indexSet)
                                destinations.remove(atOffsets: indexSet)
                            })
                        }
                        .padding()
                        .background(Color.background)
                        .scrollContentBackground(.hidden)
                        
                        NavigationLink{
                            RouteResultView(destinations: destinations, locationNames: locationNames)
                        } label: {
                            ZStack{
                                RoundedRectangle(cornerRadius: 20.0)
                                    .fill(Color.button)
                                    Text("Start")
                                    .foregroundStyle(Color.white)
                                    .fontWeight(.semibold)
                                    .font(.system(size: 30.0))
                                    .shadow(radius: 10)
                            }
                            .frame(width: 200, height: 50)
                        }
                        .padding(.bottom, 16)
                    }
                }
                .frame(maxHeight: 400)
            }
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

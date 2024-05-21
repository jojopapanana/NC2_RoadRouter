//
//  RouteResultView.swift
//  itinerarymaker
//
//  Created by Jovanna Melissa on 21/05/24.
//

import SwiftUI
import MapKit

struct RouteResultView: View {
    @State private var route: MKRoute?
    var destinations:[CLLocationCoordinate2D?]
    @State private var selectedItem:MKMapItem?
    var locationNames:[String?]
    @ObservedObject private var vm = LocationViewModel()

    var body: some View {
        NavigationStack{
            Map(selection: $selectedItem) {
                ForEach(0..<vm.routes.count, id: \.self) { index in
                    let route = vm.routes[index]
                        MapPolyline(route!.polyline)
                            .stroke(Color.blue, lineWidth: 8)
                }
                
                ForEach(0..<vm.optimizedLocationNames.count){ index in
                    Marker(vm.optimizedLocationNames[index]!, coordinate: vm.optimizedLocationCoordinates[index]!)
                }
            }
            .ignoresSafeArea()
            .onAppear(perform: {vm.fetchOptimizedRouteFrom(destinations: destinations, apiKey: "AIzaSyCPmcKGFLXqJQtlsstygllMmEV-tfdspJA", locationNames: locationNames)
            })
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
            
            Text("Route Information")
                .font(.title)
                .fontWeight(.bold)

            ForEach(vm.optimizedLocationNames, id:\.self){index in
                if(index == vm.optimizedLocationNames[0]){
                    Text("Starting point: \(index!)")
                } else if (index == vm.optimizedLocationNames[vm.optimizedLocationNames.count-1]){
                    Text("Final point: \(index!)")
                } else {
                    Text(index!)
                }
            }
            .navigationTitle("Routes Result")
        }
    }
}

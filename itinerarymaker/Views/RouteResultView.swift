//
//  RouteResultView.swift
//  itinerarymaker
//
//  Created by Jovanna Melissa on 21/05/24.
//

import SwiftUI
import MapKit
import SwiftData

struct RouteResultView: View {
    @State private var route: MKRoute?
    var destinations:[CLLocationCoordinate2D?]
    @State private var selectedItem:MKMapItem?
    var locationNames:[String?]
    @ObservedObject private var vm = LocationViewModel()
    @State private var isPresented:Bool = false
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack{
            HStack{
                VStack{
                    Text("Route Information")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 36)

                    ForEach(vm.optimizedLocationNames, id:\.self){index in
                        if(index == vm.optimizedLocationNames[0]){
                            Text("Starting point: \(index!)")
                                .font(.system(size: 25.0))
                                .multilineTextAlignment(.center)
                            Text("\n●\n●\n●\n")
                                .opacity(0.7)
                        } else if (index == vm.optimizedLocationNames[vm.optimizedLocationNames.count-1]){
                            Text("Final point: \(index!)")
                                .font(.system(size: 25.0))
                                .multilineTextAlignment(.center)
                        } else {
                            Text("\(index!)")
                                .font(.system(size: 25.0))
                                .multilineTextAlignment(.center)
                            Text("\n●\n●\n●\n")
                                .opacity(0.7)
                        }
                    }
                    
                    Spacer()
                    
                    Text("Total Travel Time:")
                        .font(.system(size: 30.0))
                        .fontWeight(.bold)
                    
                    if let identifier = (vm.travelTime){
                        Text("\(identifier)")
                            .font(.system(size: 25.0))
                            .padding(.bottom, 16)
                    }
                    
                    Text("Total Travel Distance:")
                        .font(.system(size: 30.0))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("\(vm.totalTravelDistance, specifier: "%.2f") km")
                        .font(.system(size: 25.0))
                        .padding(.bottom, 16)
                    
                    Button{
                        vm.saveRoute(context: self.context)
                        self.isPresented = true
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 20.0)
                                .fill(Color.button)
                            Text("Save Route")
                                .foregroundStyle(Color.white)
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .frame(width: 230, height: 78)
                    }
                    
                }
                .padding()
                .frame(width: 300)
                
                Map(selection: $selectedItem) {
                    ForEach(0..<vm.routes.count, id: \.self) { index in
                        let route = vm.routes[index]
                            MapPolyline(route!.polyline)
                                .stroke(Color.blue, lineWidth: 8)
                    }
                    
                    ForEach(0..<vm.optimizedLocationNames.count, id:\.self){ index in
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
            }
            .background(Color.background)
            .navigationTitle("Routes Result")
        }
        .navigationDestination(isPresented: $isPresented){
            SavedRoutesView()
        }
    }
}

#Preview{
    RouteResultView(destinations: [
    CLLocationCoordinate2D(latitude: 34.134117, longitude: -118.321495)], locationNames: ["Hollywood Sign"])
}

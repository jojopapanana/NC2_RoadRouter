//
//  SavedRoutesView.swift
//  itinerarymaker
//
//  Created by Jovanna Melissa on 21/05/24.
//

import SwiftUI
import SwiftData

struct SavedRoutesView: View {
    @Query private var routes: [Routes]
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack{
            ZStack{
                Rectangle()
                    .fill(Color.background)
                
                List{
                    ForEach(routes){route in
                        NavigationLink{
                            RouteResultView(destinations: route.destinations, locationNames: route.destinationNames)
                        } label: {
                            Text("Route from \(route.destinationNames[0]!) to \(route.destinationNames[route.destinationNames.count-1]!)")
                                .font(.system(size: 20.0))
                        }
                    }
                    .onDelete(perform: { indexSet in
                        for index in indexSet{
                            context.delete(routes[index])
                        }
                    })
                }
                .padding(.top, 48)
                .background(Color.background)
                .scrollContentBackground(.hidden)
            }
            .ignoresSafeArea()
            .navigationTitle("Saved Routes")
        }
    }
}

#Preview {
    SavedRoutesView()
}

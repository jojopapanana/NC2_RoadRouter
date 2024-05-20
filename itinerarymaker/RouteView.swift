//
//  RouteView.swift
//  itinerarymaker
//
//  Created by Jovanna Melissa on 15/05/24.
//

import SwiftUI
import MapKit

struct RouteView: View {
    @State private var route: MKRoute?
    @State private var travelTime: String?
    
    var body: some View {
        Map {
            if let route {
                MapPolyline(route.polyline)
                //bikin polyline dari property polyline nya si route
                    .stroke(.green, lineWidth: 8)
                // .stroke(gradient, style: stroke)
            }
        }
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
    }
}

#Preview {
    RouteView()
}

//
//  LandingPage.swift
//  itinerarymaker
//
//  Created by Jovanna Melissa on 21/05/24.
//

import SwiftUI

struct LandingPage: View {
    var body: some View {
        NavigationStack{
            ZStack{
                Rectangle()
                    .fill(Color.background)
                    .ignoresSafeArea()
                
                VStack{
                    Spacer()
                    
                    Image("logorr")
                        .frame(width: 300, height: 300)
                        .padding(.bottom, 168)
                    
                    Text("RoadRouter")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 16)
                    
                    Text("Plan your best road trip route now!")
                        .font(.title2)
                        .padding(.bottom, 56)
                    
                    NavigationLink{
                        InsertLocationView()
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 20.0)
                                .fill(Color.button)
                                .frame(width: 288, height: 90)
                            
                            Text("Go!")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.white)
                                .padding()
                                .font(.title3)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    LandingPage()
}

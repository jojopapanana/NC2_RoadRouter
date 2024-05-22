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
                    
                    Image("logorr1")
                        .frame(width: 300, height: 300)
                        .padding(.bottom, 112)
                    
                    Text("RoadRouter")
                        .font(.system(size: 60.0))
                        .fontWeight(.bold)
                        .foregroundStyle(Color.text)
                    
                    Text("Plan your best traveling trip experience!")
                        .font(.system(size: 40.0))
                        .padding(.bottom, 56)
                        .foregroundStyle(Color.text)
                    
                    NavigationLink{
                        InsertLocationView()
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 20.0)
                                .fill(Color.button)
                                .frame(width: 288, height: 70)
                            
                            Text("Search for route")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.white)
                                .padding()
                                .font(.system(size: 25.0))
                        }
                    }
                    .padding(.bottom, 16)
                    
                    NavigationLink{
                        SavedRoutesView()
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 20.0)
                                .fill(Color.button)
                                .frame(width: 288, height: 70)
                            
                            Text("Saved routes")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.white)
                                .padding()
                                .font(.system(size: 25.0))
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

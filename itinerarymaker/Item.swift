//
//  Item.swift
//  itinerarymaker
//
//  Created by Jovanna Melissa on 14/05/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

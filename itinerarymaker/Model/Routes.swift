//
//  Routes.swift
//  itinerarymaker
//
//  Created by Jovanna Melissa on 21/05/24.
//

import Foundation
import SwiftData
import MapKit
import CoreLocation

@Model
class Routes: Identifiable, Codable {
    var id: String
    var destinations: [CLLocationCoordinate2D?]
    var destinationNames: [String?]

    enum CodingKeys: String, CodingKey {
        case id
        case destinations
        case destinationNames
        case routes
    }
    
    init(destinations: [CLLocationCoordinate2D?], destinationNames: [String?]) {
        self.id = UUID().uuidString
        self.destinations = destinations
        self.destinationNames = destinationNames
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        destinations = try container.decode([CLLocationCoordinate2D?].self, forKey: .destinations)
        destinationNames = try container.decode([String?].self, forKey: .destinationNames)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(destinations, forKey: .destinations)
        try container.encode(destinationNames, forKey: .destinationNames)
    }
}

extension CLLocationCoordinate2D: Codable {
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}

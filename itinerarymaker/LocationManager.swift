//
//  LocationManager.swift
//  itinerarymaker
//
//  Created by Jovanna Melissa on 20/05/24.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }

    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

class LocationManager:NSObject, ObservableObject{
    private let locationManager = CLLocationManager()
    
    public var exposedLocation: CLLocation? {
            return self.locationManager.location
    }
    
    override init() {
            super.init()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestWhenInUseAuthorization()
    }
    
    
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {

        switch status {
    
        case .notDetermined         : print("notDetermined")        // location permission not asked for yet
        case .authorizedWhenInUse   : print("authorizedWhenInUse")  // location authorized
        case .authorizedAlways      : print("authorizedAlways")     // location authorized
        case .restricted            : print("restricted")           // TODO: handle
        case .denied                : print("denied")               // TODO: handle
        }
    }
}

extension LocationManager {
    func getPlace(for location: CLLocationCoordinate2D) async throws -> String? {
            let geocoder = CLGeocoder()
            let location = CLLocation(latitude: location.latitude, longitude: location.longitude)

            return try await withCheckedThrowingContinuation { continuation in
                geocoder.reverseGeocodeLocation(location) { placemarks, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let placemark = placemarks?.first, let name = placemark.name {
                        continuation.resume(returning: name)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
}

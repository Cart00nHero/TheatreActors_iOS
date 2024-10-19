//
//  PilotEntities.swift
//  PrivateKitchen
//
//  Created by 林祐正 on 2021/11/5.
//

import Foundation
import CoreLocation
import MapKit

struct PilotConfig {
    let accuracy: GPSAccuracy
    let activeType: CLActivityType
    let filterMeters: Double
    let purposeKey: String
}
struct RouteRequest {
    let source: CLLocationCoordinate2D
    let destination: CLLocationCoordinate2D
    // if you want multiple possible routes
    var alternateRoutes: Bool = false
    var transportType: MKDirectionsTransportType = .walking
}

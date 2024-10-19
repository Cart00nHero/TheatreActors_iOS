//
//  Mathematician.swift
//  WhatToEat
//
//  Created by YuCheng on 2021/2/11.
//  Copyright © 2021 YuCheng. All rights reserved.
//

import Foundation
import Theatre
import MapKit

final class Mathematician: Actor {
    private func actHaversine( center:CLLocationCoordinate2D,  range: Float64) -> Boundary {
        return Haversine(self).calculate(coordinate: center, range: range)
    }
    
    private func actCalculateDistance(
        _ from: CLLocationCoordinate2D,
        _ to: CLLocationCoordinate2D
    ) -> CLLocationDistance {
        let fromLoc = CLLocation(
            latitude: from.latitude, 
            longitude: from.longitude)
        let toLoc = CLLocation(
            latitude: to.latitude, 
            longitude: to.longitude)
        return toLoc.distance(from: fromLoc)
    }
    private func actMapZoomLevel(_ mapSize: CGSize, _ center: MKCoordinateRegion) -> Int {
        return Int(log2(360 * (Double(mapSize.width/256)/center.span.longitudeDelta)) + 1)
    }
    private func actRandomInteger(_ min: Int, _ max: Int) -> Int {
        return randomInt(min: min, max: max)
    }
    private func actCentroidCoordinates(_ coordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        var maxLat: Double = -200.0
        var maxLng: Double = -200.0
        var minLat: Double = Double(MAXFLOAT)
        var minLng: Double = Double(MAXFLOAT)
        for coordinate in coordinates {
            if (coordinate.latitude < minLat) {
                minLat = coordinate.latitude
            }
            if (coordinate.longitude < minLng) {
                minLng = coordinate.longitude;
            }
            if (coordinate.latitude > maxLat) {
                maxLat = coordinate.latitude;
            }
            if (coordinate.longitude > maxLng) {
                maxLng = coordinate.longitude;
            }
        }
        return CLLocationCoordinate2DMake(
            (maxLat + minLat) * 0.5, (maxLng + minLng) * 0.5)
    }
    
    // MARK: - private
    private func randomInt(min: Int,max: Int) -> Int {
        if min <= max {
            return Int.random(in: min..<max)
        }
        return 0
    }
    private func randomDouble(min: Double, max: Double) -> Double {
        if min <= max {
            return Double.random(in: min...max)
        }
        return 0.0
    }
    private func calculateCenterOfCoordinates(_ coordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        var maxLat: Double = -200.0
        var maxLng: Double = -200.0
        var minLat: Double = Double(MAXFLOAT)
        var minLng: Double = Double(MAXFLOAT)
        for coordinate in coordinates {
            if (coordinate.latitude < minLat) {
                minLat = coordinate.latitude
            }
            if (coordinate.longitude < minLng) {
                minLng = coordinate.longitude;
            }
            if (coordinate.latitude > maxLat) {
                maxLat = coordinate.latitude;
            }
            if (coordinate.longitude > maxLng) {
                maxLng = coordinate.longitude;
            }
        }
        return CLLocationCoordinate2DMake(
            (maxLat + minLat) * 0.5, (maxLng + minLng) * 0.5)
    }
    
}
extension Mathematician {
    func haversine(
        center:CLLocationCoordinate2D,
        range: Float64
    ) -> Teleport<Boundary> {
        let export: Teleport<Boundary> = Boundary(
            maxLat: 0.0, maxLng: 0.0,
            minLat: 0.0, minLng: 0.0)
        |> { install($0) }
        act { [unowned self] in
            export.portal = actHaversine(center: center, range: range)
        }
        return export
    }
    func calculateDistance(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D
    ) -> Teleport<CLLocationDistance> {
        let export = install(CLLocationDistance())
        act { [unowned self] in
            export.portal = actCalculateDistance(from, to)
        }
        return export
    }
    func mapZoomLevel(mapSize: CGSize,center: MKCoordinateRegion) -> Teleport<Int> {
        let export = install(Int(0))
        act { [unowned self] in
            export.portal = actMapZoomLevel(mapSize, center)
        }
        return export
    }
    func randomInteger(min: Int,max: Int) -> Teleport<Int> {
        let export = install(Int(0))
        act { [unowned self] in
            export.portal = actRandomInteger(min, max)
        }
        return export
    }
    func centroidCoordinates(_ coordinates: [CLLocationCoordinate2D]) -> Teleport<CLLocationCoordinate2D> {
        let export = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        |> { install($0) }
        act { [unowned self] in
            export.portal = actCentroidCoordinates(coordinates)
        }
        return export
    }
}
protocol MathBehaviors {
    func haversine(
        center:CLLocationCoordinate2D,
        range: Float64) -> Teleport<Boundary>
    func calculateDistance(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D) -> Teleport<CLLocationDistance>
    func mapZoomLevel(mapSize: CGSize,center: MKCoordinateRegion) -> Teleport<Int>
    func randomInteger(min: Int,max: Int) -> Teleport<Int>
    func centroidCoordinates(
        _ coordinates: [CLLocationCoordinate2D]) -> Teleport<CLLocationCoordinate2D>
}

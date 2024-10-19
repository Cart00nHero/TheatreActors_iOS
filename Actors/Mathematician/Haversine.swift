//
//  Haversin.swift
//  WhatToEat
//
//  Created by YuCheng on 2020/7/8.
//  Copyright © 2020 YuCheng. All rights reserved.
//

import MapKit

struct Boundary: Codable {
    let maxLat: Float64
    let maxLng: Float64
    let minLat: Float64
    let minLng: Float64
}
struct Haversine {
    private let actor: Mathematician
    private let EARTH_RADIUS = 6371.0
    
    init(_ actor: Mathematician) {
        self.actor = actor
    }

    func calculate(coordinate: CLLocationCoordinate2D, range: Float64) -> Boundary {
        // range is km
        let dLng = dLongitude(coordinate: coordinate, range: range)
        let dLat = dLatitude(range: range)
    //    let left_top = (coordinate.latitude+dLat, coordinate.longitude-dLng)
    //    let right_top = (coordinate.latitude + dLat, coordinate.longitude + dLng)
    //    let left_bottom = (coordinate.latitude - dLat, coordinate.longitude-dLng)
    //    let right_bottom = (coordinate.latitude - dLat, coordinate.longitude+dLng)
        let maxLat = coordinate.latitude + dLat
        let minLat = coordinate.latitude - dLat
        let maxLng = coordinate.longitude + dLng
        let minLng = coordinate.longitude - dLng
        
        return Boundary(maxLat: maxLat, maxLng: maxLng, minLat: minLat, minLng: minLng)
    }

    private func dLongitude(coordinate: CLLocationCoordinate2D, range: Float64) -> Double {
        let dLng =
            2*asin(sin(range/(2*EARTH_RADIUS)/cos(deg2rad(coordinate.latitude))))
        return rad2deg(dLng)
    }

    private func dLatitude(range: Float64) -> Double {
        let dLat = range / EARTH_RADIUS
        return rad2deg(dLat)
    }

    private func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180.0
    }

    private func rad2deg(_ number: Double) -> Double {
        return number * 180.0 / .pi
    }

}

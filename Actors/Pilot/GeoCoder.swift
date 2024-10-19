//
//  GeoCoder.swift
//  WhatToEat
//
//  Created by YuCheng on 2021/2/13.
//  Copyright © 2021 YuCheng. All rights reserved.
//

import Foundation
import Theatre
import MapKit

final class GeoCoder: Actor {
    private func actCodeAddress(_ address: String, export: Teleport<[CLPlacemark]>) {
        Task {
            let geoCoder = CLGeocoder()
            do {
                let places: [CLPlacemark] = try await geoCoder.geocodeAddressString(address)
                export.portal = places
            } catch {
                print(error)
                export.portal = []
            }
        }
    }
    private func actReverseLocation(_ location: CLLocation, export: Teleport<[CLPlacemark]>) {
        Task {
            let geoCoder = CLGeocoder()
            do {
                let places: [CLPlacemark] = try await geoCoder.reverseGeocodeLocation(location)
                export.portal = places
            } catch  {
                print(error)
                export.portal = []
            }
        }
    }
    
}
extension GeoCoder: GeoCoderBehaviors {
    func codeAddress(_ address: String) -> Teleport<[CLPlacemark]> {
        let export = install([CLPlacemark]())
        act { [unowned self] in
            actCodeAddress(address, export: export)
        }
        return export
    }
    func reverseLocation(_ location: CLLocation) -> Teleport<[CLPlacemark]> {
        let export: Teleport<[CLPlacemark]> = install([CLPlacemark]())
        act { [unowned self] in
            actReverseLocation(location, export: export)
        }
        return export
    }
}
protocol GeoCoderBehaviors {
    func codeAddress(_ address: String) -> Teleport<[CLPlacemark]>
    func reverseLocation(_ location: CLLocation) -> Teleport<[CLPlacemark]>
}

//
//  Pilot.swift
//  WhatToEat
//
//  Created by YuCheng on 2021/2/12.
//  Copyright © 2021 YuCheng. All rights reserved.
//

import Foundation
import Theatre
import CoreLocation
import MapKit

final class Pilot: Actor {
    private let compass = Compass.shared
    
    private func actSetConfig(_ config: PilotConfig) {
        compass.configureGPS(config)
    }
    private func actSubscribe(_ sender: PilotProtocol) {
        compass.bindProtocol(self, sender)
    }
    private func actAuthorize(_ auth: PilotAuthorization) {
        compass.requestAuthorization(auth)
    }
    private func actStart() {
        compass.startUpdatingLocation()
    }
    private func actStop() {
        compass.stopUpdatingLocation()
    }
    private func actRequestCurrentLocation() {
        compass.requestCurrentLocation()
    }
    private func actRequestTempFullAccuracy() -> Bool {
        return  compass.requestTempFullAccuracyAuthorization()
    }
    private func actRequestRoute(_ request: RouteRequest) -> [MKRoute] {
        let export = install([MKRoute]())
        Task {
            let directionsReq = MKDirections.Request()
            directionsReq.source = MKMapItem(placemark: MKPlacemark(coordinate: request.source))
            directionsReq.destination = MKMapItem(placemark: MKPlacemark(coordinate: request.destination))
            // if you want multiple possible routes
            directionsReq.requestsAlternateRoutes = request.alternateRoutes
            directionsReq.transportType = request.transportType
            let directions = MKDirections(request: directionsReq)
            do {
                let response: MKDirections.Response = try await directions.calculate()
                export.portal = response.routes
            } catch {
                print(error.localizedDescription)
                export.portal = []
            }
        }
        return export.portal
    }
    private func actExit() {
        compass.unBind(self)
    }
    deinit {
        compass.unBind(self)
    }
}
extension Pilot: PilotBehaviors {
    func setConfig(_ config: PilotConfig) {
        act { [unowned self] in actSetConfig(config) }
    }
    func subscribe(_ subscriber: PilotProtocol) {
        act { [unowned self] in actSubscribe(subscriber) }
    }
    func authorize(auth: PilotAuthorization) {
        act { [unowned self] in
            actAuthorize(auth)
        }
    }
    func start() {
        act(actStart)
    }
    func stop() {
        act(actStop)
    }
    func requestCurrentLocation() {
        act(actRequestCurrentLocation)
    }
    func requestTempFullAccuracy() -> Teleport<Bool> {
        let export = install(false)
        act { [unowned self] in
            export.portal = actRequestTempFullAccuracy()
        }
        return export
    }
    func requestRoute(_ request: RouteRequest) -> Teleport<[MKRoute]> {
        let export = install([MKRoute]())
        act { [unowned self] in
            export.portal = actRequestRoute(request)
        }
        return export
    }
    func exit() {
        act(actExit)
    }
}
protocol PilotBehaviors {
    func setConfig(_ config: PilotConfig)
    func subscribe(_ subscriber: PilotProtocol)
    func authorize(auth: PilotAuthorization)
    func start()
    func stop()
    func requestCurrentLocation()
    func requestTempFullAccuracy() -> Teleport<Bool>
    func requestRoute(_ request: RouteRequest) -> Teleport<[MKRoute]>
    func exit()
}
protocol PilotProtocol {
    func pilot(didUpdateLocations locations: [CLLocation])
    func pilot(didFailWithError error: Error)
    func pilot(didChangeAuthorization status: CLAuthorizationStatus)
}

// MARK: - Compass
fileprivate class Compass: NSObject {
    static let shared = Compass()
    private let pilot: Actor = Actor()
    private let manager: CLLocationManager = CLLocationManager()
    private var isUpdatingStarted = false
    private var purposeKey = ""
    private var delegates: [String : PilotProtocol] = [:]
    
    func bindProtocol(_ binder: Pilot,_ delegate: PilotProtocol) {
        let nameplate: String = addressOf(binder)
        guard delegates[nameplate] == nil else { return }
        delegates[nameplate] = delegate
    }
    func configureGPS(_ config: PilotConfig) {
        setAccuracy(config.accuracy)
        manager.activityType = config.activeType
        manager.distanceFilter =
        CLLocationDistance(config.filterMeters)
        purposeKey = config.purposeKey
        manager.delegate = self
    }
    func setAccuracy(_ accuracy: GPSAccuracy) {
        pilot.act { [unowned self] in
            switch accuracy {
            case .DEFAULT:
                manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            case .BEST_FOR_NAVIGATION:
                manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            case .BEST:
                manager.desiredAccuracy = kCLLocationAccuracyBest
            case .NEAREST_TENMETERS:
                manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            case .HUNDRED_METERS:
                manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            case .KIIOMETER:
                manager.desiredAccuracy = kCLLocationAccuracyKilometer
            case .THREE_KILOMETERS:
                manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            }
        }
    }
    
    func requestAuthorization(_ authorization: PilotAuthorization) {
        pilot.act { [unowned self] in
            let status = manager.authorizationStatus
            switch status {
            case .authorizedAlways: break
            case .authorizedWhenInUse: break
            default:
                pilotAuthorize(authorization)
            }
        }
    }
    func requestTempFullAccuracyAuthorization() -> Bool {
        let export = pilot.install(false)
        pilot.act { [unowned self] in
            let accStatus = manager.accuracyAuthorization
            if accStatus == CLAccuracyAuthorization.reducedAccuracy {
                manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: purposeKey)
                export.portal = true
            } else {
                export.portal = false
            }
        }
        return export.portal
    }
    func startUpdatingLocation() {
        pilot.act { [unowned self] in
            manager.startUpdatingLocation()
            isUpdatingStarted = true
        }
    }
    func requestCurrentLocation() {
        //request onece and accuracy select automatic
        //can't use together with startUpdatingLocation
        pilot.act { [unowned self] in
            manager.requestLocation()
        }
    }
    func stopUpdatingLocation() {
        pilot.act { [unowned self] in
            manager.stopUpdatingLocation()
            isUpdatingStarted = false
        }
    }
    func unBind(_ binder: Pilot) {
        pilot.act { [unowned self] in
            let nameplate: String = addressOf(binder)
            delegates.removeValue(forKey: nameplate)
        }
    }
    
    private func pilotAuthorize(_ authorization: PilotAuthorization) {
        switch authorization {
        case .always:
            if manager.authorizationStatus == .authorizedAlways {
                manager.requestAlwaysAuthorization()
            }
        case .whenInUse:
            manager.requestWhenInUseAuthorization()
        }
    }
    private func addressOf(_ o: UnsafeRawPointer) -> String {
        let addr = Int(bitPattern: o)
        return String(format: "%p", addr)
    }
    private func addressOf<T: AnyObject>(_ o: T) -> String {
        let addr = unsafeBitCast(o, to: Int.self)
        return String(format: "%p", addr)
    }
}
extension Compass: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        for (_, delegate) in delegates {
            delegate.pilot(didUpdateLocations: locations)
        }
    }
    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        for (_, delegate) in delegates {
            delegate.pilot(didChangeAuthorization: status)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        for (_, delegate) in delegates {
            delegate.pilot(didFailWithError: error)
        }
    }
}
// MARK: - Enum
enum GPSAccuracy : Int {
    case DEFAULT,BEST_FOR_NAVIGATION,BEST,
         NEAREST_TENMETERS,HUNDRED_METERS,
         KIIOMETER,THREE_KILOMETERS
}
enum PilotAuthorization : Int {
    case always,whenInUse
}

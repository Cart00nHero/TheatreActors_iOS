//
//  MapExtension.swift
//  WhatToEat
//
//  Created by YuCheng on 2021/3/5.
//  Copyright © 2021 YuCheng. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    //縮放級別
    var zoomLevel: Int {
        // 回傳結果
        get {
            let doubleValue = Double(self.frame.size.width/256)
            let multiplier = doubleValue / self.region.span.longitudeDelta
            return Int(log2(360 * multiplier) + 1)
            /*
            return Int(log2(360 * (Double(self.frame.size.width/256)/self.region.span.longitudeDelta)) + 1)
             */
        }
        // 設置
        set (newZoomLevel) {
            setCenterCoordinate(
                coordinate: self.centerCoordinate,
                zoomLevel: newZoomLevel, animated: false)
        }
    }
    
    // 設置縮放級別
    private func setCenterCoordinate(
        coordinate: CLLocationCoordinate2D,
        zoomLevel: Int, animated: Bool
    ){
        let powValue = pow(2, Double(zoomLevel)) * Double(self.frame.size.width)
        let span = MKCoordinateSpan(
            latitudeDelta: 0, longitudeDelta: 360 / powValue / 256)
        setRegion(
            MKCoordinateRegion(center: centerCoordinate, span: span),
            animated: animated)
    }
}

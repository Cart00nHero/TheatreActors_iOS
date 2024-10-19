//
//  Extensions.swift
//  iListen
//
//  Created by 林祐正 on 2021/4/15.
//  Copyright © 2021 SmartFun. All rights reserved.
//

import Foundation
import SwiftUI

public protocol JSONEmptyRepresentable {
    associatedtype CodingKeyType: CodingKey
}

extension KeyedDecodingContainer {
    public func decodeIfPresent<T>(_ type: T.Type, forKey key: K)
    throws -> T? where T : Decodable & JSONEmptyRepresentable {
        if contains(key) {
            let container = try nestedContainer(
                keyedBy: type.CodingKeyType.self,forKey: key)
            if container.allKeys.isEmpty {
                return nil
            }
        } else {
            return nil
        }
        return try decode(T.self, forKey: key)
    }
}
extension URL {
    func isReachable(completion: @escaping (Bool) -> ()) {
        var request = URLRequest(url: self)
        request.httpMethod = "HEAD"
        URLSession.shared.dataTask(with: request) { _, response, _ in
            completion((response as? HTTPURLResponse)?.statusCode == 200)
        }.resume()
    }
}
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
extension Int64 {
    func toInt() -> Int {
        return Int(self)
    }
}
extension Date {
    func toText(_ format: DateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.string(from: self)
    }
    
    func getDateComponents(_ componentsmp: Set<Calendar.Component>) -> DateComponents {
        // Get the current calendar
        let calendar = Calendar.current
        return calendar.dateComponents(componentsmp, from: self)
    }
    
    var tomorrowDate: Date {
        get { self.addingTimeInterval(86400) }
    }
}
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

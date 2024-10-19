//
//  StringExtensions.swift
//  PrivateKitchen
//
//  Created by 林祐正 on 2021/9/27.
//

import Foundation

extension String {
    func toInt() -> Int {
        if let integerNo = Int(self) {
            return integerNo
        }
        return 0
    }
    func toInt64() -> Int64 {
        if let integerNo = Int64(self) {
            return integerNo
        }
        return 0
    }
    func toDouble() -> Double {
        if let doubleNo = Double(self) {
            return doubleNo
        }
        return 0.0
    }
    func toFloat() -> Float {
        if let floatNo = Float(self) {
            return floatNo
        }
        return 0.0
    }
    func utf8DecodedString()-> String {
        let data = self.data(using: .utf8)
        let message = String(data: data!, encoding: .nonLossyASCII) ?? ""
        return message
    }
    func utf8EncodedString()-> String {
        let messageData = self.data(using: .nonLossyASCII)
        let text = String(data: messageData!, encoding: .utf8) ?? ""
        return text
    }
}

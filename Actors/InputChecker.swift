//
//  InputChecker.swift
//  iListen
//
//  Created by 林祐正 on 2021/9/7.
//  Copyright © 2021 SmartFun. All rights reserved.
//

import Foundation
import Theatre

class InputChecker: Actor {
    private func actPwdStrength(_ password: String) -> Bool {
        let regEx = "^(?=.*[a-z])(?=.*[0-9].*[0-9]).{8,}$"
        let passCheck = NSPredicate(format: "SELF MATCHES[c] %@", regEx)
        return passCheck.evaluate(with: password)
    }

    private func actMobileNumber(_ number: String) -> Bool {
        let regEx = "^\\+(?:[0-9]?){6,14}[0-9]$"
        let mobileCheck = NSPredicate(format: "SELF MATCHES[c] %@", regEx)
        return mobileCheck.evaluate(with: number)
    }
    
    private func actPhoneNumber(_ number: String) -> Bool {
        let regEx = "^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-s./0-9]*$"
        let phoneCheck = NSPredicate(format: "SELF MATCHES[c] %@", regEx)
        return phoneCheck.evaluate(with: number)
    }
}

extension InputChecker {
    func pwdStrength(password: String) -> Teleport<Bool> {
        let export = install(false)
        act { [unowned self] in
            export.portal = actPwdStrength(password)
        }
        return export
    }
    func mobileNumber(number: String) -> Teleport<Bool> {
        let export = install(false)
        act { [unowned self] in
            export.portal = actMobileNumber(number)
        }
        return export
    }
    func phoneNumber(number: String) -> Teleport<Bool> {
        let export = install(false)
        act { [unowned self] in
            export.portal = actPhoneNumber(number)
        }
        return export
    }
}

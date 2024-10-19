//
//  TimeGuardian.swift
//  WhatToEat
//
//  Created by YuCheng on 2021/3/3.
//  Copyright © 2021 YuCheng. All rights reserved.
//

import Foundation
import Theatre

final class TimeGuardian: Actor {
    private func actGetISO8601Date(_ dateText: String) -> Date {
        // The default timeZone for ISO8601DateFormatter is UTC
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [
            .withInternetDateTime, .withFractionalSeconds
        ]
        return dateFormatter.date(from: dateText) ?? Date()
    }

    private func actGetISO8601Text(_ date: Date) -> String {
        // The default timeZone for ISO8601DateFormatter is UTC
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [
            .withInternetDateTime, .withFractionalSeconds
        ]
        return dateFormatter.string(from: date)
    }

    private func actLocalToUTCText(
        _ dateText: String,
        local: DateFormat, utc: DateFormat
    ) -> String {
        // Create a DateFormatter for the local time zone
        let localDateFormatter = DateFormatter()
        localDateFormatter.dateFormat = local.rawValue
        localDateFormatter.timeZone = TimeZone.current
        // Convert the input date string to a Date object
        if let localDate = localDateFormatter.date(from: dateText) {
            // Create a DateFormatter for UTC
            let utcDateFormatter = DateFormatter()
            utcDateFormatter.dateFormat = utc.rawValue
            utcDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            // Convert the local Date to a UTC date string
            return utcDateFormatter.string(from: localDate)
        }
        return ""
    }

    private func actUtcToLocalText(
        _ dateText: String, utc: DateFormat,
        local: DateFormat
    ) -> String {
        // Create a DateFormatter for UTC
        let utcDateFormatter = DateFormatter()
        utcDateFormatter.dateFormat = utc.rawValue
        utcDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        // Convert the input date string to a Date object
        if let utcDate = utcDateFormatter.date(from: dateText) {
            // Create a DateFormatter for the local time zone
            let localDateFormatter = DateFormatter()
            localDateFormatter.dateFormat = local.rawValue
            localDateFormatter.timeZone = TimeZone.current
            // Convert the UTC Date to a local date string
            return localDateFormatter.string(from: utcDate)
        }
        return ""
    }

    private func actLocalToUtcDate(_ date: Date) -> Date {
        // Step 1: Get the local date
        // Step 2: Define the current calendar and set the time zone to UTC
        let utcTimeZone = TimeZone(abbreviation: "UTC")!
        var calendar = Calendar.current
        calendar.timeZone = utcTimeZone
        // Step 3: Extract the components of the local date and convert them to UTC
        let utcComponents = calendar.dateComponents(in: utcTimeZone, from: date)
        // Step 4: Create a new UTC date from the components
        return calendar.date(from: utcComponents) ?? Date()
    }

    private func actUtcToLocalDate(_ date: Date) -> Date {
        // Step 1: Assume this is a date in UTC
        // Step 2: Get the current time zone (local time zone)
        let localTimeZone = TimeZone.current
        var calendar = Calendar.current
        calendar.timeZone = localTimeZone
        // Step 3: Extract the components of the UTC date and convert them to local time
        let localComponents = calendar.dateComponents(in: localTimeZone, from: date)
        // Step 4: Create a new local date from the components
        return calendar.date(from: localComponents) ?? Date()
    }

    private func actDateToText(_ date: Date, _ format: DateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.string(from: date)
    }

    private func actTextToDate(_ dateText: String, _ format: DateFormat) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.date(from: dateText) ?? Date()
    }

    private func actSplitTimeInterval(_ interval: TimeInterval) -> (hour: Int, min: Int, sec: Int) {
        let time = Int64(interval)
        let seconds = (time % 60).toInt()
        let minutes = ((time / 60) % 60).toInt()
        let hours = ((time / 3600)).toInt()
        return (hours, minutes, seconds)
    }

    private func actTomorrow() -> Date {
        return Date.now.addingTimeInterval(86400)
    }

    private func actSubtractDate(_ minuend: Date, _ subtrahend: Date) -> TimeInterval {
        let minuendInterval = minuend.timeIntervalSinceReferenceDate
        let subtrahendInterval = subtrahend.timeIntervalSinceReferenceDate
        return minuendInterval - subtrahendInterval
    }
    /*
     func beCreateDate() -> Date {
     var aComponents = DateComponents()
     aComponents.hour = 8
     aComponents.minute = 0
     let date = Calendar.current.date(from: aComponents)
     
     let components = Calendar.current.dateComponents([.hour, .minute], from: Date())
     let hour = components.hour ?? 0
     let minute = components.minute ?? 0
     return Calendar.current.date(from: components) ?? Date()
     }
     */
}
extension TimeGuardian: TimeGuardianBehaviors {
    func getISO8601Date(_ dateText: String) -> Teleport<Date> {
        let export = install(Date())
        act { [unowned self] in
            export.portal = actGetISO8601Date(dateText)
        }
        return export
    }
    
    func getISO8601Text(_ date: Date) -> Teleport<String> {
        let export = install("")
        act { [unowned self] in
            export.portal = actGetISO8601Text(date)
        }
        return export
    }
    
    func localToUTCText(_ dateText: String, local: DateFormat, utc: DateFormat) -> Teleport<String> {
        let export = install("")
        act { [unowned self] in
            export.portal = actLocalToUTCText(dateText, local: local, utc: utc)
        }
        return export
    }
    
    func utcToLocalText(_ dateText: String, utc: DateFormat, local: DateFormat) -> Teleport<String> {
        let export = install("")
        act { [unowned self] in
            export.portal = actUtcToLocalText(dateText, utc: utc, local: local)
        }
        return export
    }
    
    func localToUtcDate(_ date: Date) -> Teleport<Date> {
        let export = install(Date())
        act { [unowned self] in
            export.portal = actLocalToUtcDate(date)
        }
        return export
    }
    
    func utcToLocalDate(_ date: Date) -> Teleport<Date> {
        let export = install(Date())
        act { [unowned self] in
            export.portal = actUtcToLocalDate(date)
        }
        return export
    }
    
    func dateToText(_ date: Date, format: DateFormat) -> Teleport<String> {
        let export = install("")
        act { [unowned self] in
            export.portal = actDateToText(date, format)
        }
        return export
    }
    
    func textToDate(_ dateText: String, format: DateFormat) -> Teleport<Date> {
        let export = install(Date())
        act { [unowned self] in
            export.portal = actTextToDate(dateText, format)
        }
        return export
    }
    
    func splitTimeInterval(_ interval: TimeInterval) -> Teleport<(hour: Int, min: Int, sec: Int)> {
        let export: Teleport<(hour: Int, min: Int, sec: Int)> = install(
            (hour: 0, min: 0, sec: 0))
        act { [unowned self] in
            export.portal = actSplitTimeInterval(interval)
        }
        return export
    }
    
    func beTomorrow() -> Teleport<Date> {
        let export = install(Date())
        act { [unowned self] in
            export.portal = actTomorrow()
        }
        return export
    }
    
    func subtractDate(minuend: Date, subtrahend: Date) -> Teleport<TimeInterval> {
        let export = install(TimeInterval())
        act { [unowned self] in
            export.portal = actSubtractDate(minuend, subtrahend)
        }
        return export
    }
}

protocol TimeGuardianBehaviors {
    func getISO8601Date(_ dateText: String) -> Teleport<Date>
    func getISO8601Text(_ date: Date) -> Teleport<String>
    func localToUTCText(_ dateText: String, local: DateFormat, utc: DateFormat) -> Teleport<String>
    func utcToLocalText(_ dateText: String, utc: DateFormat, local: DateFormat) -> Teleport<String>
    func localToUtcDate(_ date: Date) -> Teleport<Date>
    func utcToLocalDate(_ date: Date) -> Teleport<Date>
    func dateToText(_ date: Date, format: DateFormat) -> Teleport<String>
    func textToDate(_ dateText: String, format: DateFormat) -> Teleport<Date>
    func splitTimeInterval(_ interval: TimeInterval) -> Teleport<(hour: Int, min: Int, sec: Int)>
    func beTomorrow() -> Teleport<Date>
    func subtractDate(minuend: Date, subtrahend: Date) -> Teleport<TimeInterval>
}

enum DateFormat: String, CaseIterable {
    case E4M3dy4 = "EEEE, MMM d, yyyy"
    case MMddy4_oblique = "MM/dd/yyyy"
    case MMddy4HHmm_dash = "MM-dd-yyyy HH:mm"
    case M3dhmma = "MMM d, h:mm a"
    case M4y4 = "MMMM yyyy"
    case M3dy4 = "MMM d, yyyy"
    case EdM3y4HHmmssZ = "E, d MMM yyyy HH:mm:ss Z"
    case ddMMyy_dot = "dd.MM.yy"
    case HHmmssS3 = "HH:mm:ss.SSS"
    case HHmm = "HH:mm"
    case hmma = "h:mm a"
    case y4MMddHHmm_oblique = "yyyy/MM/dd HH:mm"
    case y4MMddHHmm_dash = "yyyy-MM-dd HH:mm"
    case ISO8601 = "yyyy-MM-dd'T'HH:mm:ssZ"
}

/**
 Wednesday, Sep 12, 2018           --> EEEE, MMM d, yyyy
 09/12/2018                        --> MM/dd/yyyy
 09-12-2018 14:11                  --> MM-dd-yyyy HH:mm
 Sep 12, 2:11 PM                   --> MMM d, h:mm a
 September 2018                    --> MMMM yyyy
 Sep 12, 2018                      --> MMM d, yyyy
 Wed, 12 Sep 2018 14:11:54 +0000   --> E, d MMM yyyy HH:mm:ss Z
 2018-09-12T14:11:54+0000          --> yyyy-MM-dd'T'HH:mm:ssZ
 12.09.18                          --> dd.MM.yy
 10:41:02.112                      --> HH:mm:ss.SSS
 **/

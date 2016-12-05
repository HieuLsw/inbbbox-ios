//
//  Formatter.swift
//  Inbbbox
//
//  Created by Radoslaw Szeja on 14/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct Formatter {
    struct Date {
        /// Basic date formatter with format yyyy-MM-dd
        static var Basic: NSDateFormatter {
            return Date.basicDateFormatter
        }

        /// Timestamp date formatter with ISO 8601 format yyyy-MM-dd'T'HH:mm:ssZZZZZ
        static var Timestamp: NSDateFormatter {
            return Date.timestampDateFormatter
        }
    }
}

private extension Formatter.Date {
    static var basicDateFormatter = { Void -> NSDateFormatter in
        let formatter = NSDateFormatter()
        formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        formatter.dateFormat = "yyyy-MM-dd"

        return formatter
    }()

    static var timestampDateFormatter = { Void -> NSDateFormatter in
        let formatter = NSDateFormatter()
        formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")

        return formatter
    }()
}

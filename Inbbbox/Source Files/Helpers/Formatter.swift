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
        static var Basic: DateFormatter {
            return Date.basicDateFormatter
        }

        /// Timestamp date formatter with ISO 8601 format yyyy-MM-dd'T'HH:mm:ssZZZZZ
        static var Timestamp: DateFormatter {
            return Date.timestampDateFormatter
        }
    }
}

private extension Formatter.Date {
    static var basicDateFormatter = { Void -> DateFormatter in
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        formatter.dateFormat = "yyyy-MM-dd"

        return formatter
    }()

    static var timestampDateFormatter = { Void -> DateFormatter in
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        return formatter
    }()
}

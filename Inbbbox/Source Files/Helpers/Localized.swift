//
//  Localized.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

/// Provides localized string considering app's language set in settings.
///
/// - Parameters:
///   - key: Key of localized string.
///   - comment: Comment for localized string.
/// - Returns: Localized string.
internal func Localized(_ key: String, comment: String) -> String {

    guard
        LanguageManager.shared.current != .deviceDefault,
        let path = Bundle.main.path(forResource: LanguageManager.shared.current.rawValue, ofType: "lproj"),
        let bundle = Bundle(path: path)
    else {
        return NSLocalizedString(key, comment: comment)
    }

    return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
}

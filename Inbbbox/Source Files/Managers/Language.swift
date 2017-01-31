//
//  Language.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

enum Language: String {
    case deviceDefault = "default"
    case english = "en"
    case polish = "pl"
    case german = "de"
    case portugal = "pt-PT"
    case spanish = "es"
    case french = "fr"

    /// Returns localized name for language.
    var localizedName: String {
        return Localized("Language.\(rawValue)", comment: "Language name.")
    }

    /// Returns all cases of enum.
    static var allOptions: [Language] {
        return [.deviceDefault, .english, .polish, .german, .portugal, .spanish, .french]
    }
}

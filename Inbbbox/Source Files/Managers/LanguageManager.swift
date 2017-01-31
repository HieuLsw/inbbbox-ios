//
//  LanguageManager.swift
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
        switch self {
        case .deviceDefault: return Localized("Language.Default", comment: "Default language name.")
        case .english: return Localized("Language.English", comment: "English language name.")
        case .polish: return Localized("Language.Polish", comment: "Polish language name.")
        case .german: return Localized("Language.German", comment: "German language name.")
        case .portugal: return Localized("Language.Portugal", comment: "Portugal language name.")
        case .spanish: return Localized("Language.Spanish", comment: "Spanish language name.")
        case .french: return Localized("Language.French", comment: "French language name.")
        }
    }

    /// Returns all cases of enum.
    static var allOptions: [Language] {
        return [.deviceDefault, .english, .polish, .german, .portugal, .spanish, .french]
    }
}

//final class LanguageManager {
//
//    static let shared = LanguageManager()
//
//    fileprivate let key = "app-language-key"
//
//    /// Returns current language set in the app.
//    var current: Language {
//        guard let languageString = UserDefaults.standard.string(forKey: key) else { return .deviceDefault }
//
//        return Language(rawValue: languageString) ?? .deviceDefault
//    }
//
//    /// Sets language for the app.
//    ///
//    /// - Parameter language: Language to set.
//    func set(language: Language) {
//        UserDefaults.standard.setValue(language.rawValue, forKey: key)
//        UserDefaults.standard.synchronize()
//    }
//}

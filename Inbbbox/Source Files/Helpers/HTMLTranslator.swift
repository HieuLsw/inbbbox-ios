//
//  HTMLTranslator.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

class HTMLTranslator {

    /// Replaces <b> and <i> HTML tags to <strong>, <em> tags, accepted by Dribbble comments system.
    /// - parameters: text HTML to convert
    /// - returns: Converted HTML.
    static func translateToDribbbleHTML(text: String) -> String {

        let tuples = [("<b>", "<strong>"), ("</b>", "</strong>"), ("<i>", "<em>"), ("</i>", "</em>")]

        var result = text
        for tuple in tuples {
            result = result.replacingOccurrences(of: tuple.0, with: tuple.1)
        }

        return result
    }
}

//
//  NSAttributedStringExtension.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 26/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

extension NSAttributedString {

    convenience init?(htmlString: String) {
        guard let encodedData = htmlString.data(using: String.Encoding.utf8) else {
            return nil
        }

        let attributedOptions: [String:AnyObject] = [
                NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType as AnyObject,
                NSCharacterEncodingDocumentAttribute: NSNumber(value: String.Encoding.utf8.rawValue)
        ]

        var attributedString: NSAttributedString?

        do {
            attributedString = try NSAttributedString(data: encodedData,
                options: attributedOptions, documentAttributes: nil)
        } catch {
            return nil
        }

        self.init(attributedString: attributedString!)
    }

    /// - returns: Attributed string by removing new line character at the end.
    func attributedStringByTrimingTrailingNewLine() -> NSAttributedString {

        let possibleNewLineCharacter = string.substring(from: string.characters.index(string.endIndex, offsetBy: -1))
        if possibleNewLineCharacter == "\n" {
            let range = NSRange(location: 0, length: length - 1)
            return attributedSubstring(from: range).attributedStringByTrimingTrailingNewLine()
        }

        return self
    }

    /// - returns: New line `\n` of type NSAttributedString.
    class func newLineAttributedString() -> NSAttributedString {
        return NSAttributedString(string: "\n")
    }

    /// Calculates bounding height appropiate to available width.
    ///
    /// - parameter width: Available width.
    ///
    /// - returns: Bounding height.
    func boundingHeightUsingAvailableWidth(_ width: CGFloat) -> CGFloat {

        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin]
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)

        return ceil(boundingRect(with: size, options:options, context: nil).size.height)
    }
}

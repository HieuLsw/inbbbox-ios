//
//  URLDetector.swift
//  Inbbbox
//
//  Created by Peter Bruz on 28/04/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

final class URLDetector {

    /// Detect URL in text container based on tap parameters from gesture recognizer.
    ///
    /// - parameter gestureRecognizer: Gesture recognizer of view containing text.
    /// - parameter textContainer: Text container to detect url in.
    /// - parameter layoutManager: Layout manager of tapped view.
    ///
    /// - returns: Detected URL if exists, otherwise returns `nil`.
    class func detectUrlFromGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                              textContainer: NSTextContainer,
                                              layoutManager: NSLayoutManager) -> URL? {

        guard let view = gestureRecognizer.view else { return nil }

        var locationOfTouchInLabel = gestureRecognizer.location(in: gestureRecognizer.view)
        let glyphRange = layoutManager.glyphRange(for: textContainer)

        let textOffset: CGPoint = {
            var textOffset = CGPoint.zero
            let textBounds = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
            let paddingHeight = (view.bounds.size.height - textBounds.size.height) / 2
            if paddingHeight > 0 {
                textOffset.y = paddingHeight
            }
            return textOffset
        }()

        locationOfTouchInLabel.x -= textOffset.x
        locationOfTouchInLabel.y -= textOffset.y

        let glyphIndex = layoutManager.glyphIndex(for: locationOfTouchInLabel, in: textContainer)
        let locationIndex = layoutManager.characterIndexForGlyph(at: glyphIndex)

        return (view as? UILabel)?.attributedText?.attribute(NSLinkAttributeName,
                                                             at: locationIndex, effectiveRange: nil) as? URL
    }
}

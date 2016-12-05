//
//  CommentComposerFormatter.swift
//  Inbbbox
//
//  Created by Blazej Wdowikowski on 11/9/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

final class CommentComposerFormatter {
    class func placeholderForMode(mode: ColorModeType) -> NSAttributedString {
        let textColor = mode.shotDetailsCommentContentTextColor
        let attributes = [NSForegroundColorAttributeName: textColor.colorWithAlphaComponent(0.7)]
        let placehoder = NSLocalizedString("CommentComposerView.TypeComment",
                                           comment: "Placeholder text, for comment text field.")
        return NSAttributedString(string: placehoder, attributes: attributes)
    }
}

//
//  ShotDetailsFormatter.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 23/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import UIKit.NSAttributedString

final class ShotDetailsFormatter {

    static let ShotDetailsFormatterSmallFontSize: CGFloat = 12
    static let ShotDetailsFormatterBigFontSize: CGFloat = 14

    static var shotDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.locale = NSLocale.currentLocale()

        return formatter
    }()

    static var commentDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.locale = NSLocale.currentLocale()
        formatter.timeStyle = .ShortStyle

        return formatter
    }()
    
    
    private static var colorMode: ColorModeType {
        return Settings.Customization.CurrentColorMode == .DayMode ? DayMode() : NightMode()
    }

    class func attributedStringForHeaderWithLinkRangeFromShot(shot: ShotType)
                    -> (attributedString: NSAttributedString, userLinkRange: NSRange?, teamLinkRange: NSRange?) {
        let mutableAttributedString = NSMutableAttributedString()
        var userLinkRange: NSRange?
        var teamLinkRange: NSRange?

        if shot.title.characters.count > 0 {
            appendTitleAttributedString(mutableAttributedString, shot: shot)
        }

        let author = (shot.user.name ?? shot.user.username)
        if author.characters.count > 0 {
            userLinkRange = appendAuthorAttributedString(mutableAttributedString, author: author)
        }

        if let team = shot.team?.name where team.characters.count > 0 {
            teamLinkRange = appendTeamAttributedString(mutableAttributedString, team: team)
        }

        let dateSting = shotDateFormatter.stringFromDate(shot.createdAt)
        if dateSting.characters.count > 0 {
            appendDateAttributedString(mutableAttributedString, dateSting: dateSting)
        }
        return (NSAttributedString(attributedString: mutableAttributedString), userLinkRange, teamLinkRange)
    }

    class func attributedShotDescriptionFromShot(shot: ShotType) -> NSAttributedString? {

        guard let body = shot.attributedDescription?.attributedStringByTrimingTrailingNewLine() else {
            return nil
        }

        let mutableBody = NSMutableAttributedString(attributedString: body)

        let style = NSMutableParagraphStyle()
        style.lineSpacing = 0
        style.maximumLineHeight = 20
        style.minimumLineHeight = 20

        mutableBody.addAttributes([
                NSForegroundColorAttributeName: ColorModeProvider.current().shotDetailsDescriptionViewColorTextColor,
                NSFontAttributeName: UIFont.systemFontOfSize(15),
                NSParagraphStyleAttributeName: style
        ], range: NSRange(location: 0, length: mutableBody.length))

        return mutableBody.copy() as? NSAttributedString
    }

    class func attributedCommentBodyForComment(comment: CommentType) -> NSAttributedString? {

        guard let body = comment.body where body.length > 0 else {
            return nil
        }

        let mutableBody = body.attributedStringByTrimingTrailingNewLine().mutableCopy()
        let range = NSRange(location: 0, length: mutableBody.length)

        mutableBody.addAttributes([
                NSForegroundColorAttributeName: ColorModeProvider.current().shotDetailsCommentContentTextColor,
                NSFontAttributeName: UIFont.systemFontOfSize(ShotDetailsFormatterBigFontSize)
        ], range: range)

        return mutableBody.copy() as? NSAttributedString
    }

    class func commentDateForComment(comment: CommentType) -> NSAttributedString {
        return NSAttributedString(string: commentDateFormatter.stringFromDate(comment.createdAt), attributes: [
                NSForegroundColorAttributeName: ColorModeProvider.current().shotDetailsCommentDateTextColor,
                NSFontAttributeName: UIFont.helveticaFont(.Neue, size: 10)
        ])
    }

    class func commentAuthorForComment(comment: CommentType) -> NSAttributedString {
        return NSAttributedString(string: comment.user.name ?? comment.user.username, attributes: [
                NSForegroundColorAttributeName: ColorModeProvider.current().shotDetailsCommentAuthorTextColor,
                NSFontAttributeName: UIFont.helveticaFont(.NeueMedium, size: 16)
        ])
    }

    class func commentLikesCountForComment(comment: CommentType) -> NSAttributedString {
        return NSAttributedString(string: "\(comment.likesCount)", attributes: [
            NSForegroundColorAttributeName: ColorModeProvider.current().shotDetailsCommentLikesCountTextColor,
            NSFontAttributeName: UIFont.helveticaFont(.Neue, size: 10)
        ])
    }
}

private extension ShotDetailsFormatter {

    class func appendTitleAttributedString(mutableAttributedString: NSMutableAttributedString, shot: ShotType) {
        let titleAttributedString = NSAttributedString(string: shot.title,
                attributes: [NSForegroundColorAttributeName: ColorModeProvider.current().shotDetailsHeaderViewTitleLabelTextColor,
                             NSFontAttributeName: UIFont.boldSystemFontOfSize(15)])
        mutableAttributedString.appendAttributedString(titleAttributedString)
        mutableAttributedString.appendAttributedString(NSAttributedString.newLineAttributedString())
    }

    class func appendAuthorAttributedString(mutableAttributedString: NSMutableAttributedString,
                                            author: String) -> NSRange {
        let prefixString = NSLocalizedString("ShotDetailsFormatter.By",
                comment: "Preposition describing author of shot.")
        let bigFont = UIFont.systemFontOfSize(ShotDetailsFormatterBigFontSize)
        let smallFont = UIFont.systemFontOfSize(ShotDetailsFormatterSmallFontSize)
        let authorAttributedString = NSMutableAttributedString(
        string: prefixString + " " + author, attributes: [NSForegroundColorAttributeName: ColorModeProvider.current().shotDetailsHeaderViewAuthorLinkColor,
                                                          NSFontAttributeName: bigFont])
        authorAttributedString.setAttributes([NSForegroundColorAttributeName: ColorModeProvider.current().shotDetailsHeaderViewAuthorNotLinkColor,
                                              NSFontAttributeName: smallFont],
                range: NSRange(location: 0, length: prefixString.characters.count))
        let userLinkRange = NSRange(location: mutableAttributedString.length + prefixString.characters.count,
                length: author.characters.count + 1)
        mutableAttributedString.appendAttributedString(authorAttributedString)
        mutableAttributedString.appendAttributedString(NSAttributedString.newLineAttributedString())
        return userLinkRange
    }

    class func appendTeamAttributedString(mutableAttributedString: NSMutableAttributedString, team: String) -> NSRange {
        let prefixString = NSLocalizedString("ShotDetailsFormatter.For",
                comment: "Preposition describing for who shot was made.")
        let font = UIFont.systemFontOfSize(ShotDetailsFormatterBigFontSize)
        let teamAttributedString = NSMutableAttributedString(
        string: prefixString + " " + team, attributes: [NSForegroundColorAttributeName: ColorModeProvider.current().shotDetailsHeaderViewAuthorLinkColor,
                                                        NSFontAttributeName: font])
        teamAttributedString.setAttributes([
                NSForegroundColorAttributeName: ColorModeProvider.current().shotDetailsHeaderViewAuthorNotLinkColor,
                NSFontAttributeName: UIFont.systemFontOfSize(ShotDetailsFormatterSmallFontSize)
        ], range: NSRange(location: 0, length: prefixString.characters.count))
        let teamLinkRange = NSRange(location: mutableAttributedString.length + prefixString.characters.count,
                                    length: team.characters.count + 1)
        mutableAttributedString.appendAttributedString(teamAttributedString)
        mutableAttributedString.appendAttributedString(NSAttributedString.newLineAttributedString())
        return teamLinkRange
    }

    class func appendDateAttributedString(mutableAttributedString: NSMutableAttributedString, dateSting: String) {
        let prefixString = NSLocalizedString("ShotDetailsFormatter.On",
                comment: "Preposition describing when shot was made.")
        let font = UIFont.systemFontOfSize(ShotDetailsFormatterSmallFontSize)
        let dateAttributedString = NSAttributedString(
        string: prefixString + " " + dateSting, attributes: [NSForegroundColorAttributeName: ColorModeProvider.current().shotDetailsHeaderViewAuthorNotLinkColor,
                                                             NSFontAttributeName: font])
        mutableAttributedString.appendAttributedString(dateAttributedString)
    }
}

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

    static var shotDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale.current

        return formatter
    }()

    static var commentDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale.current
        formatter.timeStyle = .short

        return formatter
    }()
    
    
    fileprivate static var colorMode: ColorModeType {
        return Settings.Customization.CurrentColorMode == .dayMode ? DayMode() : NightMode()
    }

    class func attributedStringForHeaderWithLinkRangeFromShot(_ shot: ShotType)
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

        if let team = shot.team?.name, team.characters.count > 0 {
            teamLinkRange = appendTeamAttributedString(mutableAttributedString, team: team)
        }

        let dateSting = shotDateFormatter.string(from: shot.createdAt as Date)
        if dateSting.characters.count > 0 {
            appendDateAttributedString(mutableAttributedString, dateSting: dateSting)
        }
        return (NSAttributedString(attributedString: mutableAttributedString), userLinkRange, teamLinkRange)
    }

    class func attributedShotDescriptionFromShot(_ shot: ShotType) -> NSAttributedString? {

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
                NSFontAttributeName: UIFont.sanFransiscoFont(ofSize: 15),
                NSParagraphStyleAttributeName: style
        ], range: NSRange(location: 0, length: mutableBody.length))

        return mutableBody.copy() as? NSAttributedString
    }

    class func attributedCommentBodyForComment(_ comment: CommentType) -> NSAttributedString? {

        guard let body = comment.body, body.length > 0 else {
            return nil
        }

        if let mutableBody = body.attributedStringByTrimingTrailingNewLine().mutableCopy() as? NSMutableAttributedString {
            let range = NSRange(location: 0, length: (mutableBody as AnyObject).length)

            (mutableBody as AnyObject).addAttributes([
                    NSForegroundColorAttributeName: ColorModeProvider.current().shotDetailsCommentContentTextColor,
                    NSFontAttributeName: UIFont.sanFransiscoFont(ofSize: ShotDetailsFormatterBigFontSize)
            ], range: range)

            return mutableBody.copy() as? NSAttributedString
        }
        return nil
    }

    class func commentDateForComment(_ comment: CommentType) -> NSAttributedString {
        return NSAttributedString(string: commentDateFormatter.string(from: comment.createdAt as Date), attributes: [
                NSForegroundColorAttributeName: ColorModeProvider.current().shotDetailsCommentDateTextColor,
                NSFontAttributeName: UIFont.sanFransiscoFont(withType: .regular, size: 10)
        ])
    }

    class func commentAuthorForComment(_ comment: CommentType) -> NSAttributedString {
        return NSAttributedString(string: comment.user.name ?? comment.user.username, attributes: [
                NSForegroundColorAttributeName: ColorModeProvider.current().shotDetailsCommentAuthorTextColor,
                NSFontAttributeName: UIFont.sanFransiscoFont(withType: .medium, size: 16)
        ])
    }

    class func commentLikesCountForComment(_ comment: CommentType) -> NSAttributedString {
        return NSAttributedString(string: "\(comment.likesCount)", attributes: [
            NSForegroundColorAttributeName: ColorModeProvider.current().shotDetailsCommentLikesCountTextColor,
            NSFontAttributeName: UIFont.sanFransiscoFont(withType: .regular, size: 10)
        ])
    }
}

private extension ShotDetailsFormatter {

    class func appendTitleAttributedString(_ mutableAttributedString: NSMutableAttributedString, shot: ShotType) {
        let titleAttributedString = NSAttributedString(string: shot.title,
                attributes: [NSForegroundColorAttributeName: ColorModeProvider.current().shotDetailsHeaderViewTitleLabelTextColor,
                             NSFontAttributeName: UIFont.sanFransiscoFont(withType: .bold, size: 15)])
        mutableAttributedString.append(titleAttributedString)
        mutableAttributedString.append(NSAttributedString.newLineAttributedString())
    }

    class func appendAuthorAttributedString(_ mutableAttributedString: NSMutableAttributedString,
                                            author: String) -> NSRange {
        let prefixString = NSLocalizedString("ShotDetailsFormatter.By",
                comment: "Preposition describing author of shot.")
        let bigFont = UIFont.sanFransiscoFont(ofSize: ShotDetailsFormatterBigFontSize)
        let smallFont = UIFont.sanFransiscoFont(ofSize: ShotDetailsFormatterSmallFontSize)
        let authorAttributedString = NSMutableAttributedString(
        string: prefixString + " " + author, attributes: [NSForegroundColorAttributeName: ColorModeProvider.current().shotDetailsHeaderViewAuthorLinkColor,
                                                          NSFontAttributeName: bigFont])
        authorAttributedString.setAttributes([NSForegroundColorAttributeName: ColorModeProvider.current().shotDetailsHeaderViewAuthorNotLinkColor,
                                              NSFontAttributeName: smallFont],
                range: NSRange(location: 0, length: prefixString.characters.count))
        let userLinkRange = NSRange(location: mutableAttributedString.length + prefixString.characters.count,
                length: author.characters.count + 1)
        mutableAttributedString.append(authorAttributedString)
        mutableAttributedString.append(NSAttributedString.newLineAttributedString())
        return userLinkRange
    }

    class func appendTeamAttributedString(_ mutableAttributedString: NSMutableAttributedString, team: String) -> NSRange {
        let prefixString = NSLocalizedString("ShotDetailsFormatter.For",
                comment: "Preposition describing for who shot was made.")
        let font = UIFont.sanFransiscoFont(ofSize: ShotDetailsFormatterBigFontSize)
        let teamAttributedString = NSMutableAttributedString(
        string: prefixString + " " + team, attributes: [NSForegroundColorAttributeName: ColorModeProvider.current().shotDetailsHeaderViewAuthorLinkColor,
                                                        NSFontAttributeName: font])
        teamAttributedString.setAttributes([
                NSForegroundColorAttributeName: ColorModeProvider.current().shotDetailsHeaderViewAuthorNotLinkColor,
                NSFontAttributeName: UIFont.sanFransiscoFont(ofSize: ShotDetailsFormatterSmallFontSize)
        ], range: NSRange(location: 0, length: prefixString.characters.count))
        let teamLinkRange = NSRange(location: mutableAttributedString.length + prefixString.characters.count,
                                    length: team.characters.count + 1)
        mutableAttributedString.append(teamAttributedString)
        mutableAttributedString.append(NSAttributedString.newLineAttributedString())
        return teamLinkRange
    }

    class func appendDateAttributedString(_ mutableAttributedString: NSMutableAttributedString, dateSting: String) {
        let prefixString = NSLocalizedString("ShotDetailsFormatter.On",
                comment: "Preposition describing when shot was made.")
        let font = UIFont.sanFransiscoFont(ofSize: ShotDetailsFormatterSmallFontSize)
        let dateAttributedString = NSAttributedString(
        string: prefixString + " " + dateSting, attributes: [NSForegroundColorAttributeName: ColorModeProvider.current().shotDetailsHeaderViewAuthorNotLinkColor,
                                                             NSFontAttributeName: font])
        mutableAttributedString.append(dateAttributedString)
    }
}

//
//  ShotsQuery.swift
//  Inbbbox
//
//  Created by Radoslaw Szeja on 14/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct ShotsQuery: Query {

    /// ShotsType specify source of shots.
    ///
    /// - List:           General list of the shots.
    /// - UserShots:      List of the given user's shots.
    /// - BucketShots:    List of the given bucket's shots.
    /// - UserLikedShots: List of the given user's liked shots.
    enum ShotsType {
        case list, userShots(UserType), bucketShots(BucketType), userLikedShots(UserType), likedShots, projectShots(ProjectType)

        var path: String {

            switch self {
            case .list:
                return "/shots"
            case .userShots(let user):
                let path = user.accountType == .Team ? "teams" : "users"
                return "/\(path)/\(user.username)/shots"
            case .bucketShots(let bucket):
                return "/buckets/\(bucket.identifier)/shots"
            case .userLikedShots(let user):
                return "/users/\(user.username)/likes"
            case .likedShots:
                return "/user/likes"
            case .projectShots(let project):
                return "/projects/\(project.identifier)/shots"
            }
        }
    }

    // Query definition
    let method = Method.GET
    var parameters = Parameters(encoding: .url)
    fileprivate(set) var path = "/shots"
    var followingUsersShotsQuery = false {
        willSet (newValue) {
            path = newValue ? "/user/following/shots" : "/shots"
        }
    }

    /// Initialize query for list of the shots of given type.
    ///
    /// - parameter type: Shot's type.
    init(type: ShotsType) {
        path = type.path
    }

    // Types
    enum List: String {
        case Animated = "animated"
        case Attachments = "attachments"
        case Debuts = "debuts"
        case Playoffs = "playoffs"
        case Rebounds = "rebounds"
        case Teams = "teams"
    }

    enum TimeFrame: String {
        case Week = "week"
        case Month = "month"
        case Year = "year"
        case Ever = "ever"
    }

    enum Sort: String {
        case Comments = "comments"
        case Recent = "recent"
        case Views = "views"
    }

    // Parameters keys
    fileprivate enum Key: String {
        case List = "list"
        case Timeframe = "timeframe"
        case Date = "date"
        case Sort = "sort"
    }

    // Parameters accessors
    var list: List? {
        get {
            if let listValue = parameters[Key.List.rawValue] as? String {
                return List(rawValue: listValue)
            }
            return nil
        }
        set { parameters[Key.List.rawValue] = newValue?.rawValue as AnyObject? }
    }

    var timeFrame: TimeFrame? {
        get {
            if let timeFrameValue = parameters[Key.Timeframe.rawValue] as? String {
                return TimeFrame(rawValue: timeFrameValue)
            }
            return nil
        }
        set { parameters[Key.Timeframe.rawValue] = newValue?.rawValue as AnyObject? }
    }

    var date: Date? {
        get {
            if let dateString = parameters[Key.Date.rawValue] as? String {
                return Formatter.Date.Basic.date(from: dateString)
            }
            return nil
        }
        set {
            if let newDate = newValue {
                parameters[Key.Date.rawValue] = Formatter.Date.Basic.string(from: newDate) as AnyObject?
            }
        }
    }

    var sort: Sort? {
        get {
            if let sortValue = parameters[Key.Sort.rawValue] as? String {
                return Sort(rawValue: sortValue)
            }
            return nil
        }
        set { parameters[Key.Sort.rawValue] = newValue?.rawValue as AnyObject? }
    }
}

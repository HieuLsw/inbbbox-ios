//
//  APIShotsProviderConfiguration.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 22/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

class APIShotsProviderConfiguration {

    enum ShotsSource {
        case newToday, popularToday, debuts, following

        var isActive: Bool {
            switch self {
                case .newToday: return Settings.StreamSource.NewToday
                case .popularToday: return Settings.StreamSource.PopularToday
                case .debuts: return Settings.StreamSource.Debuts
                case .following: return Settings.StreamSource.Following
            }
        }
    }

    var sources: [ShotsSource] {
        return [.newToday, .popularToday, .debuts, .following].filter { $0.isActive }
    }

    func queryByConfigurationForQuery(_ query: ShotsQuery, source: ShotsSource) -> ShotsQuery {
        var resultQuery = query
        switch source {
            case .newToday:
                resultQuery.parameters["sort"] = "recent" as AnyObject?
            case .popularToday:
                break
            case .debuts:
                resultQuery.parameters["list"] = "debuts" as AnyObject?
                resultQuery.parameters["sort"] = "recent" as AnyObject?
            case .following:
                resultQuery.followingUsersShotsQuery = true
        }

        resultQuery.date = Date()

        return resultQuery
    }
}

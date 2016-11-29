//
//  APIRateLimitKeeper.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 16/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import Async
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


private let xRateLimit = "X-RateLimit-Limit"
private let xRateLimitRemaining = "X-RateLimit-Remaining"
private let xRateLimitReset = "X-RateLimit-Reset"
private let dailyRateLimitRemainingKey = "DailyRateLimitRemainingKey"

/**
 Error related to rate limit of API.

 - DidExceedRateLimitPerMinute: Occurs when application did perform more than 60 hits to API per minute.
                                Provides time left to reset as parameter.
 - DidExceedRateLimitPerDay:    Occurs when application did perform to many hits to API per day.
                                Provides time left to reset as parameter.
 */
enum APIRateLimitKeeperError: Error {
    case didExceedRateLimitPerMinute(TimeInterval)
    case didExceedRateLimitPerDay(TimeInterval)
}

/// Protects against exceeding the API limit.
final class APIRateLimitKeeper {

    /// Minute rate limit.
    fileprivate(set) var rateLimitPerMinute: UInt?

    /// Daily rate limit.
    /// When user is **not** authenticated, then limit is uknown due to client access token usage.
    /// Inbbbox will use own client access token which is available globally for other Inbbbox aplications
    /// installed on other devices.
    var rateLimitPerDay: UInt? {
        return TokenStorage.currentToken != nil ?
            Dribbble.RequestPerDayLimitForAuthenticatedUser : nil
    }

    /// Number of api hits remaining during current minute.
    /// The number is unknown until api request wasn't sent previously.
    fileprivate(set) var rateLimitRemainingPerMinute: UInt?

    /// Number of api hits remaining during current day.
    /// The number is unknown if user is not currently logged in.
    fileprivate(set) var rateLimitRemainingPerDay: UInt? {
        get {
            if let value = Defaults[dailyRateLimitRemainingKey].int {
                return UInt(value)
            }
            return  nil
        }
        set {
            Defaults[dailyRateLimitRemainingKey] = newValue != nil ? Int(newValue!) : nil
        }
    }

    /// Time interval left to reset minute rate limit.
    /// The number is unknown until api request wasn't sent previously.
    fileprivate(set) var timeIntervalRemainingToResetMinuteLimit: TimeInterval?

    /// Time interval left to reset daily rate limit.
    var timeIntervalRemainingToResetDailyLimit: TimeInterval {

        let oneDayTimeInterval = TimeInterval(60 * 60 * 24)
        let startOfNextDay = Calendar(identifier: Calendar.Identifier.gregorian).startOfDay(
                for: Date(timeIntervalSinceNow: oneDayTimeInterval))

        return startOfNextDay.timeIntervalSince(Date())
    }

    /// Boolean that indicates if timer to reset API rate limit per minute is set
    fileprivate var timerToResetMinuteLimitIsSet = false

    /// Boolean that indicates if timer to reset API rate limit per day is set
    fileprivate var timerToResetDailyLimitIsSet = false

    /// Shared instance.
    static let sharedKeeper = APIRateLimitKeeper()

    /**
     Sets limitation according to information from given header.

     - parameter header: Header which will be used to obtain the limits.
     */
    func setCurrentLimitFromHeader(_ header: [String: AnyObject]) {

        rateLimitPerMinute = integerFromHeader(header, forKey: xRateLimit)

        if let interval = integerFromHeader(header, forKey: xRateLimitReset) {

            let previousTimeIntervalRemainingToResetMinuteLimit = timeIntervalRemainingToResetMinuteLimit

            timeIntervalRemainingToResetMinuteLimit = {
                let resetDate = Date(timeIntervalSince1970: TimeInterval(interval))
                return max(resetDate.timeIntervalSinceNow, 0)
            }()

            // Checks whether API respond with greater value of time needed to reset than stored one.
            // If yes then sets remaining rate limit to default one.
            let isNewMinuteSlotForSendingRequest =
                    previousTimeIntervalRemainingToResetMinuteLimit < timeIntervalRemainingToResetMinuteLimit
            if isNewMinuteSlotForSendingRequest {
                rateLimitRemainingPerMinute = rateLimitPerMinute
            }

            // Checks whether incoming request contains lower value for XRateLimitRemaining
            // than stored one in current request minute slot.
            // If yes then assign them to stored one. Otherwise do nothing.
            let incomingRateLimitRemainingPerMinute = integerFromHeader(header, forKey: xRateLimitRemaining)
            if incomingRateLimitRemainingPerMinute < rateLimitRemainingPerMinute {
                rateLimitRemainingPerMinute = incomingRateLimitRemainingPerMinute
            }

            if let limit = rateLimitRemainingPerMinute {
                AnalyticsManager.trackRemaining(limit)
            }
        }
    }

    /**
     Verifies daily rate limit from response.

     - parameter response: Response to verify.

     - throws: APIRateLimitKeeperError.DidExceedRateLimitPerDay error with time interval remaining
               to reset daily limit as parameter.
     */
    func verifyResponseForRateLimitation(_ response: URLResponse?) throws {

        if let response = response as? HTTPURLResponse, response.statusCode == 429 {
            throw APIRateLimitKeeperError.didExceedRateLimitPerDay(timeIntervalRemainingToResetDailyLimit)
        }
    }

    /**
     Verifies rate limit. Throws with APIRateLimitKeeperError if limit is known and exceeded.

     - throws: APIRateLimitKeeperError.DidExceedRateLimitPerDay or APIRateLimitKeeperError.DidExceedRateLimitPerMinute
               error with time interval remaining to reset limit as parameter.
     */
    func verifyRateLimit() throws {

        if var perDayRemainingLimit = rateLimitRemainingPerDay {
            perDayRemainingLimit -= 1
            rateLimitRemainingPerDay = perDayRemainingLimit
        }

        if let limit = rateLimitRemainingPerDay, limit <= 0 {

            if !timerToResetDailyLimitIsSet {
                Async.background(after: timeIntervalRemainingToResetDailyLimit) { [weak self] in
                    self?.rateLimitRemainingPerDay = nil
                    self?.timerToResetDailyLimitIsSet = false
                }
                timerToResetDailyLimitIsSet = true
            }

            throw APIRateLimitKeeperError.didExceedRateLimitPerDay(timeIntervalRemainingToResetDailyLimit ?? 0)
        }

        if let limit = rateLimitRemainingPerMinute, limit <= 1 {

            if !timerToResetMinuteLimitIsSet {
                Async.background(after: timeIntervalRemainingToResetMinuteLimit) { [weak self] in
                    self?.rateLimitRemainingPerMinute = nil
                    self?.timerToResetMinuteLimitIsSet = false
                }
                timerToResetMinuteLimitIsSet = true
            }

            throw APIRateLimitKeeperError.didExceedRateLimitPerMinute(timeIntervalRemainingToResetMinuteLimit ?? 0)
        }
    }

    /**
     Clears stored information about API rate limits. Method should be called while logging out.
     */
    func clearRateLimitsInfo() {
        rateLimitRemainingPerDay = nil
        rateLimitRemainingPerMinute = nil
    }
}

private extension APIRateLimitKeeper {

    func integerFromHeader(_ header: [String: AnyObject], forKey key: String) -> UInt? {

        if let stringValue = header[key] as? String, let uintValue = UInt(stringValue) {
            return uintValue
        }
        return nil
    }
}

//
//  APIRateLimitKeeperSpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 17/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

@testable import Inbbbox

class APIRateLimitKeeperSpec: QuickSpec {
    override func spec() {
        
        var sut: APIRateLimitKeeper!
        
        beforeEach {
            sut = APIRateLimitKeeper()
        }
        
        afterEach {
            sut = nil
        }
        
        afterSuite {
            UserDefaults.standard.removeObject(forKey: "DailyRateLimitRemainingKey")
        }

        describe("when newly initilized") {
            
            beforeEach {
                UserDefaults.standard.removeObject(forKey: "DailyRateLimitRemainingKey")
            }
            
            it("daily rate limit should not be defined") {
                expect(sut.rateLimitRemainingPerDay).to(beNil())
            }
            
            it("minute rate limit should not be defined") {
                expect(sut.rateLimitPerMinute).to(beNil())
            }
            
            it("time interval to reset minute limit should not be defined") {
                expect(sut.timeIntervalRemainingToResetMinuteLimit).to(beNil())
            }
        }

        describe("when creating sharedKeeper one more time") {
            
            var anotherAPIRateLimitKeeper: APIRateLimitKeeper!
            
            beforeEach {
                anotherAPIRateLimitKeeper = APIRateLimitKeeper.sharedKeeper
            }
            
            it("instances should be same") {
                expect(APIRateLimitKeeper.sharedKeeper).to(beIdenticalTo(anotherAPIRateLimitKeeper))
            }
        }
        
        describe("when user is authenticated") {

            beforeEach {
                TokenStorage.storeToken("fixture.token")
            }

            afterEach {
                TokenStorage.clear()
            }

            it("rate limit should be set to dribbble default") {
                expect(sut.rateLimitPerDay).to(equal(1440))
            }
        }

        describe("when user is not authenticated") {

            beforeEach {
                TokenStorage.clear()
            }

            it("rate limit should be nil") {
                expect(sut.rateLimitPerDay).to(beNil())
            }
        }
        
        describe("when setting current limit from header") {

            beforeEach {
                let header = self.fixtureHeaderWithLimit(10, remainingLimit: 5, timeToResetSinceNow: 100)
                sut.setCurrentLimitFromHeader(header)
            }

            it("rate limit per minute should be properly set") {
                expect(sut.rateLimitPerMinute).to(equal(10))
            }

            it("remaining rate limit per minute should be properly set") {
                expect(sut.rateLimitRemainingPerMinute).to(equal(5))
            }

            it("rate limit per minute should be properly set") {
                expect(sut.timeIntervalRemainingToResetMinuteLimit).to(beCloseTo(100, within: 1))
            }
        }

        describe("when verifying limitation from response") {
            
            context("and response doesn't claim about exceeding the API limit") {
                
                it("keeper shouldn't throw an error") {
                    expect{
                        try sut.verifyResponseForRateLimitation(self.fixtureResponseWithCode(200))
                    }.toNot(throwError())
                }
            }
            
            context("and response does claim about exceeding the API limit") {
                
                it("keeper should throw an error") {
                    expect{
                        try sut.verifyResponseForRateLimitation(self.fixtureResponseWithCode(429))
                    }.to(throwError(errorType: APIRateLimitKeeperError.self))
                }
            }
        }
   
        describe("when verifies rate limit per minute") {
            
            context("and rate limit is equal to 0") {
                
                beforeEach {
                    let header = self.fixtureHeaderWithLimit(10, remainingLimit: 0, timeToResetSinceNow: 100)
                    sut.setCurrentLimitFromHeader(header)
                }
                
                afterEach {
                    // Remember to increase remaining limit after this test.
                    let header = self.fixtureHeaderWithLimit(10, remainingLimit: 10, timeToResetSinceNow: 1000)
                    sut.setCurrentLimitFromHeader(header)
                }
                
                it("keeper should throw an error") {
                    expect{
                        try sut.verifyRateLimit()
                    }.to(throwError(errorType: APIRateLimitKeeperError.self))
                }
            }
        }
    }
}

private extension APIRateLimitKeeperSpec {
    
    func fixtureResponseWithCode(_ code: Int) -> HTTPURLResponse {
        return HTTPURLResponse(
            url: URL(string: "http://www.fixture.host")!,
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
    }
    
    func fixtureHeaderWithLimit(_ limit: UInt, remainingLimit: UInt, timeToResetSinceNow: TimeInterval) -> [String: AnyObject] {
        
        let rateLimitReset = Date(timeIntervalSinceNow: timeToResetSinceNow).timeIntervalSince(Date(timeIntervalSince1970: 0))
        
        return [
            "X-RateLimit-Limit": String(limit) as AnyObject,
            "X-RateLimit-Remaining": String(remainingLimit) as AnyObject,
            "X-RateLimit-Reset": String(UInt(rateLimitReset)) as AnyObject
        ]
    }
}

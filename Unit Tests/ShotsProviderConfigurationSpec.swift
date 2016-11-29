//
//  ShotsProviderConfigurationSpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 26/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Nimble
import Quick

@testable import Inbbbox

class ShotsProviderConfigurationSpec: QuickSpec {
    override func spec() {
        
        restoreEnvironmentAfterSuite()
        
        var sut: APIShotsProviderConfiguration!
        
        beforeEach {
            sut = APIShotsProviderConfiguration()
        }
        
        afterEach {
            sut = nil
        }
        
        describe("when setting all source to active") {
            
            beforeEach {
                Settings.StreamSource.NewToday = true
                Settings.StreamSource.PopularToday = true
                Settings.StreamSource.Debuts = true
                Settings.StreamSource.Following = true
            }
            
            it("should return 4 sources") {
                expect(sut.sources.count).to(equal(4))
            }
            
            context("when disabling 1 source") {
                
                beforeEach {
                    Settings.StreamSource.NewToday = false
                }
                
                it("should return 3 sources") {
                    expect(sut.sources.count).to(equal(3))
                }
                
                it("shouldn't return disabled source") {
                    expect(sut.sources).toNot(contain(APIShotsProviderConfiguration.ShotsSource.newToday))
                }
            }
        }
        
        describe("when configure query") {
            
            var query: ShotsQuery!
            
            afterEach {
                query = nil
            }
            
            context("with NewToday source") {
                
                beforeEach {
                    query = sut.queryByConfigurationForQuery(ShotsQuery(type: .list), source: .newToday)
                }
                
                it("should query have proper parameters") {
                    
                    expect(query.parameters["sort"] as? String).to(equal("recent"))
                    expect(query.followingUsersShotsQuery).to(beFalsy())
                    expect(query.date).to(equal(self.todayDate))
                }
            }
            
            context("with PopularToday source") {
                
                beforeEach {
                    query = sut.queryByConfigurationForQuery(ShotsQuery(type: .list), source: .popularToday)
                }
                
                it("should query have proper parameters") {
                    expect(query.parameters.body).to(beNil())
                    expect(query.followingUsersShotsQuery).to(beFalsy())
                    expect(query.date).to(equal(self.todayDate))
                }
            }
            
            context("with Debuts source") {
                
                beforeEach {
                    query = sut.queryByConfigurationForQuery(ShotsQuery(type: .list), source: .debuts)
                }
                
                it("should query have proper parameters") {
                    expect(query.parameters["sort"] as? String).to(equal("recent"))
                    expect(query.parameters["list"] as? String).to(equal("debuts"))
                    expect(query.followingUsersShotsQuery).to(beFalsy())
                    expect(query.date).to(equal(self.todayDate))
                }
            }
            
            context("with Following source") {
                
                beforeEach {
                    query = sut.queryByConfigurationForQuery(ShotsQuery(type: .list), source: .following)
                }
                
                it("should query have proper parameters") {
                     expect(query.parameters.body).to(beNil())
                    expect(query.followingUsersShotsQuery).to(beTruthy())
                    expect(query.date).to(equal(self.todayDate))
                }
            }
        }
    }
}

private extension ShotsProviderConfigurationSpec {
    
    func restoreEnvironmentAfterSuite() {
        
        var savedSettings: (newToday: Bool, popularToday: Bool, debuts: Bool, following: Bool)!
        
        beforeSuite {
            savedSettings = (
                newToday: Settings.StreamSource.NewToday,
                popularToday: Settings.StreamSource.PopularToday,
                debuts: Settings.StreamSource.Debuts,
                following: Settings.StreamSource.Following
            )
        }
        
        afterSuite {
            Settings.StreamSource.NewToday = savedSettings.newToday
            Settings.StreamSource.PopularToday = savedSettings.popularToday
            Settings.StreamSource.Debuts = savedSettings.debuts
            Settings.StreamSource.Following = savedSettings.following
        }
    }
    
    var todayDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter.date(from: formatter.string(from: Date()))!
    }
}

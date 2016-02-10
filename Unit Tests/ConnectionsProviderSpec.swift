//
//  ConnectionsProviderSpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 04/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import PromiseKit

@testable import Inbbbox

class ConnectionsProviderSpec: QuickSpec {
    override func spec() {
        
        var followees: [Followee]?
        var followers: [Follower]?
        var sut: MockConnectionsProvider!
        
        beforeEach {
            sut = MockConnectionsProvider()
        }
        
        afterEach {
            sut = nil
            followees = nil
            followers = nil
        }
        
        describe("when providing my folowees") {
            
            beforeEach {
                sut.mockType = .MockFollowee
            }
            
            context("and token doesn't exist") {
                
                var error: ErrorType?
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                afterEach {
                    error = nil
                }
                
                it("error should appear") {
                    sut.provideMyFollowees().then { _ -> Void in
                        fail()
                    }.error { _error in
                        error = _error
                    }
                    
                    expect(error is AuthorizableError).toEventually(beTruthy())
                }
            }
            
            context("and token does exist") {
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                }
                
                it("buckets should be properly returned") {
                    sut.provideMyFollowees().then { _followees -> Void in
                        followees = _followees
                    }.error { _ in fail() }
                    
                    expect(followees).toNotEventually(beNil())
                    expect(followees).toEventually(haveCount(3))
                }
            }
        }
        
        describe("when providing followees/followers from") {
            
            beforeEach {
                sut.mockType = .MockFollower
            }
            
            it("from next page, followers should be properly returned") {
                sut.nextPage().then { _followers -> Void in
                    followers = _followers
                }.error { _ in fail() }
                
                expect(followers).toNotEventually(beNil())
                expect(followers).toEventually(haveCount(3))
            }
            
            it("from previous page, followers be properly returned") {
                sut.previousPage().then { _followers -> Void in
                    followers = _followers
                }.error { _ in fail() }
                
                expect(followers).toNotEventually(beNil())
                expect(followers).toEventually(haveCount(3))
            }
        }
        
        describe("when providing my followers") {
            
            beforeEach {
                sut.mockType = .MockFollower
            }
            
            context("and token doesn't exist") {
                
                var error: ErrorType?
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                afterEach {
                    error = nil
                }
                
                it("error should appear") {
                    sut.provideMyFollowers().then { _ -> Void in
                        fail()
                    }.error { _error in
                        error = _error
                    }
                    
                    expect(error is AuthorizableError).toEventually(beTruthy())
                }
            }
            
            context("and token does exist") {
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                }
                
                it("buckets should be properly returned") {
                    sut.provideMyFollowers().then { _followeers -> Void in
                        followers = _followeers
                    }.error { _ in fail() }
                    
                    expect(followers).toNotEventually(beNil())
                    expect(followers).toEventually(haveCount(3))
                }
            }
        }
        
        describe("when providing followees") {
            
            beforeEach {
                sut.mockType = .MockFollowee
            }
            
            it("for user, followees should be properly returned") {
                sut.provideFolloweesForUser(User.fixtureUser()).then { _followees -> Void in
                    followees = _followees
                }.error { _ in fail() }
                
                expect(followees).toNotEventually(beNil())
                expect(followees).toEventually(haveCount(3))
            }
            
            it("for users, followees should be properly returned") {
                sut.provideFolloweesForUsers([User.fixtureUser(), User.fixtureUser()]).then { _followees -> Void in
                    followees = _followees
                }.error { _ in fail() }
                
                expect(followees).toNotEventually(beNil())
                expect(followees).toEventually(haveCount(3))
            }
        }
        
        describe("when providing followers") {
            
            beforeEach {
                sut.mockType = .MockFollower
            }
            
            it("for user, followers should be properly returned") {
                sut.provideFollowersForUser(User.fixtureUser()).then { _followers -> Void in
                    followers = _followers
                }.error { _ in fail() }
                
                expect(followers).toNotEventually(beNil())
                expect(followers).toEventually(haveCount(3))
            }
            
            it("for users, followers should be properly returned") {
                sut.provideFollowersForUsers([User.fixtureUser(), User.fixtureUser()]).then { _followers -> Void in
                    followers = _followers
                }.error { _ in fail() }
                
                expect(followers).toNotEventually(beNil())
                expect(followers).toEventually(haveCount(3))
            }
        }
    }
}

//Explanation: Create MockConnectionsProvider to override methods from PageableProvider.
private class MockConnectionsProvider: ConnectionsProvider {
    
    var mockType: MockType!
    
    enum MockType {
        case MockFollowee, MockFollower
    }
    
    override func firstPageForQueries<T: Mappable>(queries: [Query], withSerializationKey key: String?) -> Promise<[T]?> {
        return mockResult(T)
    }
    
    override func nextPageFor<T: Mappable>(type: T.Type) -> Promise<[T]?> {
        return mockResult(T)
    }
    
    override func previousPageFor<T: Mappable>(type: T.Type) -> Promise<[T]?> {
        return mockResult(T)
    }
    
    func mockResult<T: Mappable>(type: T.Type) -> Promise<[T]?> {
        return Promise<[T]?> { fulfill, _ in
            
            if mockType == nil {
                fatalError("No mock type has been set up! Did you forget to do so?")
            }
            
            let json = mockType == .MockFollowee ?
                JSONSpecLoader.sharedInstance.fixtureFolloweeConnectionsJSON(withCount: 3) :
                JSONSpecLoader.sharedInstance.fixtureFollowerConnectionsJSON(withCount: 3)
            let result = json.map { T.map($0) }
            
            fulfill(result)
        }
    }
}

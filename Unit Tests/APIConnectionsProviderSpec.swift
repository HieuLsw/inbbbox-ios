//
//  APIConnectionsProviderSpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 04/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import PromiseKit

@testable import Inbbbox

class APIConnectionsProviderSpec: QuickSpec {
    override func spec() {

        var followees: [Followee]?
        var followers: [Follower]?
        var sut: APIConnectionsProviderMock!
        
        beforeEach {
            sut = APIConnectionsProviderMock()
        }
        
        afterEach {
            sut = nil
            followees = nil
            followers = nil
        }
        
        describe("when providing my folowees") {
            
            beforeEach {
                sut.mockType = .mockFollowee
            }
            
            context("and token doesn't exist") {
                
                var error: Error?
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                afterEach {
                    error = nil
                }
                
                it("error should appear") {
                    sut.provideMyFollowees().then { _ -> Void in
                        fail()
                    }.catch { _error in
                        error = _error
                    }
                    
                    expect(error is VerifiableError).toEventually(beTruthy())
                }
            }
            
            context("and token does exist") {
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                }
                
                it("buckets should be properly returned") {
                    sut.provideMyFollowees().then { _followees -> Void in
                        followees = _followees
                    }.catch { _ in fail() }
                    
                    expect(followees).toNotEventually(beNil())
                    expect(followees).toEventually(haveCount(3))
                }
            }
        }
        
        describe("when providing followees/followers from") {
            
            beforeEach {
                sut.mockType = .mockFollower
            }
            
            it("from next page, followers should be properly returned") {
                sut.nextPage().then { _followers -> Void in
                    followers = _followers
                }.catch { _ in fail() }
                
                expect(followers).toNotEventually(beNil())
                expect(followers).toEventually(haveCount(3))
            }
            
            it("from previous page, followers be properly returned") {
                sut.previousPage().then { _followers -> Void in
                    followers = _followers
                }.catch { _ in fail() }
                
                expect(followers).toNotEventually(beNil())
                expect(followers).toEventually(haveCount(3))
            }
        }
        
        describe("when providing my followers") {
            
            beforeEach {
                sut.mockType = .mockFollower
            }
            
            context("and token doesn't exist") {
                
                var error: Error?
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                afterEach {
                    error = nil
                }
                
                it("error should appear") {
                    sut.provideMyFollowers().then { _ -> Void in
                        fail()
                    }.catch { _error in
                        error = _error
                    }
                    
                    expect(error is VerifiableError).toEventually(beTruthy())
                    expect(error is VerifiableError).toEventually(beTruthy())
                }
            }
            
            context("and token does exist") {
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                }
                
                it("buckets should be properly returned") {
                    sut.provideMyFollowers().then { _followeers -> Void in
                        followers = _followeers
                    }.catch { _ in fail() }
                    
                    expect(followers).toNotEventually(beNil())
                    expect(followers).toEventually(haveCount(3))
                }
            }
        }
        
        describe("when providing followees") {
            
            beforeEach {
                sut.mockType = .mockFollowee
            }
            
            it("for user, followees should be properly returned") {
                sut.provideFolloweesForUser(User.fixtureUser()).then { _followees -> Void in
                    followees = _followees
                }.catch { _ in fail() }
                
                expect(followees).toNotEventually(beNil())
                expect(followees).toEventually(haveCount(3))
            }
            
            it("for users, followees should be properly returned") {
                sut.provideFolloweesForUsers([User.fixtureUser(), User.fixtureUser()]).then { _followees -> Void in
                    followees = _followees
                    }.catch { _ in fail() }
                
                expect(followees).toNotEventually(beNil())
                expect(followees).toEventually(haveCount(3))
            }
        }
        
        describe("when providing followers") {
            
            beforeEach {
                sut.mockType = .mockFollower
            }
            
            it("for user, followers should be properly returned") {
                sut.provideFollowersForUser(User.fixtureUser()).then { _followers -> Void in
                    followers = _followers
                    }.catch { _ in fail() }
                
                expect(followers).toNotEventually(beNil())
                expect(followers).toEventually(haveCount(3))
            }
            
            it("for users, followers should be properly returned") {
                sut.provideFollowersForUsers([User.fixtureUser(), User.fixtureUser()]).then { _followers -> Void in
                    followers = _followers
                }.catch { _ in fail() }
                
                expect(followers).toNotEventually(beNil())
                expect(followers).toEventually(haveCount(3))
            }
        }
    }
}

//Explanation: Create ConnectionsProviderMock to override methods from PageableProvider.
private class APIConnectionsProviderMock: APIConnectionsProvider {
    
    var mockType: MockType!
    
    enum MockType {
        case mockFollowee, mockFollower
    }
    
    override func firstPageForQueries<T: Mappable>(_ queries: [Query], withSerializationKey key: String?) -> Promise<[T]?> {
        return mockResult(T.self)
    }
    
    override func nextPageFor<T: Mappable>(_ type: T.Type) -> Promise<[T]?> {
        return mockResult(T.self)
    }
    
    override func previousPageFor<T: Mappable>(_ type: T.Type) -> Promise<[T]?> {
        return mockResult(T.self)
    }
    
    func mockResult<T: Mappable>(_ type: T.Type) -> Promise<[T]?> {
        return Promise<[T]?> { fulfill, _ in
            
            if mockType == nil {
                fatalError("No mock type has been set up! Did you forget to do so?")
            }
            
            let json = mockType == .mockFollowee ?
                JSONSpecLoader.sharedInstance.fixtureFolloweeConnectionsJSON(withCount: 3) :
                JSONSpecLoader.sharedInstance.fixtureFollowerConnectionsJSON(withCount: 3)
            let result = json.map { T.map($0) }
            
            fulfill(result)
        }
    }
}

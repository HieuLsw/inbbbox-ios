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
        
        var sut: APIConnectionsProviderMock!
        
        beforeEach {
            sut = APIConnectionsProviderMock()
        }
        
        afterEach {
            sut = nil
        }
        
        describe("when providing my folowees") {
            
            beforeEach {
                sut.mockType = .mockFollowee
            }
            
            context("and token doesn't exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should appear") {
                    let promise = sut.provideMyFollowees()
                    expect(promise).to(resolveWithError(type: VerifiableError.self))
                }
            }
            
            context("and token does exist") {
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                }
                
                it("buckets should be properly returned") {
                    let promise = sut.provideMyFollowees()
                    
                    expect(promise).to(resolveWithValueMatching { followees in
                        expect(followees).toNot(beNil())
                        expect(followees).to(haveCount(3))
                    })
                }
            }
        }
        
        describe("when providing followees/followers from") {
            
            beforeEach {
                sut.mockType = .mockFollower
            }
            
            it("from next page, followers should be properly returned") {
                let promise = sut.nextPage()
                
                expect(promise).to(resolveWithValueMatching { followers in
                    expect(followers).toNot(beNil())
                    expect(followers).to(haveCount(3))
                })
            }
            
            it("from previous page, followers be properly returned") {
                let promise = sut.previousPage()
                
                expect(promise).to(resolveWithValueMatching { followers in
                    expect(followers).toNot(beNil())
                    expect(followers).to(haveCount(3))
                })
            }
        }
        
        describe("when providing my followers") {
            
            beforeEach {
                sut.mockType = .mockFollower
            }
            
            context("and token doesn't exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should appear") {
                    let promise = sut.provideMyFollowers()
                    expect(promise).to(resolveWithError(type: VerifiableError.self))
                }
            }
            
            context("and token does exist") {
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                }
                
                it("followers should be properly returned") {
                    let promise = sut.provideMyFollowers()
                    
                    expect(promise).to(resolveWithValueMatching { followers in
                        expect(followers).toNot(beNil())
                        expect(followers).to(haveCount(3))
                    })
                }
            }
        }
        
        describe("when providing followees") {
            
            beforeEach {
                sut.mockType = .mockFollowee
            }
            
            it("for user, followees should be properly returned") {
                let promise = sut.provideFolloweesForUser(User.fixtureUser())
                
                expect(promise).to(resolveWithValueMatching { followees in
                    expect(followees).toNot(beNil())
                    expect(followees).to(haveCount(3))
                })
            }
            
            it("for users, followees should be properly returned") {
                let promise = sut.provideFolloweesForUsers([User.fixtureUser(), User.fixtureUser()])
                
                expect(promise).to(resolveWithValueMatching { followees in
                    expect(followees).toNot(beNil())
                    expect(followees).to(haveCount(3))
                })
            }
        }
        
        describe("when providing followers") {
            
            beforeEach {
                sut.mockType = .mockFollower
            }
            
            it("for user, followers should be properly returned") {
                let promise = sut.provideFollowersForUser(User.fixtureUser())
                
                expect(promise).to(resolveWithValueMatching { followers in
                    expect(followers).notTo(beNil())
                    expect(followers).to(haveCount(3))
                })
            }
            
            it("for users, followers should be properly returned") {
                let promise = sut.provideFollowersForUsers([User.fixtureUser(), User.fixtureUser()])
                
                expect(promise).to(resolveWithValueMatching { followers in
                    expect(followers).notTo(beNil())
                    expect(followers).to(haveCount(3))
                })
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

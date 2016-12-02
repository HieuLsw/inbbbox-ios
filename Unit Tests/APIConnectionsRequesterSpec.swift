//
//  APIConnectionsRequesterSpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 16/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import PromiseKit
import Mockingjay

@testable import Inbbbox

class APIConnectionsRequesterSpec: QuickSpec {
    override func spec() {

        var sut: APIConnectionsRequester!
        
        beforeEach {
            sut = APIConnectionsRequester()
        }
        
        afterEach {
            sut = nil
            self.removeAllStubs()
        }
        
        describe("when following user") {
            
            var error: Error?
            var didInvokePromise: Bool?
            
            beforeEach {
                error = nil
                didInvokePromise = nil
            }
            
            context("and token does not exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should appear") {
                    sut.followUser(User.fixtureUser()).then {
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
                    self.stub(everything, json([], status: 204))
                }
                
                it("should follow user") {
                    sut.followUser(User.fixtureUser()).then {
                        didInvokePromise = true
                    }.catch { _ in fail() }
                    
                    expect(didInvokePromise).toEventually(beTruthy(), timeout: 3)
                }
            }
        }
        
        describe("when unfollowing user") {
            
            var error: Error?
            var didInvokePromise: Bool?
            
            beforeEach {
                error = nil
                didInvokePromise = nil
            }
            
            context("and token does not exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should appear") {
                    sut.unfollowUser(User.fixtureUser()).then {
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
                    self.stub(everything, json([], status: 204))
                }
                
                it("should unfollow user") {
                    sut.followUser(User.fixtureUser()).then {
                        didInvokePromise = true
                    }.catch { _ in fail() }
                    
                    expect(didInvokePromise).toEventually(beTruthy(), timeout: 3)
                }
            }
        }
        
        describe("when checking if current user follows an user") {
            
            var error: Error?
            var didInvokePromise: Bool?
            
            beforeEach {
                error = nil
                didInvokePromise = nil
            }
            
            context("and token does not exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should appear") {
                    sut.isUserFollowedByMe(User.fixtureUser()).then { _ in
                        fail("This should not be invoked")
                    }.catch { _error in
                        error = _error
                    }
                    
                    expect(error is VerifiableError).toEventually(beTruthy())
                }
            }
            
            context("and token does exist") {
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                    self.stub(everything, json([], status: 204))
                }
                
                it("should unfollow user") {
                    sut.isUserFollowedByMe(User.fixtureUser()).then { _ in
                        didInvokePromise = true
                    }.catch { _ in fail("This should not be invoked") }
                    
                    expect(didInvokePromise).toEventually(beTruthy(), timeout: 3)
                }
            }
        }
    }
}

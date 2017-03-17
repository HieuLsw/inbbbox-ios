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
            
            context("and token does not exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should appear") {
                    let promise = sut.followUser(User.fixtureUser())
                    
                    expect(promise).to(resolveWithErrorMatching { error in
                        expect(error).to(matchError(VerifiableError.authenticationRequired))
                    })
                }
            }
            
            context("and token does exist") {
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                    self.stub(everything, json([], status: 204))
                }
                
                it("should follow user") {
                    let promise = sut.followUser(User.fixtureUser())
                    
                    expect(promise).to(resolveWithSuccess())
                }
            }
        }
        
        describe("when unfollowing user") {
            
            context("and token does not exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should appear") {
                    let promise = sut.unfollowUser(User.fixtureUser())
                    
                    expect(promise).to(resolveWithErrorMatching { error in
                        expect(error).to(matchError(VerifiableError.authenticationRequired))
                    })
                }
            }
            
            context("and token does exist") {
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                    self.stub(everything, json([], status: 204))
                }
                
                it("should unfollow user") {
                    let promise = sut.followUser(User.fixtureUser())
                    
                    expect(promise).to(resolveWithSuccess())
                }
            }
        }
        
        describe("when checking if current user follows an user") {
            
            context("and token does not exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should appear") {
                    let promise = sut.isUserFollowedByMe(User.fixtureUser())
                    
                    expect(promise).to(resolveWithErrorMatching { error in
                        expect(error).to(matchError(VerifiableError.authenticationRequired))
                    })
                }
            }
            
            context("and token does exist") {
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                    self.stub(everything, json([], status: 204))
                }
                
                it("should unfollow user") {
                    let promise = sut.isUserFollowedByMe(User.fixtureUser())
                    
                    expect(promise).to(resolveWithSuccess())
                }
            }
        }
    }
}

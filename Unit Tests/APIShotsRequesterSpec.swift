//
//  APIShotsRequesterSpec.swift
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

class APIShotsRequesterSpec: QuickSpec {
    override func spec() {
        
        var sut: APIShotsRequester!
        var error: Error?
        var didInvokePromise: Bool?
        
        beforeEach {
            sut = APIShotsRequester()
        }
        
        afterEach {
            sut = nil
            error = nil
            didInvokePromise = nil
            self.removeAllStubs()
        }
        
        describe("when liking shot") {
            
            context("and token does not exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should appear") {
                    sut.likeShot(Shot.fixtureShot()).then { _ in
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
                    self.stub(everything, json([], status: 201))
                }
                
                it("should like shot") {
                    sut.likeShot(Shot.fixtureShot()).then { _ in
                        didInvokePromise = true
                    }.catch { _ in fail() }
                    
                    expect(didInvokePromise).toEventually(beTruthy(), timeout: 3)
                }
            }
        }
        
        describe("when unliking shot") {
            
            context("and token does not exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should appear") {
                    sut.unlikeShot(Shot.fixtureShot()).then { _ in
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
                
                it("should like shot") {
                    sut.unlikeShot(Shot.fixtureShot()).then { _ in
                        didInvokePromise = true
                    }.catch { _ in fail() }
                    
                    expect(didInvokePromise).toEventually(beTruthy(), timeout: 3)
                }
            }
        }
        
        describe("when checking if authenticated user like shot") {
            
            
            context("and token does not exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should appear") {
                    sut.isShotLikedByMe(Shot.fixtureShot()).then { _ in
                        fail()
                    }.catch { _error in
                        error = _error
                    }
                    
                    expect(error is VerifiableError).toEventually(beTruthy())
                }
            }
            
            context("and server respond with 200") {
                
                var isLikedByMe: Bool?
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                    self.stub(everything, json([], status: 200))
                }
                
                afterEach {
                    isLikedByMe = nil
                }
                
                it("shot should be liked by authenticated user") {
                    sut.isShotLikedByMe(Shot.fixtureShot()).then { _isLikedByMe in
                        isLikedByMe = _isLikedByMe
                    }.catch { _ in fail() }
                    
                    expect(isLikedByMe).toNotEventually(beNil())
                    expect(isLikedByMe).toEventually(beTruthy())
                }
            }
            
            context("and server respond with 404") {
                
                var isLikedByMe: Bool?
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                    let error = NSError(domain: "fixture.domain", code: 404, userInfo: nil)
                    self.stub(everything, failure(error))
                }
                
                afterEach {
                    isLikedByMe = nil
                }
                
                it("shot should not be liked by authenticated user") {
                    sut.isShotLikedByMe(Shot.fixtureShot()).then { _isLikedByMe in
                        isLikedByMe = _isLikedByMe
                    }.catch { _ in fail() }
                    
                    expect(isLikedByMe).toNotEventually(beNil())
                    expect(isLikedByMe).toEventually(beFalsy())
                }
            }
        }
        
        describe("when checking shot in user buckets") {
            
            context("should corectly return buckets") {
                var buckets: [BucketType]!
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                    self.stub(everything, json(self.fixtureJSON))
                    UserStorage.storeUser(User.fixtureUser())
                }
                
                it("should return 1 user bucket") {
                    sut.userBucketsForShot(Shot.fixtureShot()).then{ _buckets in
                        buckets = _buckets
                    }.catch { _ in fail() }
                    expect(buckets).toEventually(haveCount(1), timeout: 3)
                }
            }
        }
    }
}

private extension APIShotsRequesterSpec {
    
    var fixtureJSON: [AnyObject] {
        return JSONSpecLoader.sharedInstance.jsonWithResourceName("Buckets").arrayObject! as [AnyObject]
    }
}


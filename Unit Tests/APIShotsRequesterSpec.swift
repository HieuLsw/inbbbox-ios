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
        
        beforeEach {
            sut = APIShotsRequester()
        }
        
        afterEach {
            sut = nil
            self.removeAllStubs()
        }
        
        describe("when liking shot") {
            
            context("and token does not exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should appear") {
                    let promise: Promise<Void> = sut.likeShot(Shot.fixtureShot())
                    
                    expect(promise).to(resolveWithErrorMatching { error in
                        expect(error).to(matchError(VerifiableError.authenticationRequired))
                    })
                }
            }
            
            context("and token does exist") {
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                    self.stub(everything, json([], status: 201))
                }
                
                it("should like shot") {
                    let promise: Promise<Void> = sut.likeShot(Shot.fixtureShot())
                   
                    expect(promise).to(resolveWithSuccess())
                }
            }
        }
        
        describe("when unliking shot") {
            
            context("and token does not exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should appear") {
                    let promise = sut.unlikeShot(Shot.fixtureShot())
                    
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
                
                it("should like shot") {
                    let promise = sut.unlikeShot(Shot.fixtureShot())
                    
                    expect(promise).to(resolveWithSuccess())
                }
            }
        }
        
        describe("when checking if authenticated user like shot") {
            
            
            context("and token does not exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should appear") {
                    let promise = sut.isShotLikedByMe(Shot.fixtureShot())
                    
                    expect(promise).to(resolveWithErrorMatching { error in
                        expect(error).to(matchError(VerifiableError.authenticationRequired))
                    })
                }
            }
            
            context("and server respond with 200") {
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                    self.stub(everything, json([], status: 200))
                }
                
                it("shot should be liked by authenticated user") {
                    let promise = sut.isShotLikedByMe(Shot.fixtureShot())
                    
                    expect(promise).to(resolveWithValueMatching { (isLikedByMe: Bool) in
                        expect(isLikedByMe).toNot(beNil())
                        expect(isLikedByMe).to(beTruthy())
                    })
                }
            }
            
            context("and server respond with 404") {
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                    let error = NSError(domain: "fixture.domain", code: 404, userInfo: nil)
                    self.stub(everything, failure(error))
                }
                
                it("shot should not be liked by authenticated user") {
                    let promise = sut.isShotLikedByMe(Shot.fixtureShot())
                    
                    expect(promise).to(resolveWithValueMatching { (isLikedByMe: Bool) in
                        expect(isLikedByMe).toNot(beNil())
                        expect(isLikedByMe).to(beFalsy())
                    })
                }
            }
        }
        
        describe("when checking shot in user buckets") {
            
            context("should corectly return buckets") {
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                    self.stub(everything, json(self.fixtureJSON))
                    UserStorage.storeUser(User.fixtureUser())
                }
                
                it("should return 1 user bucket") {
                    let promise = sut.userBucketsForShot(Shot.fixtureShot())
                    
                    expect(promise).to(resolveWithValueMatching { buckets in
                        expect(buckets).to(haveCount(1))
                    })
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


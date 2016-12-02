//
//  VerifiableSpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 03/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

@testable import Inbbbox

class VerifiableSpec: QuickSpec {
    override func spec() {
        
        var sut: VerifiableMock!
        var savedTokenBeforeTestLaunch: String!
        var didInvokePromise: Bool!
        var error: Error?
        
        beforeSuite {
            savedTokenBeforeTestLaunch = TokenStorage.currentToken
        }
        
        afterSuite {
            if let token = savedTokenBeforeTestLaunch {
                TokenStorage.storeToken(token)
            }
        }
        
        beforeEach {
            sut = VerifiableMock()
        }
        
        afterEach {
            sut = nil
            didInvokePromise = false
            error = nil
        }
        
        describe("when token isn't stored") {
            
            beforeEach {
                TokenStorage.clear()
            }
            
            context("and authorization isn't needed") {
                
                it("authorization check should pass") {
                    
                    waitUntil { done in
                        sut.verifyAuthenticationStatus(false).then { _ -> Void in
                            didInvokePromise = true
                            done()
                        }.catch { _ in fail() }
                    }
                    
                    expect(didInvokePromise).to(beTruthy())
                    expect(error).to(beNil())
                }
            }
            
            context("and authorization is needed") {

                it("authorization check should throw error") {
                    
                    waitUntil { done in
                        sut.verifyAuthenticationStatus(true).then { _ -> Void in
                            fail()
                        }.catch { _error in
                            didInvokePromise = true
                            error = _error
                            done()
                        }
                    }
                    
                    expect(didInvokePromise).to(beTruthy())
                    expect(error is VerifiableError).to(beTruthy())
                }
            }
        }
        
        describe("when token exists") {
            
            beforeEach {
                TokenStorage.storeToken("fixture.token")
            }
            
            context("and authorization isn't needed") {
                
                it("authorization check should pass") {
                    
                    waitUntil { done in
                        sut.verifyAuthenticationStatus(false).then { _ -> Void in
                            didInvokePromise = true
                            done()
                        }.catch { _ in fail() }
                    }
                    
                    expect(didInvokePromise).to(beTruthy())
                    expect(error).to(beNil())
                }
            }
            
            context("and authorization is needed") {
                
                it("authorization check should throw error") {
                    
                    waitUntil { done in
                        sut.verifyAuthenticationStatus(true).then { _ -> Void in
                            didInvokePromise = true
                            done()
                        }.catch { _ in fail() }
                    }
                    
                    expect(didInvokePromise).to(beTruthy())
                    expect(error).to(beNil())
                }
            }
        }
        
        describe("when verifying account type") {
            
            beforeEach {
                UserStorage.clearUser()
            }
            
            context("and user does not exist") {
                
                it("error should occur") {
                    sut.verifyAccountType().then { _ in
                        fail()
                    }.catch { _error in
                        error = _error
                    }
                    
                    expect(error is VerifiableError).toEventually(beTruthy())
                }
            }
            
            context("and user has wrong account type") {
                
                beforeEach {
                    let user = User.fixtureUserForAccountType(.User)
                    UserStorage.storeUser(user)
                }
                
                it("error should occur") {
                    
                    sut.verifyAccountType().then { _ in
                        fail()
                    }.catch { _error in
                        error = _error
                    }
                    
                    expect(error is VerifiableError).toEventually(beTruthy())
                }
            }
            
            context("and user has correct account type") {
                
                beforeEach {
                    let user = User.fixtureUserForAccountType(.Player)
                    UserStorage.storeUser(user)
                }
                
                it("validation should pass") {
                    
                    sut.verifyAccountType().then { _ in
                        didInvokePromise = true
                    }.catch { _ in fail() }
                    
                    expect(didInvokePromise).toEventually(beTruthy())
                }
            }
        }
        
        describe("when verifying text length") {
            
            context("and text is longer than allowed") {
                
                it("should not pass validation") {
                    sut.verifyTextLength("foo", min: 0, max: 2).then { _ in
                        fail()
                    }.catch { _error in
                        error = _error
                    }
                    
                    expect(error is VerifiableError).toEventually(beTruthy())
                }
            }
            
            context("and text is shorter than allowed") {
                
                it("should not pass validation") {
                    sut.verifyTextLength("foobar", min: 0, max: 2).then { _ in
                        fail()
                    }.catch { _error in
                        error = _error
                    }
                    
                    expect(error is VerifiableError).toEventually(beTruthy())
                }
            }
            
            context("when min and max value are swapped") {
                
                it("should not pass validation") {
                    sut.verifyTextLength("foobar", min: 2, max: 0).then { _ in
                        fail()
                    }.catch { _error in
                        error = _error
                    }
                    
                    expect(error is VerifiableError).toEventually(beTruthy())
                }
            }
            
            context("when text contains whitespaces") {
                
                it("should pass validation") {
                    sut.verifyTextLength("   foo    ", min: 1, max: 3).catch { _error in
                        error = _error
                    }
                    
                    expect(error).toEventually(beNil())
                }
            }
            
            context("when text is correct") {
                
                it("should pass validation") {
                    sut.verifyTextLength("foo", min: 0, max: 10).catch { _error in
                        error = _error
                    }
                    
                    expect(error).toEventually(beNil())
                }
            }
        }
    }
}

private struct VerifiableMock: Verifiable {}

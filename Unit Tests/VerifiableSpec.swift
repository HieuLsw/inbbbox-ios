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
        
        describe("when token isn't stored") {
            
            beforeEach {
                TokenStorage.clear()
            }
            
            context("and authorization isn't needed") {
                
                it("authorization check should pass") {
                    let promise = sut.verifyAuthenticationStatus(false)
                    
                    expect(promise).to(resolveWithSuccess())
                }
            }
            
            context("and authorization is needed") {

                it("authorization check should throw error") {
                    let promise = sut.verifyAuthenticationStatus(true)
                    
                    expect(promise).to(resolveWithErrorMatching { error in
                        expect(error).to(matchError(VerifiableError.authenticationRequired))
                    })
                }
            }
        }
        
        describe("when token exists") {
            
            beforeEach {
                TokenStorage.storeToken("fixture.token")
            }
            
            context("and authorization isn't needed") {
                
                it("authorization check should pass") {
                    let promise = sut.verifyAuthenticationStatus(false)
                    
                    expect(promise).to(resolveWithSuccess())
                }
            }
            
            context("and authorization is needed") {
                
                it("authorization check should pass") {
                    let promise = sut.verifyAuthenticationStatus(true)
                    
                    expect(promise).to(resolveWithSuccess())
                }
            }
        }
        
        describe("when verifying account type") {
            
            beforeEach {
                UserStorage.clearUser()
            }
            
            context("and user does not exist") {
                
                it("error should occur") {
                    let promise = sut.verifyAccountType()
                    
                    expect(promise).to(resolveWithErrorMatching { error in
                        expect(error).to(matchError(VerifiableError.wrongAccountType))
                    })
                }
            }
            
            context("and user has wrong account type") {
                
                beforeEach {
                    let user = User.fixtureUserForAccountType(.User)
                    UserStorage.storeUser(user)
                }
                
                it("error should occur") {
                    let promise = sut.verifyAccountType()
                    
                    expect(promise).to(resolveWithErrorMatching { error in
                        expect(error).to(matchError(VerifiableError.wrongAccountType))
                    })
                }
            }
            
            context("and user has correct account type") {
                
                beforeEach {
                    let user = User.fixtureUserForAccountType(.Player)
                    UserStorage.storeUser(user)
                }
                
                it("validation should pass") {
                    let promise = sut.verifyAccountType()
                    
                    expect(promise).to(resolveWithSuccess())
                }
            }
        }
        
        describe("when verifying text length") {
            
            context("and text is longer than allowed") {
                
                it("should not pass validation") {
                    let promise = sut.verifyTextLength("foo", min: 0, max: 2)
                    
                    expect(promise).to(resolveWithErrorMatching { error in
                        expect(error).to(matchError(VerifiableError.incorrectTextLength(2)))
                    })
                }
            }
            
            context("and text is shorter than allowed") {
                
                it("should not pass validation") {
                    let promise = sut.verifyTextLength("foobar", min: 8, max: 10)
                    
                    expect(promise).to(resolveWithErrorMatching { error in
                        expect(error).to(matchError(VerifiableError.incorrectTextLength(8)))
                    })
                }
            }
            
            context("when min and max value are swapped") {
                
                it("should not pass validation") {
                    let promise = sut.verifyTextLength("foobar", min: 2, max: 0)
                    
                    expect(promise).to(resolveWithErrorMatching { error in
                        expect(error).to(matchError(VerifiableError.incorrectTextLength(2)))
                    })
                }
            }
            
            context("when text contains whitespaces") {
                
                it("should pass validation") {
                    let promise = sut.verifyTextLength("   foo    ", min: 1, max: 3)
                    
                    expect(promise).to(resolveWithSuccess())
                }
            }
            
            context("when text is correct") {
                
                it("should pass validation") {
                    let promise = sut.verifyTextLength("foo", min: 1, max: 3)
                    
                    expect(promise).to(resolveWithSuccess())
                }
            }
        }
    }
}

private struct VerifiableMock: Verifiable {}

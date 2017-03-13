//
//  APICommentsRequesterSpec.swift
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

class APICommentsRequesterSpec: QuickSpec {
    override func spec() {
        
        var sut: APICommentsRequester!
        
        beforeEach {
            sut = APICommentsRequester()
        }
        
        afterEach {
            sut = nil
        }
        
        describe("when posting comment") {
            
            afterEach {
                TokenStorage.clear()
                UserStorage.clearUser()
            }
            
            context("when token does not exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should occur") {
                    let promise = sut.postCommentForShot(Shot.fixtureShot(), withText: "fixture.text")
                    expect(promise).to(resolveWithError(type: VerifiableError.self))
                }
            }
            
            context("when token exists, but account type is wrong") {
                
                beforeEach {
                    UserStorage.storeUser(User.fixtureUserForAccountType(.User))
                    TokenStorage.storeToken("fixture.token")
                }
                
                it("error should occur") {
                    let promise = sut.postCommentForShot(Shot.fixtureShot(), withText: "fixture.text")
                    expect(promise).to(resolveWithError(type: VerifiableError.self))
                }
            }
            
            context("when token exists and account type is correct") {
                
                beforeEach {
                    UserStorage.storeUser(User.fixtureUserForAccountType(.Player))
                    TokenStorage.storeToken("fixture.token")
                    self.stub(everything, json(self.fixtureJSON))
                }
                
                afterEach {
                    self.removeAllStubs()
                }
                
                it("comment should be posted") {
                    let promise = sut.postCommentForShot(Shot.fixtureShot(), withText: "fixture.text")
                    
                    expect(promise).to(resolveWithValueMatching { (comment: CommentType) in
                        expect(comment).toNot(beNil())
                    })
                }
            }
        }
        
        describe("when updating comment") {
            
            afterEach {
                TokenStorage.clear()
                UserStorage.clearUser()
            }
            
            context("when token does not exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should occur") {
                    let promise = sut.updateComment(Comment.fixtureComment(), forShot: Shot.fixtureShot(), withText: "fixture.text")
                    expect(promise).to(resolveWithError(type: VerifiableError.self))
                }
            }
            
            context("when token exists, but account type is wrong") {
                
                beforeEach {
                    UserStorage.storeUser(User.fixtureUserForAccountType(.User))
                    TokenStorage.storeToken("fixture.token")
                }
                
                it("error should occur") {
                    let promise = sut.updateComment(Comment.fixtureComment(), forShot: Shot.fixtureShot(), withText: "fixture.text")
                    expect(promise).to(resolveWithError(type: VerifiableError.self))
                }
            }
            
            context("when token exists and account type is correct") {
                
                beforeEach {
                    UserStorage.storeUser(User.fixtureUserForAccountType(.Player))
                    TokenStorage.storeToken("fixture.token")
                    self.stub(everything, json(self.fixtureJSON))
                }
                
                afterEach {
                    self.removeAllStubs()
                }
                
                it("comment should be posted") {
                    let promise = sut.updateComment(Comment.fixtureComment(), forShot: Shot.fixtureShot(), withText: "fixture.text")
                    
                    expect(promise).to(resolveWithValueMatching { (comment: CommentType) in
                        expect(comment).toNot(beNil())
                    })
                }
            }
        }
        
        describe("when deleting comment") {
            
            afterEach {
                TokenStorage.clear()
                UserStorage.clearUser()
            }
            
            context("when token does not exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should occur") {
                    let promise = sut.deleteComment(Comment.fixtureComment(), forShot: Shot.fixtureShot())
                    expect(promise).to(resolveWithError(type: VerifiableError.self))
                }
            }
            
            context("when token exists, but account type is wrong") {
                
                beforeEach {
                    UserStorage.storeUser(User.fixtureUserForAccountType(.User))
                    TokenStorage.storeToken("fixture.token")
                }
                
                it("error should occur") {
                    let promise = sut.deleteComment(Comment.fixtureComment(), forShot: Shot.fixtureShot())
                    expect(promise).to(resolveWithError(type: VerifiableError.self))
                }
            }
            
            context("when token exists and account type is correct") {
                
                beforeEach {
                    UserStorage.storeUser(User.fixtureUserForAccountType(.Player))
                    TokenStorage.storeToken("fixture.token")
                    self.stub(everything, json(self.fixtureJSON))
                }
                
                afterEach {
                    self.removeAllStubs()
                }
                
                it("comment should be posted") {
                    let promise = sut.deleteComment(Comment.fixtureComment(), forShot: Shot.fixtureShot())
                    expect(promise).to(resolveWithSuccess())
                }
            }
        }
        
        describe("when liking comment") {
            
            afterEach {
                TokenStorage.clear()
                UserStorage.clearUser()
            }
            
            context("when token does not exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should occur") {
                    let promise = sut.likeComment(Comment.fixtureComment(), forShot: Shot.fixtureShot())
                    expect(promise).to(resolveWithError(type: VerifiableError.self))
                }
            }
            
            context("when token exists") {
                
                beforeEach {
                    UserStorage.storeUser(User.fixtureUserForAccountType(.User))
                    TokenStorage.storeToken("fixture.token")
                    self.stub(everything, json(self.fixtureJSON))
                }
                
                afterEach {
                    self.removeAllStubs()
                }
                
                it("comment should be marked as liked") {
                    let promise = sut.likeComment(Comment.fixtureComment(), forShot: Shot.fixtureShot())
                    expect(promise).to(resolveWithSuccess())
                }
            }
        }
        
        describe("when unliking comment") {
            
            afterEach {
                TokenStorage.clear()
                UserStorage.clearUser()
            }
            
            context("when token does not exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should occur") {
                    let promise = sut.unlikeComment(Comment.fixtureComment(), forShot: Shot.fixtureShot())
                    expect(promise).to(resolveWithError(type: VerifiableError.self))
                }
            }
            
            context("when token exists") {
                
                beforeEach {
                    UserStorage.storeUser(User.fixtureUserForAccountType(.User))
                    TokenStorage.storeToken("fixture.token")
                    self.stub(everything, json(self.fixtureJSON))
                }
                
                afterEach {
                    self.removeAllStubs()
                }
                
                it("comment should be marked as unliked") {
                    let promise = sut.unlikeComment(Comment.fixtureComment(), forShot: Shot.fixtureShot())
                    expect(promise).to(resolveWithSuccess())
                }
            }
        }
        
        describe("when checking if user did like a comment") {

            afterEach {
                TokenStorage.clear()
                UserStorage.clearUser()
            }
            
            context("when token does not exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should occur") {
                    let promise = sut.checkIfLikeComment(Comment.fixtureComment(), forShot: Shot.fixtureShot())
                    expect(promise).to(resolveWithError(type: VerifiableError.self))
                }
            }
            
            context("when token exists") {
                
                beforeEach {
                    UserStorage.storeUser(User.fixtureUserForAccountType(.User))
                    TokenStorage.storeToken("fixture.token")
                    self.stub(everything, json(self.fixtureJSON))
                }
                
                afterEach {
                    self.removeAllStubs()
                }
                
                it("comment should be checked for like") {
                    let promise = sut.checkIfLikeComment(Comment.fixtureComment(), forShot: Shot.fixtureShot())
                    expect(promise).to(resolveWithSuccess())
                }
            }
        }
    }
}

private extension APICommentsRequesterSpec {
    
    var fixtureJSON: [String: AnyObject] {
        return JSONSpecLoader.sharedInstance.jsonWithResourceName("Comment").dictionaryObject! as [String : AnyObject]
    }
}

//
//  ShotDetailsViewModelSpec.swift
//  Inbbbox
//
//  Created by Peter Bruz on 22/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import PromiseKit
import Dobby

@testable import Inbbbox

class ShotDetailsViewModelSpec: QuickSpec {
    
    override func spec() {
        
        var sut: ShotDetailsViewModel!
        
        beforeEach {
            let shot = Shot.fixtureShot()
            let commentsProviderMock = APICommentsProviderMock()
            let commentsRequesterMock = APICommentsRequesterMock()
            
            commentsProviderMock.provideCommentsForShotStub.on(any()) { _ in
                return Promise{ fulfill, _ in
                    
                    let json = JSONSpecLoader.sharedInstance.fixtureCommentsJSON(withCount: 10)
                    let result = json.map { Comment.map($0) }
                    var resultCommentTypes = [CommentType]()
                    for comment in result {
                        resultCommentTypes.append(comment)
                    }
                    
                    fulfill(resultCommentTypes)
                }
            }
            
            commentsProviderMock.nextPageStub.on(any()) { _ in
                return Promise{ fulfill, _ in
                    
                    let json = JSONSpecLoader.sharedInstance.fixtureCommentsJSON(withCount: 5)
                    let result = json.map { Comment.map($0) }
                    var resultCommentTypes = [CommentType]()
                    for comment in result {
                        resultCommentTypes.append(comment)
                    }
                    
                    fulfill(resultCommentTypes)
                }
            }
            
            commentsRequesterMock.postCommentForShotStub.on(any()) { _, _ in
                return Promise{ fulfill, _ in
                    let result = Comment.fixtureComment()
                    fulfill(result)
                }
            }
            
            commentsRequesterMock.deleteCommentStub.on(any()) { _, _ in
                return Promise<Void>(value: Void())
            }
            
            sut = ShotDetailsViewModel(shot: shot, isLiked: nil)
            sut.commentsProvider = commentsProviderMock
            sut.commentsRequester = commentsRequesterMock
        }
        
        afterEach {
            sut = nil
        }
        
        describe("when newly initialized") {
            
            it("view model should have correct number of items") {
                expect(sut.itemsCount).to(equal(2))
            }
            
            it("view model should have correct number of items") {
                expect(sut.itemsCount).to(equal(2))
            }
        }
        
        describe("when comments are loaded for the first time") {
            
            it("view model should have correct number of items") {
                let promise = sut.loadComments()
                
                // 10 comments + operationCell + descriptionCell + loadMoreCell
                expect(promise).to(resolveWithValueMatching { _ in
                    expect(sut.itemsCount).to(equal(13))
                })
            }
        }
        
        describe("when comments are loaded with pagination") {
            
            it("view model should have correct number of items") {
                let promise = sut.loadComments().then { sut.loadComments() }
                
                // 10 comments + 5 comments (nextPage) + operationCell + descriptionCell + loadMoreCell
                expect(promise).to(resolveWithValueMatching { _ in
                    expect(sut.itemsCount).to(equal(18))
                })
            }
        }
        
        describe("when posting comment") {
            
            it("should be correctly added") {
                let promise = sut.postComment("fixture.message")
                
                expect(promise).to(resolveWithSuccess())
            }
        }
    }
}

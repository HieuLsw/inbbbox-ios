//
//  CommentUnlikeQuerySpec.swift
//  Inbbbox
//
//  Created by Robert Abramczyk on 05/10/2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import Inbbbox

class CommentUnlikeQuerySpec: QuickSpec {
    override func spec() {
        
        SharedQuerySpec.performSpecForQuery( { Void -> Query in
            return CommentUnlikeQuery(shot: Shot.fixtureShot(), comment: Comment.fixtureComment())
        }) { Void -> QueryExpectation in
            return (method: .DELETE, encoding: .url, path: "/shots/fixture.identifier/comments/fixture.identifier/like")
        }
        
        describe("when newly initialized with shot and comment identifiers") {
            
            var sut: CommentUnlikeQuery!
            
            beforeEach {
                sut = CommentUnlikeQuery(shot: Shot.fixtureShot(), comment: Comment.fixtureComment())
            }
            
            afterEach {
                sut = nil
            }
            
            it("should have empty parameters") {
                expect(sut.parameters.queryItems).to(beEmpty())
            }
        }
    }
}

//
//  DeleteCommentQuerySpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 11/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import Inbbbox

class DeleteCommentQuerySpec: QuickSpec {
    override func spec() {
        
        SharedQuerySpec.performSpecForQuery( { Void -> Query in
            return DeleteCommentQuery(shot: Shot.fixtureShot(), comment:  Comment.fixtureComment())
        }) { Void -> QueryExpectation in
            return (method: .DELETE, encoding: .url, path: "/shots/fixture.identifier/comments/fixture.identifier")
        }
        
        describe("when newly initialized with comment") {
            
            var sut: DeleteCommentQuery!
            
            beforeEach {
                sut = DeleteCommentQuery(shot: Shot.fixtureShot(), comment:  Comment.fixtureComment())
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

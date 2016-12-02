//
//  CreateCommentQuerySpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 10/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import Inbbbox

class CreateCommentQuerySpec: QuickSpec {
    override func spec() {
        
        SharedQuerySpec.performSpecForQuery( { Void -> Query in
            return CreateCommentQuery(shot: Shot.fixtureShot(), body: "fixture.body")
        }) { Void -> QueryExpectation in
            return (method: .POST, encoding: .json, path: "/shots/fixture.identifier/comments")
        }
        
        describe("when newly initialized with comment") {
            
            var sut: CreateCommentQuery!
            
            beforeEach {
                sut = CreateCommentQuery(shot: Shot.fixtureShot(), body: "fixture.body")
            }
            
            afterEach {
                sut = nil
            }
            
            it("should have empty parameters") {
                expect(sut.parameters.queryItems).to(beEmpty())
            }
            
            it("should have body parameter properly set") {
                expect(sut.parameters["body"] as? String).to(equal("fixture.body"))
            }
        }
    }
}

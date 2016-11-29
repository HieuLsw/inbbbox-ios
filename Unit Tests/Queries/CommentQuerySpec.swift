//
//  CommentQuerySpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 10/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import Inbbbox

class CommentQuerySpec: QuickSpec {
    override func spec() {
        
        SharedQuerySpec.performSpecForQuery( { Void -> Query in
            return CommentQuery(shot: Shot.fixtureShot())
        }) { Void -> QueryExpectation in
            return (method: .GET, encoding: .url, path: "/shots/fixture.identifier/comments")
        }
        
        describe("when newly initialized with comment") {
            
            var sut: CommentQuery!
            
            beforeEach {
                sut = CommentQuery(shot: Shot.fixtureShot())
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

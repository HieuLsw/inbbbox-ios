//
//  LikeQuerySpec.swift
//  Inbbbox
//
//  Created by Radoslaw Szeja on 17/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

@testable import Inbbbox

class LikeQuerySpec: QuickSpec {
    override func spec() {
        
        SharedQuerySpec.performSpecForQuery( { Void -> Query in
            return LikeQuery(shot: Shot.fixtureShot())
        }) { Void -> QueryExpectation in
            return (method: .POST, encoding: .json, path: "/shots/fixture.identifier/like")
        }
        
        describe("when newly initialized with shot identifier") {
            
            var sut: LikeQuery!
            
            beforeEach {
                sut = LikeQuery(shot: Shot.fixtureShot())
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

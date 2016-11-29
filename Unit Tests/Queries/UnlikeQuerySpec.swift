//
//  UnlikeQuerySpec.swift
//  Inbbbox
//
//  Created by Radoslaw Szeja on 17/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

@testable import Inbbbox

class UnlikeQuerySpec: QuickSpec {
    override func spec() {
        
        SharedQuerySpec.performSpecForQuery( { Void -> Query in
            return UnlikeQuery(shot: Shot.fixtureShot())
        }) { Void -> QueryExpectation in
            return (method: .DELETE, encoding: .json, path: "/shots/fixture.identifier/like")
        }
        
        describe("when newly initialized with shot") {
            
            var sut: UnlikeQuery!
            
            beforeEach {
                sut = UnlikeQuery(shot: Shot.fixtureShot())
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

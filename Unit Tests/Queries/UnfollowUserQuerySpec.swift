//
//  UnfollowUserQuerySpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 16/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import Inbbbox

class UnfollowUserQuerySpec: QuickSpec {
    override func spec() {
        
        SharedQuerySpec.performSpecForQuery( { Void -> Query in
            return UnfollowUserQuery(user: User.fixtureUser())
        }) { Void -> QueryExpectation in
            return (method: .DELETE, encoding: .url, path: "/users/fixture.identifier/follow")
        }
        
        describe("when newly initialized with user") {
            
            var sut: UnfollowUserQuery!
            
            beforeEach {
                sut = UnfollowUserQuery(user: User.fixtureUser())
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

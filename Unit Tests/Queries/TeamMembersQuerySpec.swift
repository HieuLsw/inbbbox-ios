//
//  TeamMembersQuerySpec.swift
//  Inbbbox
//
//  Created by Peter Bruz on 10/03/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import Inbbbox

class TeamMembersQuerySpec: QuickSpec {
    override func spec() {
        
        SharedQuerySpec.performSpecForQuery( { Void -> Query in
            return TeamMembersQuery(team: Team.fixtureTeam())
        }) { Void -> QueryExpectation in
            return (method: .GET, encoding: .url, path: "/teams/fixture.identifier/members")
        }
        
        describe("when newly initialized with team") {
            
            var sut: TeamMembersQuery!
            
            beforeEach {
                sut = TeamMembersQuery(team: Team.fixtureTeam())
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

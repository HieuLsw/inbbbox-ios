//
//  ProjectsQuerySpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 15/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import Inbbbox

class ProjectsQuerySpec: QuickSpec {
    override func spec() {
        
        SharedQuerySpec.performSpecForQuery( { Void -> Query in
            return ProjectsQuery(shot: Shot.fixtureShot())
        }) { Void -> QueryExpectation in
            return (method: .GET, encoding: .url, path: "/shots/fixture.identifier/projects")
        }
        
        describe("when newly initialized with project") {
            
            var sut: ProjectsQuery!
            
            beforeEach {
                sut = ProjectsQuery(shot: Shot.fixtureShot())
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

//
//  QuerySpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 15/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Nimble
import Quick

@testable import Inbbbox

class QuerySpec: QuickSpec {
    override func spec() {
        
        SharedQuerySpec.performSpecForQuery( { Void -> Query in
            return QueryMock()
        }) { Void -> QueryExpectation in
            return (method: .POST, encoding: .json, path: "/fixture/path")
        }
        
        it("request-response protocols should be properly named") {
            expect(Method.POST.rawValue).to(equal("POST"))
            expect(Method.GET.rawValue).to(equal("GET"))
            expect(Method.PUT.rawValue).to(equal("PUT"))
            expect(Method.DELETE.rawValue).to(equal("DELETE"))
        }
    }
}

private struct QueryMock: Query {
    let method = Method.POST
    let path = "/fixture/path"
    var parameters = Parameters(encoding: .json)
}

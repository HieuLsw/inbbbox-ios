//
//  SharedQuerySpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 15/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Nimble
import Quick

@testable import Inbbbox

typealias QueryExpectation = (method: Inbbbox.Method, encoding: Parameters.Encoding, path: String)

class SharedQuerySpec {
    
    class func performSpecForQuery(_ query: @escaping (Void) -> Query, expectations: @escaping (Void) -> QueryExpectation) {
        
        var sut: Query!
        var expected: QueryExpectation!
        
        beforeEach {
            sut = query()
            expected = expectations()
        }
        
        afterEach {
            expected = nil
            sut = nil
        }
        
        it("should have parameters with proper encoding") {
            expect(sut.parameters.encoding).to(equal(expected.encoding))
        }
        
        it("should have proper method") {
            expect(sut.method.rawValue).to(equal(expected.method.rawValue))
        }
        
        it("should have proper path") {
            expect(sut.path).to(equal(expected.path))
        }
        
        it("should have dribbble service") {
            expect(sut.service is DribbbleNetworkService).to(beTrue())
        }
    }
    
}

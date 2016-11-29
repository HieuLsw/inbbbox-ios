//
//  RequestableSpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 03/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

@testable import Inbbbox

class RequestableSpec: QuickSpec {
    override func spec() {
        
        var sut: RequestableMock!
        
        describe("when initializaing request to be used as POST") {
            
            beforeEach {
                sut = RequestableMock(encoding: .json)
            }
            
            afterEach {
                sut = nil
            }
            
            it("request should have properly set http header") {
                let HTTPHeaderFields = [
                    "Content-Type" : "application/json",
                    "fixture.http.header.field" : "fixture.header"
                ]
                expect(sut.foundationRequest.allHTTPHeaderFields).to(equal(HTTPHeaderFields))
            }
            
            it("request should have url") {
                expect(sut.foundationRequest.url).toNot(beNil())
            }
            
            it("request should have proper url") {
                let expectedURL = URL(string: "https://fixture.host/v1/query.fixture/path")
                expect(sut.foundationRequest.url).to(equal(expectedURL))
            }
            
            it("request body should be properly set") {
                let expectedData = try! JSONSerialization.data(withJSONObject: ["fixture.key" : "fixture.value"], options: .prettyPrinted)
                expect(sut.foundationRequest.httpBody).to(equal(expectedData))
            }
        }
        
        describe("when initializaing request to be used as GET") {
            
            beforeEach {
                sut = RequestableMock(encoding: .url)
            }
            
            afterEach {
                sut = nil
            }
            
            it("request should have properly set http header") {
                let HTTPHeaderFields = [
                    "fixture.http.header.field" : "fixture.header"
                ]
                expect(sut.foundationRequest.allHTTPHeaderFields).to(equal(HTTPHeaderFields))
            }
            
            it("request should have url") {
                expect(sut.foundationRequest.url).toNot(beNil())
            }
            
            it("request should have proper url") {
                let expectedURL = URL(string: "https://fixture.host/v1/query.fixture/path?fixture.key=fixture.value")
                expect(sut.foundationRequest.url).to(equal(expectedURL))
            }
            
            it("request body should be nil") {
                expect(sut.foundationRequest.httpBody).to(beNil())
            }
        }
    }
}

private struct RequestableMock: Requestable {
    
    let query: Query = QueryMock()
    
    init(encoding: Parameters.Encoding) {
        query.parameters = Parameters(encoding: encoding)
        query.parameters["fixture.key"] = "fixture.value" as AnyObject?
    }
}

private struct QueryMock: Query {
    
    let path = "/query.fixture/path"
    var parameters = Parameters(encoding: .json)
    let method = Method.POST
    
    var service: SecureNetworkService {
        return ServiceMock()
    }
}

private struct ServiceMock: SecureNetworkService {
    
    let scheme = "https"
    let host = "fixture.host"
    let version = "/v1"
    
    func authorizeRequest(_ request: NSMutableURLRequest) {
        request.setValue("fixture.header", forHTTPHeaderField: "fixture.http.header.field")
    }
}

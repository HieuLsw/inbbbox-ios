//
//  ResponsableSpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 03/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import SwiftyJSON

@testable import Inbbbox

class ResponsableSpec: QuickSpec {
    override func spec() {
    
        var sut: ResponsableMock!
        
        beforeEach {
            sut = ResponsableMock()
        }
        
        afterEach {
            sut = nil
        }
        
        describe("when respond with data") {
            
            var response: Response?
            var error: ErrorType?
            
            beforeEach {
                let data = try! NSJSONSerialization.dataWithJSONObject(["fixture.key" : "fixture.value"], options: .PrettyPrinted)
                sut.responseWithData(data, response: self.mockResponse(200)).then { _response in
                    response = _response
                }.error { _ in fail() }
            }
            
            afterEach {
                response = nil
                error = nil
            }
            
            it("response should not be nil") {
                expect(response).toNotEventually(beNil())
            }
            
            it("response should have json") {
                expect(response?.json).toNotEventually(beNil())
            }
            
            it("response should have header") {
                expect(response?.header).toNotEventually(beNil())
            }
            
            it("response should have proper json") {
                expect(response?.json?.dictionaryObject as? [String: String]).toEventually(equal(["fixture.key" : "fixture.value"]))
            }
            
            it("response should have proper header") {
                expect(response?.header as? [String: String]).toEventually(equal(["fixture.header" : "fixture.http.header.field"]))
            }
            
            it("error should be nil") {
                expect(error).toEventually(beNil())
            }
        }
        
        describe("when respond with server error") {
            
            var response: Response?
            var error: ErrorType?
            
            beforeEach {
                sut.responseWithData(nil, response: self.mockResponse(422)).then { _ -> Void in
                    fail()
                }.error { _error in
                    error = _error
                }
            }
            
            afterEach {
                response = nil
                error = nil
            }
            
            it("response should be nil") {
                expect(response).toEventually(beNil())
            }
            
            it("error should not be nil") {
                expect(error).toNotEventually(beNil())
            }
            
            it("error should have corect localized message") {
                expect((error as! NSError).domain).toEventually(equal(networkErrorDomain))
            }
        }
        
        describe("when respond with dictionary of errors") {
            
            var response: Response?
            var error: ErrorType?
            
            beforeEach {
                let json = ["errors" : [["message" : "fixture.message"]]]
                let data = try! NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
                sut.responseWithData(data, response: self.mockResponse(422)).then { _ -> Void in
                    fail()
                }.error { _error in
                    error = _error
                }
            }
            
            afterEach {
                response = nil
                error = nil
            }
            
            it("response should be nil") {
                expect(response).toEventually(beNil())
            }
            
            it("response should not have json") {
                expect(response?.json).toEventually(beNil())
            }
            
            it("error should not be nil") {
                expect(error).toNotEventually(beNil())
            }
            
            it("error should have corect localized message") {
                expect((error as! NSError).localizedDescription).toEventually(equal("fixture.message"))
            }
        }
    }
}

private struct ResponsableMock: Responsable {}

private extension ResponsableSpec {
    
    func mockResponse(statusCode: Int) -> NSURLResponse {
        let url = NSURL(string: "http://fixture.host.co")!
        let headerFields = ["fixture.header": "fixture.http.header.field"]
        return NSHTTPURLResponse(URL: url, statusCode: statusCode, HTTPVersion: nil, headerFields: headerFields)!
    }
}

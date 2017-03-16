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
            
            it("should have correct response") {
                let data = try! JSONSerialization.data(withJSONObject: ["fixture.key" : "fixture.value"], options: .prettyPrinted)
                let promise = sut.responseWithData(data, response: self.mockResponse(200))
                
                expect(promise).to(resolveWithValueMatching { response in
                    let body = response.json?.dictionaryObject as? [String: String]
                    let header = response.header as? [String: String]
                    
                    expect(body).to(equal(["fixture.key" : "fixture.value"]))
                    expect(header).to(equal(["fixture.header" : "fixture.http.header.field"]))
                })
            }
        }
        
        describe("when respond with server error") {
            
            it("should raise proper error") {
                let promise = sut.responseWithData(nil, response: self.mockResponse(422))
                
                expect(promise).to(resolveWithErrorMatching { error in
                    let nsError = error as NSError
                    expect(nsError.domain).to(equal(networkErrorDomain))
                })
            }
        }
        
        describe("when respond with dictionary of errors") {
            
            it("should raise error with proper description") {
                let json = ["errors" : [["message" : "fixture.message"]]]
                let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                
                let promise = sut.responseWithData(data, response: self.mockResponse(422))
                
                expect(promise).to(resolveWithErrorMatching { error in
                    let nsError = error as NSError
                    expect(nsError.localizedDescription).to(equal("fixture.message"))
                })
            }
        }
    }
}

private struct ResponsableMock: Responsable {}

private extension ResponsableSpec {
    
    func mockResponse(_ statusCode: Int) -> URLResponse {
        let url = URL(string: "http://fixture.host.co")!
        let headerFields = ["fixture.header": "fixture.http.header.field"]
        return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: headerFields)!
    }
}

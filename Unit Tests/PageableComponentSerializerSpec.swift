//
//  PageableComponentSerializerSpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 04/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import Mockingjay

@testable import Inbbbox

class PageableComponentSerializerSpec: QuickSpec {
    override func spec() {
        
        var component: PageableComponent!
        
        afterEach {
            component = nil
        }
        
        describe("when serializing next component") {
            
            context("with proper header") {
                
                beforeEach {
                    let header = self.linkHeaderForTypes([.relNext])
                    component = PageableComponentSerializer.nextPageableComponentWithSentQuery(QueryMock(), receivedHeader: header)
                }
                
                it("serialized component should not be nil") {
                    expect(component).toNot(beNil())
                }
                
                it("serialized component should have correct path") {
                    expect(component.path).to(equal("/fixture.path.next"))
                }
                
                it("serialized component should have query items") {
                    expect(component.queryItems).toNot(beNil())
                }
                
                it("serialized component should have 2 query items") {
                    expect(component.queryItems).to(haveCount(2))
                }
                
                it("first query item of serialized component should have proper value") {
                    expect(component.queryItems!.first!.value).to(equal("3"))
                }
                
                it("first query item of serialized component should have proper name") {
                    expect(component.queryItems!.first!.name).to(equal("page"))
                }
                
                it("second query item of serialized component should have proper value") {
                    expect(component.queryItems![1].value).to(equal("100"))
                }
                
                it("second query item of serialized component should have proper name") {
                    expect(component.queryItems![1].name).to(equal("per_page"))
                }
            }
            
            context("with invalid header") {
                
                beforeEach {
                    let header = ["fixture.header.key": "fixture.header.value"]
                    component = PageableComponentSerializer.nextPageableComponentWithSentQuery(QueryMock(), receivedHeader: header as [String : AnyObject])
                }
                
                it("serialized component should not be nil") {
                    expect(component).to(beNil())
                }
            }
        }
        
        describe("when serializing previous component") {
            
            context("with proper header") {
                
                beforeEach {
                    let header = self.linkHeaderForTypes([.relPrev])
                    component = PageableComponentSerializer.previousPageableComponentWithSentQuery(QueryMock(), receivedHeader: header)
                }
                
                it("serialized component should not be nil") {
                    expect(component).toNot(beNil())
                }
                
                it("serialized component should have correct path") {
                    expect(component.path).to(equal("/fixture.path.prev"))
                }
                
                it("serialized component should have query items") {
                    expect(component.queryItems).toNot(beNil())
                }
                
                it("serialized component should have 2 query items") {
                    expect(component.queryItems).to(haveCount(2))
                }
                
                it("first query item of serialized component should have proper value") {
                    expect(component.queryItems!.first!.value).to(equal("1"))
                }
                
                it("first query item of serialized component should have proper name") {
                    expect(component.queryItems!.first!.name).to(equal("page"))
                }
                
                it("second query item of serialized component should have proper value") {
                    expect(component.queryItems![1].value).to(equal("200"))
                }
                
                it("second query item of serialized component should have proper name") {
                    expect(component.queryItems![1].name).to(equal("per_page"))
                }
                
            }
            
            context("with invalid header") {
                
                beforeEach {
                    let header = ["fixture.header.key": "fixture.header.value"]
                    component = PageableComponentSerializer.previousPageableComponentWithSentQuery(QueryMock(), receivedHeader: header as [String : AnyObject])
                }
                
                it("serialized component should not be nil") {
                    expect(component).to(beNil())
                }
            }
        }
    }
}

private struct QueryMock: Query {
    let path = "/fixture/path"
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


private enum LinkHeaderType {
    case relNext, relPrev
    
    var description: String {
        switch self {
            case .relNext:
                return "<https://fixture.host/v1/fixture.path.next?page=3&per_page=100>; rel=\"next\""
            case .relPrev:
                return "<https://fixture.host/v1/fixture.path.prev?page=1&per_page=200>; rel=\"prev\""
        }
    }
}

private extension PageableComponentSerializerSpec {
    
    func linkHeaderForTypes(_ types: [LinkHeaderType]) -> [String: AnyObject] {
        
        var linkValue = [String]()
        
        types.forEach {
            linkValue.append($0.description)
        }
        
        return [
            "Link" : linkValue.joined(separator: ",") as AnyObject
        ]
    }
}

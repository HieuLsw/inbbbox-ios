//
//  APIAttachmentsProviderSpec.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 15.11.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import PromiseKit

@testable import Inbbbox

class APIAttachmentsProviderSpec: QuickSpec {
    override func spec() {
        
        var sut: APIAttachmentsProviderPrivateMock!
        
        beforeEach {
            sut = APIAttachmentsProviderPrivateMock()
        }
        
        afterEach {
            sut = nil
        }
        
        describe("when providing attachments") {
            
            context("and they exist") {
                
                it("should be properly returned") {
                    let promise = sut.provideAttachmentsForShot(Shot.fixtureShot())
                    
                    expect(promise).to(resolveWithValueMatching { attachments in
                        expect(attachments).toNot(beNil())
                        expect(attachments).to(haveCount(3))
                        expect(attachments?.first?.identifier).to(equal("1"))

                    })
                }
            }
        }
    }
}

//Explanation: Create APIAttachmentsProviderPrivateMock to override methods from PageableProvider.
private class APIAttachmentsProviderPrivateMock: APIAttachmentsProvider {
    
    override func firstPageForQueries<T: Mappable>(_ queries: [Query], withSerializationKey key: String?) -> Promise<[T]?> {
        return mockResult(T.self)
    }
    
    override func nextPageFor<T: Mappable>(_ type: T.Type) -> Promise<[T]?> {
        return mockResult(T.self)
    }
    
    override func previousPageFor<T: Mappable>(_ type: T.Type) -> Promise<[T]?> {
        return mockResult(T.self)
    }
    
    func mockResult<T: Mappable>(_ type: T.Type) -> Promise<[T]?> {
        return Promise<[T]?> { fulfill, _ in
            
            let json = JSONSpecLoader.sharedInstance.fixtureAttachmentsJSON(withCount: 3)
            let result = json.map { T.map($0) }
            
            fulfill(result)
        }
    }
}

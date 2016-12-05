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
                
                var attachments: [Attachment]?
                
                afterEach {
                    attachments = nil
                }
                
                it("attachments should be properly returned") {
                    sut.provideAttachmentsForShot(Shot.fixtureShot()).then { _attachments -> Void in
                        attachments = _attachments
                        }.error { _ in fail() }
                    
                    expect(attachments).toNotEventually(beNil())
                    expect(attachments).toEventually(haveCount(3))
                    expect(attachments?.first?.identifier).toEventually(equal("1"))
                }
            }
        }
    }
}

//Explanation: Create APIAttachmentsProviderPrivateMock to override methods from PageableProvider.
private class APIAttachmentsProviderPrivateMock: APIAttachmentsProvider {
    
    override func firstPageForQueries<T: Mappable>(queries: [Query], withSerializationKey key: String?) -> Promise<[T]?> {
        return mockResult(T)
    }
    
    override func nextPageFor<T: Mappable>(type: T.Type) -> Promise<[T]?> {
        return mockResult(T)
    }
    
    override func previousPageFor<T: Mappable>(type: T.Type) -> Promise<[T]?> {
        return mockResult(T)
    }
    
    func mockResult<T: Mappable>(type: T.Type) -> Promise<[T]?> {
        return Promise<[T]?> { fulfill, _ in
            
            let json = JSONSpecLoader.sharedInstance.fixtureAttachmentsJSON(withCount: 3)
            let result = json.map { T.map($0) }
            
            fulfill(result)
        }
    }
}

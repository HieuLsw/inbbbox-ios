//
//  PageableProviderSpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 05/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Nimble
import Quick
import PromiseKit
import Mockingjay
import SwiftyJSON

@testable import Inbbbox

class PageableProviderSpec: QuickSpec {
    override func spec() {
        
        var sut: PageableProvider!
        
        beforeEach {
            sut = PageableProvider()
        }
        
        afterEach {
            sut = nil
        }
        
        describe("when init with custom initializer") {
            
            beforeEach {
                sut = PageableProvider(page: 2, pagination: 10)
            }
            
            it("should have properly set page") {
                expect(sut.page).to(equal(2))
            }
            
            it("should have properly set pagination") {
                expect(sut.pagination).to(equal(10))
            }
        }
        
        describe("when init with default initializer") {
            
            beforeEach {
                sut = PageableProvider()
            }
            
            it("should have properly set page") {
                expect(sut.page).to(equal(1))
            }
            
            it("should have properly set pagination") {
                expect(sut.pagination).to(equal(30))
            }
        }
        
        describe("when providing first page with success") {

            beforeEach {
                self.stub(everything, json([self.fixtureJSON]))
            }
            
            afterEach {
                self.removeAllStubs()
            }
            
            it("result should be properly returned") {
                let promise: Promise<[ModelMock]?> = sut.firstPageForQueries([QueryMock()], withSerializationKey: nil)
                
                expect(promise).to(resolveWithValueMatching { result in
                    expect(result).to(haveCount(1))
                })
            }
            
            context("then next/previous page with unavailable pageable") {
                
                it("error should appear") {
                    let promise: Promise<[ModelMock]?> = sut.firstPageForQueries([QueryMock()], withSerializationKey: nil)
                    let nextPagePromise = promise.then { _ in sut.nextPageFor(ModelMock.self) }
                    
                    expect(nextPagePromise).to(resolveWithError(type: PageableProviderError.self))
                }
                
                it("error should appear") {
                    let promise: Promise<[ModelMock]?> = sut.firstPageForQueries([QueryMock()], withSerializationKey: nil)
                    let previousPagePromise = promise.then { _ in sut.previousPageFor(ModelMock.self) }
                    
                    expect(previousPagePromise).to(resolveWithError(type: PageableProviderError.self))
                }
            }
            
            context("then next/previous page with available pageable components") {
                
                beforeEach {
                    self.removeAllStubs()
                    self.stub(everything, json([self.fixtureJSON], headers: self.fixtureHeader))
                }
                
                it("results from next page should be properly returned") {
                    let promise: Promise<[ModelMock]?> = sut.firstPageForQueries([QueryMock()], withSerializationKey: nil)
                    let nextPagePromise = promise.then { _ in sut.nextPageFor(ModelMock.self) }
                    
                    expect(nextPagePromise).to(resolveWithValueMatching { result in
                        expect(result).to(haveCount(1))
                    })
                }
                
                it("results from previous page should be properly returned") {
                    let promise: Promise<[ModelMock]?> = sut.firstPageForQueries([QueryMock()], withSerializationKey: nil)
                    let nextPagePromise = promise.then { _ in sut.previousPageFor(ModelMock.self) }
                    
                    expect(nextPagePromise).to(resolveWithValueMatching { result in
                        expect(result).to(haveCount(1))
                    })
                }
            }
        }
        
        describe("when providing first page with network error") {
            
            beforeEach {
                let error = NSError(domain: "", code: 0, userInfo: nil)
                self.stub(everything, failure(error))
            }
            
            afterEach {
                self.removeAllStubs()
            }
            
            it("error should appear") {
                let promise: Promise<[ModelMock]?> = sut.firstPageForQueries([QueryMock()], withSerializationKey: nil)
                
                expect(promise).to(resolveWithError())
            }
        }
        
        describe("when providing next/previous page without using firstPage method first") {
            
            it("error should appear") {
                let promise = sut.nextPageFor(ModelMock.self)
                
                expect(promise).to(resolveWithError(type: PageableProviderError.self))
            }
            
            it("error should appear") {
                let promise = sut.previousPageFor(ModelMock.self)
                
                expect(promise).to(resolveWithError(type: PageableProviderError.self))
            }
        }
    }
}

private struct ModelMock: Mappable {
    
    let identifier: String
    let title: String?
    
    static var map: (JSON) -> ModelMock {
        return { json in
            return ModelMock(
                identifier: json["identifier"].stringValue,
                title: json["title"].stringValue
            )
        }
    }
}

private extension PageableProviderSpec {
    
    var fixtureJSON: [String: AnyObject] {
        return [
            "identifier" : "fixture.identifier" as AnyObject,
            "title" : "fixture.title" as AnyObject
        ]
    }
    
    var fixtureHeader: [String: String] {
        return [
            "Link" :
                "<https://fixture.host/v1/fixture.path?page=1&per_page=100>; rel=\"prev\"," +
                "<https://fixture.host/v1/fixture.path?page=3&per_page=100>; rel=\"next\""
        ]
    }
}

private struct QueryMock: Query {
    let path = "/fixture/path"
    var parameters = Parameters(encoding: .json)
    let method = Method.POST
}

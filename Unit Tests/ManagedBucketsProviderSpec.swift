//
//  ManagedBucketsProviderSpec.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

import Quick
import Nimble
import CoreData
import PromiseKit

@testable import Inbbbox

class ManagedBucketsProviderSpec: QuickSpec {
    
    override func spec() {
        var sut: ManagedBucketsProvider!
        var inMemoryManagedObjectContext: NSManagedObjectContext!
        
        beforeEach {
            inMemoryManagedObjectContext = setUpInMemoryManagedObjectContext()
            sut = ManagedBucketsProvider(managedObjectContext: inMemoryManagedObjectContext)
        }
        
        afterEach {
            inMemoryManagedObjectContext = nil
            sut = nil
        }
        
        describe("My buckets") {
            
            context("providing my buckets") {
                
                var myBuckets: [ManagedBucket]?
                
                it("all my buckets should be returned") {
                     let bucketRequester = ManagedBucketsRequester(managedObjectContext: inMemoryManagedObjectContext)
                    
                    _ = firstly {
                        bucketRequester.addBucket("fuxture.name.1", description: nil)
                    }.then { _ in
                        bucketRequester.addBucket("fuxture.name.2", description: nil)
                    }.then { _ in
                        bucketRequester.addBucket("fuxture.name.3", description: nil)
                    }.then { _ in
                        sut.provideMyBuckets()
                    }.then { buckets in
                        myBuckets = buckets as? [ManagedBucket]
                    }
                    expect(myBuckets?.count).toEventually(equal(3))
                }
            }
            
        }


    }
}



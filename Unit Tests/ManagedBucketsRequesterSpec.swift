//
//  ManagedBucketsRequesterSpec.swift
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

class ManagedBucketsRequesterSpec: QuickSpec {

    override func spec() {
        var sut: ManagedBucketsRequester!
        var inMemoryManagedObjectContext: NSManagedObjectContext!
        
        beforeEach {
            inMemoryManagedObjectContext = setUpInMemoryManagedObjectContext()
            sut = ManagedBucketsRequester(managedObjectContext: inMemoryManagedObjectContext)

        }
        
        afterEach {
            inMemoryManagedObjectContext = nil
            sut = nil
        }
        
        it("should have managed object context") {
            expect(sut.managedObjectContext).toNot(beNil())
        }
        
        describe("create buckets") {
            var createdBucket: ManagedBucket?
            
            context("bucket should be created properly") {
                
                afterEach {
                    createdBucket = nil
                }
                
                it("with description") {
                    let description = NSAttributedString(string: "fixture")
                    _ = firstly {
                        sut.addBucket("fixture", description: description)
                    }.then { bucket in
                        createdBucket = bucket as? ManagedBucket
                    }
                    expect(createdBucket).toEventuallyNot(beNil())
                    expect(createdBucket!.name).toEventually(equal("fixture"))
                    expect(createdBucket!.attributedDescription!).toEventually(equal(description))
                }
                
                it("without description") {
                    _ = firstly {
                        sut.addBucket("fixture", description: nil)
                    }.then { bucket in
                        createdBucket = bucket as? ManagedBucket
                    }
                    expect(createdBucket).toEventuallyNot(beNil())
                    expect(createdBucket!.name).toEventually(equal("fixture"))
                    expect(createdBucket!.attributedDescription).toEventually(beNil())
                }
            }
        }
        
        describe("shots handling") {
            
            var bucket: ManagedBucket!
            var shot: ManagedShot!
            
            beforeEach() {
                let managedObjectsProvider = ManagedObjectsProvider(managedObjectContext: inMemoryManagedObjectContext)
                bucket = managedObjectsProvider.managedBucket(Bucket.fixtureBucket())
                shot = managedObjectsProvider.managedShot(Shot.fixtureShot())

            }
            
            afterEach {
                bucket = nil
                shot = nil
            }
            
            context("adding shots") {
                
                it("adding one shot") {
                    _ = sut.addShot(shot, toBucket: bucket)
                    expect(bucket.shots?.count).toEventuallyNot(equal(0))
                }
                
                it("adding few different shots") {
                    let managedObjectsProvider = ManagedObjectsProvider(managedObjectContext: inMemoryManagedObjectContext)
                    let shot2 = managedObjectsProvider.managedShot(Shot.fixtureShotWithIdentifier("fixture.id.2"))
                    let shot3 = managedObjectsProvider.managedShot(Shot.fixtureShotWithIdentifier("fixture.id.3"))
                    _ = sut.addShot(shot, toBucket: bucket)
                    _ = sut.addShot(shot2, toBucket: bucket)
                    _ = sut.addShot(shot3, toBucket: bucket)
                    expect(bucket.shots?.count).toEventually(equal(3))
                }
                
                it("adding few times the same shots") {
                    _ = sut.addShot(shot, toBucket: bucket)
                    _ = sut.addShot(shot, toBucket: bucket)
                    _ = sut.addShot(shot, toBucket: bucket)
                    
                    expect(bucket.shots?.count).toEventually(equal(1))
                    expect(bucket.shots?.count).toEventuallyNot(equal(3))
                }
                
            }
            
            context("removing shots") {
                
                it("removing only shot") {
                    bucket.shots = [shot]
                    _ = sut.removeShot(shot, fromBucket: bucket)
                    expect(bucket.shots?.count).toEventually(equal(0))
                }
                
                it("removing few shots") {
                    let managedObjectsProvider = ManagedObjectsProvider(managedObjectContext: inMemoryManagedObjectContext)
                    let shot2 = managedObjectsProvider.managedShot(Shot.fixtureShotWithIdentifier("fixture.id.2"))
                    let shot3 = managedObjectsProvider.managedShot(Shot.fixtureShotWithIdentifier("fixture.id.3"))
                    bucket.shots = [shot, shot2, shot3]
                    
                    _ = sut.removeShot(shot, fromBucket: bucket)
                    _ = sut.removeShot(shot2, fromBucket: bucket)
                    expect(bucket.shots?.count).toEventually(equal(1))
                    
                }
            }
        }
        
    }
}

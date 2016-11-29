//
// Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import Dobby

@testable import Inbbbox

class ShotsAnimatorSpec: QuickSpec {

    override func spec() {

        var sut: ShotsAnimator?

        beforeEach {
            sut = ShotsAnimator()
        }

        afterEach {
            sut = nil
        }

        describe("start animation with completion") {

            var capturedAddedItemsIndexPaths: [IndexPath]?
            var capturedDeletedItemsIndexPaths: [IndexPath]?
            var capturedDelays: [Double]?
            var didInvokeCompletion: Bool?

            beforeEach {
                capturedAddedItemsIndexPaths = [IndexPath]()
                capturedDeletedItemsIndexPaths = [IndexPath]()
                capturedDelays = [Double]()

                let collectionViewMock = CollectionViewMock(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
                collectionViewMock.insertItemsAtIndexPathsStub.on(any()) { (indexPaths:[IndexPath]) in
                    capturedAddedItemsIndexPaths!.append(indexPaths.first!)
                }
                collectionViewMock.deleteItemsAtIndexPathsStub.on(any()) { (indexPaths:[IndexPath]) in
                    capturedDeletedItemsIndexPaths!.append(indexPaths.first!)
                }
                collectionViewMock.performBatchUpdatesStub.on(any()) { updates, completion in
                    updates?()
                    completion?(true)
                }
                
                let delegateMock = ShotsAnimatorDelegateMock()
                delegateMock.collectionViewForShotsAnimatorStub.on(any(), return: collectionViewMock)
                let shot = Shot.fixtureShot()
                delegateMock.itemsForShotsAnimatorStub.on(any(), return: [shot, shot, shot])
                sut!.delegate = delegateMock

                let asyncWrapperMock = AsyncWrapperMock()
                asyncWrapperMock.mainStub.on(any()) { after, block in
                    capturedDelays!.append(after!)
                    block()
                    return asyncWrapperMock
                }

                sut!.asyncWrapper = asyncWrapperMock

                sut!.startAnimationWithCompletion() {
                    didInvokeCompletion = true
                }
            }

            describe("adding items") {

                it("should add 3 items") {
                    expect(capturedAddedItemsIndexPaths!.count).to(equal(3))
                }

                describe("first added item") {

                    var addedItemIndexPath: IndexPath?
                    var addedItemDelay: Double?

                    beforeEach {
                        addedItemIndexPath = capturedAddedItemsIndexPaths![0]
                        addedItemDelay = capturedDelays![0]
                    }

                    it("should add item for proper index path") {
                        expect(addedItemIndexPath!).to(equal(IndexPath(item: 0, section: 0)))
                    }

                    it("should add item with proper delay") {
                        expect(addedItemDelay).to(beCloseTo(0.1))
                    }
                }

                describe("second added item") {

                    var addedItemIndexPath: IndexPath?
                    var addedItemDelay: Double?

                    beforeEach {
                        addedItemIndexPath = capturedAddedItemsIndexPaths![1]
                        addedItemDelay = capturedDelays![1]
                    }

                    it("should add item for proper index path") {
                        expect(addedItemIndexPath!).to(equal(IndexPath(item: 1, section: 0)))
                    }

                    it("should add item with proper delay") {
                        expect(addedItemDelay).to(beCloseTo(0.2))
                    }
                }

                describe("third added item") {

                    var addedItemIndexPath: IndexPath?
                    var addedItemDelay: Double?

                    beforeEach {
                        addedItemIndexPath = capturedAddedItemsIndexPaths![2]
                        addedItemDelay = capturedDelays![2]
                    }

                    it("should add item for proper index path") {
                        expect(addedItemIndexPath!).to(equal(IndexPath(item: 2, section: 0)))
                    }

                    it("should add item with proper delay") {
                        expect(addedItemDelay).to(beCloseTo(0.3))
                    }
                }
            }

            describe("deleting items") {

                it("should delete 2 items") {
                    expect(capturedDeletedItemsIndexPaths!.count).to(equal(2))
                }

                it("should make 1 second pause before deleting items"){
                    expect(capturedDelays![3]).to(beCloseTo(1.0))
                }

                describe("first deleted item") {

                    var deletedItemIndexPath: IndexPath?
                    var deletedItemDelay: Double?

                    beforeEach {
                        deletedItemIndexPath = capturedDeletedItemsIndexPaths![0]
                        deletedItemDelay = capturedDelays![4]
                    }

                    it("should delete item for proper index path") {
                        expect(deletedItemIndexPath!).to(equal(IndexPath(item: 2, section: 0)))
                    }

                    it("should delete item with proper delay") {
                        expect(deletedItemDelay).to(beCloseTo(0.1))
                    }
                }

                describe("second deleted item") {

                    var deletedItemIndexPath: IndexPath?
                    var deletedItemDelay: Double?

                    beforeEach {
                        deletedItemIndexPath = capturedDeletedItemsIndexPaths![1]
                        deletedItemDelay = capturedDelays![5]
                    }

                    it("should delete item for proper index path") {
                        expect(deletedItemIndexPath!).to(equal(IndexPath(item: 1, section: 0)))
                    }

                    it("should delete item with proper delay") {
                        expect(deletedItemDelay).to(beCloseTo(0.2))
                    }
                }

                it("should invoke completion") {
                    expect(didInvokeCompletion).to(beTruthy())
                }
            }
        }
    }
}

//
// Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import Dobby

@testable import Inbbbox

class InitialShotsCollectionViewLayoutSpec: QuickSpec {

    override func spec() {

        var sut: InitialShotsCollectionViewLayout!
        var collectionViewMock: CollectionViewMock!
        let fixtureCollectionViewBounds = FixtureCollectionViewBounds()
        let withoutAuthorFixtureFirstItemAttributes = WithoutAuthorFixtureFirstItemAttributes()
        let withoutAuthorFixtureSecondItemAttributes = WithoutAuthorFixtureSecondItemAttributes()
        
        let withAuthorFixtureFirstItemAttributes = WithAuthorFixtureFirstItemAttributes()
        let withAuthorFixtureSecondItemAttributes = WithAuthorFixtureSecondItemAttributes()

        beforeEach {
            sut = InitialShotsCollectionViewLayout()
            collectionViewMock = CollectionViewMock(frame: CGRect(x: 0,y: 0, width: 0, height: 0), collectionViewLayout: sut!)
        }

        afterEach() {
            sut = nil
        }

        describe("collection view layout without author's name showed") {
            
            beforeEach {
                Settings.Customization.ShowAuthor = false
            }
            
            describe("collection view content size") {

                var contentSize: CGSize!

                beforeEach {
                    collectionViewMock.bounds = CGRect(x: fixtureCollectionViewBounds.x, y: fixtureCollectionViewBounds.y, width: fixtureCollectionViewBounds.width, height: fixtureCollectionViewBounds.height)
                    contentSize = sut.collectionViewContentSize
                }

                it("should have proper content size") {
                    expect(contentSize).to(equal(CGSize(width: fixtureCollectionViewBounds.width, height: fixtureCollectionViewBounds.height)))
                }
            }

            describe("layout attributes for elements in rect") {

                var layoutAttributes: [UICollectionViewLayoutAttributes]!

                beforeEach {
                        collectionViewMock.bounds = CGRect(x: fixtureCollectionViewBounds.x, y: fixtureCollectionViewBounds.y, width: fixtureCollectionViewBounds.width, height: fixtureCollectionViewBounds.height)
                        collectionViewMock.center = CGPoint(x: fixtureCollectionViewBounds.width / 2, y: fixtureCollectionViewBounds.height / 2)
                }

                context("when collection view has 2 items in first section") {

                    beforeEach {
                        collectionViewMock.numberOfItemsInSectionStub.on(equals(0), return: 2)
                        layoutAttributes = sut.layoutAttributesForElements(in: CGRect(x:0, y:0, width: 0, height: 0))
                    }

                    it("should have layout attributes for 2 items") {
                        expect(layoutAttributes.count).to(equal(2))
                    }

                    describe("first item layout attributes") {

                        var firstItemLayoutAttributes: UICollectionViewLayoutAttributes!

                        beforeEach {
                            firstItemLayoutAttributes = layoutAttributes![0]
                        }

                        it("should have proper size") {
                            expect(firstItemLayoutAttributes.size).to(equal(CGSize(width: withoutAuthorFixtureFirstItemAttributes.width, height: withoutAuthorFixtureFirstItemAttributes.height)))
                        }
                        
                        it("should have proper item height to width ratio") {
                            let heightToWidhtRatio = firstItemLayoutAttributes.size.height / firstItemLayoutAttributes.size.width
                            expect(heightToWidhtRatio).to(equal(withoutAuthorFixtureFirstItemAttributes.height / withoutAuthorFixtureFirstItemAttributes.width))
                        }

                        it("should have proper center") {
                            expect(firstItemLayoutAttributes.center).to(equal(withoutAuthorFixtureFirstItemAttributes.center))
                        }

                        it("should have proper z index") {
                            expect(firstItemLayoutAttributes.zIndex).to(equal(withoutAuthorFixtureFirstItemAttributes.zIndex))
                        }
                    }

                    describe("second item layout attributes") {

                        var secondItemLayoutAttributes: UICollectionViewLayoutAttributes!

                        beforeEach {
                            secondItemLayoutAttributes = layoutAttributes![1]
                        }

                        it("should have proper size") {
                            expect(secondItemLayoutAttributes.size).to(equal(CGSize(width: withoutAuthorFixtureSecondItemAttributes.width, height: withoutAuthorFixtureSecondItemAttributes.height)))
                        }
                        
                        it("should have proper item height to width ratio") {
                            let heightToWidhtRatio = secondItemLayoutAttributes.size.height / secondItemLayoutAttributes.size.width
                            expect(heightToWidhtRatio).to(equal(withoutAuthorFixtureSecondItemAttributes.height / withoutAuthorFixtureSecondItemAttributes.width))
                        }

                        it("should have proper center") {
                            expect(secondItemLayoutAttributes.center).to(equal(withoutAuthorFixtureSecondItemAttributes.center))
                        }

                        it("should have proper z index") {
                            expect(secondItemLayoutAttributes.zIndex).to(equal(withoutAuthorFixtureSecondItemAttributes.zIndex))
                        }
                    }
                }
            }

            describe("should invalidate layout for bounds change") {

                var boundsChanged: Bool!

                beforeEach {
                    collectionViewMock.bounds = CGRect(x: 0, y: 0, width: 375, height: 667)
                    boundsChanged = sut.shouldInvalidateLayout(forBoundsChange: CGRect(x: 0, y: 0, width: 200, height: 100))
                }

                it("should invalidate layout when bounds size changes") {
                    expect(boundsChanged).to(beTruthy())
                }
            }

            describe("initial layout attributes for appearing item") {

                var initialLayoutAttributes: UICollectionViewLayoutAttributes!

                beforeEach {
                    collectionViewMock.bounds = CGRect(x: fixtureCollectionViewBounds.x, y: fixtureCollectionViewBounds.y, width: fixtureCollectionViewBounds.width, height: fixtureCollectionViewBounds.height)
                    collectionViewMock.center = CGPoint(x: fixtureCollectionViewBounds.width / 2, y: fixtureCollectionViewBounds.height / 2)
                    collectionViewMock.numberOfItemsInSectionStub.on(0, return: 1)
                    initialLayoutAttributes = sut.initialLayoutAttributesForAppearingItem(at: IndexPath(item: 0, section: 0))
                }

                it("should have proper size") {
                    expect(initialLayoutAttributes.size).to(equal(CGSize(width: withoutAuthorFixtureFirstItemAttributes.width, height: withoutAuthorFixtureFirstItemAttributes.height)))
                }

                it("should have proper center") {
                    expect(initialLayoutAttributes.center).to(equal(withoutAuthorFixtureFirstItemAttributes.center))
                }

                it("should have proper z index") {
                    expect(initialLayoutAttributes.zIndex).to(equal(withoutAuthorFixtureFirstItemAttributes.zIndex))
                }

                it("should have alpha 0") {
                    expect(initialLayoutAttributes.alpha).to(equal(withoutAuthorFixtureFirstItemAttributes.alpha))
                }
            }

            describe("final layout attributes for appearing item") {

                var finalLayoutAttributes: UICollectionViewLayoutAttributes!

                beforeEach {
                    collectionViewMock.bounds = CGRect(x: fixtureCollectionViewBounds.x, y: fixtureCollectionViewBounds.y, width: fixtureCollectionViewBounds.width, height: fixtureCollectionViewBounds.height)
                    collectionViewMock.center = CGPoint(x: fixtureCollectionViewBounds.width / 2, y: fixtureCollectionViewBounds.height / 2)
                    collectionViewMock.numberOfItemsInSectionStub.on(0, return: 1)
                    finalLayoutAttributes = sut.finalLayoutAttributesForDisappearingItem(at: IndexPath(item: 0, section: 0))
                }

                it("should have proper size") {
                    expect(finalLayoutAttributes.size).to(equal(CGSize(width: withoutAuthorFixtureFirstItemAttributes.width, height: withoutAuthorFixtureFirstItemAttributes.height)))
                }

                it("should have proper center") {
                    expect(finalLayoutAttributes.center).to(equal(CGPoint(x: fixtureCollectionViewBounds.width / 2, y: fixtureCollectionViewBounds.height + withoutAuthorFixtureFirstItemAttributes.height)))
                }

                it("should have proper z index") {
                    expect(finalLayoutAttributes.zIndex).to(equal(withoutAuthorFixtureFirstItemAttributes.zIndex))
                }

                it("should have alpha 0") {
                    expect(finalLayoutAttributes.alpha).to(equal(withoutAuthorFixtureFirstItemAttributes.alpha))
                }
            }
        }
        
        describe("collection view layout with author's name showed") {
            
            beforeEach {
                Settings.Customization.ShowAuthor = true
            }
            
            describe("collection view content size") {
                
                var contentSize: CGSize!
                
                beforeEach {
                    collectionViewMock.bounds = CGRect(x: fixtureCollectionViewBounds.x, y: fixtureCollectionViewBounds.y, width: fixtureCollectionViewBounds.width, height: fixtureCollectionViewBounds.height)
                    contentSize = sut.collectionViewContentSize
                }
                
                it("should have proper content size") {
                    expect(contentSize).to(equal(CGSize(width: fixtureCollectionViewBounds.width, height: fixtureCollectionViewBounds.height)))
                }
            }
            
            describe("layout attributes for elements in rect") {
                
                var layoutAttributes: [UICollectionViewLayoutAttributes]!
                
                beforeEach {
                    collectionViewMock.bounds = CGRect(x: fixtureCollectionViewBounds.x, y: fixtureCollectionViewBounds.y, width: fixtureCollectionViewBounds.width, height: fixtureCollectionViewBounds.height)
                    collectionViewMock.center = CGPoint(x: fixtureCollectionViewBounds.width / 2, y: fixtureCollectionViewBounds.height / 2)
                }
                
                context("when collection view has 2 items in first section") {
                    
                    beforeEach {
                        collectionViewMock.numberOfItemsInSectionStub.on(0, return: 2)
                        layoutAttributes = sut.layoutAttributesForElements(in: CGRect(x:0, y:0, width: 0, height: 0))
                    }
                    
                    it("should have layout attributes for 2 items") {
                        expect(layoutAttributes.count).to(equal(2))
                    }
                    
                    describe("first item layout attributes") {
                        
                        var firstItemLayoutAttributes: UICollectionViewLayoutAttributes!
                        
                        beforeEach {
                            firstItemLayoutAttributes = layoutAttributes![0]
                        }
                        
                        it("should have proper size") {
                            expect(firstItemLayoutAttributes.size).to(equal(CGSize(width: withAuthorFixtureFirstItemAttributes.width, height: withAuthorFixtureFirstItemAttributes.height)))
                        }
                        
                        it("should have proper item height to width ratio") {
                            let heightToWidhtRatio = firstItemLayoutAttributes.size.height / firstItemLayoutAttributes.size.width
                            expect(heightToWidhtRatio).to(equal(withAuthorFixtureFirstItemAttributes.height / withAuthorFixtureFirstItemAttributes.width))
                        }
                        
                        it("should have proper center") {
                            expect(firstItemLayoutAttributes.center).to(equal(withAuthorFixtureFirstItemAttributes.center))
                        }
                        
                        it("should have proper z index") {
                            expect(firstItemLayoutAttributes.zIndex).to(equal(withAuthorFixtureFirstItemAttributes.zIndex))
                        }
                    }
                    
                    describe("second item layout attributes") {
                        
                        var secondItemLayoutAttributes: UICollectionViewLayoutAttributes!
                        
                        beforeEach {
                            secondItemLayoutAttributes = layoutAttributes![1]
                        }
                        
                        it("should have proper size") {
                            expect(secondItemLayoutAttributes.size.height).to(beCloseTo(withAuthorFixtureSecondItemAttributes.height))
                            expect(secondItemLayoutAttributes.size.width).to(beCloseTo(withAuthorFixtureSecondItemAttributes.width))
                        }
                        
                        it("should have proper item height to width ratio") {
                            let heightToWidhtRatio = secondItemLayoutAttributes.size.height / secondItemLayoutAttributes.size.width
                            expect(heightToWidhtRatio).to(beCloseTo(withAuthorFixtureSecondItemAttributes.height / withAuthorFixtureSecondItemAttributes.width))
                        }
                        
                        it("should have proper center") {
                            expect(secondItemLayoutAttributes.center).to(equal(withAuthorFixtureSecondItemAttributes.center))
                        }
                        
                        it("should have proper z index") {
                            expect(secondItemLayoutAttributes.zIndex).to(equal(withAuthorFixtureSecondItemAttributes.zIndex))
                        }
                    }
                }
            }
            
            describe("should invalidate layout for bounds change") {
                
                var boundsChanged: Bool!
                
                beforeEach {
                    collectionViewMock.bounds = CGRect(x: 0, y: 0, width: 375, height: 667)
                    boundsChanged = sut.shouldInvalidateLayout(forBoundsChange: CGRect(x: 0, y: 0, width: 200, height: 100))
                }
                
                it("should invalidate layout when bounds size changes") {
                    expect(boundsChanged).to(beTruthy())
                }
            }
            
            describe("initial layout attributes for appearing item") {
                
                var initialLayoutAttributes: UICollectionViewLayoutAttributes!
                
                beforeEach {
                    collectionViewMock.bounds = CGRect(x: fixtureCollectionViewBounds.x, y: fixtureCollectionViewBounds.y, width: fixtureCollectionViewBounds.width, height: fixtureCollectionViewBounds.height)
                    collectionViewMock.center = CGPoint(x: fixtureCollectionViewBounds.width / 2, y: fixtureCollectionViewBounds.height / 2)
                    collectionViewMock.numberOfItemsInSectionStub.on(0, return: 1)
                    initialLayoutAttributes = sut.initialLayoutAttributesForAppearingItem(at: IndexPath(item: 0, section: 0))
                }
                
                it("should have proper size") {
                    expect(initialLayoutAttributes.size).to(equal(CGSize(width: withAuthorFixtureFirstItemAttributes.width, height: withAuthorFixtureFirstItemAttributes.height)))
                }
                
                it("should have proper center") {
                    expect(initialLayoutAttributes.center).to(equal(withAuthorFixtureFirstItemAttributes.center))
                }
                
                it("should have proper z index") {
                    expect(initialLayoutAttributes.zIndex).to(equal(withAuthorFixtureFirstItemAttributes.zIndex))
                }
                
                it("should have alpha 0") {
                    expect(initialLayoutAttributes.alpha).to(equal(withAuthorFixtureFirstItemAttributes.alpha))
                }
            }
            
            describe("final layout attributes for appearing item") {
                
                var finalLayoutAttributes: UICollectionViewLayoutAttributes!
                
                beforeEach {
                    collectionViewMock.bounds = CGRect(x: fixtureCollectionViewBounds.x, y: fixtureCollectionViewBounds.y, width: fixtureCollectionViewBounds.width, height: fixtureCollectionViewBounds.height)
                    collectionViewMock.center = CGPoint(x: fixtureCollectionViewBounds.width / 2, y: fixtureCollectionViewBounds.height / 2)
                    collectionViewMock.numberOfItemsInSectionStub.on(0, return: 1)
                    finalLayoutAttributes = sut.finalLayoutAttributesForDisappearingItem(at: IndexPath(item: 0, section: 0))
                }
                
                it("should have proper size") {
                    expect(finalLayoutAttributes.size).to(equal(CGSize(width: withAuthorFixtureFirstItemAttributes.width, height: withAuthorFixtureFirstItemAttributes.height)))
                }
                
                it("should have proper center") {
                    expect(finalLayoutAttributes.center).to(equal(CGPoint(x: fixtureCollectionViewBounds.width / 2, y: fixtureCollectionViewBounds.height + withAuthorFixtureFirstItemAttributes.height)))
                }
                
                it("should have proper z index") {
                    expect(finalLayoutAttributes.zIndex).to(equal(withAuthorFixtureFirstItemAttributes.zIndex))
                }
                
                it("should have alpha 0") {
                    expect(finalLayoutAttributes.alpha).to(equal(withAuthorFixtureFirstItemAttributes.alpha))
                }
            }
        }
    }
}

private struct FixtureCollectionViewBounds {
    let width = CGFloat(320)
    let height = CGFloat(568)
    let x = CGFloat(0)
    let y = CGFloat(0)
}

private struct WithoutAuthorFixtureFirstItemAttributes {
    let width = CGFloat(265)
    let height = CGFloat(198.75)
    let center = CGPoint(x: 160, y: 284)
    let zIndex = 0
    let alpha = CGFloat(0)
}

private struct WithoutAuthorFixtureSecondItemAttributes  {
    let width = CGFloat(210)
    let height = CGFloat(157.5)
    let center = CGPoint(x: 160, y: 324)
    let zIndex = -1
    let alpha = CGFloat(0)
}

private struct WithAuthorFixtureFirstItemAttributes {
    let width = CGFloat(265)
    let height = CGFloat(219.95)
    let center = CGPoint(x: 160, y: 284)
    let zIndex = 0
    let alpha = CGFloat(0)
}

private struct WithAuthorFixtureSecondItemAttributes  {
    let width = CGFloat(210)
    let height = CGFloat(174.3)
    let center = CGPoint(x: 160, y: 324)
    let zIndex = -1
    let alpha = CGFloat(0)
}

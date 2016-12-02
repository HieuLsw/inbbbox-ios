//
//  AutoScrollableShotsAnimatorSpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 31/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

@testable import Inbbbox

class AutoScrollableShotsAnimatorSpec: QuickSpec {
    override func spec() {
        
        var sut: AutoScrollableShotsAnimator!
        var collectionViews: [UICollectionView]! // keep reference to be able to check expectation
        let content =  [
            UIImage.referenceImageWithColor(.green),
            UIImage.referenceImageWithColor(.yellow),
            UIImage.referenceImageWithColor(.red)
        ]
        var mockSuperview: UIView!
        
        beforeEach {
            let collectionView_1 = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 200), collectionViewLayout: UICollectionViewFlowLayout())
            let collectionView_2 = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 200), collectionViewLayout: UICollectionViewFlowLayout())
            
            collectionViews = [collectionView_1, collectionView_2]
            let bindForAnimation = collectionViews.map {
                (collectionView: $0, shots: content)
            }
            
            mockSuperview = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            mockSuperview.addSubview(collectionView_1)
            mockSuperview.addSubview(collectionView_2)

            sut = AutoScrollableShotsAnimator(bindForAnimation: bindForAnimation)
        }
        
        afterEach {
            sut = nil
            collectionViews = nil
            mockSuperview = nil
        }
        
        it("when newly created, content offset should be 0") {
            expect(collectionViews.map{ $0.contentOffset }).to(equal([CGPoint.zero, CGPoint.zero]))
        }
        
        describe("when scrolling to middle") {
            
            beforeEach {
                sut.scrollToMiddleInstantly()
            }
            
            it("collection views should be in the middle") {
                let middlePoint = CGPoint(x: 0, y: -100)
                expect(collectionViews.map{ $0.contentOffset }).to(equal([middlePoint, middlePoint]))
            }
        }
        
        describe("when performing scroll animation") {
            
            afterEach {
                sut.stopAnimation()
            }
            
            context("first collection view") {
                
                var initialValueY: CGFloat!
                
                beforeEach {
                    initialValueY = collectionViews[0].contentOffset.y
                    sut.startScrollAnimationInfinitely()
                    RunLoop.current.run(until: NSDate() as Date)
                }
                
                it("should be scrolled up") {
                    expect(collectionViews[0].contentOffset.y).toEventually(beGreaterThan(initialValueY))
                }
            }
            
            context("collection view") {
                
                var initialValueY: CGFloat!
                
                beforeEach {
                    initialValueY = collectionViews[1].contentOffset.y
                    sut.startScrollAnimationInfinitely()
                    RunLoop.current.run(until: NSDate() as Date)
                }
                
                it("should be scrolled down") {
                    expect(collectionViews[1].contentOffset.y).toEventually(beLessThan(initialValueY))
                }
            }
            
            context("and stopping it") {
                
                beforeEach {
                    sut.stopAnimation()
                }
                
                context("first collection view") {
                    
                    var initialValueY: CGFloat!
                    
                    beforeEach {
                        initialValueY = collectionViews[0].contentOffset.y
                    }
                    
                    it("first collection view should be in same place") {
                        expect(collectionViews[0].contentOffset.y).toEventually(equal(initialValueY))
                    }
                }
                
                
                context("second collection view") {
                    
                    var initialValueY: CGFloat!
                    
                    beforeEach {
                        initialValueY = collectionViews[1].contentOffset.y
                    }
                    
                    it("first collection view should be in same place") {
                        expect(collectionViews[1].contentOffset.y).toEventually(equal(initialValueY))
                    }
                }
            }
        }
    }
}

//
// Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import Dobby

@testable import Inbbbox

class ShotCollectionViewCellSpec: QuickSpec {
    override func spec() {
        
        var sut: ShotCollectionViewCell!
        
        beforeEach {
            sut = ShotCollectionViewCell(frame: CGRect.zero)
        }
        
        afterEach {
            sut = nil
        }
        
        describe("shot container view") {
            
            var shotContainer: UIView!
            
            beforeEach {
                shotContainer = sut.shotContainer
            }
            
            it("should not translate autoresizing mask into constraints") {
                expect(shotContainer.translatesAutoresizingMaskIntoConstraints).to(beFalsy())
            }
            
            it("should be added to cell content view subviews") {
                expect(sut.contentView.subviews).to(contain(shotContainer))
            }
        }
        
        describe("like image view") {
            
            var likeImageView: DoubleImageView!
            
            beforeEach {
                likeImageView = sut.likeImageView
            }
            
            it("should not translate autoresizing mask into constraints") {
                expect(likeImageView.translatesAutoresizingMaskIntoConstraints).to(beFalsy())
            }
            
            it("should be added to cell content view subviews") {
                expect(sut.shotContainer.subviews).to(contain(likeImageView))
            }
            
            it("should have proper first image") {
                expect(UIImagePNGRepresentation(likeImageView.firstImageView.image!)).to(equal(UIImagePNGRepresentation(UIImage(named: "ic-like-swipe")!)))
            }
            
            it("should have proper second image") {
                expect(UIImagePNGRepresentation(likeImageView.secondImageView.image!)).to(equal(UIImagePNGRepresentation(UIImage(named: "ic-like-swipe-filled")!)))
            }
        }
        
        describe("bucket image view") {
            
            var bucketImageView: DoubleImageView!
            
            beforeEach {
                bucketImageView = sut.bucketImageView
            }
            
            it("should not translate autoresizing mask into constraints") {
                expect(bucketImageView.translatesAutoresizingMaskIntoConstraints).to(beFalsy())
            }
            
            it("should be added to cell content view subviews") {
                expect(sut.shotContainer.subviews).to(contain(bucketImageView))
            }
            
            it("should have proper first image") {
                expect(UIImagePNGRepresentation(bucketImageView.firstImageView.image!)).to(equal(UIImagePNGRepresentation(UIImage(named: "ic-bucket-swipe")!)))
            }
            
            it("should have proper second image") {
                expect(UIImagePNGRepresentation(bucketImageView.secondImageView.image!)).to(equal(UIImagePNGRepresentation(UIImage(named: "ic-bucket-swipe-filled")!)))
            }
        }
        
        describe("comment image view") {
            
            var commentImageView: DoubleImageView!
            
            beforeEach {
                commentImageView = sut.commentImageView
            }
            
            it("should not translate autoresizing mask into constraints") {
                expect(commentImageView.translatesAutoresizingMaskIntoConstraints).to(beFalsy())
            }
            
            it("should be added to cell content view subviews") {
                expect(sut.shotContainer.subviews).to(contain(commentImageView))
            }
            
            it("should have proper first image") {
                expect(UIImagePNGRepresentation(commentImageView.firstImageView.image!)).to(equal(UIImagePNGRepresentation(UIImage(named: "ic-comment")!)))
            }
            
            it("should have proper second image") {
                expect(UIImagePNGRepresentation(commentImageView.secondImageView.image!)).to(equal(UIImagePNGRepresentation(UIImage(named: "ic-comment-filled")!)))
            }
        }
        
        describe("shot image view") {
            
            var shotImageView: UIImageView!
            
            beforeEach {
                shotImageView = sut.shotImageView
            }
            
            it("should not translate autoresizing mask into constraints") {
                expect(shotImageView.translatesAutoresizingMaskIntoConstraints).to(beFalsy())
            }
            
            it("should be added to cell content view subviews") {
                expect(sut.shotContainer.subviews).to(contain(shotImageView))
            }
        }
        
        describe("requires constraint based layout") {
            
            var requiresConstraintBasedLayout: Bool!
            
            beforeEach {
                requiresConstraintBasedLayout = ShotCollectionViewCell.requiresConstraintBasedLayout
            }
            
            it("should require constraint based layout") {
                expect(requiresConstraintBasedLayout).to(beTruthy())
            }
        }
        
        pending("randomly crashes bitrise, works locally; check with Xcode 8 and Swift 3 after conversion") {
            describe("swiping cell") {
                
                var panGestureRecognizer: UIPanGestureRecognizer!
                
                beforeEach {
                    panGestureRecognizer = sut.contentView.gestureRecognizers!.filter{ $0 is UIPanGestureRecognizer }.first as! UIPanGestureRecognizer!
                }
                
                context("when swipe began") {
                    
                    var delegateMock: ShotCollectionViewCellDelegateMock!
                    var didInformDelegateCellDidStartSwiping: Bool!
                    
                    beforeEach {
                        delegateMock = ShotCollectionViewCellDelegateMock()
                        didInformDelegateCellDidStartSwiping = false
                        delegateMock.shotCollectionViewCellDidStartSwipingStub.on(any()) { _ in
                            didInformDelegateCellDidStartSwiping = true
                        }
                        sut.delegate = delegateMock
                        let panGestureRecognizerMock = PanGestureRecognizerMock()
                        panGestureRecognizerMock.stateStub.on(any()) {
                            return .began
                        }
                        panGestureRecognizer!.specRecognize(with: panGestureRecognizerMock)
                    }
                    
                    it("should inform delegate that cell did start swiping") {
                        expect(didInformDelegateCellDidStartSwiping).to(beTruthy())
                    }
                }
                
                context("when swipe ended") {
                    
                    var panGestureRecognizerMock: PanGestureRecognizerMock!
                    var viewClassMock: ViewMock.Type!
                    
                    var capturedRestoreInitialStateDuration: TimeInterval!
                    var capturedRestoreInitialStateDelay: TimeInterval!
                    var capturedRestoreInitialStateDamping: CGFloat!
                    var capturedRestoreInitialStateVelocity: CGFloat!
                    var capturedRestoreInitialStateOptions: UIViewAnimationOptions!
                    var capturedRestoreInitialStateAnimations: (() -> Void)!
                    var capturedRestoreInitialStateCompletion: ((Bool) -> Void)!
                    
                    beforeEach {
                        viewClassMock = ViewMock.self
                        viewClassMock.springAnimationStub.on(any()) { duration, delay, damping, velocity, options, animations, completion in
                            capturedRestoreInitialStateDuration = duration
                            capturedRestoreInitialStateDelay = delay
                            capturedRestoreInitialStateDamping = damping
                            capturedRestoreInitialStateVelocity = velocity
                            capturedRestoreInitialStateOptions = options
                            capturedRestoreInitialStateAnimations = animations
                            capturedRestoreInitialStateCompletion = completion
                        }
                        sut.viewClass = viewClassMock
                        panGestureRecognizerMock = PanGestureRecognizerMock()
                        panGestureRecognizerMock.stateStub.on(any()) {
                            return .ended
                        }
                    }
                    
                    sharedExamples("returning to initial cell state animation") { (sharedExampleContext: @escaping SharedExampleContext) in
                        
                        it("should animate returning to initial cell state with duration 0.3") {
                            expect(capturedRestoreInitialStateDuration).to(equal(0.3))
                        }
                        
                        it("should animate returning to initial cell state without delay") {
                            expect(capturedRestoreInitialStateDelay).to(equal(sharedExampleContext()["expectedDelay"] as? TimeInterval))
                        }
                        
                        it("should animate returning to initial cell state with damping 0.6") {
                            expect(capturedRestoreInitialStateDamping).to(equal(0.6))
                        }
                        
                        it("should animate returning to initial cell state with velocity 0.9") {
                            expect(capturedRestoreInitialStateVelocity).to(equal(0.9))
                        }
                        
                        it("should animate returning to initial cell state with ease in out option") {
                            expect(capturedRestoreInitialStateOptions == UIViewAnimationOptions.curveEaseInOut).to(beTruthy())
                        }
                        
                        describe("restore initial state animations block") {
                            
                            beforeEach {
                                sut.shotImageView.transform = CGAffineTransform.identity.translatedBy(x: 100, y: 0)
                                capturedRestoreInitialStateAnimations()
                            }
                            
                            it("should restore shot image view identity tranform") {
                                
                                
                                expect(sut.shotImageView.transform).to(equal(CGAffineTransform.identity))
                            }
                        }
                        
                        describe("restore initial state completion block") {
                            
                            var delegateMock: ShotCollectionViewCellDelegateMock!
                            var didInformDelegateCellDidEndSwiping: Bool!
                            var capturedAction: ShotCollectionViewCell.Action!
                            
                            beforeEach {
                                sut.swipeCompletion = { action in
                                    capturedAction = action
                                }
                                delegateMock = ShotCollectionViewCellDelegateMock()
                                didInformDelegateCellDidEndSwiping = false
                                delegateMock.shotCollectionViewCellDidEndSwipingStub.on(any()) { _ in
                                    didInformDelegateCellDidEndSwiping = true
                                }
                                sut.delegate = delegateMock
                                sut.bucketImageView.isHidden = true
                                sut.commentImageView.isHidden = true
                                sut.likeImageView.firstImageView.alpha = 0
                                sut.likeImageView.secondImageView.alpha = 1
                                capturedRestoreInitialStateCompletion(true)
                            }
                            
                            it("should invoke swipe completion with Comment action") {
                                let actionWrapper = sharedExampleContext()["expectedAction"] as! ShotCollectionViewCellActionWrapper
                                expect(capturedAction).to(equal(actionWrapper.action))
                            }
                            
                            it("should inform delegate that cell did end swiping") {
                                expect(didInformDelegateCellDidEndSwiping).to(beTruthy())
                            }
                            
                            it("show bucket image view") {
                                expect(sut.bucketImageView.isHidden).to(beFalsy())
                            }
                            
                            it("show comment image view") {
                                expect(sut.commentImageView.isHidden).to(beFalsy())
                            }
                            
                            describe("like image view") {
                                
                                var likeImageView: DoubleImageView!
                                
                                beforeEach {
                                    likeImageView = sut.likeImageView
                                }
                                
                                it("should display first image view") {
                                    expect(likeImageView.firstImageView.alpha).to(equal(0))
                                }
                                
                                it("should hide second image view") {
                                    expect(likeImageView.secondImageView.alpha).to(equal(1))
                                }
                            }
                        }
                    }
                    
                    context("when user swiped") {
                        
                        var capturedActionDuration: TimeInterval!
                        var capturedActionDelay: TimeInterval!
                        var capturedActionOptions: UIViewAnimationOptions!
                        var capturedActionAnimations: (() -> Void)!
                        var capturedActionCompletion: ((Bool) -> Void)!
                        
                        beforeEach {
                            viewClassMock.animationStub.on(any()) { duration, delay, options, animations, completion in
                                capturedActionDuration = duration
                                capturedActionDelay = delay
                                capturedActionOptions = options
                                capturedActionAnimations = animations
                                capturedActionCompletion = completion
                            }
                        }
                        
                        context("slightly right") {
                            
                            beforeEach {
                                panGestureRecognizerMock.translationInViewStub.on(any()) { _ in
                                    return CGPoint(x: 50, y:0)
                                }
                                panGestureRecognizer!.specRecognize(with: panGestureRecognizerMock)
                            }
                            
                            it("should animate like action with duration 0.3") {
                                expect(capturedActionDuration).to(equal(0.3))
                            }
                            
                            it("should animate like action without delay") {
                                expect(capturedActionDelay).to(equal(0))
                            }
                            
                            it("should animate like action without options") {
                                expect(capturedActionOptions).to(equal([]))
                            }
                            
                            describe("like action animations block") {
                                
                                beforeEach {
                                    sut.contentView.bounds = CGRect(x: 0, y: 0, width: 100, height: 0)
                                    sut.likeImageView.alpha = 0
                                    capturedActionAnimations()
                                }
                                
                                it("should set shot image view tranform") {
                                    expect(sut.shotImageView.transform).to(equal(CGAffineTransform.identity.translatedBy(x: 100, y: 0)))
                                }
                                
                                describe("like image view") {
                                    
                                    var likeImageView: DoubleImageView!
                                    
                                    beforeEach {
                                        likeImageView = sut.likeImageView
                                    }
                                    
                                    it("should have alpha 1") {
                                        expect(likeImageView.alpha).to(equal(1.0))
                                    }
                                    
                                    it("should display second image view") {
                                        expect(likeImageView.secondImageView.alpha).to(equal(1))
                                    }
                                    
                                    it("should hide first image view") {
                                        expect(likeImageView.firstImageView.alpha).to(equal(0))
                                    }
                                }
                            }
                            
                            describe("like action completion block") {
                                
                                beforeEach {
                                    capturedActionCompletion(true)
                                }
                                
                                itBehavesLike("returning to initial cell state animation") {
                                    ["expectedDelay": 0.2,
                                     "expectedAction": ShotCollectionViewCellActionWrapper(action: ShotCollectionViewCell.Action.like)]
                                }
                            }
                        }
                        
                        context("considerably right") {
                            
                            beforeEach {
                                panGestureRecognizerMock.translationInViewStub.on(any()) { _ in
                                    return CGPoint(x: 150, y:0)
                                }
                                panGestureRecognizer!.specRecognize(with: panGestureRecognizerMock)
                            }
                            
                            it("should animate bucket action with duration 0.3") {
                                expect(capturedActionDuration).to(equal(0.3))
                            }
                            
                            it("should animate bucket action without delay") {
                                expect(capturedActionDelay).to(equal(0))
                            }
                            
                            it("should animate bucket action without options") {
                                expect(capturedActionOptions).to(equal([]))
                            }
                            
                            describe("bucket action animations block") {
                                
                                beforeEach {
                                    sut.contentView.bounds = CGRect(x: 0, y: 0, width: 100, height: 0)
                                    sut.bucketImageView.alpha = 0
                                    capturedActionAnimations()
                                }
                                
                                it("should set shot image view tranform") {
                                    expect(sut.shotImageView.transform).to(equal(CGAffineTransform.identity.translatedBy(x: 100, y: 0)))
                                }
                            }
                            
                            describe("bucket action completion block") {
                                
                                beforeEach {
                                    capturedActionCompletion(true)
                                }
                                
                                itBehavesLike("returning to initial cell state animation") {
                                    ["expectedDelay": 0.2,
                                     "expectedAction": ShotCollectionViewCellActionWrapper(action: ShotCollectionViewCell.Action.bucket)]
                                }
                            }
                        }
                        
                        context("slightly left") {
                            
                            beforeEach {
                                panGestureRecognizerMock.translationInViewStub.on(any()) { _ in
                                    return CGPoint(x: -50, y:0)
                                }
                                panGestureRecognizer!.specRecognize(with: panGestureRecognizerMock)
                            }
                            
                            it("should animate comment action with duration 0.3") {
                                expect(capturedActionDuration).to(equal(0.3))
                            }
                            
                            it("should animate comment action without delay") {
                                expect(capturedActionDelay).to(equal(0))
                            }
                            
                            it("should animate comment action without options") {
                                expect(capturedActionOptions).to(equal([]))
                            }
                            
                            describe("comment action animations block") {
                                
                                beforeEach {
                                    sut.contentView.bounds = CGRect(x: 0, y: 0, width: 100, height: 0)
                                    sut.commentImageView.alpha = 0
                                    capturedActionAnimations()
                                }
                                
                                it("should set shot image view tranform") {
                                    expect(sut.shotImageView.transform).to(equal(CGAffineTransform.identity.translatedBy(x: -100, y: 0)))
                                }
                            }
                            
                            describe("comment action completion block") {
                                
                                beforeEach {
                                    capturedActionCompletion(true)
                                }
                                
                                itBehavesLike("returning to initial cell state animation") {
                                    ["expectedDelay": 0.2,
                                     "expectedAction": ShotCollectionViewCellActionWrapper(action: ShotCollectionViewCell.Action.comment)]
                                }
                            }
                        }
                    }
                }
            }
            
            describe("gesture recognizer should begin") {
                
                context("when gesture recognizer is pan gesture recognizer") {
                    
                    context("when user is scrolling with higher horizontal velocity") {
                        
                        var gestureRecognizerShouldBegin: Bool!
                        
                        beforeEach {
                            let panGestureRecognize = PanGestureRecognizerMock()
                            panGestureRecognize.velocityInViewStub.on(any()) { _ in
                                return CGPoint(x:100, y:0)
                            }
                            gestureRecognizerShouldBegin = sut.gestureRecognizerShouldBegin(panGestureRecognize)
                        }
                        
                        it("should begin gesture recognizer") {
                            expect(gestureRecognizerShouldBegin).to(beTruthy())
                        }
                    }
                    
                    context("when user is scrolling with higher vertical velocity") {
                        
                        var gestureRecognizerShouldBegin: Bool!
                        
                        beforeEach {
                            let panGestureRecognize = PanGestureRecognizerMock()
                            panGestureRecognize.velocityInViewStub.on(any()) { _ in
                                return CGPoint(x:0, y:100)
                            }
                            gestureRecognizerShouldBegin = sut.gestureRecognizerShouldBegin(panGestureRecognize)
                        }
                        
                        it("should not begin gesture recognizer") {
                            expect(gestureRecognizerShouldBegin).to(beFalsy())
                        }
                    }
                }
            }
        }
        
        describe("reusable") {
            
            describe("reuse identifier") {
                
                var reuseIdentifier: String?
                
                beforeEach {
                    reuseIdentifier = ShotCollectionViewCell.identifier
                }
                
                it("should have proper reuse identifier") {
                    expect(reuseIdentifier).to(equal("ShotCollectionViewCell.Type"))
                }
            }
        }
        
        describe("gesture recognizer delegate") {
            
            describe("gesture recognize should should recognize simultaneously") {
                
                var shouldRecognizeSimultaneously: Bool!
                
                beforeEach {
                    shouldRecognizeSimultaneously = sut.gestureRecognizer(UIGestureRecognizer(), shouldRecognizeSimultaneouslyWith: UIGestureRecognizer())
                }
                
                it("should alwawys block other gesture recognizers") {
                    expect(shouldRecognizeSimultaneously).to(beFalsy())
                }
            }
        }
    }
}

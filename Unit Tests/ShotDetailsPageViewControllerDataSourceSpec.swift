//
//  ShotDetailsPageViewControllerDataSourceSpec.swift
//  Inbbbox
//
//  Created by Robert Abramczyk on 28/10/2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

@testable import Inbbbox

class ShotDetailsPageViewControllerDataSourceSpec: QuickSpec {
    
    override func spec() {
        
        var sut: ShotDetailsPageViewControllerDataSource!
        var shot: ShotType!
        var shotDetailsViewController: ShotDetailsViewController!
        var pageViewController: ShotDetailsPageViewController!
        
        context("when one shot is given") {
            beforeEach {
                shot = Shot.fixtureShot()
                shotDetailsViewController = ShotDetailsViewController(shot: shot)
                sut = ShotDetailsPageViewControllerDataSource(shots: [shot], initialViewController: shotDetailsViewController)
                pageViewController = ShotDetailsPageViewController(shotDetailsPageDataSource: sut)
            }
            
            afterEach {
                shot = nil
                shotDetailsViewController = nil
                sut = nil
                pageViewController = nil
            }
            
            describe("when newly initialized") {
                
                it("data source should have initial view controller") {
                    expect(sut.initialViewController).toNot(beNil())
                }
                
                it("data source should have correct initial view controller") {
                    expect(sut.initialViewController).to(equal(shotDetailsViewController))
                }
                
                it("initialViewController should have a correct index") {
                    expect(sut.initialViewController?.shotIndex).to(equal(0))
                }
            }
            
            describe("when providing data to UPageViewController") {
                
                it("nil should be returned when asking for view controller before index of 0") {
                    let controller = sut.pageViewController(pageViewController, viewControllerBefore: shotDetailsViewController)
                    expect(controller).to(beNil())
                }
                
                it("nil should be returned when asking for view controller after index of shots.count - 1") {
                    let controller = sut.pageViewController(pageViewController, viewControllerAfter: shotDetailsViewController)
                    expect(controller).to(beNil())
                }
            }
        }
        
        context("when multiple shots are provided") {
            beforeEach {
                shot = Shot.fixtureShot()
                shotDetailsViewController = ShotDetailsViewController(shot: shot)
                shotDetailsViewController.shotIndex = 1
                sut = ShotDetailsPageViewControllerDataSource(shots: [shot, shot, shot], initialViewController: shotDetailsViewController)
                pageViewController = ShotDetailsPageViewController(shotDetailsPageDataSource: sut)
            }
            
            afterEach {
                shot = nil
                shotDetailsViewController = nil
                sut = nil
                pageViewController = nil
            }
            
            describe("when newly initialized") {
                
                it("data source should have initial view controller") {
                    expect(sut.initialViewController).toNot(beNil())
                }
                
                it("data source should have correct initial view controller") {
                    expect(sut.initialViewController).to(equal(shotDetailsViewController))
                }
                
                it("initialViewController should have a correct index") {
                    expect(sut.initialViewController?.shotIndex).to(equal(1))
                }
            }
            
            describe("when providing data to UPageViewController") {
                
                describe("when asking for view controller before index greater than 0") {
                    
                    it("a new view controller should be returned") {
                        expect(sut.pageViewController(pageViewController, viewControllerBefore: shotDetailsViewController)).toNot(beNil())
                    }
                    
                    it("a new view controller different than initialViewController should be returned") {
                        expect(sut.pageViewController(pageViewController, viewControllerBefore: shotDetailsViewController)).toNot(equal(shotDetailsViewController))
                    }
                }
                
                describe("when asking for view controller after index less than shots.count - 1") {
                    
                    it("a new view controller should be returned") {
                        expect(sut.pageViewController(pageViewController, viewControllerAfter: shotDetailsViewController)).toNot(beNil())
                    }
                    
                    it("a new view controller different than initialViewController should be returned") {
                        expect(sut.pageViewController(pageViewController, viewControllerAfter: shotDetailsViewController)).toNot(equal(shotDetailsViewController))
                    }
                }
                
                describe("when asking for view controller with the same index as initialViewController") {
                    
                    it("the initialViewController shoulb be returned") {
                        expect(sut.pageViewController(pageViewController, viewControllerBefore: sut.pageViewController(pageViewController, viewControllerAfter: shotDetailsViewController)!)).to(equal(shotDetailsViewController))
                    }
                }
            }
        }
    }
}

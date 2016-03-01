//
//  LikesViewModelSpec.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 29.02.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

@testable import Inbbbox

class LikesViewModelSpec: QuickSpec {
    
    override func spec() {
        
        var sut: LikesViewModelMock!
        let fixtureImageURL = NSURL(string: "https://fixture.domain/fixture.image.normal.png")
        
        beforeEach {
           sut = LikesViewModelMock()
        }
        
        afterEach {
           sut = nil
        }
        
        describe("When initialized") {
            
            it("should have proper number of shots") {
                expect(sut.itemsCount).to(equal(0))
            }
        }
        
        describe("When downloading initial data") {
                
            beforeEach {
                sut.downloadInitialItems()
            }
                
            it("should have proper number of shots") {
                expect(sut.itemsCount).to(equal(2))
            }
            
            it("should return proper cell data for index path") {
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                let cellData = sut.shotCollectionViewCellViewData(indexPath)
                expect(cellData.animated).to(equal(true))
                expect(cellData.imageURL).to(equal(fixtureImageURL))
            }
        }
        
        describe("When downloading data for next page") {
            
            beforeEach {
                sut.downloadItemsForNextPage()
            }
            
            it("should have proper number of shots") {
                expect(sut.itemsCount).to(equal(3))
            }
            
            it("should return proper shot data for index path") {
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                let cellData = sut.shotCollectionViewCellViewData(indexPath)
                expect(cellData.animated).to(equal(true))
                expect(cellData.imageURL).to(equal(fixtureImageURL))
            }
        }
    }
}

//Explanation: Create LikesViewModelMock to override methods from BaseCollectionViewViewModel.

private class LikesViewModelMock: LikesViewModel {
 
    override func downloadInitialItems() {
        let shot = Shot.fixtureShot()
        self.likedShots = [shot, shot]
    }
    
    override func downloadItemsForNextPage() {
        let shot = Shot.fixtureShot()
        self.likedShots = [shot, shot, shot]
    }
}

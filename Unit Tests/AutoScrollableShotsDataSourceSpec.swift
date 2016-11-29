//
//  AutoScrollableShotsDataSourceSpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 30/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

@testable import Inbbbox

class AutoScrollableShotsDataSourceSpec: QuickSpec {
    override func spec() {
        
        var sut: AutoScrollableShotsDataSource!
        
        describe("when initializing with content and collection view") {
            
            var collectionView: UICollectionView!
            let content = [
                UIImage.referenceImageWithColor(.green),
                UIImage.referenceImageWithColor(.yellow),
                UIImage.referenceImageWithColor(.red)
            ]
            
            beforeEach {
                collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 200), collectionViewLayout: UICollectionViewFlowLayout())
                sut = AutoScrollableShotsDataSource(collectionView: collectionView, content: content)
            }
            
            afterEach {
                sut = nil
                collectionView = nil
            }
            
            it("collection view should be same") {
                expect(sut!.collectionView).to(equal(collectionView))
            }
            
            it("collection view datasource should be properly set") {
                expect(sut.collectionView.dataSource!) === sut
            }
            
            it("collection view delegate should be properly set") {
                expect(sut.collectionView.delegate!) === sut
            }

            it("collection view item size should be correct") {
                expect(sut.itemSize).to(equal(CGSize(width: 100, height: 100)))
            }
            
            it("collection view should have exactly 1 section") {
                expect(sut.collectionView.numberOfSections).to(equal(1))
            }
            
            it("collection view should have proper cell class") {
                let indexPath = IndexPath(item: 0, section: 0)
                expect(sut.collectionView.dataSource!.collectionView(sut.collectionView, cellForItemAt: indexPath)).to(beAKindOf(AutoScrollableCollectionViewCell.self))
            }
            
            describe("and showing content") {
                
                context("with preparing for animation") {
                    
                    beforeEach {
                        sut.prepareForAnimation()
                    }
                    
                    it("collection view should have exactly 1 section") {
                        expect(sut.collectionView.numberOfItems(inSection: 0)).to(equal(7))
                    }
                    
                    it("extended content should be 2") {
                        expect(sut.extendedScrollableItemsCount).to(equal(2))
                    }
                }
                
                context("without preparing for animation") {
                    
                    it("collection view should have exactly 1 section") {
                        expect(sut.collectionView.numberOfItems(inSection: 0)).to(equal(content.count))
                    }
                }
                
                context("for first cell") {
                    
                    it("image should be same as first in content") {
                        let indexPath = IndexPath(item: 0, section: 0)
                        let cell = sut.collectionView.dataSource!.collectionView(sut.collectionView, cellForItemAt: indexPath) as! AutoScrollableCollectionViewCell
                        
                        expect(cell.imageView.image).to(equal(content.first!))
                    }
                }
            }
        }
    }
}

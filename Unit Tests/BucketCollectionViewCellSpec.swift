//
//  BucketCollectionViewCellSpec.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 25.01.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

@testable import Inbbbox

class BucketCollectionViewCellSpec: QuickSpec {

    override func spec() {
        
        describe("reusable") {
            
            describe("reuse identifier") {
                
                var reuseIdentifier: String?
                
                beforeEach {
                    reuseIdentifier = BucketCollectionViewCell.identifier
                }
                
                it("should have proper reuse identifier") {
                    expect(reuseIdentifier).to(equal("BucketCollectionViewCell.Type"))
                }
            }
        }
    }
}

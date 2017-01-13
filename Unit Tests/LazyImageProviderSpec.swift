//
//  LazyImageProviderSpec.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import Mockingjay

@testable import Inbbbox

class LazyImageProviderSpec: QuickSpec {
    
    override func spec() {
        let thumbUrlString = "https://fixture.com/thumnail.jpg"
        let normalUrlString = "https://fixture.com/normal.jpg"
        let hidpiUrlString = "https://fixture.com/hidpi.jpg"
        
        let thumb = UIImagePNGRepresentation(UIImage(color: .red)!)!
        let normal = UIImagePNGRepresentation(UIImage(color: .blue)!)!
        let hidpi = UIImagePNGRepresentation(UIImage(color: .green)!)!
        
        describe("downloading images") {
            
            context("images should be returned") {
                beforeEach {
                    self.stub(uri(thumbUrlString), http(200, headers: nil, download: .content(thumb)))
                    self.stub(uri(normalUrlString), http(200, headers: nil, download: .content(normal)))
                    self.stub(uri(hidpiUrlString), http(200, headers: nil, download: .content(hidpi)))
                }
            
                it("in correct order") {
                    var returnedImages = 0
                    LazyImageProvider.lazyLoadImageFromURLs(
                        (URL(string: thumbUrlString)!, URL(string: normalUrlString)!, URL(string: hidpiUrlString)!),
                        teaserImageCompletion: { image in
                            expect(image).toNot(beNil())
                            expect(returnedImages).to(equal(0))
                            returnedImages += 1
                        },
                        normalImageCompletion: { image in
                            expect(image).toNot(beNil())
                            expect(returnedImages).to(equal(1))
                            returnedImages += 1
                        },
                        hidpiImageCompletion: { image in
                            expect(image).toNot(beNil())
                            expect(returnedImages).to(equal(2))
                            returnedImages += 1
                        })
                    expect(returnedImages).toEventually(equal(3))
                }
            }
            
        }
        
    }

}

private extension UIImage {

    func equals(image: UIImage) -> Bool {
        let dataFirst = UIImagePNGRepresentation(self)
        let dataSecond = UIImagePNGRepresentation(image)
        
        return dataFirst == dataSecond
    }
}

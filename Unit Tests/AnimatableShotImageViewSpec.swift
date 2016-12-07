//
//  ShotDetailsViewControllerSpec.swift
//  Inbbbox
//
//  Created by Blazej Wdowikowski on 12/6/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import Mockingjay
import Haneke

@testable import Inbbbox

class AnimatableShotImageViewSpec: QuickSpec {
    override func spec() {
        
        var imageView: AnimatableShotImageView!
        
        beforeEach {
            imageView = AnimatableShotImageView(frame: .zero)
        }
        
        afterEach {
            imageView = nil
        }
        
        
        describe("when loading new imgae") {
            
            var shot: ShotType!
            var imageData: Data!
            var url: URL!
            
            beforeEach {
                shot = Shot.fixtureGifShotWithIdentifier("fixture gif shot")
                imageData = UIImagePNGRepresentation(#imageLiteral(resourceName: "ic-ball"))!
                url = shot.shotImage.normalURL
                Shared.dataCache.removeAll()
            }
            
            afterEach {
                shot = nil
                imageData = nil
                url = nil
            }
            
            it("should download image only once with same given url ") {
                
                imageView.loadAnimatableShotFromUrl(url)
                imageView.loadAnimatableShotFromUrl(url)
                
                expect(imageView.downloader.tasks).toEventually(haveCount(1))
            }
            
            it("shouldn't have tasks after download completion") {
                
                self.stub(uri(url.absoluteString), http(200, headers: nil, download: .content(imageData)))
                
                imageView.loadAnimatableShotFromUrl(url)
            
                expect(imageView.downloader.tasks).toEventually(haveCount(0))
            }
            
        }
    }
}

//
//  ShotImage.swift
//  Inbbbox
//
//  Created by Kamil Tomaszewski on 05/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON


/**
 Shot image URL.
 
 - hidpiURL: url of image with resolution 800x600. May not be present.
 - normalURL: url of image with typical resolution 400x300. May be smaller if created before October 4th, 2012.
 - teaserURL: url of image with typical resolution 200x150. May be smaller if created before October 4th, 2012.
 */

struct ShotImage: ShotImageType {
    let hidpiURL: NSURL?
    let normalURL: NSURL
    let teaserURL: NSURL
}

extension ShotImage: Mappable {
    static var map: JSON -> ShotImage {
        return { json in
            ShotImage(
                hidpiURL: json[Key.Hidpi.rawValue].URL,
                normalURL: json[Key.Normal.rawValue].URL!,
                teaserURL: json[Key.Teaser.rawValue].URL!
            )
        }
    }
    
    private enum Key: String {
        case Hidpi = "hidpi"
        case Normal = "normal"
        case Teaser = "teaser"
    }
}

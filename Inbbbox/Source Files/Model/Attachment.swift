//
//  Attachment.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 15.11.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Attachment {
    let identifier: String
    let thumbnailURL: URL?
    let imageURL: URL?
}

extension Attachment: Mappable {
    
    static var map: (JSON) -> Attachment {
        return { json in
            
            return Attachment(identifier: json[Key.Identifier.rawValue].stringValue,
                               thumbnailURL: json[Key.ThumbnailURL.rawValue].url,
                               imageURL: json[Key.ImageURL.rawValue].url)
        }
    }
    
    fileprivate enum Key: String {
        case Identifier = "id"
        case ThumbnailURL = "thumbnail_url"
        case ImageURL = "url"
    }
}

//
//  ManagedShotImage.swift
//  Inbbbox
//
//  Created by Lukasz Wolanczyk on 2/17/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import CoreData

class ManagedShotImage: NSManagedObject {

    @NSManaged var mngd_hidpiURL: String?
    @NSManaged var mngd_normalURL: String
    @NSManaged var mngd_teaserURL: String
}

extension ManagedShotImage: ShotImageType {

    var hidpiURL: URL? {
        guard let encodedString = mngd_hidpiURL?.addingPercentEncoding(
        withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return nil
        }
        return URL(string: encodedString)
    }
    var normalURL: URL {
        let encodedString = mngd_normalURL.addingPercentEncoding(
        withAllowedCharacters: CharacterSet.urlQueryAllowed)
        return URL(string: encodedString!)!

    }
    var teaserURL: URL {
        let encodedString = mngd_teaserURL.addingPercentEncoding(
        withAllowedCharacters: CharacterSet.urlQueryAllowed)
        return URL(string: encodedString!)!
    }
}

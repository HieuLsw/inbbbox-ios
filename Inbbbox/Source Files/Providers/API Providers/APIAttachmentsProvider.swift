//
//  APIAttachmentsProvider.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 15.11.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

class APIAttachmentsProvider: PageableProvider {
    
    /**
     Provides attachments for given shot.
     
     - parameter shot: Shot which attachments we want to download
     
     - returns: Promise which resolves with attachments or nil.
     */
    func provideAttachmentsForShot(shot: ShotType) -> Promise<[Attachment]?> {
        let query = AttachmentQuery(shot: shot)
        return Promise<[Attachment]?> { fulfill, reject in
            firstly {
                firstPageForQueries([query], withSerializationKey: nil)
            }.then { (attachments: [Attachment]?) -> Void in
                fulfill(attachments.flatMap { $0.map { $0 as Attachment } })
            }.error(reject)
        }
    }
}

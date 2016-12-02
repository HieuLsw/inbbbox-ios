//
//  SimpleShotsViewModel.swift
//  Inbbbox
//
//  Created by Peter Bruz on 13/04/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

protocol SimpleShotsViewModel: BaseCollectionViewViewModel {

    var title: String { get }
    var shots: [ShotType] { get set }

    func emptyCollectionDescriptionAttributes() -> EmptyCollectionViewDescription
    func shotCollectionViewCellViewData(_ indexPath: IndexPath) -> (shotImage: ShotImageType, animated: Bool)
    func clearViewModelIfNeeded()
}

struct EmptyCollectionViewDescription {

    var firstLocalizedString: String
    var attachmentImageName: String
    var imageOffset: CGPoint
    var lastLocalizedString: String
}

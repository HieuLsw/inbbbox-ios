//
//  BucketContentViewModel.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 15.03.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit


class BucketContentViewModel: SimpleShotsViewModel {

    weak var delegate: BaseCollectionViewViewModelDelegate?
    var shots = [ShotType]()
    private let shotsProvider = ShotsProvider()
    private var userMode: UserMode
    private var bucket: BucketType

    var itemsCount: Int {
        return shots.count
    }

    var title: String {
        return bucket.name
    }

    init(bucket: BucketType) {
        userMode = UserStorage.isUserSignedIn ? .LoggedUser : .DemoUser
        self.bucket = bucket
    }

    func downloadInitialItems() {
        firstly {
            shotsProvider.provideShotsForBucket(self.bucket)
        }.then { shots -> Void in
            if let shots = shots where shots != self.shots {
                self.shots = shots
            }
            self.delegate?.viewModelDidLoadInitialItems()
        }.error { error in
            self.delegate?.viewModelDidFailToLoadInitialItems(error)
        }
    }

    func downloadItemsForNextPage() {
        guard UserStorage.isUserSignedIn else {
            return
        }
        firstly {
            shotsProvider.nextPage()
        }.then { shots -> Void in
            if let shots = shots where shots.count > 0 {
                let indexes = shots.enumerate().map { index, _ in
                    return index + self.shots.count
                }
                self.shots.appendContentsOf(shots)
                let indexPaths = indexes.map {
                    NSIndexPath(forRow:($0), inSection: 0)
                }
                self.delegate?.viewModel(self, didLoadItemsAtIndexPaths: indexPaths)
            }
        }.error { error in
            self.notifyDelegateAboutFailure(error)
        }
    }

    func emptyCollectionDescriptionAttributes() -> EmptyCollectionViewDescription {
        let description = EmptyCollectionViewDescription(
            firstLocalizedString: NSLocalizedString("BucketContent.EmptyData.FirstLocalizedString",
                comment: "BucketContentCollectionView, empty data set view"),
            attachmentImageName: ColorModeProvider.current().emptyBucketImageName,
            imageOffset: CGPoint(x: 0, y: -4),
            lastLocalizedString: NSLocalizedString("BucketContent.EmptyData.LastLocalizedString",
                comment: "BucketContentCollectionView, empty data set view")
        )
        return description
    }

    func shotCollectionViewCellViewData(indexPath: NSIndexPath) -> (shotImage: ShotImageType, animated: Bool) {
        let shotImage = shots[indexPath.row].shotImage
        let animated = shots[indexPath.row].animated
        return (shotImage, animated)
    }

    func clearViewModelIfNeeded() {
        let currentUserMode = UserStorage.isUserSignedIn ? UserMode.LoggedUser : .DemoUser
        if userMode != currentUserMode {
            shots = []
            userMode = currentUserMode
            delegate?.viewModelDidLoadInitialItems()
        }
    }
}

//
//  FolloweesViewModel.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 26.02.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

class FolloweesViewModel: BaseCollectionViewViewModel {

    weak var delegate: BaseCollectionViewViewModelDelegate?
    let title = NSLocalizedString("FolloweesViewModel.Title", comment:"Title of Following screen")
    var followees = [Followee]()
    var followeesIndexedShots = [Int: [ShotType]]()
    fileprivate let teamsProvider = APITeamsProvider()
    fileprivate let connectionsProvider = APIConnectionsProvider()
    fileprivate let shotsProvider = ShotsProvider()
    fileprivate var userMode: UserMode
    fileprivate var followeesDuringDownload = [Followee]()

    fileprivate let netguruTeam = Team(identifier: "653174", name: "", username: "", avatarURL: nil, createdAt: Date(), followersCount: 0, followingsCount: 0, bio: "", location: "")

    var itemsCount: Int {
        return followees.count
    }

    init() {
        userMode = UserStorage.isUserSignedIn ? .loggedUser : .demoUser
    }

    func downloadInitialItems() {

        firstly {
            UserStorage.isUserSignedIn ?
                    connectionsProvider.provideMyFollowees() : teamsProvider.provideMembersForTeam(netguruTeam)
        }.then { followees -> Void in
            if let followees = followees, followees != self.followees || followees.count == 0 {
                self.followees = followees
                self.delegate?.viewModelDidLoadInitialItems()
            }
        }.catch { error in
            self.delegate?.viewModelDidFailToLoadInitialItems(error)
        }
    }
    
    func downloadItemsForNextPage() { /* empty */ }
    
    func downloadItem(at index: Int) {
        guard followees.count > index else { return }
        let followee = followees[index]
        guard !followeesDuringDownload.contains(where: { (f) -> Bool in return f == followee }) else { return }
        
        downloadShots(for: followee)
    }

    func followeeCollectionViewCellViewData(_ indexPath: IndexPath) -> FolloweeCollectionViewCellViewData {
        return FolloweeCollectionViewCellViewData(followee: followees[indexPath.row],
                shots: followeesIndexedShots[indexPath.row])
    }

    func clearViewModelIfNeeded() {
        let currentUserMode = UserStorage.isUserSignedIn ? UserMode.loggedUser : .demoUser
        if userMode != currentUserMode {
            followees = []
            userMode = currentUserMode
            delegate?.viewModelDidLoadInitialItems()
        }
    }
}

private extension FolloweesViewModel {
    
    func downloadShots(for followees: [Followee]) {
        for followee in followees {
            downloadShots(for: followee)
        }
    }
    
    func downloadShots(for followee: Followee) {
        followeesDuringDownload.append(followee)
        firstly {
            shotsProvider.provideShotsForUser(followee)
        }.then { shots -> Void in
            var indexOfFollowee: Int?
            for (index, item) in self.followees.enumerated() {
                if item.identifier == followee.identifier {
                    indexOfFollowee = index
                    break
                }
            }
            guard let index = indexOfFollowee else {
                return
            }
            if let shots = shots {
                self.followeesIndexedShots[index] = shots
            } else {
                self.followeesIndexedShots[index] = [ShotType]()
            }
            let indexPath = IndexPath(row: index, section: 0)
            self.delegate?.viewModel(self, didLoadShotsForItemAtIndexPath: indexPath)
        }.catch { error in
            self.notifyDelegateAboutFailure(error)
        }.always {
            self.removeFromFolloweesDuringDownload(followee)
        }
    }
    
    func removeFromFolloweesDuringDownload(_ followee: Followee) {
        guard let indexForRemove = followeesDuringDownload.index(where: { (f) -> Bool in return f == followee }) else { return }
        followeesDuringDownload.remove(at: indexForRemove)
    }
}

extension FolloweesViewModel {

    struct FolloweeCollectionViewCellViewData {
        let name: String?
        let avatarURL: URL?
        let numberOfShots: String
        let shotsImagesURLs: [URL]?
        let firstShotImage: ShotImageType?

        init(followee: Followee, shots: [ShotType]?) {
            self.name = followee.name
            self.avatarURL = followee.avatarURL as URL?
            self.numberOfShots = String.localizedStringWithFormat(NSLocalizedString("%d shots",
                    comment: "How many shots in collection?"), followee.shotsCount)
            if let shots = shots, shots.count > 0 {
                let allShotsImagesURLs = shots.map {
                    $0.shotImage.teaserURL
                }
                switch allShotsImagesURLs.count {
                case 1:
                    shotsImagesURLs = [allShotsImagesURLs[0] as URL, allShotsImagesURLs[0] as URL,
                                       allShotsImagesURLs[0] as URL, allShotsImagesURLs[0] as URL]
                case 2:
                    shotsImagesURLs = [allShotsImagesURLs[0] as URL, allShotsImagesURLs[1] as URL,
                                       allShotsImagesURLs[1] as URL, allShotsImagesURLs[0] as URL]
                case 3:
                    shotsImagesURLs = [allShotsImagesURLs[0] as URL, allShotsImagesURLs[1] as URL,
                                       allShotsImagesURLs[2] as URL, allShotsImagesURLs[0] as URL]
                default:
                    shotsImagesURLs = [allShotsImagesURLs[0] as URL, allShotsImagesURLs[1] as URL,
                                       allShotsImagesURLs[2] as URL, allShotsImagesURLs[3] as URL]
                }
                firstShotImage = shots[0].shotImage
            } else {
                self.shotsImagesURLs = nil
                self.firstShotImage = nil
            }
        }
    }

}

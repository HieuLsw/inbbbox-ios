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
    let title = Localized("FolloweesViewModel.Title", comment:"Title of Following screen")
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
                    connectionsProvider.provideMyFollowees() : teamsProvider.provideMembers(forTeam: netguruTeam)
        }.then { followees -> Void in
            if let followees = followees {

                firstly {
                    self.removeBlockedUsers(followees)
                }.then { filteredFollowees -> Void in
                    if let filteredFollowees = filteredFollowees, filteredFollowees != self.followees || filteredFollowees.count == 0 {
                        self.followees = filteredFollowees
                    }
                }.then {
                    self.delegate?.viewModelDidLoadInitialItems()
                }.catch { _ in }
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

    func removeBlockedUsers(_ followees: [Followee]) -> Promise<[Followee]?> {
        return Promise<[Followee]?> { fulfill, reject in

            firstly {
                UsersProvider().provideBlockedUsers()
            }.then { users -> Void in
                if let blockedUsers = users {
                    let filteredFollowees = followees.filter({ (followee) -> Bool in
                        let authors = blockedUsers.filter { $0.identifier == followee.identifier }
                        return authors.count == 0
                    })
                    fulfill(filteredFollowees)
                } else {
                    fulfill(followees)
                }
            }.catch(execute: reject)
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
        }.catch { _ in }
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
            self.numberOfShots = String.localizedStringWithFormat(Localized("%d shots",
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

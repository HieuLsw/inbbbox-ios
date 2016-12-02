//
//  ProfileViewModel.swift
//  Inbbbox
//
//  Created by Peter Bruz on 05/05/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

protocol ProfileViewModel: BaseCollectionViewViewModel {

    var title: String { get }
    var avatarURL: URL? { get }
    var shouldShowFollowButton: Bool { get }
    var collectionIsEmpty: Bool { get }

    func isProfileFollowedByMe() -> Promise<Bool>
    func followProfile() -> Promise<Void>
    func unfollowProfile() -> Promise<Void>
}

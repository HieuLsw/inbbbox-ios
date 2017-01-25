//
//  ProfileShotsOrMembersViewModel.swift
//  Inbbbox
//
//  Created by Peter Bruz on 05/05/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

protocol ProfileShotsOrMembersViewModel: BaseCollectionViewViewModel {
    var collectionIsEmpty: Bool { get }
}

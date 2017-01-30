//
//  FlashMessageTitles.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 10.11.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct FlashMessageTitles {
    
    static var bucketCreationFailed: String {
        return Localized("BucketsCollectionViewController.NewBucketFail", comment: "Displayed when creating new bucket fails.")
    }

    static var bucketProcessingFailed: String {
        return Localized("ShotDetailsViewController.BucketError", comment: "Error while adding/removing shot to bucket.")
    }

    static var deleteCommentFailed: String {
        return Localized("ShotDetailsViewController.RemovingCommentError", comment: "Error while removing comment.")
    }

    static var addingCommentFailed: String {
        return Localized("ShotDetailsViewController.AddingCommentError", comment: "Error while adding comment.")
    }

    static var downloadingShotsFailed: String {
        return Localized("UIAlertControllerExtension.UnableToDownloadShots", comment: "Informing user about problems with downloading shots.")
    }

    static var downloadingTeamsFailed: String {
        return Localized("UIAlertControllerExtension.UnableToDownloadTeams", comment: "Informing user about problems with downloading teams.")
    }

    static var tryAgain: String {
        return Localized("UIAlertControllerExtension.TryAgain", comment: "Allows user to try again after error occurred.")
    }
}

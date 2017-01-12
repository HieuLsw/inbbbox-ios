//
//  FlashMessageTitles.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 10.11.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct FlashMessageTitles {
    
    static let bucketCreationFailed = NSLocalizedString("BucketsCollectionViewController.NewBucketFail",
                                       comment: "Displayed when creating new bucket fails.")
    static let bucketProcessingFailed = NSLocalizedString("ShotDetailsViewController.BucketError",
                                         comment: "Error while adding/removing shot to bucket.")
    static let deleteCommentFailed = NSLocalizedString("ShotDetailsViewController.RemovingCommentError",
                                      comment: "Error while removing comment.")
    static let addingCommentFailed = NSLocalizedString("ShotDetailsViewController.AddingCommentError",
                                      comment: "Error while adding comment.")
    static let downloadingShotsFailed = NSLocalizedString("UIAlertControllerExtension.UnableToDownloadShots",
                                         comment: "Informing user about problems with downloading shots.")
    static let downloadingTeamsFailed = NSLocalizedString("UIAlertControllerExtension.UnableToDownloadTeams",
            comment: "Informing user about problems with downloading teams.")
    static let tryAgain = NSLocalizedString("UIAlertControllerExtension.TryAgain",
                                            comment: "Allows user to try again after error occurred.")
}

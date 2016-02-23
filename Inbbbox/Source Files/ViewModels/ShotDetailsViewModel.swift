//
//  ShotDetailsViewModel.swift
//  Inbbbox
//
//  Created by Peter Bruz on 18/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

protocol ShotDetailsViewModelDelegate: class {
    func performBatchUpdate(insertIndexPaths: [NSIndexPath], reloadIndexPaths: [NSIndexPath], deleteIndexPaths: [NSIndexPath])
    func presentAlertController(controller: UIAlertController)
}

class ShotDetailsViewModel {
    
    // Public properties
    weak var delegate: ShotDetailsViewModelDelegate?
    
    var commentsCount: Int {
        return comments.count
    }
    
    var itemsCount: Int {
        guard comments.count > 0 else { return 0 }
        
        return comments.count >= Int(shot.commentsCount) ? comments.count : comments.count + 1
    }
    
    var compactVariantCanBeDisplayed: Bool {
        return itemsCount >= changingHeaderStyleCommentsThreshold
    }
    
    // Comment requester and provider
    var commentsProvider = CommentsProvider(page: 1, pagination: 20)
    var commentsRequester = CommentsRequester()
    
    // Private
    
    private let shot: Shot
    private var comments = [Comment]()
    private let changingHeaderStyleCommentsThreshold = 3
    
    //Storages
    private let localStorage = ShotsLocalStorage()
    private let userStorageClass = UserStorage.self
    
    // Requesters
    private let shotsRequester =  ShotsRequester()
    
    // Formatters
    private let shotDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        return formatter
    }()
    
    private let commentDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    init(shot: Shot) {
        self.shot = shot
    }
    
    // Comments methods
    
    func loadComments(completion: (Result) -> Void) {
        
        if comments.count == 0 {
            firstly {
                self.commentsProvider.provideCommentsForShot(shot)
            }.then { comments -> Void in
                self.comments = comments ?? []
            }.then {
                completion(Result.Success)
            }.error { error in
                completion(Result.Error(error))
            }
        } else {
            firstly {
                self.commentsProvider.nextPage()
            }.then { comments -> Void in
                self.appendCommentsAndUpdateCollectionView(comments! as [Comment])
            }.then {
                completion(Result.Success)
            }.error { error in
                completion(Result.Error(error))
            }
        }
    }
    
    func postComment(message: String, completion: (Result) -> Void) {
        
        firstly {
            commentsRequester.postCommentForShot(shot, withText: message)
        }.then { comment in
            self.comments.append(comment)
        }.then {
            completion(Result.Success)
        }.error { error in
            completion(Result.Error(error))
        }
    }
    
    // Shot methods
    
    func userDidTapLikeButton(like: Bool, completion: (Result) -> Void) {
        
        let operationClosure = {
            if self.userStorageClass.currentUser != nil {
                firstly {
                    like ? self.shotsRequester.likeShot(self.shot) : self.shotsRequester.unlikeShot(self.shot)
                    }.then {
                        completion(Result.Success)
                    }.error { error in
                        completion(Result.Error(error))
                }
            } else {
                do {
                    like ? try self.localStorage.like(shotID: self.shot.identifier) : try self.localStorage.unlike(shotID: self.shot.identifier)
                    completion(Result.Success)
                } catch {
                    completion(Result.Error(error))
                }
            }
        }
        
        if like {
            operationClosure()
        } else {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel) { _ in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            }
            
            let unlikeAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Unlike", comment: ""), style: .Destructive) { _ in
                operationClosure()
            }
            alertController.addAction(cancelAction)
            alertController.addAction(unlikeAction)
            delegate?.presentAlertController(alertController)
        }
    }
    
    // Provide viewData methods
    
    func viewDataForHeader(completion: (Result, HeaderViewData?) -> Void) {
        var shotLiked: Bool?
        var headerViewData: HeaderViewData?
        firstly{
            self.isShotLikedByMe()
            }.then { liked in
                shotLiked = liked
            }.then {
                headerViewData = HeaderViewData(
                    description: self.shot.description?.mutableCopy() as? NSMutableAttributedString,
                    title: self.shot.title!,
                    author: self.shot.user.name ?? self.shot.user.username,
                    client: self.shot.team?.name,
                    shotInfo: self.shotDateFormatter.stringFromDate(self.shot.createdAt),
                    shot: self.shot.image.normalURL.absoluteString,
                    avatar: self.shot.user.avatarString!,
                    shotLiked: shotLiked!,
                    shotInBuckets: true // NGRTodo: provide this information
                )
            }.then {
                completion(Result.Success, headerViewData)
            }.error {error in
                completion(Result.Error(error), nil)
        }
    }
    
    func viewDataForCellAtIndex(index: Int) -> ShotDetailsViewModel.DetailsCollectionViewCellViewData {
        let comment = comments[index]
        return DetailsCollectionViewCellViewData(
            avatar: comment.user.avatarString!,
            author: comment.user.name ?? comment.user.username,
            comment: comment.body?.mutableCopy() as? NSMutableAttributedString ?? NSMutableAttributedString(),
            time: commentDateFormatter.stringFromDate(comment.createdAt)
        )
    }
    
    func viewDataForLoadMoreCell() -> ShotDetailsViewModel.LoadMoreCellViewData {
        let difference = Int(shot.commentsCount) - commentsCount
        return LoadMoreCellViewData(
            commentsCount: difference > Int(commentsProvider.pagination) ? Int(commentsProvider.pagination).stringValue : difference.stringValue
        )
    }
}

private extension ShotDetailsViewModel {
    
    // Comments methods
    func appendCommentsAndUpdateCollectionView(comments: [Comment]) {
        
        let currentCommentCount = self.comments.count
        let possibleLoadMoreCellIndexPath:NSIndexPath? =  {
            if commentsCount < itemsCount {
                return NSIndexPath(forItem: currentCommentCount, inSection: 0)
            } else {
                return nil
            }
        }()
        
        var indexPathsToInsert = [NSIndexPath]()
        var indexPathsToReload = [NSIndexPath]()
        var indexPathsToDelete = [NSIndexPath]()
        
        self.comments.appendContentsOf(comments)
        
        for i in currentCommentCount..<self.comments.count {
            indexPathsToInsert.append(NSIndexPath(forItem: i, inSection: 0))
        }
        if let loadMoreCellIndexPath = possibleLoadMoreCellIndexPath {
            if self.comments.count < Int(shot.commentsCount) {
                indexPathsToReload.append(loadMoreCellIndexPath)
            } else {
                indexPathsToDelete.append(loadMoreCellIndexPath)
            }
        }
        
        delegate?.performBatchUpdate(indexPathsToInsert, reloadIndexPaths: indexPathsToReload, deleteIndexPaths: indexPathsToDelete)
    }
    
    // Shot methods
    func isShotLikedByMe() -> Promise<Bool> {
    
        return Promise<Bool> { fulfill, reject in
            
            if self.userStorageClass.currentUser != nil {
                firstly {
                    shotsRequester.isShotLikedByMe(shot)
                }.then { liked in
                    fulfill(liked)
                }.error { error in
                    reject(error)
                }
            } else {
                let liked = localStorage.likedShots.contains{
                    $0.id == shot.identifier
                }
                fulfill(liked)
            }
        }
    }
}

extension ShotDetailsViewModel {
    
    struct HeaderViewData {
        let description: NSMutableAttributedString?
        let title: String
        let author: String
        let client: String?
        let shotInfo: String
        let shot: String
        let avatar: String
        let shotLiked: Bool
        let shotInBuckets: Bool
    }
    
    struct DetailsCollectionViewCellViewData {
        let avatar: String
        let author: String
        let comment: NSMutableAttributedString
        let time: String
    }
    
    struct LoadMoreCellViewData {
        let commentsCount: String
    }
}

enum Result {
    case Success
    case Error(ErrorType)
}

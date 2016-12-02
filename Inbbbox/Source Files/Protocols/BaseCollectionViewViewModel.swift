//
//  BaseCollectionViewViewModel.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 26.02.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

protocol BaseCollectionViewViewModel {

    weak var delegate: BaseCollectionViewViewModelDelegate? { get set }
    var itemsCount: Int { get }

    func downloadInitialItems()
    func downloadItemsForNextPage()
}

protocol BaseCollectionViewViewModelDelegate: class {

    func viewModelDidLoadInitialItems()
    func viewModelDidFailToLoadInitialItems(_ error: Error)
    func viewModelDidFailToLoadItems(_ error: Error)
    func viewModel(_ viewModel: BaseCollectionViewViewModel, didLoadItemsAtIndexPaths indexPaths: [IndexPath])
    func viewModel(_ viewModel: BaseCollectionViewViewModel, didLoadShotsForItemAtIndexPath indexPath: IndexPath)
}

extension BaseCollectionViewViewModelDelegate {

    func viewModel(_ viewModel: BaseCollectionViewViewModel, didLoadShotsForItemAtIndexPath indexPath: IndexPath) {
        // Empty by design - optional function.
    }
}

extension BaseCollectionViewViewModel {

    func notifyDelegateAboutFailure(_ error: Error) {
        if let downloadError = error as? PageableProviderError {
            if downloadError != .didReachLastPage {
                self.delegate?.viewModelDidFailToLoadItems(error)
            }
        } else {
            self.delegate?.viewModelDidFailToLoadItems(error)
        }
    }
}

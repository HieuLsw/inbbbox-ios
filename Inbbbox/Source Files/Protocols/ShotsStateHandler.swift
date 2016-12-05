//
//  ShotsStateHandler.swift
//  Inbbbox
//
//  Created by Lukasz Wolanczyk on 3/22/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

protocol ShotsStateHandlerDelegate: class {

    /// This method is called to inform object conforming to this protocol to configure for next state
    ///
    /// - parameter shotsStateHandler: Instance of ShotsStateHandler2
    func shotsStateHandlerDidInvalidate(shotsStateHandler: ShotsStateHandler)

    /// Optional method, called to inform delegate about failure.
    /// - parameter error: Describes failure.
    func shotsStateHandlerDidFailToFetchItems(error: ErrorType)
}

extension ShotsStateHandlerDelegate {
    func shotsStateHandlerDidFailToFetchItems(error: ErrorType) {
        // Optional delegate method.
    }
}

/// Holds configuration for specific ShotsCollectionViewController.State
protocol ShotsStateHandler: UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {

    /// Can be used in some methods.
    weak var shotsCollectionViewController: ShotsCollectionViewController? { get set }

    /// The ShotsStateHandler's delegate object.
    weak var delegate: ShotsStateHandlerDelegate? { get set }

    /// State which this handler represents.
    var state: ShotsCollectionViewController.State { get }

    /// State that will be after current state is invalidated.
    var nextState: ShotsCollectionViewController.State? { get }

    /// Enables/Disables user interaction on tab bar.
    var tabBarInteractionEnabled: Bool { get }

    /// Alpha value for tab bar.
    var tabBarAlpha: CGFloat { get }

    /// Collection view layout for current state.
    var collectionViewLayout: UICollectionViewLayout { get }

    /// Enables/Disables user interaction on collection view.
    var collectionViewInteractionEnabled: Bool { get }

    /**
     Enables/Disables scrolling on collection view.
     Does't work if collectionViewInteractionEnabled is false.
     */
    var collectionViewScrollEnabled: Bool { get }
    
    /**
     Indicates if no shots view should be displayed
     */
    var shouldShowNoShotsView: Bool { get }

    /**
     Do any necessary steps to prepare yourself for presenting data.
    */
    func prepareForPresentingData()

    /**
     Reload data and possibly perform any other action or animation required by this handler.
     ShotsCollectionViewController calls this action after downloading shots or state changes.
     */
    func presentData()
    
}

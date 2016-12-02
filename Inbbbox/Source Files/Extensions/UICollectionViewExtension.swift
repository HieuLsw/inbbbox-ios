//
//  UICollectionViewExtensions.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 23/04/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

extension UICollectionView {

    /// Defines type used during registering class for reusable view.
    enum `Type` {
        case cell, header, footer
    }

    /// Registers class for reuse.
    /// Specific registration method is choosed based on view type.
    ///
    /// - parameter aClass: Class to register.
    /// - parameter type:   Type of reusable view.
    ///
    /// - SeeAlso: `ViewType` enum.
    func registerClass<T: UICollectionReusableView>(_ aClass: T.Type, type: Type) where T: Reusable {

        switch type {
        case .cell:
            register(aClass, forCellWithReuseIdentifier: T.identifier as String)
        case .header:
            register(aClass, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                         withReuseIdentifier: T.identifier)
        case .footer:
            register(aClass, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                                         withReuseIdentifier: T.identifier)
        }
    }

    /// Dequeues reusable cell or suplementary view based on type.
    ///
    /// - parameter aClass:         Class to dequeue.
    /// - parameter forIndexPath:   The index path specifying the location of the cell or view.
    /// - parameter type:           Type of reusable view.
    ///
    /// - SeeAlso: `ViewType` enum.
    ///
    /// - returns: A valid UICollectionReusableView object.
    func dequeueReusableClass<T: UICollectionReusableView>(_ aClass: T.Type,
            forIndexPath indexPath: IndexPath, type: Type) -> T where T: Reusable {

        switch type {
        case .cell:
            return (dequeueReusableCell(withReuseIdentifier: T.identifier,
                                             for: indexPath) as? T)!
        case .header:
            return (dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                      withReuseIdentifier: T.identifier,
                                             for: indexPath) as? T)!
        case .footer:
            return (dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter,
                                      withReuseIdentifier: T.identifier,
                                             for: indexPath) as? T)!
        }
    }

    /// Calculates size for auto sizing cell.
    ///
    /// - parameter cell:           Cell for which calculation happens. Must be of `Type`.
    /// - parameter textToBound:    Optional text that will be considered during calculations.
    /// - parameter withInsets:     Set insets if needed.
    ///
    /// - SeeAlso: `Type` enum.
    ///
    /// - returns: Size of cell.
    func sizeForAutoSizingCell<T: UICollectionViewCell>(_ cell: T.Type,
                 textToBound: [NSAttributedString?]?, withInsets
            additionalInsets: UIEdgeInsets = UIEdgeInsets.zero) -> CGSize where T: AutoSizable {

        let insets = cell.contentInsets
        let availableWidth = bounds.size.width - (cell.maximumContentWidth ?? 0) -
                (insets.left + insets.right + additionalInsets.left + additionalInsets.right)
        var height = CGFloat(0)

        if let textToBound = textToBound {

            let textToCalculateHeight = textToBound.flatMap { $0 }

            if textToCalculateHeight.count > 0 {

                textToCalculateHeight.forEach {
                    height += $0.boundingHeightUsingAvailableWidth(availableWidth) +
                            cell.verticalInteritemSpacing
                }

                height += insets.top + insets.bottom + additionalInsets.top +
                        additionalInsets.bottom
            }
        }

        return CGSize(
            width: bounds.size.width,
            height: max(cell.minimumRequiredHeight, height)
        )
    }
}

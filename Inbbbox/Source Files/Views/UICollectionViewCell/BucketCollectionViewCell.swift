//
//  BucketCollectionViewCell.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 22.01.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class BucketCollectionViewCell: BaseInfoShotsCollectionViewCell, Reusable, WidthDependentHeight,
        InfoShotsCellConfigurable {
    struct ConstantValues {
        let top, left, width, height: CGFloat
    }
    struct PositionsConstraints {
        let top, left, width, height: NSLayoutConstraint
    }
    
    var imagesConstants: [ConstantValues]?
    var animatableConstraints: [PositionsConstraints]?
    var positionShift = 0
    let rotationDuration = 1.25

    let firstShotImageView = UIImageView.newAutoLayout()
    let secondShotImageView = UIImageView.newAutoLayout()
    let thirdShotImageView = UIImageView.newAutoLayout()
    let fourthShotImageView = UIImageView.newAutoLayout()

    override var shotsViewHeightToWidthRatio: CGFloat {
        return 1
    }
    fileprivate var didSetConstraints = false

    func makeRotationOnImages() {
        
        // representation of animation state
        positionShift -= 1
        if positionShift < 0 {
            positionShift=3
        }
        
        if let animatableConstraints = animatableConstraints, let valuesConstants = imagesConstants {
        
            for (index, constraints) in animatableConstraints.enumerated() {
            
                // index of values in constraints array, shifted by animation state
                let valsIndex = (index + positionShift) % animatableConstraints.count
                
                // views z-index repositions, for last and first animation frame
                if valsIndex == 3 {
                    if let view = constraints.top.firstItem as? UIView {
                        shotsView.sendSubview(toBack: view)
                    }
                }
                if valsIndex == 0 {
                    if let view = constraints.top.firstItem as? UIView {
                        shotsView.bringSubview(toFront: view)
                    }
                }
                
                // constants apply
                self.updateConstraints(constraints, withValues: valuesConstants[valsIndex])
            }
        }
        
        UIView.animate(withDuration: rotationDuration, delay: 0, options: UIViewAnimationOptions(), animations: { [weak self] in
            
            self?.shotsView.layoutIfNeeded()
            
        }, completion: nil)
    }
    // MARK: - Lifecycle

    override func commonInit() {
        super.commonInit()
        setupShotsView()
        setupContainerShotView()
    }

    // MARK: - UIView

    override func updateConstraints() {
        if !didSetConstraints {
            setShotsViewConstraints()
            setInfoViewConstraints()
            didSetConstraints = true
        }
        super.updateConstraints()
    }

    // MARK: - Info Shots Cell Configurable

    func setupShotsView() {
        for view in [firstShotImageView, secondShotImageView, thirdShotImageView, fourthShotImageView] {
            view.backgroundColor = ColorModeProvider.current().shotViewCellBackground
            shotsView.addSubview(view)
        }
    }
    
    func setupContainerShotView() {
        self.shotsView.backgroundColor = ColorModeProvider.current().shotViewCellBackground
    }

    func setShotsViewConstraints() {
        
        imagesConstants = self.instantiateConstants()
        
        if let imagesConstants = imagesConstants {
            animatableConstraints = [setupAndReturnConstraints(firstShotImageView, withValues: imagesConstants[0]),
                                    setupAndReturnConstraints(secondShotImageView, withValues: imagesConstants[1]),
                                    setupAndReturnConstraints(thirdShotImageView, withValues: imagesConstants[2]),
                                    setupAndReturnConstraints(fourthShotImageView, withValues: imagesConstants[3])]
        }
    }

    func setInfoViewConstraints() {
        nameLabel.autoPinEdge(.bottom, to: .top, of: numberOfShotsLabel)
        nameLabel.autoPinEdge(.top, to: .top, of: infoView, withOffset: 6.5)
        nameLabel.autoPinEdge(.left, to: .left, of: infoView)
        nameLabel.autoPinEdge(.right, to: .right, of: infoView)
        numberOfShotsLabel.autoPinEdge(.left, to: .left, of: nameLabel)
    }

    func clearImages() {
        for imageView in [firstShotImageView, secondShotImageView, thirdShotImageView, fourthShotImageView] {
            imageView.image = nil
        }
    }

    // MARK: - Width dependent height
    static var heightToWidthRatio: CGFloat {
        return CGFloat(1.25)
    }
}

extension BucketCollectionViewCell: ColorModeAdaptable {
    func adaptColorMode(_ mode: ColorModeType) {
        updateBackgroundColorsForMode(mode)
    }
    
    fileprivate func updateBackgroundColorsForMode(_ mode: ColorModeType) {
        for view in [firstShotImageView, secondShotImageView, thirdShotImageView, fourthShotImageView, shotsView] {
            view.backgroundColor = ColorModeProvider.current().shotViewCellBackground
        }
    }
}

// MARK: Constraints animation
private extension BucketCollectionViewCell {
    
    func instantiateConstants() -> [ConstantValues] {
        let spacings = CollectionViewLayoutSpacings()
        let largeWidth = contentView.bounds.width
        let largeHeight = largeWidth * spacings.smallerShotHeightToWidthRatio
        let subimageWidth = contentView.bounds.width / 3
        let subimageHeight = subimageWidth * spacings.smallerShotHeightToWidthRatio
        
        return [ConstantValues(top: 0, left: 0, width: largeWidth, height: largeHeight),
                ConstantValues(top: largeHeight, left: 0, width: subimageWidth, height: subimageHeight),
                ConstantValues(top: largeHeight, left: subimageWidth, width: subimageWidth, height: subimageHeight),
                ConstantValues(top: largeHeight, left: 2 * subimageWidth, width: subimageWidth, height: subimageHeight)]
    }
    
    func setupAndReturnConstraints(_ view:UIView, withValues values:ConstantValues) -> PositionsConstraints {
        let topConstr = view.autoPinEdge(.top, to: .top, of: shotsView, withOffset: values.top)
        let leftConstr = view.autoPinEdge(.left, to: .left, of: shotsView, withOffset: values.left)
        let widthConstr = view.autoSetDimension(.width, toSize: values.width)
        let heightConstr = view.autoSetDimension(.height, toSize: values.height)
        
        return PositionsConstraints(top: topConstr, left: leftConstr, width: widthConstr, height: heightConstr)
    }
    
    func updateConstraints(_ constraints:PositionsConstraints, withValues values:ConstantValues) {
        constraints.top.constant = values.top
        constraints.left.constant = values.left
        constraints.width.constant = values.width
        constraints.height.constant = values.height
    }
}

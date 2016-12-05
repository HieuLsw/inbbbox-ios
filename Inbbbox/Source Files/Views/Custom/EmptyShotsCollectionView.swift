//
//  EmptyShotsCollectionView.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 25.10.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

class EmptyShotsCollectionView: UIView {
    
    private let descriptionLabel = UILabel.newAutoLayoutView()
    private let imageView = UIImageView.newAutoLayoutView()
    private let cellPlaceholder = UIView.newAutoLayoutView()
    
    private var didUpdateConstraints = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cellPlaceholder.backgroundColor = UIColor.separatorGrayColor()
        cellPlaceholder.layer.cornerRadius = 5
        cellPlaceholder.layer.shadowColor = UIColor.cellBackgroundColor().CGColor
        cellPlaceholder.layer.shadowRadius = 3
        cellPlaceholder.layer.shadowOpacity = 1
        cellPlaceholder.layer.shadowOffset = CGSizeMake(0, 0)
        cellPlaceholder.clipsToBounds = false
        
        addSubview(cellPlaceholder)
        
        descriptionLabel.text = NSLocalizedString("ShotsCollectionViewController.NoShotsErrorLabel", comment: "Select at least 1 \nstream source \nin the settings")
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .Center
        descriptionLabel.font = UIFont.helveticaFont(.NeueLight, size: 25)
        descriptionLabel.textColor = UIColor.cellBackgroundColor()
        addSubview(descriptionLabel)
        
        imageView.image = UIImage(named: "ic-nostream-pointer")
        imageView.contentMode = .ScaleAspectFit
        addSubview(imageView)
    }
    
    @available(*, unavailable, message="Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        if !didUpdateConstraints {
            didUpdateConstraints = true
            
            cellPlaceholder.autoPinEdgeToSuperviewEdge(.Left, withInset: CollectionViewLayoutSpacings().itemMargin)
            cellPlaceholder.autoPinEdgeToSuperviewEdge(.Right, withInset: CollectionViewLayoutSpacings().itemMargin)
            cellPlaceholder.autoMatchDimension(.Height, toDimension: .Width, ofView: cellPlaceholder, withMultiplier: CollectionViewLayoutSpacings().biggerShotHeightToWidthRatio)
            cellPlaceholder.autoAlignAxisToSuperviewAxis(.Horizontal)
            
            imageView.autoSetDimension(.Height, toSize: 48)
            imageView.autoMatchDimension(.Width, toDimension: .Width, ofView: self, withMultiplier: 0.190)
            imageView.autoPinEdgeToSuperviewEdge(.Right, withInset: 4)
            imageView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 16)
            
            descriptionLabel.autoAlignAxisToSuperviewAxis(.Vertical)
            descriptionLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 52)
        }
        super.updateConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cellPlaceholder.hidden = cellPlaceholder.frame.intersect(descriptionLabel.frame).height != 0
    }

}

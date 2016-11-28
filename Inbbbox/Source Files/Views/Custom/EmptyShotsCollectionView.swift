//
//  EmptyShotsCollectionView.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 25.10.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

class EmptyShotsCollectionView: UIView {
    
    fileprivate let descriptionLabel = UILabel.newAutoLayout()
    fileprivate let imageView = UIImageView.newAutoLayout()
    fileprivate let cellPlaceholder = UIView.newAutoLayout()
    
    fileprivate var didUpdateConstraints = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cellPlaceholder.backgroundColor = UIColor.separatorGrayColor()
        cellPlaceholder.layer.cornerRadius = 5
        cellPlaceholder.layer.shadowColor = UIColor.cellBackgroundColor().cgColor
        cellPlaceholder.layer.shadowRadius = 3
        cellPlaceholder.layer.shadowOpacity = 1
        cellPlaceholder.layer.shadowOffset = CGSize.zero
        cellPlaceholder.clipsToBounds = false
        
        addSubview(cellPlaceholder)
        
        descriptionLabel.text = NSLocalizedString("ShotsCollectionViewController.NoShotsErrorLabel", comment: "Select at least 1 \nstream source \nin the settings")
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = UIFont.helveticaFont(.neueLight, size: 25)
        descriptionLabel.textColor = UIColor.cellBackgroundColor()
        addSubview(descriptionLabel)
        
        imageView.image = UIImage(named: "ic-nostream-pointer")
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }
    
    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        if !didUpdateConstraints {
            didUpdateConstraints = true
            
            cellPlaceholder.autoPinEdge(toSuperviewEdge: .left, withInset: CollectionViewLayoutSpacings().itemMargin)
            cellPlaceholder.autoPinEdge(toSuperviewEdge: .right, withInset: CollectionViewLayoutSpacings().itemMargin)
            cellPlaceholder.autoMatch(.height, to: .width, of: cellPlaceholder, withMultiplier: CollectionViewLayoutSpacings().biggerShotHeightToWidthRatio)
            cellPlaceholder.autoAlignAxis(toSuperviewAxis: .horizontal)
            
            imageView.autoSetDimension(.height, toSize: 48)
            imageView.autoMatch(.width, to: .width, of: self, withMultiplier: 0.190)
            imageView.autoPinEdge(toSuperviewEdge: .right, withInset: 4)
            imageView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
            
            descriptionLabel.autoAlignAxis(toSuperviewAxis: .vertical)
            descriptionLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 52)
        }
        super.updateConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cellPlaceholder.isHidden = cellPlaceholder.frame.intersection(descriptionLabel.frame).height != 0
    }

}

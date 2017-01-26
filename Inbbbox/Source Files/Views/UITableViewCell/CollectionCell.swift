//
//  CollectionCell.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout
import TTTAttributedLabel

class CollectionCell: UITableViewCell, Reusable {
    
    let backgroundLabel = UILabel.newAutoLayout()
    let titleLabel = TTTAttributedLabel.newAutoLayout()
    let counterLabel = UILabel.newAutoLayout()
    fileprivate var collectionView: UICollectionView
    
    fileprivate var didSetConstraints = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(collectionView)
        
        backgroundLabel.font = UIFont.boldSystemFont(ofSize: 54)
        contentView.addSubview(backgroundLabel)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.kern = 0.8
        contentView.addSubview(titleLabel)
        
        counterLabel.font = UIFont.boldSystemFont(ofSize: 10)
        contentView.addSubview(counterLabel)
        
        setNeedsUpdateConstraints()
    }
    
    @available(*, unavailable, message: "Use init(style:reuseIdentifier:) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        if !didSetConstraints {
            didSetConstraints = true
            
            backgroundLabel.autoPinEdge(toSuperviewEdge: .leading)
            backgroundLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 0)
            
            titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 24)
            titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 14)
            
            counterLabel.autoPinEdge(.leading, to: .trailing, of: titleLabel, withOffset: 2)
            counterLabel.autoPinEdge(.top, to: .top, of: titleLabel)
            
            collectionView.autoPinEdge(toSuperviewEdge: .leading)
            collectionView.autoPinEdge(toSuperviewEdge: .trailing)
            collectionView.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 2)
            collectionView.autoPinEdge(toSuperviewEdge: .bottom)
            collectionView.autoSetDimension(.height, toSize: 113)
        }
        
        super.updateConstraints()
    }
}

extension CollectionCell: ColorModeAdaptable {
    func adaptColorMode(_ mode: ColorModeType) {
        backgroundColor = mode.profileDetailsBackgroundColor
        backgroundLabel.textColor = mode.profileDetailsCollectionBackgroundLabelTextColor
        titleLabel.textColor = mode.profileDetailsCollectionTitleLabelTextColor
        counterLabel.textColor = mode.profileDetailsCollectionCounterLabelTextColor
    }
}

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
    
    var shots: [ShotType]? {
        didSet {
            collectionView.reloadData()
            collectionView.scrollRectToVisible(CGRect.zero, animated: false)
        }
    }
    
    let backgroundLabel = UILabel.newAutoLayout()
    let titleLabel = TTTAttributedLabel.newAutoLayout()
    let counterLabel = UILabel.newAutoLayout()
    fileprivate var collectionView: UICollectionView
    
    fileprivate var indexPathsNeededImageUpdate = [IndexPath]()
    fileprivate var didSetConstraints = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: CarouselCollectionViewLayout())
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        
        backgroundLabel.font = UIFont.boldSystemFont(ofSize: 54)
        contentView.addSubview(backgroundLabel)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.kern = 0.8
        contentView.addSubview(titleLabel)
        
        counterLabel.font = UIFont.boldSystemFont(ofSize: 10)
        contentView.addSubview(counterLabel)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.registerClass(SimpleShotCollectionViewCell.self, type: .cell)
        contentView.addSubview(collectionView)
        
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
            collectionView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
            collectionView.autoSetDimension(.height, toSize: 113)
        }
        
        super.updateConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        shots = nil
        indexPathsNeededImageUpdate = [IndexPath]()
    }
}

extension CollectionCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let shots = shots {
            return shots.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = prepareShotCell(at: indexPath, in: collectionView)
        return cell
    }
}

// MARK: Private extension

private extension CollectionCell {

    func lazyLoadImage(_ shotImage: ShotImageType, forCell cell: SimpleShotCollectionViewCell,
                       atIndexPath indexPath: IndexPath) {
        let imageLoadingCompletion: (UIImage) -> Void = { [weak self] image in
            
            guard let certainSelf = self, certainSelf.indexPathsNeededImageUpdate.contains(indexPath) else {
                return
            }
            
            cell.shotImageView.image = image
        }
        LazyImageProvider.lazyLoadImageFromURLs(
            (shotImage.teaserURL, shotImage.normalURL, nil),
            teaserImageCompletion: imageLoadingCompletion,
            normalImageCompletion: imageLoadingCompletion
        )
    }
    
    func prepareShotCell(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableClass(SimpleShotCollectionViewCell.self, forIndexPath: indexPath, type: .cell)
        
        guard let shots = shots else {
            cell.gifLabel.isHidden = true
            return cell
        }
        let cellData = shots[indexPath.item]
        
        indexPathsNeededImageUpdate.append(indexPath)
        lazyLoadImage(cellData.shotImage, forCell: cell, atIndexPath: indexPath)
        cell.gifLabel.isHidden = !cellData.animated
        
        return cell
    }

}

extension CollectionCell: ColorModeAdaptable {
    func adaptColorMode(_ mode: ColorModeType) {
        backgroundLabel.textColor = mode.profileDetailsCollectionBackgroundLabelTextColor
        titleLabel.textColor = mode.profileDetailsCollectionTitleLabelTextColor
        counterLabel.textColor = mode.profileDetailsCollectionCounterLabelTextColor
    }
}

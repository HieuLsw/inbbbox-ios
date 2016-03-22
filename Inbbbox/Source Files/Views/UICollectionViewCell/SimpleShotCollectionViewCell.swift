//
//  SimpleShotCollectionViewCell.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 26.01.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class SimpleShotCollectionViewCell: UICollectionViewCell, Reusable, WidthDependentHeight {
    
    let shotImageView = UIImageView.newAutoLayoutView()
    let gifLabel = GifIndicatorView.newAutoLayoutView()
    private var didSetConstraints = false

    // MARK - Life cycle
    
    @available(*, unavailable, message="Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        contentView.backgroundColor = UIColor.cellBackgroundColor()
        contentView.addSubview(shotImageView)
        contentView.addSubview(gifLabel)
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
    }
    
    // MARK - UIView
    
    override class func requiresConstraintBasedLayout() -> Bool{
        return true
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        if !didSetConstraints {
            didSetConstraints = true
            shotImageView.autoPinEdgesToSuperviewEdges()
            gifLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 5)
            gifLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 5)
        }
    }
    
    // MARK: - Reusable
    static var reuseIdentifier: String {
        return "SimpleShotCollectionViewCellIdentifier"
    }
    
    //MARK: - Width dependent height
    static var heightToWidthRatio: CGFloat {
        return CGFloat(0.75)
    }
}

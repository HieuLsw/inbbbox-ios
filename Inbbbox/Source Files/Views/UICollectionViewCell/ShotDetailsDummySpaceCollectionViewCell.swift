//
//  ShotDetailsDummySpaceCollectionViewCell.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 10/03/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ShotDetailsDummySpaceCollectionViewCell: UICollectionViewCell {

    private let separatorView = UIView.newAutoLayoutView()
    private var didUpdateConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable, message="Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }

    override func updateConstraints() {

        if !didUpdateConstraints {
            didUpdateConstraints = true

            separatorView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Bottom)
            separatorView.autoSetDimension(.Height, toSize: 1)
        }

        super.updateConstraints()
    }
    
    private func setupSubviews() {
        let currentColorMode = ColorModeProvider.current()
        separatorView.backgroundColor = currentColorMode.shotDetailsSeparatorColor
        contentView.addSubview(separatorView)
        
        contentView.backgroundColor = currentColorMode.shotDummySpaceBackground
    }
}

extension ShotDetailsDummySpaceCollectionViewCell: AutoSizable {

    static var minimumRequiredHeight: CGFloat {
        return 20
    }
}

extension ShotDetailsDummySpaceCollectionViewCell: Reusable {

    class var reuseIdentifier: String {
        return String(ShotDetailsDummySpaceCollectionViewCell)
    }
}

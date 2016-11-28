//
//  ShotDetailsDummySpaceCollectionViewCell.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 10/03/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ShotDetailsDummySpaceCollectionViewCell: UICollectionViewCell {

    fileprivate let separatorView = UIView.newAutoLayout()
    fileprivate var didUpdateConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    override func updateConstraints() {

        if !didUpdateConstraints {
            didUpdateConstraints = true

            separatorView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .bottom)
            separatorView.autoSetDimension(.height, toSize: 1)
        }

        super.updateConstraints()
    }
    
    fileprivate func setupSubviews() {
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

    class var identifier: String {
        return String(describing: ShotDetailsDummySpaceCollectionViewCell.self)
    }
}

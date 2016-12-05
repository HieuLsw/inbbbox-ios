//
//  BaseInfoShotsCollectionViewCell
//  Inbbbox
//
//  Created by Aleksander Popko on 04.02.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class BaseInfoShotsCollectionViewCell: UICollectionViewCell {

    let shotsView = UIImageView.newAutoLayoutView()
    let infoView = UIView.newAutoLayoutView()
    let nameLabel = UILabel.newAutoLayoutView()
    let numberOfShotsLabel = UILabel.newAutoLayoutView()
    var shotsViewHeightToWidthRatio: CGFloat {
        return 0.75
    }
    private var didSetConstraints = false
    var isRegisteredTo3DTouch = false

    // MARK: Life cycle

    @available(*, unavailable, message="Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    // MARK: Setup UI

     func commonInit() {

        nameLabel.textColor = UIColor.pinkColor()
        nameLabel.font = UIFont.systemFontOfSize(13, weight:UIFontWeightMedium)
        infoView.addSubview(nameLabel)

        numberOfShotsLabel.textColor = UIColor.followeeTextGrayColor()
        numberOfShotsLabel.font = UIFont.systemFontOfSize(10)
        infoView.addSubview(numberOfShotsLabel)

        shotsView.layer.cornerRadius = 5
        shotsView.clipsToBounds = true

        contentView.addSubview(shotsView)
        contentView.addSubview(infoView)
    }

    // MARK: UIView

    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }

    override func updateConstraints() {

        if !didSetConstraints {
            shotsView.autoMatchDimension(.Height, toDimension: .Width, ofView: shotsView, withMultiplier: shotsViewHeightToWidthRatio)
            shotsView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Bottom)
            infoView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Top)
            infoView.autoPinEdge(.Top, toEdge: .Bottom, ofView: shotsView)
            didSetConstraints = true
        }
        super.updateConstraints()
    }
}

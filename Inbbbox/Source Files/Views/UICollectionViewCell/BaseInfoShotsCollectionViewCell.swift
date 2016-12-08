//
//  BaseInfoShotsCollectionViewCell
//  Inbbbox
//
//  Created by Aleksander Popko on 04.02.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class BaseInfoShotsCollectionViewCell: UICollectionViewCell {

    let shotsView = UIImageView.newAutoLayout()
    let infoView = UIView.newAutoLayout()
    let nameLabel = UILabel.newAutoLayout()
    let numberOfShotsLabel = UILabel.newAutoLayout()
    var shotsViewHeightToWidthRatio: CGFloat {
        return 0.75
    }
    fileprivate var didSetConstraints = false
    var isRegisteredTo3DTouch = false

    // MARK: Life cycle

    @available(*, unavailable, message: "Use init(frame:) instead")
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
        nameLabel.font = UIFont.sanFransiscoFont(withType: .medium, size: 13)
        infoView.addSubview(nameLabel)

        numberOfShotsLabel.textColor = UIColor.followeeTextGrayColor()
        numberOfShotsLabel.font = UIFont.sanFransiscoFont(ofSize: 10)
        infoView.addSubview(numberOfShotsLabel)

        shotsView.layer.cornerRadius = 5
        shotsView.clipsToBounds = true

        contentView.addSubview(shotsView)
        contentView.addSubview(infoView)
    }

    // MARK: UIView

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    override func updateConstraints() {

        if !didSetConstraints {
            shotsView.autoMatch(.height, to: .width, of: shotsView, withMultiplier: shotsViewHeightToWidthRatio)
            shotsView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .bottom)
            infoView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .top)
            infoView.autoPinEdge(.top, to: .bottom, of: shotsView)
            didSetConstraints = true
        }
        super.updateConstraints()
    }
}

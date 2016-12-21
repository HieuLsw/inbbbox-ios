//
//  TeamCollectionViewCell.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import PureLayout
import UIKit

final class TeamCollectionViewCell: UICollectionViewCell, Reusable {

    let logoImageView: UIImageView = UIImageView.newAutoLayout()

    private(set) lazy var nameLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightSemibold)
        label.numberOfLines = 0
        label.textColor = .textDarkGrayColor()
        return label
    }()

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        nameLabel.text = "Netguru"
        logoImageView.image = UIImage(named: "ic-ball")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        logoImageView.image = nil
        nameLabel.text = nil
    }

    private func setupLayout() {
        addSubview(logoImageView)
        addSubview(nameLabel)

        logoImageView.autoSetDimensions(to: CGSize(width: 45, height: 45))
        logoImageView.autoAlignAxis(toSuperviewAxis: .horizontal)
        logoImageView.autoPinEdge(toSuperviewEdge: .left, withInset: 24)

        nameLabel.autoAlignAxis(.horizontal, toSameAxisOf: logoImageView)
        nameLabel.autoPinEdge(.left, to: .right, of: logoImageView, withOffset: 14)
    }

}

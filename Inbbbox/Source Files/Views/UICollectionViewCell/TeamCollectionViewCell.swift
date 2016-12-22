//
//  TeamCollectionViewCell.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import PureLayout
import UIKit

final class TeamCollectionViewCell: UICollectionViewCell, Reusable {

    private let logoSize = 45

    let logoImageView: UIImageView = UIImageView.newAutoLayout()

    private(set) lazy var nameLabel: UILabel = { [unowned self] in
        let label = UILabel()

        label.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightSemibold)
        label.numberOfLines = 0
        label.textColor = .textLightGrayColor()

        return label
    }()

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        logoImageView.image = nil
        nameLabel.text = nil
    }

    private func setupLayout() {
        addSubview(logoImageView)
        addSubview(nameLabel)

        logoImageView.autoSetDimensions(to: CGSize(width: logoSize, height: logoSize))
        logoImageView.autoAlignAxis(toSuperviewAxis: .horizontal)
        logoImageView.autoPinEdge(toSuperviewEdge: .left, withInset: 24)
        logoImageView.layer.cornerRadius = logoSize / 2
        logoImageView.clipsToBounds = true

        nameLabel.autoAlignAxis(.horizontal, toSameAxisOf: logoImageView)
        nameLabel.autoPinEdge(.left, to: .right, of: logoImageView, withOffset: 14)
        nameLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 24)
    }

}

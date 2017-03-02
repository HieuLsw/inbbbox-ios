//
//  BlockedUsersTableViewCell.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

class BlockedUsersTableViewCell: UITableViewCell, Reusable {

    let avatarView = AvatarView(size: CGSize(width: 35, height: 35), bordered: false)
    let titleLabel = UILabel.newAutoLayout()
    let edgesInset: CGFloat = 16

    fileprivate var didSetConstraints = false

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
        titleLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(titleLabel)

        contentView.addSubview(avatarView)

        setNeedsUpdateConstraints()
    }

    @available(*, unavailable, message: "Use init(style:reuseIdentifier:) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        if !didSetConstraints {
            didSetConstraints = true

            titleLabel.autoPinEdge(.left, to: .right, of: avatarView, withOffset: 10)
            titleLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
            titleLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: edgesInset)

            avatarView.autoSetDimensions(to: CGSize(width: 35, height: 35))
            avatarView.autoPinEdge(toSuperviewEdge: .leading, withInset: edgesInset)
            avatarView.autoAlignAxis(toSuperviewAxis: .horizontal)
        }

        super.updateConstraints()
    }
}

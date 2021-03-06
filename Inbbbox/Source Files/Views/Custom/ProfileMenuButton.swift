//
//  ProfileMenuButton.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

class ProfileMenuButton: UIButton {

    var badge = 0 {
        didSet {
            badgeLabel.text = "\(badge)"
            badgeLabel.isHidden = badge == 0
            
            if badge == 0 {
                nameLabel.textAlignment = .center
            } else {
                nameLabel.textAlignment = .right
            }
        }
    }

    var badgeColor = ColorModeProvider.current().activeMenuButtonBadge {
        didSet {
            badgeLabel.textColor = badgeColor
        }
    }
    
    var name: String? {
        get {
            return nameLabel.text
        }
        set {
            nameLabel.text = newValue
        }
    }
    
    var nameColor = ColorModeProvider.current().activeMenuButtonTitle {
        didSet {
            nameLabel.textColor = nameColor
        }
    }
    
    var nameFont: UIFont {
        get {
            return nameLabel.font
        }
        set {
            nameLabel.font = newValue
        }
    }

    fileprivate let badgeLabel = UILabel()
    fileprivate let nameLabel = UILabel()
    fileprivate var didSetConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        badgeLabel.font = UIFont.systemFont(ofSize: 10)
        nameLabel.font = titleLabel?.font
        nameLabel.textAlignment = .center
        
        addSubview(badgeLabel)
        addSubview(nameLabel)
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        if !didSetConstraints {
            didSetConstraints = true

            let offset = CGFloat(4.0)
            badgeLabel.autoPinEdge(.leading, to: .trailing, of: nameLabel)
            badgeLabel.autoPinEdge(.bottom, to: .top, of: nameLabel, withOffset: 7)
            badgeLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: offset)
            
            nameLabel.adjustsFontSizeToFitWidth = true
            nameLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: offset)
            nameLabel.autoAlignAxis(.horizontal, toSameAxisOf: self)
            nameLabel.autoMatch(.width, to: .width, of: self, withOffset: -(badgeLabel.intrinsicContentSize.width + (offset * 2)) )
        }

        super.updateConstraints()
    }
}

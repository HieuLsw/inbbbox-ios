//
//  LoginView.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 28/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout

class LoginView: UIView {

    fileprivate let cornerRadius = CGFloat(28)

    let loginButton = UIButton(type: .system)
    let loginAsGuestButton = UIButton(type: .system)
    let shotsView = AutoScrollableShotsView(numberOfColumns: 4)
    let dribbbleLogoImageView = UIImageView(image: UIImage(named: "ic-ball"))
    let orLabel = ORLoginLabel()
    let copyrightlabel = UILabel()
    let loadingLabel = UILabel()

    let logoImageView = UIImageView(image: UIImage(named: "logo-inbbbox"))
    let pinkOverlayView = UIImageView(image: UIImage(named: "bg-intro-gradient"))
    let sloganLabel = UILabel()
    let defaultWhiteColor = UIColor.RGBA(249, 212, 226, 1)

    var isAnimating = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(shotsView)
        addSubview(pinkOverlayView)
        addSubview(logoImageView)
        addSubview(orLabel)
        addSubview(dribbbleLogoImageView)

        loginButton.setTitle(Localized("LoginView.LoginButtonTitle", comment: "Title of log in button"),
                             for: .normal)
        loginButton.backgroundColor = UIColor.white
        loginButton.layer.cornerRadius = cornerRadius
        loginButton.setTitleColor(UIColor.pinkColor(), for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        loginButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        loginButton.titleLabel?.textAlignment = NSTextAlignment.center
        loginButton.titleEdgeInsets.left = 2.5 * cornerRadius
        loginButton.titleEdgeInsets.right = cornerRadius
        insertSubview(loginButton, belowSubview: dribbbleLogoImageView)

        loginAsGuestButton.setTitle(Localized("LoginView.GuestButtonTitle", comment: "Title of guest button"),
                                    for: .normal)
        loginAsGuestButton.backgroundColor = UIColor.clear
        loginAsGuestButton.layer.cornerRadius = cornerRadius
        loginAsGuestButton.layer.borderWidth = 1
        loginAsGuestButton.layer.borderColor = UIColor.white.cgColor
        loginAsGuestButton.setTitleColor(UIColor.white, for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        addSubview(loginAsGuestButton)

        sloganLabel.text = Localized("LoginView.Slogan", comment: "Slogan")
        sloganLabel.textAlignment = .center
        sloganLabel.textColor = defaultWhiteColor
        sloganLabel.font = UIFont.systemFont(ofSize: 25, weight: UIFontWeightLight)
        addSubview(sloganLabel)

        loadingLabel.text = Localized("LoginView.Loading", comment: "")
        loadingLabel.textAlignment = .center
        loadingLabel.textColor = defaultWhiteColor
        loadingLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
        addSubview(loadingLabel)

        copyrightlabel.text = Localized("LoginView.Copyright", comment:"Describes copyright holder")
        copyrightlabel.textAlignment = .center
        copyrightlabel.textColor = defaultWhiteColor
        copyrightlabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightMedium)
        copyrightlabel.adjustsFontSizeToFitWidth = true
        addSubview(copyrightlabel)
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        /**
            Sorry for using rects here, but autolayout is going crazy with
            animations provided by our designer...

            If you want to be devoured by UIKit mutable state, please refactor this to autolayout.
        */
        if !isAnimating {

            let inset = CGFloat(30)
            let height = 2 * cornerRadius
            loginButton.frame = CGRect(x: inset, y: frame.maxY - height - 132,
                width: frame.width - 2 * inset, height: height
            )

            let size = dribbbleLogoImageView.image?.size ?? CGSize.zero
            dribbbleLogoImageView.frame = CGRect(x: loginButton.frame.minX + 30,
                y: loginButton.frame.midY - size.height * 0.5,
                width: size.width, height: size.height
            )

            loginAsGuestButton.frame = CGRect(x: inset, y: frame.maxY - 56 - height + 200,
                width: frame.width - 2 * inset, height: height
            )

            let width = CGFloat(150)
            orLabel.frame = CGRect(x: frame.midX - width * 0.5,
                y: loginAsGuestButton.frame.minY - height,
                width: width, height: 60
            )

            loadingLabel.frame = CGRect(x: 0, y: frame.maxY - 65,
                width: frame.width, height: 20
            )

            let sloganHeight = CGFloat(40)
            sloganLabel.frame = CGRect(x: 0, y: frame.midY - sloganHeight * 0.5,
                width: frame.width, height: sloganHeight
            )

            let imageSize = logoImageView.image!.size
            logoImageView.frame = CGRect(x: frame.midX - imageSize.width * 0.5,
                y: sloganLabel.frame.minY - 30 - imageSize.height,
                width: imageSize.width, height: imageSize.height
            )

            shotsView.frame = frame
            pinkOverlayView.frame = frame

            let standardSpacing: CGFloat = 20
            copyrightlabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: standardSpacing)
            copyrightlabel.autoPinEdge(toSuperviewEdge: .leading, withInset: standardSpacing)
            copyrightlabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: standardSpacing)
            copyrightlabel.autoSetDimension(.height, toSize: 14.5)
            copyrightlabel.autoAlignAxis(toSuperviewAxis: .vertical)
        }
    }
}

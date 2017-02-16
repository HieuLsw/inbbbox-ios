//
//  AvatarView.swift
//  Inbbbox
//
//  Created by Peter Bruz on 18/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

protocol AvatarViewDelegate: class {
    func avatarView(_ avatarView: AvatarView, didTapButton avatarButton: UIButton)
}

class AvatarView: UIView {

    let imageView = UIImageView()
    weak var delegate: AvatarViewDelegate?
    fileprivate var avatarButton: UIButton

    convenience init(size: CGSize, bordered: Bool = true, borderWidth: CGFloat = 10) {
        self.init(avatarFrame: CGRect(origin: CGPoint.zero, size: size), bordered: bordered, borderWidth: borderWidth)
    }

    convenience init(avatarFrame: CGRect, bordered: Bool = true, borderWidth: CGFloat = 10) {
        self.init(frame: avatarFrame)

        backgroundColor = .white
        layer.mask = roundedMaskLayer(avatarFrame)

        if bordered {
            let maskFrame = CGRect(x: borderWidth, y: borderWidth, width: avatarFrame.width - 2 * borderWidth,
                    height: avatarFrame.height - 2 * borderWidth)
            imageView.layer.mask = roundedMaskLayer(maskFrame)
        }
    }

    fileprivate override init(frame: CGRect) {
        avatarButton = UIButton(frame: frame)
        super.init(frame: frame)
        imageView.frame.size = frame.size
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        avatarButton.addTarget(self, action: #selector(didTapAvatarButton), for: .touchUpInside)
        addSubview(avatarButton)
    }

    @available(*, unavailable, message: "Use init(frame:) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func didTapAvatarButton() {
        delegate?.avatarView(self, didTapButton: avatarButton)
    }

    fileprivate func roundedMaskLayer(_ maskFrame: CGRect) -> CAShapeLayer {
        let maskLayer = CAShapeLayer()
        let ovalPath = UIBezierPath(ovalIn: maskFrame)
        maskLayer.path = ovalPath.cgPath
        return maskLayer
    }
}

//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

//    MARK: - Life cycle

    let diameter = CGFloat(70)

    @available(*, unavailable, message: "Use init() or init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let currentMode = ColorModeProvider.current()
        layer.cornerRadius = diameter/2
        layer.shadowColor = currentMode.shadowColor.cgColor
        layer.shadowOffset = currentMode.tabBarCenterButtonShadowOffset
        layer.shadowRadius = 3
        layer.shadowOpacity = 1
        layer.masksToBounds = false
    }

//    MARK: - UIView

    override var intrinsicContentSize: CGSize {
        return CGSize(width: diameter, height: diameter)
    }
}

extension RoundedButton: ColorModeAdaptable {
    func adaptColorMode(_ mode: ColorModeType) {
        setImage(UIImage(named: mode.tabBarCenterButtonNormalImageName), for: .normal)
        setImage(UIImage(named: mode.tabBarCenterButtonSelectedImageName), for: .selected)
        backgroundColor = mode.tabBarCenterButtonBackground
        layer.shadowColor = mode.shadowColor.cgColor
        layer.shadowOffset = mode.tabBarCenterButtonShadowOffset
    }
}

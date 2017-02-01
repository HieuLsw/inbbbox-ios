//
//  ProfileMenuBarView.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

class ProfileMenuBarView: UIView {

    var didSelectItem: ((ProfileMenuItem) -> Void)?

    let menuStackView = UIStackView()

    fileprivate let shotsButton = ProfileMenuButton()
    fileprivate let teamButton = ProfileMenuButton()
    fileprivate let infoButton = ProfileMenuButton()
    fileprivate let projectsButton = ProfileMenuButton()
    fileprivate let bucketsButton = ProfileMenuButton()
    fileprivate let underlineBarView = UnderlineBarView()

    fileprivate var didSetConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = ColorModeProvider.current().menuBackground

        deselectAllItems()

        shotsButton.setTitle(Localized("ProfileMenuBarView.Shots", comment: "Shots card title."), for: .normal)
        teamButton.setTitle(Localized("ProfileMenuBarView.Team", comment: "Team card title."), for: .normal)
        infoButton.setTitle(Localized("ProfileMenuBarView.Info", comment: "Info card title."), for: .normal)
        projectsButton.setTitle(Localized("ProfileMenuBarView.Projects", comment: "Projects card title."), for: .normal)
        bucketsButton.setTitle(Localized("ProfileMenuBarView.Buckets", comment: "Buckets card title."), for: .normal)

        [shotsButton, teamButton, infoButton, projectsButton, bucketsButton].forEach {
            $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            $0.addTarget(self, action: #selector(didSelect(button:)), for: .touchUpInside)
        }

        menuStackView.distribution = .fillEqually
        
        menuStackView.spacing = 10

        addSubview(menuStackView)
        addSubview(underlineBarView)
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        if !didSetConstraints {
            didSetConstraints = true

            menuStackView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
            menuStackView.autoPinEdge(.bottom, to: .top, of: underlineBarView)

            underlineBarView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
            underlineBarView.autoSetDimension(.height, toSize: 2)
        }
        
        super.updateConstraints()
    }
    
    // MARK: public

    /// Sets menu view up with items and related badges values.
    ///
    /// - Parameter data: List of tuples containing menu items and badges.
    func setup(with data: [(item: ProfileMenuItem, badge: Int)]) {
        let buttonsWithBagdes: [ProfileMenuButton] = data.map { itemWithBadge in
            let button = menuButton(for: itemWithBadge.item)
            button.badge = itemWithBadge.badge
            return button
        }

        buttonsWithBagdes.forEach {
            menuStackView.addArrangedSubview($0)
        }
    }

    /// Updates item's badge with given value.
    ///
    /// - Parameters:
    ///   - item: Item to update badge for.
    ///   - value: Value to set in badge.
    func updateBadge(for item: ProfileMenuItem, with value: Int) {
        menuButton(for: item).badge = value
    }

    /// Selects given item.
    ///
    /// - Parameter item: Item to select.
    func select(item: ProfileMenuItem) {
        deselectAllItems()
        select(button: menuButton(for: item))
    }
}

private extension ProfileMenuBarView {

    dynamic func didSelect(button: ProfileMenuButton) {
        deselectAllItems()
        select(button: button)

        let item: ProfileMenuItem? = {
            switch button {
            case shotsButton: return .shots
            case teamButton: return .team
            case infoButton: return .info
            case projectsButton: return .projects
            case bucketsButton: return .buckets
            default: return nil
            }
        }()

        if let item = item {
            didSelectItem?(item)
        }
    }

    func select(button: ProfileMenuButton) {
        button.setTitleColor(ColorModeProvider.current().activeMenuButtonTitle, for: .normal)
        button.badgeColor = ColorModeProvider.current().activeMenuButtonBadge
        underlineBarView.underline(frame: button.frame)
    }


    func deselectAllItems() {
        [shotsButton, teamButton, infoButton, projectsButton, bucketsButton].forEach {
            $0.setTitleColor(ColorModeProvider.current().inactiveMenuButtonTitle, for: .normal)
            $0.badgeColor = ColorModeProvider.current().inactiveMenuButtonBadge
        }
    }

    func menuButton(for item: ProfileMenuItem) -> ProfileMenuButton {
        switch item {
        case .shots: return shotsButton
        case .team: return teamButton
        case .info: return infoButton
        case .projects: return projectsButton
        case .buckets: return bucketsButton
        }
    }
}

//
//  ProfileInfoViewModel.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import PromiseKit

final class ProfileInfoViewModel: BaseCollectionViewViewModel {

    private let userProvider = APIUsersProvider()
    private let teamsProvider = TeamsProvider()
    private let apiTeamsProvider = APITeamsProvider()
    private let shotsProvider = ShotsProvider()
    
    private var user: UserType
    private var userTeams = [TeamType]()
    
    private var team: TeamType?
    private var teamMembers = [UserType]()
    private var teamMemberShots = [Int: [ShotType]]()

    weak var delegate: BaseCollectionViewViewModelDelegate?

    var itemsCount: Int {
        return userTeams.count
    }
    
    var teamsCount: Int {
        return userTeams.count
    }

    var teamMembersCount: Int {
        return teamMembers.count
    }

    var shotsCount: String {
        return String(user.shotsCount)
    }

    var followersCount: String {
        return String(user.followersCount)
    }

    var followingsCount: String {
        return String(user.followingsCount)
    }

    var location: String {
        return user.location
    }

    var bio: NSAttributedString? {
        guard let body = NSAttributedString(htmlString: user.bio)?.attributedStringByTrimingTrailingNewLine() else {
            return nil
        }
        
        let mutableBody = NSMutableAttributedString(attributedString: body)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 0
        style.maximumLineHeight = 20
        style.minimumLineHeight = 20
        
        mutableBody.addAttributes([
            NSForegroundColorAttributeName: ColorModeProvider.current().smallTextColor,
            NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
            NSParagraphStyleAttributeName: style
        ], range: NSRange(location: 0, length: mutableBody.length))
        
        return mutableBody.copy() as? NSAttributedString
    }

    var shouldHideLocation: Bool {
        return user.location.characters.count == 0
    }

    var shouldHideTeams: Bool {
        guard let accountType = user.accountType else { return itemsCount == 0 }
        return itemsCount == 0 || accountType == .Team
    }

    var shouldHideTeamMembers: Bool {
        return user.accountType != .Team
    }

    var isTeamsEmpty: Bool {
        return userTeams.isEmpty
    }

    init(user: UserType) {
        self.user = user
        if let accountType = user.accountType, accountType == .Team {
            team = Team(
                identifier: user.identifier,
                name: user.name ?? "",
                username: user.username,
                avatarURL: user.avatarURL,
                createdAt: Date(),
                followersCount: user.followersCount,
                followingsCount: user.followingsCount,
                bio: user.bio,
                location: user.location
            )
        }
    }

    func downloadInitialItems() {
        user.accountType == .Team ? downloadMembersOfTeam() : downloadTeams()
    }

    func downloadItemsForNextPage() {
        firstly {
            teamsProvider.nextPage()
        }.then { teams -> Void in
            if let teams = teams, teams.count > 0 {
                let indexPaths = teams.enumerated().map { index, _ in
                    return IndexPath(row: (index + self.userTeams.count), section: 0)
                }
                self.userTeams.append(contentsOf: teams)
                self.delegate?.viewModel(self, didLoadItemsAtIndexPaths: indexPaths)
            }
        }.catch { error in
            self.delegate?.viewModelDidFailToLoadItems(error)
        }
    }

    private func downloadTeams() {
        firstly {
            teamsProvider.provideTeamFor(user: user)
        }.then { teams -> Void in
            if let teams = teams {
                self.userTeams = teams
            }
            self.delegate?.viewModelDidLoadInitialItems()
        }.catch { error in
            self.delegate?.viewModelDidFailToLoadInitialItems(error)
        }
    }
    
    private func downloadMembersOfTeam() {
        guard let team = team else { return }
        firstly {
            apiTeamsProvider.provideMembersForTeam(team)
        }.then { teamMembers -> Void in
            if let teamMembers = teamMembers, teamMembers != self.teamMembers || teamMembers.count == 0 {
                self.teamMembers = teamMembers
                self.downloadShotsForTeamMembers()
                self.delegate?.viewModelDidLoadInitialItems()
            }
        }.catch { error in
            self.delegate?.viewModelDidFailToLoadInitialItems(error)
        }
    }
    
    private func downloadShotsForTeamMembers() {
        teamMembers.forEach { member in
            firstly {
                shotsProvider.provideShotsForUser(member)
            }.then { shots -> Void in
                guard let shots = shots else { return }
                guard let index = self.teamMembers.index(where: { $0.identifier == member.identifier }) else { return }
                self.teamMemberShots[index] = shots
                let indexPath = IndexPath(row: index, section: 0)
                self.delegate?.viewModel(self, didLoadShotsForItemAtIndexPath: indexPath)
            }.catch { error in
                self.notifyDelegateAboutFailure(error)
            }
        }
    }

    func team(forIndex index: Int) -> TeamType {
        return userTeams[index]
    }

    func member(forIndex index: Int) -> UserType {
        return teamMembers[index]
    }

    func shots(forIndex index: Int) -> [ShotType]? {
        return teamMemberShots[index]
    }
    
    func downloadItem(at index: Int) { /* empty */ }
    
}

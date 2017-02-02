//
//  ProfileProjectsViewModel.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

class ProfileProjectsViewModel: ProfileProjectsOrBucketsViewModel {

    weak var delegate: BaseCollectionViewViewModelDelegate?
    var projects = [ProjectType]()
    var projectsIndexedShots = [Int: [ShotType]]()

    fileprivate let projectsProvider = ProjectsProvider()
    fileprivate let shotsProvider = ShotsProvider()
    fileprivate var user: UserType

    var itemsCount: Int {
        return projects.count
    }

    init(user: UserType) {
        self.user = user
    }

    func downloadInitialItems() {
        firstly {
            projectsProvider.provideProjectsForUser(user)
        }.then {
            projects -> Void in
            var projectsShouldBeReloaded = true
            if let projects = projects {
                if projects == self.projects && projects.count != 0 {
                    projectsShouldBeReloaded = false
                }
                self.projects = projects
                self.downloadShots(projects)
            }
            if projectsShouldBeReloaded {
                self.delegate?.viewModelDidLoadInitialItems()
            }
        }.catch {
            error in
            self.delegate?.viewModelDidFailToLoadInitialItems(error)
        }
    }

    func downloadItemsForNextPage() {
        guard UserStorage.isUserSignedIn else {
            return
        }
        firstly {
            projectsProvider.nextPage()
        }.then {
            projects -> Void in
            if let projects = projects, projects.count > 0 {
                let indexes = projects.enumerated().map {
                    index, _ in
                    return index + self.projects.count
                }
                self.projects.append(contentsOf: projects)
                let indexPaths = indexes.map {
                    IndexPath(row: ($0), section: 0)
                }
                self.delegate?.viewModel(self, didLoadItemsAtIndexPaths: indexPaths)
            }
        }.catch { error in
            self.notifyDelegateAboutFailure(error)
        }
    }
    
    func downloadItem(at index: Int) { /* empty */ }
    
    func downloadShots(_ projects: [ProjectType]) {
        for project in projects {
            firstly {
                shotsProvider.provideShotsForProject(project)
            }.then {
                shots -> Void in
                var projectsShotsShouldBeReloaded = true
                var indexOfProjects: Int?
                for (index, item) in self.projects.enumerated() {
                    if item.identifier == project.identifier {
                        indexOfProjects = index
                        break
                    }
                }
                guard let index = indexOfProjects else {
                    return
                }
                if let oldShots = self.projectsIndexedShots[index], let newShots = shots {
                    projectsShotsShouldBeReloaded = oldShots != newShots
                }
                if let shots = shots {
                    self.projectsIndexedShots[index] = shots
                } else {
                    self.projectsIndexedShots[index] = [ShotType]()
                }
                if projectsShotsShouldBeReloaded {
                    let indexPath = IndexPath(row: index, section: 0)
                    self.delegate?.viewModel(self, didLoadShotsForItemAtIndexPath: indexPath)
                }
            }.catch { error in
                self.notifyDelegateAboutFailure(error)
            }
        }
    }

    func projectTableViewCellViewData(_ indexPath: IndexPath) -> ProfileProjectTableViewCellViewData {
        return ProfileProjectTableViewCellViewData(project: projects[indexPath.row],
                                                  shots: projectsIndexedShots[indexPath.row])
    }

    func clearViewModelIfNeeded() {
        projects = []
        delegate?.viewModelDidLoadInitialItems()
    }
}

extension ProfileProjectsViewModel {

    struct ProfileProjectTableViewCellViewData {
        let name: String
        let numberOfShots: String
        let shots: [ShotType]?

        init(project: ProjectType, shots: [ShotType]?) {
            if let name = project.name {
                self.name = name
            } else {
                self.name = ""
            }
            self.numberOfShots = String(format: "%d", project.shotsCount)
            if let shots = shots, shots.count > 0 {
                self.shots = shots
            } else {
                self.shots = nil
            }
        }
    }
}

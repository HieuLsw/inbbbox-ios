//
//  ProfileProjectsViewModelSpec.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

@testable import Inbbbox

class ProfileProjectsViewModelSpec: QuickSpec {

    override func spec() {

        var sut: ProfileProjectsViewModelMock!
        let fixtureProjectName = "fixture.name"
        let fixtureNumberOfShots = "4"

        beforeEach {
            sut = ProfileProjectsViewModelMock(user: User.fixtureUser())
        }

        afterEach {
            sut = nil
        }

        describe("When initialized") {

            it("should have proper number of projects") {
                expect(sut.itemsCount).to(equal(0))
            }
        }

        describe("When downloading initial data") {

            beforeEach {
                sut.downloadInitialItems()
            }

            it("should have proper number of projects") {
                expect(sut.itemsCount).to(equal(2))
            }

            it("should return proper cell data for index path") {
                let indexPath = IndexPath(row: 0, section: 0)
                let cellData = sut.projectTableViewCellViewData(indexPath)
                expect(cellData.name).to(equal(fixtureProjectName))
                expect(cellData.numberOfShots).to(equal(fixtureNumberOfShots))
                expect(cellData.shots).toNotEventually(beNil())
                expect(cellData.shots).toEventually(haveCount(1))
            }
        }

        describe("When downloading data for next page") {

            beforeEach {
                sut.downloadItemsForNextPage()
            }

            it("should have proper number of projects") {
                expect(sut.itemsCount).to(equal(3))
            }

            it("should return proper shot data for index path") {
                let indexPath = IndexPath(row: 1, section: 0)
                let cellData = sut.projectTableViewCellViewData(indexPath)
                expect(cellData.name).to(equal(fixtureProjectName))
                expect(cellData.numberOfShots).to(equal(fixtureNumberOfShots))
                expect(cellData.shots).toNotEventually(beNil())
                expect(cellData.shots).toEventually(haveCount(1))
            }
        }

        /// In this test, we won't override `downloadItemsForNextPage` method.
        describe("When truly downloading data for next page") {

            let fakeDelegate = ViewModelDelegate()

            beforeEach {
                sut.delegate = fakeDelegate
                sut.shouldCallNextPageDownloadSuper = true
                sut.downloadItemsForNextPage()
            }

            it("should notify delegate about failure") {
                expect(fakeDelegate.didCallDelegate).toEventually(beTrue())
            }
        }
    }
}

//Explanation: Create mock class to override methods from BaseCollectionViewViewModel.

private class ProfileProjectsViewModelMock: ProfileProjectsViewModel {

    var shouldCallNextPageDownloadSuper = false

    override func downloadInitialItems() {
        let project = Project.fixtureProject()
        projects = [project, project]
        downloadShots(projects)
    }

    override func downloadItemsForNextPage() {
        let project = Project.fixtureProject()
        projects = [project, project, project]
        downloadShots(projects)

        if shouldCallNextPageDownloadSuper {
            super.downloadItemsForNextPage()
        }
    }

    override func downloadShots(_ projects: [ProjectType]) {
        for index in 0...projects.count - 1 {
            projectsIndexedShots[index] = [Shot.fixtureShot()]
        }
    }
}

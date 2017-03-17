//
//  ManagedProjectsProviderSpec.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

import Quick
import Nimble
import CoreData
import PromiseKit

@testable import Inbbbox

class ManagedProjectsProviderSpec: QuickSpec {
    
    override func spec() {
        
        var sut: ManagedProjectsProvider!
        var inMemoryManagedObjectContext: NSManagedObjectContext!
        
        beforeEach {
            inMemoryManagedObjectContext = setUpInMemoryManagedObjectContext()
            sut = ManagedProjectsProvider(managedObjectContext: inMemoryManagedObjectContext)
        }
        
        afterEach {
            inMemoryManagedObjectContext = nil
            sut = nil
        }
        
        it("should have managed object context") {
            expect(sut.managedObjectContext).toNot(beNil())
        }
        
        describe("provide projects for shot") {
            
            var project: ProjectType!
            var shot: ManagedShot!
            
            beforeEach {
                let managedObjectsProvider = ManagedObjectsProvider(managedObjectContext: inMemoryManagedObjectContext)
                shot = managedObjectsProvider.managedShot(Shot.fixtureShot())
                let json = JSONSpecLoader.sharedInstance.jsonWithResourceName("Project")
                project = managedObjectsProvider.managedProject(Project.map(json))
                shot.projects = [project]
            }
            
            it("should return 1 project") {
                let promise = sut.provideProjectsForShot(shot)
                
                expect(promise).to(resolveWithValueMatching { projects in
                    expect(projects).to(haveCount(1))
                    expect(projects?.first?.identifier).to(equal(project.identifier))
                })
            }
        }
    }
}

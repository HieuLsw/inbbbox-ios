//
//  SettingsViewModelSpec.swift
//  Inbbbox
//
//  Created by Peter Bruz on 30/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

@testable import Inbbbox

class SettingsViewModelSpec: QuickSpec {

    override func spec() {

        var sut: SettingsViewModel!

        describe("when newly created as guest user") {

            beforeEach {
                UserStorage.clearUser()
                sut = SettingsViewModel(delegate: SettingsViewController())
            }

            afterEach {
                sut = nil
            }

            it("should have account title") {
                expect(sut.title).to(equal("Account & Settings"))
            }

            it("should have 5 sections") {
                expect(sut.sectionsCount()).to(equal(6))
            }

            describe("first section") {

                it("should have 1 items") {
                    expect(sut.sections[0].count).to(equal(1))
                }

                describe("first item") {
                    it("should be label item") {
                        let item = sut.sections[0][0]
                        expect(item is LabelItem).to(beTrue())
                    }
                }
            }

            describe("second section") {

                it("should have 2 items") {
                    expect(sut.sections[1].count).to(equal(2))
                }

                describe("first item") {
                    it("should be switch item") {
                        let item = sut.sections[1][0]
                        expect(item is SwitchItem).to(beTrue())
                    }
                }

                describe("second item") {
                    it("should be date item") {
                        let item = sut.sections[1][1]
                        expect(item is DateItem).to(beTrue())
                    }
                }
            }

            describe("third section") {

                it("should have 3 items") {
                    expect(sut.sections[2].count).to(equal(3))
                }

                describe("first item") {
                    it("should be switch item") {
                        let item = sut.sections[2][0]
                        expect(item is SwitchItem).to(beTrue())
                    }
                }

                describe("second item") {
                    it("should be switch item") {
                        let item = sut.sections[2][1]
                        expect(item is SwitchItem).to(beTrue())
                    }
                }

                describe("third item") {
                    it("should be switch item") {
                        let item = sut.sections[2][2]
                        expect(item is SwitchItem).to(beTrue())
                    }
                }
            }

            describe("fourth section") {

                it("should have 2 items") {
                    expect(sut.sections[3].count).to(equal(2))
                }

                describe("first item") {
                    it("should be switch item") {
                        let item = sut.sections[3][0]
                        expect(item is SwitchItem).to(beTrue())
                    }
                }
                
                describe("second item") {
                    it("should be switch item") {
                        let item = sut.sections[3][1]
                        expect(item is SwitchItem).to(beTrue())
                    }
                }
            }

            describe("fifth section") {

                it("should have 1 item") {
                    expect(sut.sections[4].count).to(equal(1))
                }

                describe("first item") {
                    it("should be ? item") {
                        let item = sut.sections[4][0]
                        expect(item is LabelItem).to(beTrue())
                    }
                }
            }
            
            describe("sixth section") {
                
                it("should have 1 item") {
                    expect(sut.sections[5].count).to(equal(1))
                }
                
                describe("first item") {
                    it("should be ? item") {
                        let item = sut.sections[5][0]
                        expect(item is LabelItem).to(beTrue())
                    }
                }
            }
        }

        describe("when newly created as logged user") {

            beforeEach {
                UserStorage.storeUser(User.fixtureUser())
                sut = SettingsViewModel(delegate: SettingsViewController())
            }

            afterEach {
                sut = nil
                UserStorage.clearUser()
            }

            it("should have account title") {
                expect(sut.title).to(equal("Account & Settings"))
            }

            it("should have 4 sections") {
                expect(sut.sectionsCount()).to(equal(5))
            }

            describe("first section") {

                it("should have 2 items") {
                    expect(sut.sections[0].count).to(equal(2))
                }

                describe("first item") {
                    it("should be switch item") {
                        let item = sut.sections[0][0]
                        expect(item is SwitchItem).to(beTrue())
                    }
                }

                describe("second item") {
                    it("should be date item") {
                        let item = sut.sections[0][1]
                        expect(item is DateItem).to(beTrue())
                    }
                }
            }

            describe("second section") {

                it("should have 4 items") {
                    expect(sut.sections[1].count).to(equal(4))
                }

                describe("first item") {
                    it("should be switch item") {
                        let item = sut.sections[1][0]
                        expect(item is SwitchItem).to(beTrue())
                    }
                }

                describe("second item") {
                    it("should be switch item") {
                        let item = sut.sections[1][1]
                        expect(item is SwitchItem).to(beTrue())
                    }
                }

                describe("third item") {
                    it("should be switch item") {
                        let item = sut.sections[1][2]
                        expect(item is SwitchItem).to(beTrue())
                    }
                }

                describe("fourth item") {
                    it("should be switch item") {
                        let item = sut.sections[1][3]
                        expect(item is SwitchItem).to(beTrue())
                    }
                }
            }

            describe("third section") {
                
                it("should have 2 items") {
                    expect(sut.sections[2].count).to(equal(2))
                }

                describe("first item") {
                    it("should be switch item") {
                        let item = sut.sections[2][0]
                        expect(item is SwitchItem).to(beTrue())
                    }
                }
                
                describe("second item") {
                    it("should be switch item") {
                        let item = sut.sections[2][1]
                        expect(item is SwitchItem).to(beTrue())
                    }
                }
            }

            describe("fourth section") {

                it("should have 1 item") {
                    expect(sut.sections[3].count).to(equal(1))
                }

                describe("first item") {
                    it("should be ? item") {
                        let item = sut.sections[3][0]
                        expect(item is LabelItem).to(beTrue())
                    }
                }
            }
            
            describe("fifth section") {
                
                it("should have 1 item") {
                    expect(sut.sections[4].count).to(equal(1))
                }
                
                describe("first item") {
                    it("should be ? item") {
                        let item = sut.sections[4][0]
                        expect(item is LabelItem).to(beTrue())
                    }
                }
            }
        }
    }
}

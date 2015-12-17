//
//  ShotsQuerySpec.swift
//  Tindddler
//
//  Created by Radoslaw Szeja on 14/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

import Tindddler

@testable import Tindddler

class ShotsQuerySpec: QuickSpec {
    override func spec() {
        
        var sut: ShotsQuery!
        
        beforeEach {
            sut = ShotsQuery()
        }
        
        afterEach {
            sut = nil
        }
        
        describe("when newly initiliazed") {
            
            it("should have correct method") {
                expect(sut.method.rawValue).to(equal("GET"))
            }
            
            it("should have correct path") {
                expect(sut.path).to(equal("/shots"))
            }
            
            it("should have correct service instance") {
                expect(sut.service is DribbbleNetworkService).to(beTrue())
            }
            
            it("should have correct parameters encoding") {
                expect(sut.parameters.encoding).to(equal(Parameters.Encoding.URL))
            }
            
            it("should have nil list parameter") {
                expect(sut.list).to(beNil())
            }
            
            it("should have nil time frame parameter") {
                expect(sut.timeFrame).to(beNil())
            }
            
            it("should have nil date parameter") {
                expect(sut.date).to(beNil())
            }
            
            it("should have nil sort parameter") {
                expect(sut.sort).to(beNil())
            }
            
            describe("changing list parameter to") {
                
                afterEach {
                    sut.list = nil
                }
                
                context("animated") {
                    beforeEach {
                        sut.list = .Animated
                    }
                    
                    it("should have value") {
                        expect(sut.list).to(equal(ShotsQuery.List.Animated))
                    }
                }
                
                context("attachments") {
                    beforeEach {
                        sut.list = .Attachments
                    }
                    
                    it("should have value") {
                        expect(sut.list).to(equal(ShotsQuery.List.Attachments))
                    }
                }
                
                context("debuts") {
                    beforeEach {
                        sut.list = .Debuts
                    }
                    
                    it("should have value") {
                        expect(sut.list).to(equal(ShotsQuery.List.Debuts))
                    }
                }
                
                context("playoffs") {
                    beforeEach {
                        sut.list = .Playoffs
                    }
                    
                    it("should have value") {
                        expect(sut.list).to(equal(ShotsQuery.List.Playoffs))
                    }
                }
                
                context("rebounds") {
                    beforeEach {
                        sut.list = .Rebounds
                    }
                    
                    it("should have value") {
                        expect(sut.list).to(equal(ShotsQuery.List.Rebounds))
                    }
                }
                
                context("teams") {
                    beforeEach {
                        sut.list = .Teams
                    }
                    
                    it("should have value") {
                        expect(sut.list).to(equal(ShotsQuery.List.Teams))
                    }
                }
                
            }
            
            describe("changing time frame parameter to") {
                
                afterEach {
                    sut.timeFrame = nil
                }
                
                context("week") {
                    beforeEach {
                        sut.timeFrame = .Week
                    }
                    
                    it("should have value") {
                        expect(sut.timeFrame).to(equal(ShotsQuery.TimeFrame.Week))
                    }
                }
                
                context("month") {
                    beforeEach {
                        sut.timeFrame = .Month
                    }
                    
                    it("should have value") {
                        expect(sut.timeFrame).to(equal(ShotsQuery.TimeFrame.Month))
                    }
                }
                
                context("year") {
                    beforeEach {
                        sut.timeFrame = .Year
                    }
                    
                    it("should have value") {
                        expect(sut.timeFrame).to(equal(ShotsQuery.TimeFrame.Year))
                    }
                }
                
                context("ever") {
                    beforeEach {
                        sut.timeFrame = .Ever
                    }
                    
                    it("should have value") {
                        expect(sut.timeFrame).to(equal(ShotsQuery.TimeFrame.Ever))
                    }
                }
            }
            
            describe("changing date parameter") {
                
                var  date: NSDate!
                
                beforeEach {
                    let components = NSDateComponents()
                    components.calendar = NSCalendar.currentCalendar()
                    components.day = 3
                    components.month = 3
                    components.year = 2015
                    date = components.date
                    sut.date = date
                }
                
                afterEach {
                    sut.date = nil
                }
             
                it("should have correct date") {
                    expect(sut.date).to(equal(date))
                }
            }
            
            describe("changing sort parameter to") {
                
                context("commnets") {
                    beforeEach {
                        sut.sort = .Comments
                    }
                    
                    it("should have correct value") {
                        expect(sut.sort).to(equal(ShotsQuery.Sort.Comments))
                    }
                }
                
                context("recent") {
                    beforeEach {
                        sut.sort = .Recent
                    }
                    
                    it("should have correct value") {
                        expect(sut.sort).to(equal(ShotsQuery.Sort.Recent))
                    }
                }
                
                context("views") {
                    beforeEach {
                        sut.sort = .Views
                    }
                    
                    it("should have correct value") {
                        expect(sut.sort).to(equal(ShotsQuery.Sort.Views))
                    }
                }
            }
        }
    }
}
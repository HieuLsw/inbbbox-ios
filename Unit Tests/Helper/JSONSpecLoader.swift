//
//  JSONLoader.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 27/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import SwiftyJSON
@testable import Inbbbox


class JSONSpecLoader {
    
    static let sharedInstance = JSONSpecLoader()

    func jsonWithResourceName(name: String) -> JSON {
        
        let file = NSBundle(forClass: self.dynamicType).pathForResource(name, ofType:"json")
        let data = NSData(contentsOfFile: file!)
        return JSON(data: data!)
    }
    
    func fixtureShotJSON(configuration: [(identifier: Int, animated: Bool)]) -> [JSON] {
        
        let json = fixtureJSONArrayWithResourceName("Shot", count: configuration.count)
        var array = [JSON]()
        
        for (index, var element) in json.enumerate() {
            element["animated"].boolValue = configuration[index].animated
            element["id"].intValue = configuration[index].identifier
            
            array.append(element)
        }

        return array
    }
    
    func fixtureBucketsJSON(withCount count: Int) -> [JSON] {
        return fixtureJSONArrayWithResourceName("Bucket", count: count)
    }
    
    func fixtureFolloweeConnectionsJSON(withCount count: Int) -> [JSON] {
        return fixtureJSONArrayWithResourceName("FolloweeConnection", count: count)
    }
    
    func fixtureFollowerConnectionsJSON(withCount count: Int) -> [JSON] {
        return fixtureJSONArrayWithResourceName("FollowerConnection", count: count)
    }
    
    func fixtureCommentsJSON(withCount count: Int) -> [JSON] {
        return fixtureJSONArrayWithResourceName("Comment", count: count)
    }
    
    func fixtureProjectsJSON(withCount count: Int) -> [JSON] {
        return fixtureJSONArrayWithResourceName("Project", count: count)
    }
}

private extension JSONSpecLoader {
    
    func fixtureJSONArrayWithResourceName(name: String, count: Int) -> [JSON] {
        
        var array = [JSON]()
        
        for i in 0..<count {
            var json = JSONSpecLoader.sharedInstance.jsonWithResourceName(name)
            json["id"].intValue = i+1
            
            array.append(json)
        }
        
        return array
    }
}

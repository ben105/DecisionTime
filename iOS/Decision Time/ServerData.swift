//
//  ServerData.swift
//  Decision Time
//
//  Created by Ben Rooke on 1/2/17.
//
//

import Foundation

class Topic {
    let identifier: Int
    let title: String
    let score: Int
    
    private init(identifier: Int, title: String, score: Int) {
        self.identifier = identifier
        self.title = title
        self.score = score
    }
    
    static func PoliticalTopic(withData data: [String: AnyObject?]) -> Topic? {
        guard let title = data["title"] as? String else {
            return nil
        }
        var score = data["score"] as? Int
        if score == nil {
            score = 0
        }
        guard let id = data["topic_id"] as? Int else {
            return nil
        }
        return Topic(identifier: id, title: title, score: score!)
    }
}

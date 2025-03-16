//
//  Item.swift
//  Toybox Connect
//
//  Created by Darren Candra on 15/3/2025.
//

import Foundation
import SwiftData

struct QuizResponse: Identifiable, Codable {
    var id = UUID()
    var question: String
    var answer: Bool?
}

@Model
final class Item {
    var name: String
    var timestamp: Date
    var friendship: Int
    var answers: [QuizAnswer]
    
    init(name: String, timestamp: Date, friendship: Int, answers: [QuizAnswer] = []) {
        self.name = name
        self.timestamp = timestamp
        self.friendship = friendship
        self.answers = answers
    }
}

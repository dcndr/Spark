//
//  Item.swift
//  Toybox Connect
//
//  Created by Darren Candra on 15/3/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

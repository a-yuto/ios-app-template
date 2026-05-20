//
//  Item.swift
//  ios-app-template
//
//  Created by araki on 2026/05/20.
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

//
//  Item.swift
//  nypattendance
//
//  Created by Tan Thor Jen on 21/10/24.
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

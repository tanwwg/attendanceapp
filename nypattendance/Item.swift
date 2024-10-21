//
//  Item.swift
//  nypattendance
//
//  Created by Tan Thor Jen on 21/10/24.
//

import Foundation
import SwiftData

struct Student: Codable, Identifiable {
    var id: String { admissionNumber }

    var order: Int
    var name: String
    var admissionNumber: String
    
    var orderStr: String { String(order) }
}

@Model
final class Class {
    @Attribute(.unique)
    var id: UUID
    
    var timestamp: Date
    
    var name: String
    var students: [Student] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Attendance.parentClass)
    var attendance: [Attendance] = []
    
    init(name: String) {
        self.id = UUID()  // Automatically generate a unique UUID
        self.timestamp = Date.now
        self.name = name
    }
    
}

struct Attendee: Codable, Identifiable {
    var id: String { admissionNumber }

    var order: Int
    var name: String
    var admissionNumber: String
    
    var isAttend: Bool = false
    var remarks: String = ""
    
    var orderStr: String { String(order) }
}

@Model
final class Attendance {
    @Attribute(.unique)
    var id: UUID
    
    var timestamp: Date
    
    var parentClass: Class?
    var attendees: [Attendee] = []
    
    init(parent: Class) {
        self.id = UUID()  // Automatically generate a unique UUID
        self.timestamp = Date.now
        
        self.parentClass = parent
        self.attendees = parent.students.map { Attendee(order: $0.order, name: $0.name, admissionNumber: $0.admissionNumber, isAttend: false) }
    }
    
}

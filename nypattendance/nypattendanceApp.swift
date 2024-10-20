//
//  nypattendanceApp.swift
//  nypattendance
//
//  Created by Tan Thor Jen on 21/10/24.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

@main
struct nypattendanceApp: App {
    var body: some Scene {
        DocumentGroup(editing: .itemDocument, migrationPlan: nypattendanceMigrationPlan.self) {
            ContentView()
        }
    }
}

extension UTType {
    static var itemDocument: UTType {
        UTType(importedAs: "com.example.item-document")
    }
}

struct nypattendanceMigrationPlan: SchemaMigrationPlan {
    static var schemas: [VersionedSchema.Type] = [
        nypattendanceVersionedSchema.self,
    ]

    static var stages: [MigrationStage] = [
        // Stages of migration between VersionedSchema, if required.
    ]
}

struct nypattendanceVersionedSchema: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] = [
        Item.self,
    ]
}

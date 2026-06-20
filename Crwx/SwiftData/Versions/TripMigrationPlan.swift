//
//  TripMigrationPlan.swift
//  Mewx
//
//  Created by Matthew Goacher on 2/13/25.
//

import Foundation
import SwiftData
import WxSalt

public typealias CurrentSchema = TripSchemaV20

struct TripMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] = [
        TripSchemaV1.self,
        TripSchemaV2.self,
        TripSchemaV3.self,
        TripSchemaV4.self,
        TripSchemaV5.self,
        TripSchemaV6.self,
        TripSchemaV7.self,
        TripSchemaV8.self,
        TripSchemaV9.self,
        TripSchemaV10.self,
        TripSchemaV11.self,
        TripSchemaV12.self,
        TripSchemaV13.self,
        TripSchemaV14.self,
        TripSchemaV15.self,
        TripSchemaV16.self,
        TripSchemaV17.self,
        TripSchemaV18.self,
        TripSchemaV19.self,
        TripSchemaV20.self
    ]
    static var stages: [MigrationStage] = [
        migrateV1toV2,
        migrateV2toV3,
        migrateV3toV4,
        migrateV4toV5,
        migrateV5toV6,
        migrateV6toV7,
        migrateV7toV8,
        migrateV8toV9,
        migrateV9toV10,
        migrateV10toV11,
        migrateV11toV12,
        migrateV12toV13,
        migrateV13toV14,
        migrateV14toV15,
        migrateV15toV16,
        migrateV16toV17,
        migrateV17toV18,
        migrateV18toV19,
        migrateV19toV20
    ]
    
    static let migrateV1toV2: MigrationStage = .custom(fromVersion: TripSchemaV1.self, toVersion: TripSchemaV2.self, willMigrate: nil, didMigrate: nil)
    static let migrateV3toV4: MigrationStage = .custom(fromVersion: TripSchemaV3.self, toVersion: TripSchemaV4.self, willMigrate: nil, didMigrate: nil)
    static let migrateV4toV5: MigrationStage = .custom(fromVersion: TripSchemaV4.self, toVersion: TripSchemaV5.self, willMigrate: nil, didMigrate: nil)
    static let migrateV5toV6: MigrationStage = .custom(fromVersion: TripSchemaV5.self, toVersion: TripSchemaV6.self, willMigrate: nil, didMigrate: nil)
    static let migrateV6toV7: MigrationStage = .custom(fromVersion: TripSchemaV6.self, toVersion: TripSchemaV7.self, willMigrate: nil, didMigrate: nil)
    static let migrateV10toV11: MigrationStage = .custom(fromVersion: TripSchemaV10.self, toVersion: TripSchemaV11.self, willMigrate: nil, didMigrate: nil)
    static let migrateV12toV13: MigrationStage = .custom(fromVersion: TripSchemaV12.self, toVersion: TripSchemaV13.self, willMigrate: nil, didMigrate: nil)
    static let migrateV14toV15: MigrationStage = .custom(fromVersion: TripSchemaV14.self, toVersion: TripSchemaV15.self, willMigrate: nil, didMigrate: nil)
    static let migrateV15toV16: MigrationStage = .custom(fromVersion: TripSchemaV15.self, toVersion: TripSchemaV16.self, willMigrate: nil, didMigrate: nil)
    static let migrateV16toV17: MigrationStage = .custom(fromVersion: TripSchemaV16.self, toVersion: TripSchemaV17.self, willMigrate: nil, didMigrate: nil)
    static let migrateV17toV18: MigrationStage = .custom(fromVersion: TripSchemaV17.self, toVersion: TripSchemaV18.self, willMigrate: nil, didMigrate: nil)
    static let migrateV18toV19: MigrationStage = .custom(fromVersion: TripSchemaV18.self, toVersion: TripSchemaV19.self, willMigrate: nil, didMigrate: nil)
    static let migrateV19toV20: MigrationStage = .custom(fromVersion: TripSchemaV19.self, toVersion: TripSchemaV20.self, willMigrate: nil, didMigrate: nil)
}
extension Schema {
    public static var tripSchema: Schema {
        .init(versionedSchema: CurrentSchema.self)
    }
}
@MainActor
var appContainer: ModelContainer {
    do {
        let container = try ModelContainer(for: .init(versionedSchema: CurrentSchema.self), migrationPlan: TripMigrationPlan.self, configurations: [])
//        if try container.mainContext.fetchCount(LocationProfile.self) == 0 {
//            for location in LocationProfileViewModel.samples {
//                let new = LocationProfile(viewModel: location)
//                container.mainContext.insert(new)
//            }
//            try container.mainContext.save()
//        }
        return container
    } catch {
        fatalError("Failed to create SwiftData container")
    }
}


@MainActor
let previewContainer: ModelContainer = {
    do {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try ModelContainer(for: .tripSchema, configurations: configuration)
        let trips = Trip.previews(complete: 4, incompletion: nil)
        for trip in trips {
            container.mainContext.insert(trip)
        }
        for location in LocationProfileViewModel.samples {
            let new = LocationProfile(viewModel: location)
            container.mainContext.insert(new)
        }
        try container.mainContext.save()
        return container
    }
    catch {
        fatalError("Failed to create preview container")
    }
}()



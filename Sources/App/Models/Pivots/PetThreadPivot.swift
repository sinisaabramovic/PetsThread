//
//  PetThreadPivot.swift
//  App
//
//  Created by Sinisa Abramovic on 15/02/2020.
//

import Foundation
import FluentPostgreSQL

final class PetThreadPivot: PostgreSQLUUIDPivot {
    
    var id: UUID?
    var petID: Pet.ID
    var threadID: PetThread.ID
    
    typealias Left = Pet
    typealias Right = PetThread
    static let leftIDKey: LeftIDKey = \.petID
    static let rightIDKey: RightIDKey = \.threadID
    
    init(_ pet: Pet, _ thread: PetThread) throws {
        self.petID = try pet.requireID()
        self.threadID = try thread.requireID()
    }
}

extension PetThreadPivot: ModifiablePivot {}

extension PetThreadPivot: Migration {
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.petID, to: \Pet.id, onDelete: .cascade)
            builder.reference(from: \.threadID, to: \PetThread.id, onDelete: .cascade)
        }
    }
    
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return .done(on: connection)
    }
    
}

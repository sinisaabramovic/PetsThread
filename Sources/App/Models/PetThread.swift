//
//  PetThread.swift
//  App
//
//  Created by Sinisa Abramovic on 14/02/2020.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class PetThread: Codable {
    
    var id: Int?
    var userID: UUID?
    var petID: Int?
    
    var typeID: PetThreadType.ID
    
    var threadName: String?
    var threadDescription: String?
    var dateCreated: Date?
    var isActive: Bool?
    var executionInSeconds: Int?
    var imageURL: String?
    
    init(name: String, threadDescription: String, userID: UUID, petID: Int, dateCreated: Date, isActive: Bool, executeIn: Int, type: PetThreadType.ID, imageURL: String) {
        self.threadName = name
        self.threadDescription = threadDescription
        self.userID = userID
        self.petID = petID
        self.dateCreated = dateCreated
        self.isActive = isActive
        self.executionInSeconds = executeIn
        self.typeID = type
        self.imageURL = imageURL
    }
}


extension PetThread: Content {}
extension PetThread: Parameter {}

extension PetThread: PostgreSQLModel {
    static var entity: String = "Threads"
}

extension PetThread: Migration {
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
         return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
            builder.reference(from: \.typeID, to: \PetThreadType.id)
            builder.reference(from: \.petID, to: \Pet.id)
         }
     }
    
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return .done(on: connection)
    }
}

extension PetThread {
    var pets: Siblings<PetThread, Pet, PetThreadPivot> {
      return siblings()
    }
}


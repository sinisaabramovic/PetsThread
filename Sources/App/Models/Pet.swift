import Foundation
import Vapor
import FluentPostgreSQL

final class Pet: Codable {
    var id: Int?
    var userID: User.ID    
    var typeID: PetType.ID
    
    var name: String
    var age: Int
    var imageURL: String
    
    init(name: String, type: PetType.ID, age: Int, userID: User.ID, imageURL: String) {
        self.name = name
        self.typeID = type
        self.age = age
        self.userID = userID
        self.imageURL = imageURL
    }
}

extension Pet: Content {}
extension Pet: Parameter {}

extension Pet: PostgreSQLModel {
    static var entity: String = "Pets"
}

extension Pet: Migration {
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
            builder.reference(from: \.typeID, to: \PetType.id)
        }
    }
    
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return .done(on: connection)
    }
}

extension Pet {
    var user: Parent<Pet, User> {
        return parent(\.userID)
    }
    
    var typeOf: Parent<Pet, PetType> {
        return parent(\.typeID)
    }
    
    var threads: Siblings<Pet, PetThread, PetThreadPivot> {
      return siblings()
    }
    
    func configure(with pet: PetCreateData) {
        self.name = pet.name
        self.typeID = pet.typeID
        self.age = pet.age
        self.imageURL = pet.imageURL
    }
}


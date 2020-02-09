import Foundation
import Vapor
import FluentPostgreSQL

final class Pet: Codable {
    var id: Int?
    var userID: User.ID
    var name: String
    var typeID: PetType.ID
    var age: Int
    
    init(name: String, type: PetType.ID, age: Int, userID: User.ID) {
        self.name = name
        self.typeID = type
        self.age = age
        self.userID = userID
    }
}

extension Pet: PostgreSQLModel {}

extension Pet: Migration {
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

extension Pet: Content {}

extension Pet: Parameter {}

extension Pet {
    var user: Parent<Pet, User> {
        return parent(\.userID)
    }
    var type: Parent<Pet, PetType> {
        return parent(\.typeID)
    }
}

// Useful Docker commands
//docker exec -it postgres psql -U vapor -d vapor
// Manage DB
//docker exec -it postgres psql -U vapor -d postgres -c "DROP DATABASE vapor;"
//docker exec -it postgres psql -U vapor -d postgres -c "CREATE DATABASE vapor;"

// Creates new docker image for PostgreSQL
// dokcer stop postgres
// docker rm postgres
// docker run --name postgres -e POSTGRES_DB=vapor -e POSTGRES_USER=vapor -e POSTGRES_PASSWORD=password -p 5432:5432 -d postgres


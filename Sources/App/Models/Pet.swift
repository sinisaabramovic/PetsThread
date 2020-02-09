import Foundation
import Vapor
import FluentPostgreSQL

final class Pet: Codable {
    var id: Int?
    var userID: User.ID
    var name: String
    var type: String
    var age: Int
    
    init(name: String, type: String, age: Int, userID: User.ID) {
        self.name = name
        self.type = type
        self.age = age
        self.userID = userID
    }
}

extension Pet: PostgreSQLModel {}

extension Pet: Migration {}

extension Pet: Content {}

extension Pet: Parameter {}

// Useful Docker commands
//docker exec -it postgres psql -U vapor -d vapor
// Manage DB
//docker exec -it postgres psql -U vapor -d postgres -c "DROP DATABASE vapor;"
//docker exec -it postgres psql -U vapor -d postgres -c "CREATE DATABASE vapor;"

// Creates new docker image for PostgreSQL
// docker run --name postgres -e POSTGRES_DB=vapor -e POSTGRES_USER=vapor -e POSTGRES_PASSWORD=password -p 5432:5432 -d postgres


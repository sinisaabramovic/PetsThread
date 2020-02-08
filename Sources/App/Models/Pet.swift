import Vapor
import FluentPostgreSQL

enum PetType: String, Codable  {
    case Dog
    case Cat
    case Fish
}

final class Pet: Codable {
    var id: Int?
    var name: String
    var type: PetType
    var age: Int
    
    init(name: String, type: PetType, age: Int) {
        self.name = name
        self.type = type
        self.age = age
    }
}

extension Pet: PostgreSQLModel {}

extension Pet: Migration {}

extension Pet: Content {}

extension Pet: Parameter {}

extension PetType: ReflectionDecodable {
    static func reflectDecoded() throws -> (PetType, PetType) {
        return (.Dog, .Cat)
    }
}

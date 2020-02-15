//
//  PetType.swift
//  App
//
//  Created by Sinisa Abramovic on 09/02/2020.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class PetType: Codable {
    var id: UUID?
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

extension PetType: Parameter {}
extension PetType: Content {}

extension PetType: PostgreSQLUUIDModel {
    static var entity: String = "Types"
}
extension PetType: Migration {
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.name)
        }
    }
    
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return .done(on: connection)
    }
}

struct BasePetTypes: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        let dog = PetType(name: "Dog")
        let cat = PetType(name: "Cat")
        let fish = PetType(name: "Fish")
        let spider = PetType(name: "Spider")
        let horse = PetType(name: "Horse")
        let iguana = PetType(name: "Iguana")
        
        _ = dog.save(on: connection).transform(to: ())
        _ = cat.save(on: connection).transform(to: ())
        _ = fish.save(on: connection).transform(to: ())
        _ = spider.save(on: connection).transform(to: ())
        _ = horse.save(on: connection).transform(to: ())
        
        return iguana.save(on: connection).transform(to: ())
    }
    
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return .done(on: connection)
    }
}



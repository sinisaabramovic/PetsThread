//
//  PetThreadType.swift
//  App
//
//  Created by Sinisa Abramovic on 14/02/2020.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class PetThreadType: Codable {
    var id: UUID?
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

extension PetThreadType: Content {}
extension PetThreadType: Parameter {}

extension PetThreadType: PostgreSQLUUIDModel {
    static var entity: String = "ThreadTypes"
}

extension PetThreadType: Migration {
    
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

struct BaseThreadTypes: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        let walk = PetThreadType(name: "Walk")
        let feed = PetThreadType(name: "Feed")
        let kiss = PetThreadType(name: "Kiss")
        let hello = PetThreadType(name: "Say Hello")
        
        _ = walk.save(on: connection).transform(to: ())
        _ = feed.save(on: connection).transform(to: ())
        _ = kiss.save(on: connection).transform(to: ())
        
        return hello.save(on: connection).transform(to: ())
    }
    
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return .done(on: connection)
    }
}


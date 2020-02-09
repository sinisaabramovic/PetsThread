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

extension PetType: PostgreSQLUUIDModel {}
extension PetType: Migration {}
extension PetType: Content {}
extension PetType: Parameter {}



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

extension PetThreadType: PostgreSQLUUIDModel {
    static var entity: String = "ThreadTypes"
}
extension PetThreadType: Migration {}
extension PetThreadType: Content {}
extension PetThreadType: Parameter {}

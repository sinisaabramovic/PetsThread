//
//  User.swift
//  App
//
//  Created by Sinisa Abramovic on 09/02/2020.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class User: Codable {
    var id: UUID?
    
    var name: String
    var username: String
    var password: String
    var imageURL: String
    
    init(name: String, username: String, password: String, imageURL: String) {
        self.name = name
        self.username = username
        self.password = password
        self.imageURL = imageURL
    }
}

extension User: PostgreSQLUUIDModel {
    static var entity: String = "Users"
}
extension User: Content {}
extension User: Migration {}
extension User: Parameter {}


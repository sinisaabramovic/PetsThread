//
//  UserController.swift
//  App
//
//  Created by Sinisa Abramovic on 09/02/2020.
//

import Foundation
import Vapor
import Fluent
import Crypto

struct UserController: RouteCollection {
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "users")
//        usersRoute.get(use: getAllHandler)
//        usersRoute.get(User.parameter, use: getHandler)        
        usersRoute.post(User.self, use: createHandler)
        
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: loginHandler)
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = usersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenAuthGroup.get(User.parameter, "pets", use: getPetsHandler)
    }
    
    func createHandler(_ req: Request, user: User) throws -> Future<User.Public> {
        user.password = try BCrypt.hash(user.password)
        return user.save(on: req).convertToPublic()
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[User.Public]> {
        return User.query(on: req).decode(data: User.Public.self).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).convertToPublic()
    }
    
    func getPetsHandler(_ req: Request) throws -> Future<[Pet]> {
      return try req.parameters.next(User.self).flatMap(to: [Pet].self) { user in
        try user.pet.query(on: req).all()
      }
    }

    func loginHandler(_ req: Request) throws -> Future<Token> {
      let user = try req.requireAuthenticated(User.self)
      let token = try Token.generate(for: user)
      return token.save(on: req)
    }
}

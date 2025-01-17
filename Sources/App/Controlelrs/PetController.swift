//
//  PetController.swift
//  App
//
//  Created by Sinisa Abramovic on 09/02/2020.
//

import Foundation
import Vapor
import Fluent
import Authentication

struct PetController: RouteCollection {
    
    func boot(router: Router) throws {
        let petRoutes = router.grouped("api", "pets")
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = petRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenAuthGroup.post(Pet.self, use: createHandler)
        tokenAuthGroup.put(Pet.parameter, use: updateHandler)
        tokenAuthGroup.delete(Pet.parameter, use: deleteHandler)
        tokenAuthGroup.post(Pet.parameter, "threads", PetThread.parameter, use: addThreadHandler)
        tokenAuthGroup.delete(Pet.parameter, "threads", PetThread.parameter, use: removeThreadHandler)
        tokenAuthGroup.get(use: getAllHandler)
        tokenAuthGroup.get(Pet.parameter, "threads", use: getThreadsHandler)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Pet]> {
        let user = try req.requireAuthenticated(User.self)
        let userID = try user.requireID()
        return Pet.query(on: req).group(.or) { or in
            or.filter(\.userID == userID)
        }.sort(\.id, .ascending).all()
    }
    
    func createHandler(_ req: Request, pet: Pet) throws -> Future<Pet> {
        let user = try req.requireAuthenticated(User.self)
        pet.userID = try user.requireID()
        return pet.save(on: req)
    }
    
    func updateHandler(_ req: Request) throws -> Future<Pet> {
        return try flatMap(to: Pet.self, req.parameters.next(Pet.self), req.content.decode(PetCreateData.self), { (pet, updatePet) in
            pet.configure(with: updatePet)
            let user = try req.requireAuthenticated(User.self)
            pet.userID = try user.requireID()
            
            return pet.save(on: req)
        })
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let isAccepted = try _isAccetable(on: req, for: "userID")
        if isAccepted {
            return try req
                .parameters
                .next(Pet.self)
                .delete(on: req)
                .transform(to: .noContent)
        } else {
            throw Abort(.badRequest)
        }
    }
    
    func searchHandler(_ req: Request) throws -> Future<[Pet]> {
        guard let search = req.query[String.self, at: "name"] else {
            throw Abort(.badRequest)
        }
        let user = try req.requireAuthenticated(User.self)
        let userID = try user.requireID()
        return Pet.query(on: req).group(.or) { or in
            or.filter(\.name == search).filter(\.userID == userID)
        }.all()
    }
    
    func getFirstHandler(_ req: Request) throws -> Future<Pet> {
        let isAccepted = try _isAccetable(on: req, for: "userID")
        if isAccepted {
            return Pet.query(on: req).first().unwrap(or: Abort(.notFound))
        } else {
            throw Abort(.badRequest)
        }
    }
    
    func sortedHandler(_ req: Request) throws -> Future<[Pet]> {
        let isAccepted = try _isAccetable(on: req, for: "userID")
        if isAccepted {
            return Pet.query(on: req).sort(\.name, .ascending).all()
        } else {
            throw Abort(.badRequest)
        }
    }
    
    func getUserHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(Pet.self).flatMap(to: User.Public.self, { pet in
            pet.user.get(on: req).convertToPublic()
        })
    }
    
    func getPetTypeHandler(_ req: Request) throws -> Future<PetType> {
        return try req.parameters.next(Pet.self).flatMap(to: PetType.self) { pet in
            pet.typeOf.get(on: req)
        }
    }
    
    func addThreadHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Pet.self),
                           req.parameters.next(PetThread.self)) { pet, thread in
                            return pet.threads.attach(thread, on: req).transform(to: .created)
        }
    }
    
    func getThreadsHandler(_ req: Request) throws -> Future<[PetThread]> {
        return try req.parameters.next(Pet.self).flatMap(to: [PetThread].self) { pet in
            try pet.threads.query(on: req).all()
        }
    }
    
    func removeThreadHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Pet.self),
                           req.parameters.next(PetThread.self)) { pet, thread in
                            return pet.threads.detach(thread, on: req).transform(to: .noContent)
        }
    }
}

private extension PetController {
    
    func _isAccetable(on req: Request, for param: String) throws -> Bool {
        guard let search = req.query[String.self, at: param] else {
            throw Abort(.badRequest)
        }
        let user = try req.requireAuthenticated(User.self)
        let userID = try user.requireID().uuidString
        
        return userID == search
    }
}

struct PetCreateData: Content {
    let name: String
    let age: Int
    let imageURL: String
    var typeID: PetType.ID
}

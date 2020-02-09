//
//  PetController.swift
//  App
//
//  Created by Sinisa Abramovic on 09/02/2020.
//

import Foundation
import Vapor
import Fluent

struct PetController: RouteCollection {
    
    func boot(router: Router) throws {
        let petRoutes = router.grouped("api", "pets")
        petRoutes.get(use: getAllHandler)
        petRoutes.post(use: createHandler)
        petRoutes.get(Pet.parameter, use: getHandler)
        petRoutes.put(Pet.parameter, use: updateHandler)
        petRoutes.delete(Pet.parameter, use: deleteHandler)
        petRoutes.get("search", use: searchHandler)
        petRoutes.get("first", use: getFirstHandler)
        petRoutes.get("sorted", use: sortedHandler)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Pet]> {
        return Pet.query(on: req).all()
    }
    
    func createHandler(_ req: Request) throws -> Future<Pet> {
        return try req
            .content
            .decode(Pet.self)
            .flatMap(to: Pet.self, { pet in
            return pet.save(on: req)
        })
    }
    
    func getHandler(_ req: Request) throws -> Future<Pet> {
        return try req.parameters.next(Pet.self)
    }
    
    func updateHandler(_ req: Request) throws -> Future<Pet> {
        return try flatMap(to: Pet.self, req.parameters.next(Pet.self), req.content.decode(Pet.self), { (pet, updatePet) in
            pet.name = updatePet.name
            pet.age = updatePet.age
            pet.type = updatePet.type
            
            return pet.save(on: req)
        })
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req
            .parameters
            .next(Pet.self)
            .delete(on: req)
            .transform(to: .noContent)
    }
    
    func searchHandler(_ req: Request) throws -> Future<[Pet]> {
        guard let search = req.query[String.self, at: "name"] else {
            throw Abort(.badRequest)
        }
        return Pet.query(on: req).group(.or) { or in
            or.filter(\.name == search)
            or.filter(\.type == search)
        }.all()
    }
    
    func getFirstHandler(_ req: Request) throws -> Future<Pet> {
        return Pet.query(on: req).first().unwrap(or: Abort(.notFound))
    }
    
    func sortedHandler(_ req: Request) throws -> Future<[Pet]> {
        return Pet.query(on: req).sort(\.name, .ascending).all()
    }
}

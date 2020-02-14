//
//  PetTypeConrtoller.swift
//  App
//
//  Created by Sinisa Abramovic on 09/02/2020.
//

import Foundation
import Vapor
import Fluent

struct PetTypeController: RouteCollection {
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "types")
        usersRoute.post(PetType.self, use: createHandler)
        usersRoute.get(use: getAllHandler)
        usersRoute.get(PetType.parameter, use: getHandler)
    }
    
    func createHandler(_ req: Request, type: PetType) throws -> Future<PetType> {
        return type.save(on: req)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[PetType]> {
        return PetType.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<PetType> {
        return try req.parameters.next(PetType.self)
    }
}

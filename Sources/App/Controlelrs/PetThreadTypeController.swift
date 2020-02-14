//
//  PetThreadTypeController.swift
//  App
//
//  Created by Sinisa Abramovic on 14/02/2020.
//

import Foundation
import Vapor
import Fluent

struct PetThreadTypeController: RouteCollection {
    func boot(router: Router) throws {
        let threadTypeRoute = router.grouped("api", "threadtypes")
        threadTypeRoute.post(PetThreadType.self, use: createHandler)
        threadTypeRoute.get(use: getAllHandler)
        threadTypeRoute.get(PetThreadType.parameter, use: getHandler)
    }
    
    func createHandler(_ req: Request, type: PetThreadType) throws -> Future<PetThreadType> {
        return type.save(on: req)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[PetThreadType]> {
        return PetThreadType.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<PetThreadType> {
        return try req.parameters.next(PetThreadType.self)
    }
}

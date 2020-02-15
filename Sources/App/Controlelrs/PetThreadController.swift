//
//  PetThreadController.swift
//  App
//
//  Created by Sinisa Abramovic on 14/02/2020.
//

import Foundation
import Vapor
import Fluent

struct PetThreadController: RouteCollection {
    
    func boot(router: Router) throws {
        let threadsRoute = router.grouped("api", "threads")
        threadsRoute.post(PetThread.self, use: createHandler)
        threadsRoute.get(use: getAllHandler)
    }
    
    func createHandler(_ req: Request, thread: PetThread) throws -> Future<PetThread> {
        return thread.save(on: req)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[PetThread]> {
        return PetThread.query(on: req).all()
    }
    
    func getAllForUserHandler(_ req: Request) throws -> Future<[PetThread]> {
        return PetThread.query(on: req).all()
    }
}

struct PetThreadCreateData: Content {
    let name: String
    let age: Int
    let imageURL: String
}

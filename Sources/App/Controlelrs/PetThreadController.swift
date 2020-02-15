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
        
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = threadsRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenAuthGroup.post(PetThread.self, use: createHandler)
        tokenAuthGroup.get(use: getAllHandler)
        tokenAuthGroup.get(use: getHandler)
        tokenAuthGroup.get(PetThread.parameter, "pets", use: getPetsHandler)
    }
    
    func createHandler(_ req: Request, thread: PetThread) throws -> Future<PetThread> {
        return thread.save(on: req)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[PetThread]> {
        return PetThread.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<PetThread> {
      return try req.parameters.next(PetThread.self)
    }
    
    func getAllForUserHandler(_ req: Request) throws -> Future<[PetThread]> {
        return PetThread.query(on: req).all()
    }
    
    func getPetsHandler(_ req: Request) throws -> Future<[Pet]> {
      return try req.parameters.next(PetThread.self).flatMap(to: [Pet].self) { thread in
        try thread.pets.query(on: req).all()
      }
    }
}

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
        //        tokenAuthGroup.get(use: getHandler)
        tokenAuthGroup.get(PetThread.parameter, "pets", use: getPetsHandler)
    }
    
    func createHandler(_ req: Request, thread: PetThread) throws -> Future<PetThread> {
        let user = try req.requireAuthenticated(User.self)
        let userID = try user.requireID()
        let petID = thread.petID
        thread.userID = userID
        // taj pet mora pripadati tom korinsiku!!!!
        return Pet.query(on: req).group(.and) {
            $0.filter(\.userID == userID).filter(\.id == petID)
        }.all().flatMap(to: PetThread.self) { pets in
            if !pets.isEmpty {
                 return thread.save(on: req)
            } else {
                throw Abort(.badRequest)
            }
        }
    }
    
    func updateHandler(_ req: Request) throws -> Future<PetThread> {
        return try flatMap(to: PetThread.self, req.parameters.next(PetThread.self), req.content.decode(PetThread.self), { (thread, updateThread) in
            thread.configure(with: updateThread)
            let user = try req.requireAuthenticated(User.self)
            let userID = try user.requireID()
            let petID = thread.petID
            thread.userID = userID
            
            return Pet.query(on: req).group(.and) {
                $0.filter(\.userID == userID).filter(\.id == petID)
            }.all().flatMap(to: PetThread.self) { pets in
                if !pets.isEmpty {
                     return thread.save(on: req)
                } else {
                    throw Abort(.badRequest)
                }
            }
        })
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[PetThread]> {
        let user = try req.requireAuthenticated(User.self)
        let userID = try user.requireID()
        return PetThread.query(on: req).group(.or) { or in
            or.filter(\.userID == userID)
        }.sort(\.id, .ascending).all()
    }
    
    //    func getHandler(_ req: Request) throws -> Future<PetThread> {
    //        let isAccepted = try _isAccetable(on: req, for: "userID")
    //        if isAccepted {
    //            return try req.parameters.next(PetThread.self)
    //        } else {
    //            throw Abort(.badRequest)
    //        }
    //    }
    
    //    func getAllForUserHandler(_ req: Request) throws -> Future<[PetThread]> {
    //        return PetThread.query(on: req).all()
    //    }
    //
    func getPetsHandler(_ req: Request) throws -> Future<[Pet]> {
        return try req.parameters.next(PetThread.self).flatMap(to: [Pet].self) { thread in
            try thread.pets.query(on: req).group(.or) { or in
                let user = try req.requireAuthenticated(User.self)
                let userID = try user.requireID()
                or.filter(\.userID == userID)
            }.sort(\.id, .ascending).all()
        }
    }
}

import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    // Create new pet
    router.post("api", "pet") { req -> Future<Pet> in
        return try req.content.decode(Pet.self).flatMap(to: Pet.self) { pet in
            return pet.save(on: req)
        }
    }
    
    //Get all pets
    router.get("api", "pets") { req -> Future<[Pet]> in
        return Pet.query(on: req).all()
    }
    
    //Get pet
    router.get("api", "pet", Pet.parameter) { req -> Future<Pet> in
        return try req.parameters.next(Pet.self)
    }
    
    //Update pet
    router.put("api", "pet", Pet.parameter) { req -> Future<Pet> in
        return try flatMap(
            to: Pet.self,
            req.parameters.next(Pet.self),
            req.content.decode(Pet.self)) { pet, updatedPet in
                pet.name = updatedPet.name
                pet.age = updatedPet.age
                pet.type = updatedPet.type
                
                return pet.save(on: req)
        }
    }
    
    //Delete pet
    router.delete("api", "pet", Pet.parameter) { req -> Future<HTTPStatus> in
        return try req.parameters.next(Pet.self)
            .delete(on: req)
            .transform(to: .noContent)
    }
    
    //Search pet
    router.get("api", "pet", "search") { req -> Future<[Pet]> in
        guard let searchTerm = req.query[String.self, at: "name"] else {
            throw Abort(.badRequest)
        }
        
        return Pet.query(on: req).filter(\.name == searchTerm).all()
    }
}

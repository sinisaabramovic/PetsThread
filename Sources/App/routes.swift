import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works! \nCreated in 2020\n by Sinisa"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    // Refactored using controllers
    // Pet controller
    let petController = PetController()
    try router.register(collection: petController)
    
    let userController = UserController()
    try router.register(collection: userController)
}

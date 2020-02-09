import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return """
                          __      _
                        o'')}____//
                         `_/      )
                         (_(_/-(_/
                **************************************
                |           It works!                |
                |     Created in 2020 by Sinisa      |
                **************************************
        """
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    // Refactored using controllers
    // Pet controller
    
    let petTypeController = PetTypeConrtoller()
    try router.register(collection: petTypeController)
    
    let petController = PetController()
    try router.register(collection: petController)
    
    let userController = UserController()
    try router.register(collection: userController)
    
    let categoriesController = CategoryController()
    try router.register(collection: categoriesController)
}

import FluentPostgreSQL
import Vapor
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    let databaseConfig: PostgreSQLDatabaseConfig
    if let url = Environment.get("DATABASE_URL") {
        databaseConfig = PostgreSQLDatabaseConfig(url: url)!
    } else {
        let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
        let databaseName: String
        let databasePort: Int
        
        if env == .testing {
            databaseName = "vapor"
            if let testPort = Environment.get("DATABASE_PORT") {
                databasePort = Int(testPort) ?? 5432
            } else {
                databasePort = 5432
            }
        } else {
            databaseName = "vapor"
            databasePort = 5432
        }
        databaseConfig = PostgreSQLDatabaseConfig(hostname: hostname, port: databasePort, username: "vapor", database: databaseName, password: "password")
    }
    
    // Register the configured SQLite database to the database config.
    let database = PostgreSQLDatabase(config: databaseConfig)
    var databases = DatabasesConfig()
    databases.add(database: database, as: .psql)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: PetType.self, database: .psql)
    migrations.add(model: PetThreadType.self, database: .psql)
    migrations.add(model: Pet.self, database: .psql)
    migrations.add(model: PetThread.self, database: .psql)
    migrations.add(model: Token.self, database: .psql)
    // Setup for default values
    migrations.add(migration: BasePetTypes.self, database: .psql)
    migrations.add(migration: BaseThreadTypes.self, database: .psql)
    
    services.register(migrations)
    
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
}

// Useful Docker commands
//docker exec -it postgres psql -U vapor -d vapor
// Manage DB
//docker exec -it postgres psql -U vapor -d postgres -c "DROP DATABASE vapor;"
//docker exec -it postgres psql -U vapor -d postgres -c "CREATE DATABASE vapor;"

// Creates new docker image for PostgreSQL
// docker stop postgres
// docker rm postgres
// docker run --name postgres -e POSTGRES_DB=vapor -e POSTGRES_USER=vapor -e POSTGRES_PASSWORD=password -p 5432:5432 -d postgres

// Start Docker container
// docker container start postgres

import FluentPostgreSQL
import Vapor
import Authentication
import Leaf

/// Called before your application initializes.
public func configure(
	_ config: inout Config,
	_ env: inout Environment,
	_ services: inout Services
	) throws {
	// register Authentication provider
	try services.register(AuthenticationProvider())
	try services.register(FluentPostgreSQLProvider())
	try services.register(LeafProvider())
	
	
	let router = EngineRouter.default()
	try routes(router)
	services.register(router, as: Router.self)
	
	// Register middleware
	var middlewares = MiddlewareConfig() // Create _empty_ middleware config
	middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
	// middlewares.use(DateMiddleware.self) // Adds `Date` header to responses
	middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
	middlewares.use(SessionsMiddleware.self)
	services.register(middlewares)
	
	// Configure a database
	var databases = DatabasesConfig()
	let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
	let username = Environment.get("DATABASE_USER") ?? "vapor"
	let databaseName = Environment.get("DATABASE_DB") ?? "vapor"
	let password = Environment.get("DATABASE_PASSWORD") ?? "password"
	
	let databaseConfig = PostgreSQLDatabaseConfig(
		hostname: hostname,
		username: username,
		database: databaseName,
		password: password)
	let database = PostgreSQLDatabase(config: databaseConfig)
	databases.add(database: database, as: .psql)
	services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Channel.self, database: .psql)
	migrations.add(model: Item.self, database: .psql)
    services.register(migrations)
	
	var commandConfig = CommandConfig.default()
	commandConfig.use(RevertCommand.self, as: "revert")
	services.register(commandConfig)

}

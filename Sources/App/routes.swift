import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
	// Register the routes collection for creating and extracting Feeds
	let feedController = FeedRoutes()
	try router.register(collection: feedController)
}

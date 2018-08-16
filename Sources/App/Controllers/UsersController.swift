import Vapor
import FluentPostgreSQL
import Crypto
import Authentication

struct UsersController: RouteCollection {
	func boot(router: Router) throws
	{
		let usersRoute = router.grouped("users")
		
		usersRoute.get("register", use: renderRegister)
		usersRoute.post("register", use: register)
		
		usersRoute.get("logout", use: logout)
		
		usersRoute.get("login", use: renderLogin)
		let authedSessionRoutes = usersRoute.grouped(User.authSessionsMiddleware())
		authedSessionRoutes.post("login", use: login)
		
		let protectedRoutes = authedSessionRoutes.grouped(RedirectMiddleware<User>(path: "/users/login"))
		protectedRoutes.get("profile", use: renderProfile)
		
		protectedRoutes.post("newcast", use: newPodcast)
		
  	}
	
	func renderRegister(_ req: Request)
		throws -> Future<View>
	{
		return try req.view().render("register")
	}
	
	func register(_ req: Request)
		throws -> Future<Response>
	{
		return try req
			.content
			.decode(User.self)
			.flatMap
			{	user in
				return User
					.query(on: req)
					.filter(\User.email == user.email)
					.first()
					.flatMap
					{	result in
						if let _ = result
						{
							return Future.map(on: req)
							{ //_ in
								return req.redirect(to: "/users/register")
					}
				}
				user.password = try BCryptDigest().hash(user.password)
				return user
					.save(on: req)
					.map
					{	_ in
						return req.redirect(to: "/users/login")
				}
			}
		}
	}
	
	
	func renderLogin(_ req: Request)
		throws -> Future<View>
	{
		return try req.view().render("login")
	}
	
	func login(_ req: Request)
		throws -> Future<Response>
	{
		return try req
			.content
			.decode(User.self)
			.flatMap
			{	user in
				return User.authenticate(
				username: user.email,
				password: user.password,
				using: BCryptDigest(),
				on: req
				)
				.map
				{	user in
					guard let user = user
						else
					{
						return req.redirect(to: "/users/login")
					}
					try req.authenticateSession(user)
					return req.redirect(to: "/users/profile")
			}
		}
	}
	
	func renderProfile(_ req: Request)
		throws -> Future<View>
	{
		let user = try req.requireAuthenticated(User.self)
		let context = try ProfileContext(user: user, on: req)
		return try req.view().render("profile",
									 context)
	}
	
	func logout(_ req: Request)
		throws -> Future<Response>
	{
		try req.unauthenticateSession(User.self)
		return Future.map(on: req) { return req.redirect(to: "/users/login") }
	}
	
	func newPodcast(_ req: Request)
		throws -> Future<Response>
	{
		return try req
			.content
			.decode(NewChannel.self)
			.flatMap
			{	channel in
				return Channel
					.query(on: req)
					.filter(\Channel.title == channel.title)
					.first()
					.flatMap
					{	result in
						if let _ = result
						{
							return Future.map(on: req)
							{ //_ in
								return req.redirect(to: "/users/profile")
							}
						}
						let user = try req.requireAuthenticated(User.self)
						var podcast: Channel
						podcast.title = channel.title
						podcast.link = channel.link
						podcast.language = "en-US"
						podcast.creator = channel.creator ?? user.author
						podcast.copyright = "&#8471; &amp; &#xA9; \(podcast.creator)"
						podcast.type = channel.type ?? "episodic"
						podcast.subtitle = channel.subtitle
						podcast.image = channel.image
						podcast.description = channel.description
						podcast.userID = user.id!
						return podcast
							.save(on: req)
							.map
							{
								return req.redirect(to: "/users/profile")
						}
				}
		}
	}
}

struct NewChannel: Codable
{
	var title: String
	var link: URL
	var creator: String?
	var type: String?
	var subtitle: String
	var image: URL
	var description: String
}

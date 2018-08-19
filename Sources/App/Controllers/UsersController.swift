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
		//protectedRoutes.get("profile", Int.parameter, use: renderEpisodes)
		
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
			.decode(LoginRequest.self)
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
						//var podcast
						
						let title = channel.title
						let link = channel.link
						let language = "en-US"
						let creator = channel.creator ?? user.author
						let copyright = "&#8471; &amp; &#xA9; \(creator)"
						let date = Date()
						let type = channel.type ?? "episodic"
						let subtitle = channel.subtitle
						let image = channel.image
						let description = channel.description
						let userID = user.id!
						let explicit = channel.explicit ?? "clean"

						return Channel(title: title,
									   link: link,
									   description: description,
									   language: language,
									   creator: creator,
									   date: date,
									   image: image,
									   userID: userID,
									   copyright: copyright,
									   subtitle: subtitle,
									   type: type,
									   explicit: explicit)
							.save(on: req)
							.map
							{	result in
								
								let redirectID = result.id!
								
								return req.redirect(to: "/users/profile/\(redirectID)")
								
							}
						
				}
		}
	}
	
	func renderEpisodes(_ req: Request)
		throws -> Future<View>
	{
		return try req.view().render("login")
	}
}

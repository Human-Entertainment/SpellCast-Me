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
		
		usersRoute.get("login", use: renderLogin)
		let authedSessionRouter = usersRoute.grouped(User.authSessionsMiddleware())
		authedSessionRouter.post("login", use: login)
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
						return req.redirect(to: "/login")
					}
					try req.authenticateSession(user)
					return req.redirect(to: "/profile")
			}
		}
	}
}

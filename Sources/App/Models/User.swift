import FluentPostgreSQL
import Vapor
import Authentication  // added

final class User: Content
{
	var id: UUID?
	/// The podcast creators name - the CMS does not _yet_ support networks - Maybe ready for beta?
	var author: String
	var email: String
	var password: String
	init(author: String, email: String, password: String)
	{
		self.author = author
		self.email = email
		self.password = password
	}
}
extension User: PostgreSQLUUIDModel {}
extension User: Migration {}
extension User: PasswordAuthenticatable
{
	static var usernameKey: WritableKeyPath<User, String>
	{
		return \User.email
	}
	static var passwordKey: WritableKeyPath<User, String>
	{
		return \User.password
	}
}
extension User: SessionAuthenticatable {}

extension User {
  var Podcasts: Children<User, Channel> {
    return children(\.userID)
  }
}

struct ProfileContext: Encodable {
	let user: User
	let podcasts: Future<[Channel]>
	
	init(user: User, on conn: DatabaseConnectable) throws {
		self.user = user
		self.podcasts = try user.Podcasts.query(on: conn).all() // TODO: I don't know the syntax
	}
}

import FluentPostgreSQL
import Vapor
import Authentication  // added

final class User: Content
{
	var id: UUID?
	var email: String  // added
	var password: String  // added
	init(email: String, password: String)
	{
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


import Foundation
import Vapor
import FluentPostgreSQL

final class Channel: Codable {
	/// Internal ID, used to identify when generating _a_ feed, as well as for uploading podcast episodes
	var id: Int?
	/// The title, not difficult
	var title: String
	/// Link to the podcast, not to the feed however, as this _shouldn't_ be necessessary
	var link: URL
	/// The Copyright
	var copyright: String
	/// Quick motto or something like that
	var subtitle: String
	/// Is it serial or episodic?
	var type: String
	/// The date the podcast was created, nothing too fancy
	var date: Date
	/// What is the PodCast about?
	var description: String
	/// In which language is the podcast spoken
	var language: String
	/// Who made the podcast - this is actually pretty often the network, and as this CMS is made for networks as well as individuals, this has to be called _often_.
	var creator: String
	/// The artwork used in the feed, maybe it should be a string?
	var image: URL
	/// The owner of the podcast
	var userID: UUID
	/// Is the podcast explicit? (Default is no in UserController file)
	var explicit: String
	
	init(title: String,
		 link: URL,
		 description: String,
		 language: String,
		 creator: String,
		 date: Date,
		 image: URL,
		 userID: UUID,
		 copyright: String,
		 subtitle: String,
		 type: String,
		 explicit: String)
	{
		self.copyright = copyright
		self.title = title
		self.link = link
		self.description = description
		self.language = language
		self.creator = creator
		self.date = date
		self.image = image
		self.userID = userID
		self.subtitle = subtitle
		self.type = type
		self.explicit = explicit
	}
	
}

extension Channel: PostgreSQLModel{}
extension Channel: Migration{}
extension Channel: Parameter{}

extension Channel
{
	var Items: Children<Channel, Item>
	{
		return children(\.channelID)
	}
	
	var Users: Parent<Channel, User>
	{
		return parent(\.userID)
	}
}

extension Channel: Content{}

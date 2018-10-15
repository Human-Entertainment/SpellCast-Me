import Foundation
import Vapor
import FluentPostgreSQL

final class Item: Codable {
	var id: Int?
	var title: String
	var link: String
	var guid: String
	var enclosure: Enclosure
	var description: String
	var subject: String?
	var pubDate: Date
	var author: String?
	var channelID: Int
	var duration: String
	var explicit: String?
	
	init(title: String,
		 link: String,
		 enclosure: Enclosure,
		 description: String,
		 subject: String,
		 pubDate: Date,
		 author: String,
		 channelID: Int,
		 duration: String,
		 explicit: String)
	{
		self.title = title
		self.link = link
		self.guid = link
		self.enclosure = enclosure
		self.description = description
		self.subject = subject
		self.pubDate = pubDate
		self.author = author
		self.channelID = channelID
		self.duration = duration
		self.explicit = explicit
	}
}

extension Item: PostgreSQLModel,
				Content,
				Migration{}
//extension Item: Content{}
//extension Item: Migration{}

extension Item
{
	var channel: Parent<Item, Channel>
	{
		return parent(\.channelID)
	}
}

struct Enclosure: Codable {
	var url: String
	var length: String
	var type: String
}

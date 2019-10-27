import Foundation
import Vapor

struct FeedGenerator
{
	//public init() {}
	
    public func generateFeed(root: Channel, episode: [Item]) -> String
	{
		let rfc822DateFormatter = DateFormatter()
		rfc822DateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
		rfc822DateFormatter.locale = Locale(identifier: "en_US_POSIX")
		rfc822DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
		
		var feed: String
		feed = "<rss>\n"
			feed = feed + "\t<channel>\n"
			feed = feed + "\t\t<title>\(root.title)</title>\n"
			feed = feed + "\t\t<link>\(root.link)</link>\n"
		feed = feed + "\t\t<pubDate>\(rfc822DateFormatter.string(from: root.date))</pubDate>\n"
		
				feed = feed + "\t\t<item>\n"
				for element in episode
				{
					feed = feed + "\t\t\t<title>\(element.title)</title>\n"
					feed = feed + "\t\t\t<description>\(element.description)</description>\n"
				}
				feed = feed + "\t\t</item>\n"
		
			feed = feed + "\t</channel>\n"
		feed = feed + "</rss>"
		
		return feed
	}
}

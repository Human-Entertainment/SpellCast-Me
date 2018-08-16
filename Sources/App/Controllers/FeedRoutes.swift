/*
import Foundation
import Vapor

struct FeedRoutes: RouteCollection
{
	func boot(router: Router)
		throws
	{
		let feedRoutes = router.grouped("feed")
		feedRoutes.get(use: getAll)
		feedRoutes.get(Channel.parameter, "rss.feed", use: generateFeed)
		
		feedRoutes.post(PodCreate.self, use: createPodcast)
		
		let episodeGroup = feedRoutes.grouped("episodes")
		episodeGroup.post(EpiCreate.self, use: episedeUpload)
	}

	func getAll(_ req: Request)
		throws -> Future<[Channel]>
	{
		return Channel.query(on: req).all()
	}
	
	func createPodcast(_ req: Request, data: PodCreate)
		throws -> Future<Channel>
	{
		let date = Date()
		let podcast = try Channel(title: data.title, link: data.link, description: data.description, language: "en-US", creator: data.creator, date: date, image: data.image)
		return podcast.save(on: req)
	}
	
	func episedeUpload(_ req: Request, data: EpiCreate)// structer: MultiFormStruct)
		throws -> Future<Item>
	{
		//let data = structer.episode
		let mimetype = data.media.contentType?.type

		let enclosure = Enclosure(url: "localhost", length: "123", type: mimetype!)
		print(data.media.data)

		let date = Date()
		let episode = try Item(title: data.title, link: "http://herp.com", enclosure: enclosure, description: data.description, subject: data.subject, pubDate: date, author: data.author, channelID: data.channelID)
		return episode.save(on: req)
	}

	func generateFeed(_ req: Request)
		throws -> Future<HTTPResponse>
	{
		return try req
			.parameters
			.next(Channel.self)
			.flatMap
			{	root in
				return try root
					.Items
					.query(on: req)
					.all()
					.map
					{	episodes in
						
						let httpHeader: HTTPHeaders = HTTPHeaders([("application","rss+xml")])
						
						let httpBody = HTTPBody(string: FeedGenerator().generateFeed(root: root, episode: episodes))
						
						return HTTPResponse(status: .ok, headers: httpHeader, body: httpBody)
					}
				
			}
	}
}

struct PodCreate: Content
{
	/// Internal ID, used to identify when generating _a_ feed, as well as for uploading podcast episodes
	var id: Int?
	/// The title, not difficult
	var title: String
	/// Link to the podcast, not to the feed however, as this _shouldn't_ be necessessary
	var link: URL
	/// What is the PodCast about?
	var description: String
	/// Who made the podcast - this is actually pretty often the network, and as this CMS is made for networks as well as individuals, this has to be called _often_.
	var creator: String
	/// The artwork used in the feed, maybe it should be a string?
	var image: URL
}

/*struct MultiFormStruct: Content
{
	var episode: EpiCreate
	var Image: File
}
*/
struct EpiCreate: Content
{
	var title: String
	var description: String
	var subject: String
	var author: String
	var channelID: Int
	var media: File
}
*/

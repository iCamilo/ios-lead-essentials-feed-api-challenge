//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
		
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success((data, response)):
                let result = RemoteFeedMapper.map(data: data, response: response)
                completion(result)
            default:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

struct RemoteFeedMapper {
    struct FeedImagesResponse: Codable {
        var items: [FeedImageResponse]
        var feedImages: [FeedImage] {
            items.map { $0.feedImage }
        }
    
        struct FeedImageResponse: Codable {
            var image_id: UUID
            var image_url: URL
            var image_desc: String?
            var image_loc: String?
            
            var feedImage: FeedImage {
                return FeedImage(id: image_id,
                                 description: image_desc,
                                 location: image_loc,
                                 url: image_url)
            }
        }
    }
    
    static let HTTP_200 = 200
    
    static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
        guard response.statusCode == HTTP_200,
              let itemsResponse = try? JSONDecoder().decode(FeedImagesResponse.self, from: data)
        else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
                       
        return .success(itemsResponse.feedImages)
    }
}

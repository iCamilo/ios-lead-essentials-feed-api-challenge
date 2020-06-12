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
        let HTTP_200 = 200
        
        client.get(from: url) { result in
            switch result {
            case let .success((data, response)):
                guard response.statusCode == HTTP_200,
                      let _ = try? JSONSerialization.jsonObject(with: data)
                else {
                    completion(.failure(Error.invalidData))
                    return
                }
                
                do {
                    let itemsResponse = try JSONDecoder().decode(FeedImagesResponse.self, from: data)
                    let feedImages: [FeedImage] = itemsResponse.items.map {
                        FeedImage(id: $0.image_id, description: $0.image_desc,
                                  location: $0.image_loc, url: $0.image_url)
                    }
                    
                    completion(.success(feedImages))
                } catch {
                    completion(.failure(Error.invalidData))
                }
            default:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

struct FeedImagesResponse: Codable {
    struct FeedImageResponse: Codable {
        var image_id: UUID
        var image_url: URL
        var image_desc: String?
        var image_loc: String?
    }
    
    var items: [FeedImageResponse]
}

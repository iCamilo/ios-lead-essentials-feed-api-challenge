//
//  FeedMapper.swift
//  FeedAPIChallenge
//
//  Created by Roman Bozhenko on 18.09.2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

enum FeedMapper {
    private struct Root: Decodable {
        let items: [Item]

        struct Item: Decodable {
            let id: UUID
            let description: String?
            let location: String?
            let url: URL

            enum CodingKeys: String, CodingKey {
                case id = "image_id"
                case description = "image_desc"
                case location = "image_loc"
                case url = "image_url"
            }

            var feedImage: FeedImage {
                FeedImage(id: id, description: description, location: location, url: url)
            }
        }
    }

    static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
        if response.statusCode == 200 {
            if let root = try? JSONDecoder().decode(Root.self, from: data) {
                return .success(root.items.map { $0.feedImage })
            }

            return .failure(RemoteFeedLoader.Error.invalidData)
        }

        return .failure(RemoteFeedLoader.Error.invalidData)
    }
}

//
//  FeedMapper.swift
//  FeedAPIChallenge
//
//  Created by Roman Bozhenko on 18.09.2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

enum FeedMapper {
	static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		if response.statusCode == 200 {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		return .failure(RemoteFeedLoader.Error.invalidData)
	}
}

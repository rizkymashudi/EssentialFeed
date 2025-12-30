//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by rizky mashudi on 30/12/25.
//

import Foundation

internal final class FeedItemsMapper {
  private struct BaseResponse: Codable {
    let items: [Item]
    var feeds: [FeedItem] {
      items.map { $0.item }
    }
  }

  private struct Item: Codable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
    
    var item: FeedItem {
      return FeedItem(id: id, description: description, location: location, imageURL: image)
    }
  }
  
  private static var OK_200: Int { return 200 }
  
  internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
    guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(BaseResponse.self, from: data) else {
      return .failure(RemoteFeedLoader.Error.invalidData)
    }
    return .success(root.feeds)
  }
}

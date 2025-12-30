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
  
  internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
    guard response.statusCode == OK_200 else {
      throw RemoteFeedLoader.Error.invalidData
    }
    
    return try JSONDecoder().decode(BaseResponse.self, from: data).items.map { $0.item }
  }
}

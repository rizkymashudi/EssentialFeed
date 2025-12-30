//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by rizky mashudi on 15/12/25.
//

import Foundation

public enum HTTPClientResult {
  case success(Data, HTTPURLResponse)
  case failure(Error)
}

public protocol HTTPClient {
  func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
  private let url: URL
  private let client: HTTPClient
  
  public enum Error: Swift.Error {
    case connectivity
    case invalidData
  }
  
  public enum Result: Equatable {
    case success([FeedItem])
    case failure(Error)
  }
  
  public init(url: URL, client: HTTPClient) {
    self.client = client
    self.url = url
  }
  
  public func load(completion: @escaping (Result) -> Void) {
    client.get(from: url) { result in
      switch result {
      case .success(let data, let response):
        do {
          let items = try FeedItemsMapper.map(data, response)
          completion(.success(items))
            
        } catch {
          completion(.failure(.invalidData))
        }
        
      case .failure(_):
        completion(.failure(.connectivity))
      }
    }
  }
}

private class FeedItemsMapper {
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
  
  static var OK_200: Int { return 200 }
  
  static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
    guard response.statusCode == OK_200 else {
      throw RemoteFeedLoader.Error.invalidData
    }
    
    return try JSONDecoder().decode(BaseResponse.self, from: data).items.map { $0.item }
  }
}

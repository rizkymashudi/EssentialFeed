//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

public struct FeedItem: Equatable, Codable {
	let id: UUID
	let description: String?
	let location: String?
	let imageURL: URL
  
  public init(id: UUID, description: String?, location: String?, imageURL: URL) {
    self.id = id
    self.description = description
    self.location = location
    self.imageURL = imageURL
  }
}

private extension FeedItem {
  private enum CodingKeys: String, CodingKey {
    case id
    case description
    case location
    case imageURL = "image"
  }
}

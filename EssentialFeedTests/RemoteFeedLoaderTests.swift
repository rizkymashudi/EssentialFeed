//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by rizky mashudi on 10/12/25.
//

import XCTest
@testable import EssentialFeed

class RemoteFeedLoaderTests: XCTest {
  func test_init_doesNotRequestDataFromURL() {
    let (_, client) = makeSUT()
    
    XCTAssertNil(client.requestedURL)
  }
  
  func test_load_requestDataFromURL() {
    let url = URL(string: "https://a-given-url.com")!
    let (sut, client) = makeSUT(url: url)
    
    sut.load()
    
    XCTAssertEqual(client.requestedURL, url)
  }
  
  private func makeSUT(
    url: URL = URL(string: "https://a-url.com")!
  ) -> (sut: RemoteFeedLoader, client: MockHTTPClient) {
    let client = MockHTTPClient()
    let sut = RemoteFeedLoader(url: url, client: client)
    return (sut, client)
  }
  
  private class MockHTTPClient: HTTPClient {
    var requestedURL: URL?
    
    func get(from url: URL) {
      requestedURL = url
    }
  }
}

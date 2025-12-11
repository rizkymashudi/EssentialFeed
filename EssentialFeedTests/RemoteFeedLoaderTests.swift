//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by rizky mashudi on 10/12/25.
//

import XCTest

class RemoteFeedLoader {
  let client: HTTPClient
  let url: URL
  
  init(url: URL, client: HTTPClient) {
    self.client = client
    self.url = url
  }
  
  func load(){
    client.get(from: url)
  }
}

protocol HTTPClient {
  func get(from url: URL)
}

class MockHTTPClient: HTTPClient {
  var requestedURL: URL?
  
  func get(from url: URL) {
    requestedURL = url
  }
}

class RemoteFeedLoaderTests: XCTest {
  func test_init_doesNotRequestDataFromURL() {
    let url = URL(string: "https://a-url.com")!
    let client = MockHTTPClient()
    let _ = RemoteFeedLoader(url: url, client: client)
    
    XCTAssertNil(client.requestedURL)
  }
  
  func test_load_requestsDataFromURL() {
    let url = URL(string: "https://a-given-url.com")!
    let client = MockHTTPClient()
    let sut = RemoteFeedLoader(url: url, client: client)
    
    sut.load()
    
    XCTAssertEqual(client.requestedURL, url)
  }
}

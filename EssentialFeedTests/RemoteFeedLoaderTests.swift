//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by rizky mashudi on 10/12/25.
//

import XCTest

class RemoteFeedLoader {
  let client: HTTPClient
  
  init(client: HTTPClient) {
    self.client = client
  }
  
  func load(){
    client.get(from: URL(string: "https://google.com")!)
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
    let client = MockHTTPClient()
    let _ = RemoteFeedLoader(client: client)
    
    XCTAssertNil(client.requestedURL)
  }
  
  func test_load_requestsDataFromURL() {
    let client = MockHTTPClient()
    let sut = RemoteFeedLoader(client: client)
    
    sut.load()
    
    XCTAssertNil(client.requestedURL)
  }
}

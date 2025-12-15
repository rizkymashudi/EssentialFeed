//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by rizky mashudi on 10/12/25.
//

import XCTest
@testable import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
  func test_init_doesNotRequestDataFromURL() {
    let (_, client) = makeSUT()
    
    XCTAssertTrue(client.requestedURLs.isEmpty)
  }
  
  func test_load_requestsDataFromURL() {
    let url = URL(string: "https://a-given-url.com")!
    let (sut, client) = makeSUT(url: url)
    
    sut.load()
    
    XCTAssertEqual(client.requestedURLs, [url])
  }
  
  func test_loadTwice_requestsDataFromURLTwice() {
    let url = URL(string: "https://a-given-url.com")!
    let (sut, client) = makeSUT(url: url)
    
    sut.load()
    sut.load()
    
    XCTAssertEqual(client.requestedURLs, [url, url])
  }
  
  func test_load_deliversErrorOnClientError() {
    // Given
    let (sut, client) = makeSUT()
    
    // When
    var capturedErrors = [RemoteFeedLoader.Error]()
    sut.load { capturedErrors.append($0) }
    let clientError = NSError(domain: "Test", code: 0)
    client.completions[0](clientError)
    
    // Then
    XCTAssertEqual(capturedErrors, [.connectivity])
  }
  
  private func makeSUT(
    url: URL = URL(string: "https://a-url.com")!
  ) -> (sut: RemoteFeedLoader, client: MockHTTPClient) {
    let client = MockHTTPClient()
    let sut = RemoteFeedLoader(url: url, client: client)
    return (sut, client)
  }
  
  private class MockHTTPClient: HTTPClient {
    var requestedURLs = [URL]()
    var error: Error?
    var completions = [(Error) -> Void]()
    
    func get(from url: URL, completion: @escaping (Error) -> Void) {
      completions.append(completion)
      requestedURLs.append(url)
    }
  }
}

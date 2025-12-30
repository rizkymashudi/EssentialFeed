//
//  URLSessionHTTPClientTests.swift
//  EssentialFeed
//
//  Created by rizky mashudi on 30/12/25.
//

import XCTest

// Production Code
class URLSessionHTTPClient {
  private let session: URLSessionProtocol
  
  init(session: URLSessionProtocol) {
    self.session = session
  }
  
  func get(from url: URL) {
    let request = URLRequest(url: url)
    session.dataTask(with: request) { _, _, _ in }.resume()
  }
}


// Unit Tests code
class URLSessionHTTPClientTests: XCTestCase {
  func test_getFromURL_createsDataTaskWithURL() {
    let url = URL(string: "http://any-url.com")!
    let session = URLSessionMock()
    let sut = URLSessionHTTPClient(session: session)
    
    sut.get(from: url)
    
    XCTAssertEqual(session.receivedURLs, [url])
  }
  
  private class URLSessionMock: URLSessionProtocol {
    var receivedURLs: [URL] = []
    
    func dataTask(
      with request: URLRequest,
      completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTaskProtocol {
      
      if let url = request.url {
        receivedURLs.append(url)
      }
      
      return DummyDataTask()
    }
  }
  
  private class DummyDataTask: URLSessionDataTaskProtocol {
    func resume() {}
  }
}

protocol URLSessionDataTaskProtocol {
  func resume()
}

protocol URLSessionProtocol {
  func dataTask(
    with request: URLRequest,
    completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
  ) -> URLSessionDataTaskProtocol
}

extension URLSession: URLSessionProtocol {
  func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> any URLSessionDataTaskProtocol {
    Foundation.URLSession.dataTask(self)(with: request, completionHandler: completionHandler)
  }
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

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
  
  func test_getFromURL_resumesDataTaskWithURL() {
    let url = URL(string: "http://any-url.com")!
    let session = URLSessionSpy()
    let task = URLSessionDataTaskSpy()
    session.stub(url: url, task: task)
    let sut = URLSessionHTTPClient(session: session)
    
    sut.get(from: url)
    
    XCTAssertEqual(task.resumeCallCount, 1)
  }
}

// MARK: Helpers
extension URLSessionHTTPClientTests {
  private class URLSessionSpy: URLSessionProtocol {
    private var stubs = [URL: URLSessionDataTaskProtocol]()
    
    func stub(url: URL, task: URLSessionDataTaskProtocol) {
      stubs[url] = task
    }
    
    func dataTask(
      with request: URLRequest,
      completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTaskProtocol {
      guard let url = request.url else {
        return DummyDataTask()
      }
      return stubs[url] ?? DummyDataTask()
    }
  }
  
  private class DummyDataTask: URLSessionDataTaskProtocol {
    func resume() {}
  }
  
  private class URLSessionDataTaskSpy: URLSessionDataTaskProtocol {
    var resumeCallCount: Int = 0
    
    func resume() {
      resumeCallCount += 1
    }
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

//
//  URLSessionHTTPClientTests.swift
//  EssentialFeed
//
//  Created by rizky mashudi on 30/12/25.
//

import XCTest
import EssentialFeed

// Production Code
class URLSessionHTTPClient {
  private let session: URLSessionProtocol
  
  init(session: URLSessionProtocol) {
    self.session = session
  }
  
  func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
    let request = URLRequest(url: url)
    session.dataTask(with: request) { _, _, error in
      if let error = error {
        completion(.failure(error))
      }
    }.resume()
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
    
    sut.get(from: url) { _ in }
    
    XCTAssertEqual(task.resumeCallCount, 1)
  }
  
  func test_getFromURL_failsOnRequestError() {
    let url = URL(string: "http://any-url.com")!
    let session = URLSessionSpy()
    let error = NSError(domain: "Any error", code: 1)
    session.stub(url: url, error: error)
    
    let sut = URLSessionHTTPClient(session: session)
    
    let exp = expectation(description: "Wait for completion")
    
    sut.get(from: url) { result in
      switch result {
      case let . failure(receivedError as NSError):
        XCTAssertEqual(receivedError, error)
      default:
        XCTFail("Expected .failure with error, got \(result) instead.")
      }
      
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 1.0)
  }
}

// MARK: Helpers
extension URLSessionHTTPClientTests {
  private class URLSessionSpy: URLSessionProtocol {
    private var stubs = [URL: Stub]()
    
    private struct Stub {
      let task: URLSessionDataTaskProtocol
      let error: Error?
    }
    
    func stub(url: URL, task: URLSessionDataTaskProtocol = DummyDataTask(), error: Error? = nil) {
      stubs[url] = Stub(task: task, error: error)
    }
    
    func dataTask(
      with request: URLRequest,
      completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTaskProtocol {
      guard let url = request.url, let stub = stubs[url] else {
        fatalError("Couldn't find stub for \(request)")
      }
      completionHandler(nil, nil, stub.error)
      return stub.task
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

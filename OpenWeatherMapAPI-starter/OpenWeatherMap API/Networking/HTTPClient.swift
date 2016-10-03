//
//  HTTPClient.swift
//  TripPlanner
//
//  Created by Benjamin Encz on 7/27/15.
//  Copyright © 2015 Make School. All rights reserved.
//

// Copyright © 2015 Chris Eidhof
// See the accompanying blog post: http://chris.eidhof.nl/posts/tiny-networking-in-swift.html

import Foundation

enum Method: String { // Bluntly stolen from Alamofire
  case OPTIONS = "OPTIONS"
  case GET = "GET"
  case HEAD = "HEAD"
  case POST = "POST"
  case PUT = "PUT"
  case PATCH = "PATCH"
  case DELETE = "DELETE"
  case TRACE = "TRACE"
  case CONNECT = "CONNECT"
}

struct Resource<A> {
  let baseURL: String
  let path: String
  let queryString: String?
  let method : Method
  let requestBody: Data?
  let headers : [String:String]?
  let parse: (Data) -> A?
}

enum Reason {
  case couldNotParseJSON
  case noData
  case noSuccessStatusCode(statusCode: Int)
  case other(NSError)
}

struct HTTPClient {
  
  func apiRequest<A>(_ session: URLSession = URLSession.shared, resource: Resource<A>, failure: @escaping (Reason, Data?) -> (), completion: @escaping (A) -> ()) {
    
    var urlString = resource.baseURL + "/" + resource.path
    
    if let queryString = resource.queryString {
      urlString = urlString + "?" + queryString
    }

    let escapedString = urlString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
    let url = URL(string: escapedString!)
    
    let request = NSMutableURLRequest(url: url!)
    request.httpMethod = resource.method.rawValue
    request.httpBody = resource.requestBody
    
    if let headers = resource.headers {
      for (key,value) in headers {
        request.setValue(value, forHTTPHeaderField: key)
      }
    }
    
    let task = session.dataTask(with: request as URLRequest){ (data, response, error) -> Void in
      if let httpResponse = response as? HTTPURLResponse {
        if (isSuccessStatusCode(httpResponse.statusCode)) {
          if let responseData = data {
            if let result = resource.parse(responseData) {
              completion(result)
            } else {
              failure(Reason.couldNotParseJSON, data)
            }
          } else {
            failure(Reason.noData, data)
          }
        } else {
          failure(Reason.noSuccessStatusCode(statusCode: httpResponse.statusCode), data)
        }
      } else {
        failure(Reason.other(error! as NSError), data)
      }
    }
    task.resume()
    
  }
  
}

func isSuccessStatusCode(_ statusCode: Int) -> Bool {
  return (statusCode / 200 == 1)
}

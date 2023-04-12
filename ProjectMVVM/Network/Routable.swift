//
//  Routable.swift
//  ProjectMVVM
//
//  Created by Atul Gupta on 04/01/23.
//

import Foundation

public protocol Routable {
    var url: URL { get }
    var method: HTTPMethod { get }
    var endPoint: String { get }
    var headers: [String: String] { get }
    var body: Data? { get }
    var request: URLRequest { get }
    var constantHeaders: [String: String] { get }
}

public extension Routable {
    
    var headers: [String: String] {
        return [:]
    }
    
    var constantHeaders: [String: String] {
        var headers: [String: String] = [:]
        
        headers["Content-Type"] = "application/json"
        headers["platform"] = "iOS"
        
        if let versionCode = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            headers["iOSVersionCode"] = versionCode
        }
        
        return headers
    }
    
    var request: URLRequest {
        var request                 = URLRequest(url: self.url)
        request.httpMethod          = self.method.rawValue
        request.allHTTPHeaderFields = self.headers.merging(self.constantHeaders) { (current, _) in current }
        request.httpBody            = self.body
        request.cachePolicy         = .reloadRevalidatingCacheData
        return request
    }
}

public enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
    case PATCH
}

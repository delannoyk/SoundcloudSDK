//
//  Request.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 15/03/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

// MARK: - JSONObject
////////////////////////////////////////////////////////////////////////////

class JSONObject {
    let value: AnyObject?
    var index: Int = 0

    init(_ value: AnyObject?) {
        self.value = value
    }

    subscript(index: Int) -> JSONObject {
        return (value as? [AnyObject]).map { JSONObject($0[index]) } ?? JSONObject(nil)
    }

    subscript(key: String) -> JSONObject {
        return (value as? NSDictionary).map { JSONObject($0[key]) } ?? JSONObject(nil)
    }

    func map<U>(transform: (JSONObject) -> U) -> [U]? {
        if let value = value as? [AnyObject] {
            return value.map({ transform(JSONObject($0)) })
        }
        return nil
    }

    func flatMap<U>(transform: (JSONObject) -> U?) -> [U]? {
        if let value = value as? [AnyObject] {
            return value.flatMap { transform(JSONObject($0)) }
        }
        return nil
    }
}

extension JSONObject {
    var anyObjectValue: AnyObject? {
        return value
    }

    var intValue: Int? {
        return (value as? Int)
    }

    var uint64Value: UInt64? {
        return (value as? UInt64)
    }

    var doubleValue: Double? {
        return (value as? Double)
    }

    var boolValue: Bool? {
        return (value as? Bool)
    }

    var stringValue: String? {
        return (value as? String)
    }

    var urlValue: URL? {
        return (value as? String).map { URL(string: $0)?.appendingQueryString("client_id=\(Soundcloud.clientIdentifier!)") } ?? nil
    }

    func dateValue(format: String) -> Date? {
        let date: Date?? = stringValue.map {
            return DateFormatter.dateFormatter(with: format).date(from: $0)
        }
        return date ?? nil
    }
}

// MARK: - DateFormatter

extension DateFormatter {
    private static var dateFormatters = [String: DateFormatter]()

    fileprivate static func dateFormatter(with format: String) -> DateFormatter {
        if let dateFormatter = dateFormatters[format] {
            return dateFormatter
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatters[format] = dateFormatter
        return dateFormatter
    }
}

////////////////////////////////////////////////////////////////////////////


// MARK: - Result
////////////////////////////////////////////////////////////////////////////

public enum Result<T, E> {
    case Success(T)
    case Failure(E)

    public var isSuccessful: Bool {
        switch self {
        case .Success(_):
            return true
        default:
            return false
        }
    }

    public var result: T? {
        switch self {
        case .Success(let result):
            return result
        default:
            return nil
        }
    }

    public var error: E? {
        switch self {
        case .Failure(let error):
            return error
        default:
            return nil
        }
    }
}

////////////////////////////////////////////////////////////////////////////


// MARK: - HTTPMethod
////////////////////////////////////////////////////////////////////////////

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"

    func URLRequest(URL: URL, parameters: HTTPParametersConvertible? = nil, headers: [String: String]? = nil) -> URLRequest {
        let URLRequestInfo: (URL: URL, HTTPBody: Data?) = {
            if let parameters = parameters {
                if self == .GET {
                    return (URL: URL.URLByAppendingQueryString(parameters.queryStringValue), HTTPBody: nil)
                }
                return (URL: URL, HTTPBody: parameters.formDataValue)
            }
            return (URL: URL, HTTPBody: nil)
        }()

        let URLRequest = NSMutableURLRequest(URL: URLRequestInfo.URL)
        URLRequest.HTTPBody = URLRequestInfo.HTTPBody
        URLRequest.HTTPMethod = rawValue
        headers?.forEach { key, value in
            URLRequest.addValue(value, forHTTPHeaderField: key)
        }
        return URLRequest
    }
}

////////////////////////////////////////////////////////////////////////////


// MARK: - Parameters
////////////////////////////////////////////////////////////////////////////

protocol HTTPParametersConvertible {
    var queryStringValue: String { get }
    var formDataValue: Data { get }
}

////////////////////////////////////////////////////////////////////////////


// MARK: - Errors
////////////////////////////////////////////////////////////////////////////

protocol RequestError {
    init(networkError: ErrorType)
    init(jsonError: ErrorType)
    init?(httpURLResponse: NSHTTPURLResponse)
}

////////////////////////////////////////////////////////////////////////////


// MARK: - Request
////////////////////////////////////////////////////////////////////////////

struct Request<T, E: RequestError> {
    private let dataTask: NSURLSessionDataTask

    init(url: URL, method: HTTPMethod, parameters: HTTPParametersConvertible?, headers: [String: String]? = nil, parse: JSONObject -> Result<T, E>, completion: Result<T, E> -> Void) {
        let URLRequest = method.URLRequest(URL, parameters: parameters, headers: headers)

        dataTask = NSURLSession.sharedSession().dataTaskWithRequest(URLRequest) { data, response, error in
            if let response = response as? NSHTTPURLResponse, error = E(httpURLResponse: response) {
                dispatch_async(dispatch_get_main_queue()) {
                    completion(.Failure(error))
                }
            }
            else {
                if let data = data {
                    var result: Result<T, E>
                    do {
                        let JSON = try JSONObject(NSJSONSerialization.JSONObjectWithData(data, options: []))
                        result = parse(JSON)
                    } catch let error {
                        result = .Failure(E(jsonError: error))
                    }

                    dispatch_async(dispatch_get_main_queue()) {
                        completion(result)
                    }
                }
                else if let error = error {
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(.Failure(E(networkError: error)))
                    }
                }
            }
        }
    }

    func start() {
        dataTask.resume()
    }

    func stop() {
        dataTask.suspend()
    }
}

////////////////////////////////////////////////////////////////////////////

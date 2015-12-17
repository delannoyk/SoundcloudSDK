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

internal class JSONObject {
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

    func map<U>(f: JSONObject -> U) -> [U]? {
        if let value = value as? [AnyObject] {
            return value.map({ f(JSONObject($0)) })
        }
        return nil
    }

    func flatMap<U>(f: JSONObject -> U?) -> [U]? {
        if let value = value as? [AnyObject] {
            return value.flatMap { f(JSONObject($0)) }
        }
        return nil
    }
}

internal extension JSONObject {
    internal var anyObjectValue: AnyObject? {
        return value
    }

    internal var intValue: Int? {
        return (value as? Int)
    }

    internal var uint64Value: UInt64? {
        return (value as? UInt64)
    }

    internal var doubleValue: Double? {
        return (value as? Double)
    }

    internal var boolValue: Bool? {
        return (value as? Bool)
    }

    internal var stringValue: String? {
        return (value as? String)
    }

    internal var URLValue: NSURL? {
        return (value as? String).map { NSURL(string: $0)?.URLByAppendingQueryString("client_id=\(Soundcloud.clientIdentifier!)") } ?? nil
    }

    internal func dateValue(dateFormat: String) -> NSDate? {
        let date: NSDate?? = stringValue.map {
            return NSDateFormatter.dateFormatterWithFormat(dateFormat).dateFromString($0)
        }
        return date ?? nil
    }
    
    internal func arrayValue<T>(mapping: JSONObject -> T?) -> [T]? {
        if let actualJsonArray = value as? [AnyObject] {
            return actualJsonArray.flatMap { mapping(JSONObject($0)) }
        }
        return nil
    }
}

////////////////////////////////////////////////////////////////////////////


// MARK: - DateFormatter
////////////////////////////////////////////////////////////////////////////

private extension NSDateFormatter {
    private static var dateFormatters = [String: NSDateFormatter]()

    private static func dateFormatterWithFormat(format: String) -> NSDateFormatter {
        if let dateFormatter = dateFormatters[format] {
            return dateFormatter
        }

        let dateFormatter = NSDateFormatter()
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

internal enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"

    func URLRequest(URL: NSURL, parameters: HTTPParametersConvertible? = nil) -> NSURLRequest {
        let URLRequestInfo: (URL: NSURL, HTTPBody: NSData?) = {
            if let parameters = parameters {
                if self == .GET {
                    return (URL: URL.URLByAppendingQueryString(parameters.stringValue), HTTPBody: nil)
                }
                return (URL: URL, HTTPBody: parameters.dataValue)
            }
            return (URL: URL, HTTPBody: nil)
        }()

        let URLRequest = NSMutableURLRequest(URL: URLRequestInfo.URL)
        URLRequest.HTTPBody = URLRequestInfo.HTTPBody
        URLRequest.HTTPMethod = rawValue
        return URLRequest
    }
}

////////////////////////////////////////////////////////////////////////////


// MARK: - Parameters
////////////////////////////////////////////////////////////////////////////

internal protocol HTTPParametersConvertible {
    var stringValue: String { get }
    var dataValue: NSData { get }
}

////////////////////////////////////////////////////////////////////////////


// MARK: - Errors
////////////////////////////////////////////////////////////////////////////

internal protocol RequestError {
    init(networkError: ErrorType)
    init(jsonError: ErrorType)
    init?(HTTPURLResponse: NSHTTPURLResponse)
}

////////////////////////////////////////////////////////////////////////////


// MARK: - Request
////////////////////////////////////////////////////////////////////////////

internal struct Request<T, E: RequestError> {
    private let dataTask: NSURLSessionDataTask

    init(URL: NSURL, method: HTTPMethod, parameters: HTTPParametersConvertible?, parse: JSONObject -> Result<T, E>, completion: Result<T, E> -> Void) {
        let URLRequest = method.URLRequest(URL, parameters: parameters)

        dataTask = NSURLSession.sharedSession().dataTaskWithRequest(URLRequest) { data, response, error in
            if let response = response as? NSHTTPURLResponse, error = E(HTTPURLResponse: response) {
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

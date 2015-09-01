//
//  Request.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 15/03/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

internal let GenericError = NSError(domain: "SoundcloudSDK", code: -1, userInfo: nil)

// MARK: - JSONObject
////////////////////////////////////////////////////////////////////////////

internal class JSONObject: SequenceType {
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

    func generate() -> GeneratorOf<JSONObject> {
        return GeneratorOf<JSONObject> {
            if self.index + 1 < 0 {
                return nil
            }
            return self[self.index++]
        }
    }

    func map<U>(f: JSONObject -> U) -> [U]? {
        if let value = value as? [AnyObject] {
            return value.map({ f(JSONObject($0)) })
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
        if let actualJsonArray =  value as? [AnyObject] {
            let values = actualJsonArray.map { mapping(JSONObject($0)) }
            return compact(values)
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


// MARK: - Box
////////////////////////////////////////////////////////////////////////////

public class Box<T> {
    public let value: T

    public init(_ value: T) {
        self.value = value
    }
}

////////////////////////////////////////////////////////////////////////////


// MARK: - Result
////////////////////////////////////////////////////////////////////////////

public enum Result<T> {
    case Success(Box<T>)
    case Failure(NSError)

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
            return result.value
        default:
            return nil
        }
    }

    public var error: NSError? {
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


// MARK: - Request
////////////////////////////////////////////////////////////////////////////

internal struct Request<T> {
    private let dataTask: NSURLSessionDataTask

    init(URL: NSURL, method: HTTPMethod, parameters: HTTPParametersConvertible?, parse: JSONObject -> Result<T>, completion: Result<T> -> Void) {
        let URLRequest = method.URLRequest(URL, parameters: parameters)

        dataTask = NSURLSession.sharedSession().dataTaskWithRequest(URLRequest, completionHandler: { (data, response, error) -> Void in
            if let session = Soundcloud.session, response = response as? NSHTTPURLResponse where response.statusCode == 401 {
                session.refreshSession({ result in
                    switch result {
                    case .Success(_):
                        let request = Request(URL: URL, method: method, parameters: parameters, parse: parse, completion: completion)
                        request.start()
                    case .Failure(let error):
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            completion(.Failure(error))
                        })
                    }
                })
            }
            else {
                if let data = data {
                    let JSON = JSONObject(NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil))
                    let result = parse(JSON)

                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(result)
                    })
                }
                else {
                    completion(.Failure(error))
                }
            }
        })
    }

    func start() {
        dataTask.resume()
    }

    func stop() {
        dataTask.suspend()
    }
}

////////////////////////////////////////////////////////////////////////////

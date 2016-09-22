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
        return (value as? Dictionary<String, AnyObject>).map { JSONObject($0[key]) } ?? JSONObject(nil)
    }

    func map<U>(_ transform: (JSONObject) -> U) -> [U]? {
        if let value = value as? [AnyObject] {
            return value.map({ transform(JSONObject($0)) })
        }
        return nil
    }

    func flatMap<U>(_ transform: (JSONObject) -> U?) -> [U]? {
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

    func dateValue(withFormat format: String) -> Date? {
        let date: Date?? = stringValue.map {
            return DateFormatter.dateFormatter(withFormat: format).date(from: $0)
        }
        return date ?? nil
    }
    
    func arrayValue<T>(_ mapping: (JSONObject) -> T?) -> [T]? {
        if let actualJsonArray = value as? [AnyObject] {
            return actualJsonArray.flatMap { mapping(JSONObject($0)) }
        }
        return nil
    }
}

////////////////////////////////////////////////////////////////////////////


// MARK: - DateFormatter
////////////////////////////////////////////////////////////////////////////

private extension DateFormatter {
    static var dateFormatters = [String: DateFormatter]()

    static func dateFormatter(withFormat format: String) -> DateFormatter {
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
    case success(T)
    case failure(E)

    public var isSuccessful: Bool {
        switch self {
        case .success(_):
            return true
        default:
            return false
        }
    }

    public var result: T? {
        switch self {
        case .success(let result):
            return result
        default:
            return nil
        }
    }

    public var error: E? {
        switch self {
        case .failure(let error):
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

    func urlRequest(_ url: URL, parameters: HTTPParametersConvertible? = nil, headers: [String: String]? = nil) -> URLRequest {
        let urlRequestInfo: (url: URL, HTTPBody: Data?) = {
            if let parameters = parameters {
                if self == .GET {
                    return (url: url.appendingQueryString(parameters.queryStringValue), HTTPBody: nil)
                }
                return (url: url, HTTPBody: parameters.formDataValue)
            }
            return (url: url, HTTPBody: nil)
        }()

        var request = URLRequest(url: urlRequestInfo.url)
        request.httpBody = urlRequestInfo.HTTPBody
        request.httpMethod = rawValue
        headers?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        return request
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
    init(networkError: Error)
    init(jsonError: Error)
    init?(httpURLResponse: HTTPURLResponse)
}

////////////////////////////////////////////////////////////////////////////


// MARK: - Request
////////////////////////////////////////////////////////////////////////////

struct Request<T, E: RequestError> {
    fileprivate let dataTask: URLSessionDataTask

    init(url: URL, method: HTTPMethod, parameters: HTTPParametersConvertible?, headers: [String: String]? = nil, parse: @escaping (JSONObject) -> Result<T, E>, completion: @escaping (Result<T, E>) -> Void) {
        let request = method.urlRequest(url, parameters: parameters, headers: headers)

        dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse, let error = E(httpURLResponse: response) {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            else {
                if let data = data {
                    var result: Result<T, E>
                    do {
                        let JSON = try JSONObject(JSONSerialization.jsonObject(with: data, options: []) as AnyObject)
                        result = parse(JSON)
                    } catch let error {
                        result = .failure(E(jsonError: error))
                    }

                    DispatchQueue.main.async {
                        completion(result)
                    }
                }
                else if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(E(networkError: error)))
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

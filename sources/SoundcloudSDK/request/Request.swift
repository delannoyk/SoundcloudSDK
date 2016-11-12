//
//  Request.swift
//  SoundcloudSDK
//
//  Created by Kevin DELANNOY on 15/03/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Foundation

class JSONObject {
    let value: Any?
    var index: Int = 0

    init(_ value: Any?) {
        self.value = value
    }

    subscript(index: Int) -> JSONObject {
        return (value as? [Any]).map { JSONObject($0[index]) } ?? JSONObject(nil)
    }

    subscript(key: String) -> JSONObject {
        return (value as? NSDictionary).map { JSONObject($0.object(forKey: key)) } ?? JSONObject(nil)
    }

    func map<U>(transform: (JSONObject) -> U) -> [U]? {
        if let value = value as? [Any] {
            return value.map({ transform(JSONObject($0)) })
        }
        return nil
    }

    func flatMap<U>(transform: (JSONObject) -> U?) -> [U]? {
        if let value = value as? [Any] {
            return value.flatMap { transform(JSONObject($0)) }
        }
        return nil
    }
}

extension JSONObject {
    var anyValue: Any? {
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
        return (value as? String).map { URL(string: $0)?.appendingQueryString("client_id=\(SoundcloudClient.clientIdentifier!)") } ?? nil
    }

    func dateValue(format: String) -> Date? {
        let date: Date?? = stringValue.map {
            return DateFormatter.dateFormatter(with: format).date(from: $0)
        }
        return date ?? nil
    }
}

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

    public func recover(_ transform: (E) -> T) -> T {
        switch self {
        case .success(let result):
            return result
        case .failure(let error):
            return transform(error)
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"

    func urlRequest(url: URL, parameters: HTTPParametersConvertible? = nil, headers: [String: String]? = nil) -> URLRequest {
        let URLRequestInfo: (url: URL, HTTPBody: Data?) = {
            if let parameters = parameters {
                if self == .get {
                    return (url: url.appendingQueryString(parameters.queryStringValue), HTTPBody: nil)
                }
                return (url: url, HTTPBody: parameters.formDataValue)
            }
            return (url: url, HTTPBody: nil)
        }()

        var request = URLRequest(url: URLRequestInfo.url)
        request.httpBody = URLRequestInfo.HTTPBody
        request.httpMethod = rawValue
        headers?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        return request
    }
}

protocol HTTPParametersConvertible {
    var queryStringValue: String { get }
    var formDataValue: Data { get }
}

protocol RequestError {
    init(networkError: Error)
    init(jsonError: Error)
    init?(httpURLResponse: HTTPURLResponse)
}

public protocol CancelableOperation {
    func cancel()
}

struct Request<T, E: RequestError>: CancelableOperation {
    private let dataTask: URLSessionDataTask

    init(url: URL, method: HTTPMethod, parameters: HTTPParametersConvertible?, headers: [String: String]? = nil, parse: @escaping (JSONObject) -> Result<T, E>, completion: @escaping (Result<T, E>) -> Void) {
        let URLRequest = method.urlRequest(url: url, parameters: parameters, headers: headers)

        dataTask = URLSession.shared.dataTask(with: URLRequest) { data, response, error in
            if let response = response as? HTTPURLResponse, let error = E(httpURLResponse: response) {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            } else {
                if let data = data {
                    var result: Result<T, E>
                    do {
                        let JSON = try JSONObject(JSONSerialization.jsonObject(with: data, options: []))
                        result = parse(JSON)
                    } catch let error {
                        result = .failure(E(jsonError: error))
                    }

                    DispatchQueue.main.async {
                        completion(result)
                    }
                } else if let error = error {
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

    func cancel() {
        dataTask.cancel()
    }
}

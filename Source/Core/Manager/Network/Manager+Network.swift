//
//  Manager+Network.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 23/11/24.
//

import Foundation

extension Manager {
    struct Network: Sendable {
        private let configuration: Configuration = .default

        public var get: @Sendable (String, @escaping (Result<Data, NetworkError>) -> Void) -> Void
        public var post: @Sendable (String, Data?, @escaping (Result<Data, NetworkError>) -> Void) -> Void
        public var put: @Sendable (String, Data?, @escaping (Result<Data, NetworkError>) -> Void) -> Void
        public var delete: @Sendable (String, @escaping (Result<Data, NetworkError>) -> Void) -> Void
    }
}

extension Manager.Network {
    struct Configuration {
        let baseURL: URL
        let timeout: TimeInterval
        let retryCount: Int
        let token: String

        static let `default` = Configuration(
            baseURL: URL(string: "https://7hgi9vtkdc.execute-api.sa-east-1.amazonaws.com")!,
            timeout: 10,
            retryCount: 3, 
            token: ""
        )
        
        static let exchangeRate = Configuration(
            baseURL: URL(string: "https://api-realtime.exrates.coinapi.io")!,
            timeout: 10,
            retryCount: 3, 
            token: "a8675627-7e9b-414e-822a-e5f762ae7543"
        )
        
        static let marketData = Configuration(
            baseURL: URL(string: "https://rest.coinapi.io")!,
            timeout: 10,
            retryCount: 3, 
            token: "cfa0e689-7529-4a00-9c84-276be9102ec6"
        )
    }

    enum NetworkError: Error, Equatable {
        case connectionError(String)
        case invalidResponse
        case decodingError(String)
        case serviceException(ServiceException)
    }

    enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }

    struct ServiceException: Codable, Equatable {
        let error: String
    }

    struct ResponseContext {
        let attempt: Int
        let configuration: Configuration
        let retry: (Int) -> Void
        let completion: (Result<Data, NetworkError>) -> Void
    }
}

extension Manager.Network {
    public static let exchangeRateLive: Self = {
        let configuration = Configuration.exchangeRate
        return Self(
            get: { endpoint, completion in
                request(endpoint: endpoint,
                        method: .get,
                        configuration: configuration,
                        completion: completion)
            },
            post: { endpoint, body, completion in
                request(endpoint: endpoint,
                        method: .post,
                        body: body,
                        configuration: configuration,
                        completion: completion)
            },
            put: { endpoint, body, completion in
                request(endpoint: endpoint,
                        method: .put,
                        body: body,
                        configuration: configuration,
                        completion: completion)
            },
            delete: { endpoint, completion in
                request(endpoint: endpoint,
                        method: .delete,
                        configuration: configuration,
                        completion: completion)
            }
        )
    }()
    
    public static let marketRateLive: Self = {
        let configuration = Configuration.marketData
        return Self(
            get: { endpoint, completion in
                request(endpoint: endpoint,
                        method: .get,
                        configuration: configuration,
                        completion: completion)
            },
            post: { endpoint, body, completion in
                request(endpoint: endpoint,
                        method: .post,
                        body: body,
                        configuration: configuration,
                        completion: completion)
            },
            put: { endpoint, body, completion in
                request(endpoint: endpoint,
                        method: .put,
                        body: body,
                        configuration: configuration,
                        completion: completion)
            },
            delete: { endpoint, completion in
                request(endpoint: endpoint,
                        method: .delete,
                        configuration: configuration,
                        completion: completion)
            }
        )
    }()

    private static func request(
        endpoint: String,
        method: Method,
        body: Data? = nil,
        configuration: Configuration,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) {
        let url = configuration.baseURL.appendingPathComponent(endpoint)
        let session = configureSession(with: configuration)

        func performRequest(attempt: Int) {
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.httpBody = body

            interceptRequest(&request, with: configuration)

            let task = session.dataTask(with: request) { data, response, error in
                let context = ResponseContext(
                    attempt: attempt,
                    configuration: configuration,
                    retry: performRequest,
                    completion: completion
                )

                do {
                    try handleResponse(data: data, response: response, error: error, context: context)
                } catch {
                    context.completion(.failure(.decodingError(error.localizedDescription)))
                }
            }
            task.resume()
        }

        performRequest(attempt: 0)
    }

    private static func configureSession(with configuration: Configuration) -> URLSession {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = configuration.timeout
        return URLSession(configuration: sessionConfig)
    }

    private static func handleResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        context: ResponseContext
    ) throws {
        if let error = error {
            handleConnectionError(error, context: context)
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            context.completion(.failure(.invalidResponse))
            return
        }

        guard let data = data else {
            context.completion(.failure(.invalidResponse))
            return
        }

        switch httpResponse.statusCode {
        case 200...299:
            context.completion(.success(data))
        case 400...599:
            handleServerError(data: data, statusCode: httpResponse.statusCode, context: context)
        default:
            context.completion(.failure(.invalidResponse))
        }
    }

    private static func handleConnectionError(_ error: Error, context: ResponseContext) {
        if context.attempt < context.configuration.retryCount {
            scheduleRetry(context)
        } else {
            context.completion(.failure(.connectionError(error.localizedDescription)))
        }
    }

    private static func handleServerError(data: Data, statusCode: Int, context: ResponseContext) {
        do {
            let serviceError = try decodeServiceError(data)
            if shouldRetry(statusCode: statusCode,
                           attempt: context.attempt,
                           maxAttempts: context.configuration.retryCount) {
                scheduleRetry(context)
            } else {
                context.completion(.failure(.serviceException(serviceError)))
            }
        } catch {
            context.completion(.failure(.decodingError(error.localizedDescription)))
        }
    }

    private static func decodeServiceError(_ data: Data) throws -> ServiceException {
        return try JSONDecoder().decode(ServiceException.self, from: data)
    }

    private static func shouldRetry(statusCode: Int, attempt: Int, maxAttempts: Int) -> Bool {
        return statusCode >= 500 && attempt < maxAttempts
    }

    private static func scheduleRetry(_ context: ResponseContext) {
        let delay = pow(2.0, Double(context.attempt)) // Backoff exponencial
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            context.retry(context.attempt + 1)
        }
    }

    private static func interceptRequest(_ request: inout URLRequest, with configuration: Configuration) {
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("json", forHTTPHeaderField: "X-Requested-With")
        request.setValue("application/json", forHTTPHeaderField: "Accept-Encoding")
        request.setValue(configuration.token, forHTTPHeaderField: "X-CoinAPI-Key")
    }

    static func request<T: Decodable>(endpoint: String,
                                      method: Method,
                                      body: Data? = nil,
                                      configuration: Configuration = .default) async throws -> T {
        let data = try await performRequest(endpoint: endpoint,
                                            method: method,
                                            body: body,
                                            configuration: configuration)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private static func performRequest(endpoint: String,
                                       method: Method,
                                       body: Data? = nil,
                                       configuration: Configuration) async throws -> Data {
        let url = configuration.baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body

        interceptRequest(&request, with: configuration)
        let session = configureSession(with: configuration)

        let (data, response) = try await session.data(for: request)
        return try handleResponse(data: data, response: response)
    }

    private static func handleResponse(data: Data, response: URLResponse?) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return data
        case 400...599:
            let serviceError = try? JSONDecoder().decode(ServiceException.self, from: data)
            if let serviceError = serviceError {
                throw NetworkError.serviceException(serviceError)
            }
            throw NetworkError.invalidResponse
        default:
            throw NetworkError.invalidResponse
        }
    }
}

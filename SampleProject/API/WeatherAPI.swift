//
//  APICaller.swift
//  SampleProject
//
//  Created by hideto.higashi on 2022/12/20.
//

import Foundation
import ComposableArchitecture

struct APICaller {
    static var shared = APICaller()

    func fetch(url: String) async throws -> (Data, URLResponse) {
        guard let url = URL(string: url) else { throw NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL) }
        let (data, response) = try await URLSession.shared.data(from: url)
        return (data, response)
    }

    func decode<T: Decodable>(data: Data) throws -> T {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return try jsonDecoder.decode([T].self, from: data)[0]
    }
}

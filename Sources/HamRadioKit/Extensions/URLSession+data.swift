//
//  URLSession+data.swift
//  
//
//  Created by Thomas Gatzweiler on 27.08.22.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@available(macOS 10.15, *)
extension URLSession {
    func data(from url: URL) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            self.dataTask(with: url) { data, response, _ in
                if let data = data, let response = response {
                    continuation.resume(with: .success((data, response)))
                }
                else {
                    continuation.resume(with: .failure(DownloadError()))
                }

            }.resume()
        }
    }
}

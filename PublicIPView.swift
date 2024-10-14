//
//  PublicIPView.swift
//  PaldPing
//
//  Created by Pierre-Alexandre L. Dumais on 2024-10-13.
//

import Foundation

enum PublicIPError: Error {
    case invalidURL
    case networkError(Error)
    case invalidData
}

class PublicIPFetcher: ObservableObject {
    @Published var publicIP: String = "Fetching..."
    @Published var error: PublicIPError?

    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func fetchPublicIP() {
        guard let url = URL(string: "https://api.ipify.org") else {
            self.error = .invalidURL
            self.publicIP = "Error: Invalid URL"
            return
        }

        urlSession.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.error = .networkError(error)
                    self?.publicIP = "Error: \(error.localizedDescription)"
                    return
                }

                guard let data = data, let ip = String(data: data, encoding: .utf8) else {
                    self?.error = .invalidData
                    self?.publicIP = "Error: Couldn't fetch IP"
                    return
                }

                self?.error = nil
                self?.publicIP = ip
            }
        }.resume()
    }
}

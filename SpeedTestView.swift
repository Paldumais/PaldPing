//
//  SpeedTestView.swift
//  PaldPing
//
//  Created by Pierre-Alexandre L. Dumais on 2024-10-13.
//

import Foundation

enum SpeedTestError: Error {
    case invalidURL
    case networkError(Error)
    case noData
}

class SpeedTestManager: ObservableObject {
    @Published var downloadSpeed: Double = 0
    @Published var uploadSpeed: Double = 0
    @Published var isTestingSpeed: Bool = false
    @Published var error: SpeedTestError?

    private let downloadTestURL = "https://speed.cloudflare.com/__down?bytes=100000000"
    private let uploadTestURL = "https://speed.cloudflare.com/__up"
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func startSpeedTest() {
        isTestingSpeed = true
        downloadSpeed = 0
        uploadSpeed = 0
        error = nil

        testDownloadSpeed { [weak self] result in
            switch result {
            case .success(let speed):
                self?.downloadSpeed = speed
                self?.testUploadSpeed { [weak self] result in
                    switch result {
                    case .success(let speed):
                        self?.uploadSpeed = speed
                    case .failure(let error):
                        self?.error = error
                    }
                    self?.isTestingSpeed = false
                }
            case .failure(let error):
                self?.error = error
                self?.isTestingSpeed = false
            }
        }
    }

    private func testDownloadSpeed(completion: @escaping (Result<Double, SpeedTestError>) -> Void) {
        guard let url = URL(string: downloadTestURL) else {
            completion(.failure(.invalidURL))
            return
        }

        let startTime = Date()

        urlSession.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(.networkError(error))) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.noData)) }
                return
            }

            let elapsedTime = Date().timeIntervalSince(startTime)
            let speedMbps = Double(data.count * 8) / (1_000_000 * elapsedTime)

            DispatchQueue.main.async {
                completion(.success(speedMbps))
            }
        }.resume()
    }

    private func testUploadSpeed(completion: @escaping (Result<Double, SpeedTestError>) -> Void) {
        guard let url = URL(string: uploadTestURL) else {
            completion(.failure(.invalidURL))
            return
        }

        let dataToUpload = Data(repeating: 0, count: 10_000_000) // 10 MB of data
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

        let startTime = Date()

        urlSession.uploadTask(with: request, from: dataToUpload) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(.networkError(error))) }
                return
            }

            let elapsedTime = Date().timeIntervalSince(startTime)
            let speedMbps = Double(dataToUpload.count * 8) / (1_000_000 * elapsedTime)

            DispatchQueue.main.async {
                completion(.success(speedMbps))
            }
        }.resume()
    }
}

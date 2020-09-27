//
//  GoogleFontAPI.swift
//  GoogleFontPicker
//
//  Created by Eric Hsu on 2020/9/27.
//

import Foundation

class GoogleFontAPI {
    static let apiUrl = URL(string: "https://www.googleapis.com/webfonts/v1/webfonts")!
    #warning("Please input your Google API key")
    static let apiKey = "TO BE REPLACED"
    enum APIError: Error {
        case unknown
    }
    class func fetch(_ baseUrl: URL = apiUrl, _ key: String = apiKey, completion: @escaping (Result<GoogleFontResp, Error>) -> Void) {
        guard var urlComp = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false) else {
            return
        }
        urlComp.queryItems = [URLQueryItem(name: "key", value: key)]
        guard let url = urlComp.url else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                return DispatchQueue.main.async { completion(.failure(error ?? APIError.unknown)) }
            }
            do {
                let res = try JSONDecoder().decode(GoogleFontResp.self, from: data)
                DispatchQueue.main.async { completion(.success(res)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}

struct GoogleFontResp: Codable {
    let kind: String
    struct Item: Codable {
        let family: String
        let variants: [String]
        let subsets: [String]
        let version: String
        let lastModified: String
        struct Files: Codable {
            let regular: URL?
            let italic: URL?
            let _500: URL?
            let _600: URL?
            let _700: URL?
            let _800: URL?
            let _100: URL?
            let _200: URL?
            let _300: URL?
            let _500italic: URL?
            let _700italic: URL?
            let _800italic: URL?
            let _900: URL?
            let _900italic: URL?
            let _100italic: URL?
            let _300italic: URL?
            let _600italic: URL?
            let _200italic: URL?
            private enum CodingKeys: String, CodingKey {
                case regular
                case italic
                case _500 = "500"
                case _600 = "600"
                case _700 = "700"
                case _800 = "800"
                case _100 = "100"
                case _200 = "200"
                case _300 = "300"
                case _500italic = "500italic"
                case _700italic = "700italic"
                case _800italic = "800italic"
                case _900 = "900"
                case _900italic = "900italic"
                case _100italic = "100italic"
                case _300italic = "300italic"
                case _600italic = "600italic"
                case _200italic = "200italic"
            }
        }
        let files: Files
        let category: String
        let kind: String
    }
    let items: [Item]
}

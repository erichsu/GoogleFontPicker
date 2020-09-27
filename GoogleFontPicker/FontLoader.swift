//
//  FontLoader.swift
//  GoogleFontPicker
//
//  Created by Eric Hsu on 2020/9/27.
//

import UIKit
class FontLoader {
    static let cache = NSCache<NSURL, UIFont>()
    class func load(url: URL, completion: @escaping (Result<UIFont, Error>) -> Void) {

        print("Loading Font URL: \(url)")
        if let font = cache.object(forKey: url as NSURL) {
            print("Font: \(font.familyName) loaded from cache!")
            DispatchQueue.main.async { completion(.success(font)) }
        } else {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else { return }
                let fontData = data as CFData?
                let dataProvider = CGDataProvider(data: fontData!)
                let cgFont = CGFont(dataProvider!)

                var error: Unmanaged<CFError>?
                if !CTFontManagerRegisterGraphicsFont(cgFont!, &error) {
                    print("Error loading Font!")
                    DispatchQueue.main.async { completion(.failure(error!.takeUnretainedValue())) }
                } else {
                    let fontName = cgFont!.postScriptName! as String
                    print("Font: \(fontName) loaded!")
                    let font = UIFont(name: fontName, size: UIFont.systemFontSize)!
                    cache.setObject(font, forKey: url as NSURL)
                    DispatchQueue.main.async { completion(.success(font)) }
                }
            }.resume()
        }
    }
}

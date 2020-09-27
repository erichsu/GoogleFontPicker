//
//  ViewController.swift
//  GoogleFontPicker
//
//  Created by Eric Hsu on 2020/9/27.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    typealias Item = GoogleFontResp.Item
    var fonts: [Item] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        GoogleFontAPI.fetch { [weak self] res in
            guard case .success(let data) = res else { return }
            self?.fonts = data.items.filter { $0.files.regular != nil }
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        //
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fonts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fontCell", for: indexPath)
        (cell as? FontCell)?.setup(with: fonts[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fontUrl = fonts[indexPath.row].files.regular!
        FontLoader.load(url: fontUrl) { [previewLabel] res in
            guard case .success(let font) = res else { return }
            previewLabel?.font = font
        }
    }
}

class FontCell: UICollectionViewCell {
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var fontLabel: UILabel!

    func setup(with item: GoogleFontResp.Item) {
        fontLabel.text = item.family

        FontLoader.load(url: item.files.regular!) { [fontLabel, indicator] res in
            indicator?.stopAnimating()
            switch res {
                case .success(let font):
                    fontLabel?.font = font
                case .failure(let error):
                    fontLabel?.text = "Missing Font!"
                    print(error)
            }
        }
    }
}

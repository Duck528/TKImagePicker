//
//  TKAlbumViewController.swift
//  TKImagePicker
//
//  Created by 안덕환 on 2018. 3. 11..
//  Copyright © 2018년 안덕환. All rights reserved.
//

import UIKit
import Photos


class TKAlbumsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var albumCollection: TKAlbumCollection?
    private let cellIdentifier = "AlbumCell"
    
    public static func create() -> TKAlbumsViewController {
        let sb = UIStoryboard(name: "TKAlbum", bundle: TKBundle.bundle())
        return sb.instantiateViewController(withIdentifier: "Albums") as! TKAlbumsViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.reloadData()
    }
}


extension TKAlbumsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        guard let albumCollection = albumCollection else { return 0 }
        return albumCollection.numberOfPhotoAlbums
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TKAlbumCell,
            let albumCollection = albumCollection else {
                return UICollectionViewCell()
        }
        
        let album = albumCollection.album(at: indexPath)
        cell.model = album
        return cell
    }
}

extension TKAlbumsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.width, height: 90)
    }
}


class TKAlbumCell: UICollectionViewCell {
 
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numberOfPhotosLabel: UILabel!
    
    var model: TKAlbum? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        guard let model = model else { return }
        titleLabel.text = model.albumTitle
        numberOfPhotosLabel.text = model.numberOfPhotoAssets.formattedByDecimal()
        loadPhoto()
    }
    
    private func loadPhoto() {
        guard let model = model, let thumbnailPhotoAsset = model.thumbnailPhotoAsset else { return }
        PHImageManager.default().requestImage(
            for: thumbnailPhotoAsset, targetSize: bounds.size,
            contentMode: .aspectFill, options: nil, resultHandler: { [weak self] image, _ in
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
        })
    }
}

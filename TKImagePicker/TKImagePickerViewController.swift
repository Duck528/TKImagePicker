//
//  TKImagePickerViewController.swift
//  TKImagePicker
//
//  Created by 안덕환 on 2018. 3. 11..
//  Copyright © 2018년 안덕환. All rights reserved.
//

import UIKit
import SnapKit
import Photos

public class TKImagePickerViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var albumLabel: UIButton!
    @IBOutlet weak var albumArrowIndicatorView: UIImageView!
    @IBOutlet weak var previewImageView: UIImageView!
    
    var albumCollection = TKAlbumCollection()
    
    private let cellIdentifier = "PhotoCell"
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        albumCollection.fetchPhotoAlbums(onCompletion: { [weak self] in
            self?.collectionView.reloadData()
        })
    }
    
    public static func create() -> TKImagePickerViewController {
        let sb = UIStoryboard(name: "TKImagePicker", bundle: TKBundle.bundle())
        return sb.instantiateViewController(withIdentifier: "previewImagePicker") as! TKImagePickerViewController
    }
}


extension TKImagePickerViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        guard let currentAlbum = albumCollection.currentAlbum else { return 0 }
        return currentAlbum.numberOfPhotoAssets
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

extension TKImagePickerViewController: UICollectionViewDelegateFlowLayout {
    
    private func cellSize() -> CGSize {
        let len = UIScreen.main.bounds.width / 4.0
        return CGSize(width: len, height: len)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize()
    }
}


class TKPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var blurView: UIView!
    // video meta info
    @IBOutlet weak var videoPlayTimeLabel: UILabel!
    
    private var requestId: PHImageRequestID?
    
    var model: PHAsset? {
        didSet {
            updateUI()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        guard let requestId = requestId else { return }
        PHImageManager.default().cancelImageRequest(requestId)
    }
    
    private func updateUI() {
        guard let model = model else { return }
        switch model.mediaType {
        case .image:
            loadPhoto()
        case .video:
            loadVideo()
        default:
            break
        }
    }
    
    private func loadPhoto() {
        guard let model = model else { return }
        requestId = PHImageManager.default().requestImage(
            for: model, targetSize: frame.size, contentMode: .aspectFill,
            options: nil, resultHandler: { [weak self] image, _ in
                if let image = image {
                    DispatchQueue.main.async { [weak self] in
                        self?.imageView.image = image
                    }
                }
        })
    }
    
    private func loadVideo() {
        guard let model = model else { return }
        let requestOptions = PHVideoRequestOptions()
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.deliveryMode = .fastFormat
        requestId = PHImageManager.default().requestAVAsset(
            forVideo: model, options: requestOptions, resultHandler: { [weak self] avAsset, _, _ in
                guard let avAsset = avAsset else { return }
                let thumbnailGenerator = AVAssetImageGenerator(asset: avAsset)
                let thumbnailTime = CMTime(seconds: 1, preferredTimescale: 60)
                let cgImage = try? thumbnailGenerator.copyCGImage(at: thumbnailTime, actualTime: nil)
                if let cgImage = cgImage {
                    let thumbnailImage = UIImage(cgImage: cgImage)
                    DispatchQueue.main.async {
                        self?.imageView.image = thumbnailImage
                    }
                }
        })
    }
}








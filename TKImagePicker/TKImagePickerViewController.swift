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


public protocol TKImagePickerViewControllerDelegate: class {
    
    func imagePickerViewControllerDidCancel(_ imagePicker: TKImagePickerViewController)
    func imagePickerViewControllerDidAdd(_ imagePicker: TKImagePickerViewController, image: UIImage)
}


public class TKImagePickerViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var gridLayout: TKGridLayout!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var albumArrowIndicatorView: UIImageView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var navigationAreaView: UIView!
    @IBOutlet weak var albumTitleLabel: UILabel!
    
    private let cellIdentifier = "PhotoCell"
    
    public weak var delegate: TKImagePickerViewControllerDelegate?
    
    var albumCollection = TKAlbumCollection()
    var albumsPresented = false
    
    public static func create() -> TKImagePickerViewController {
        let sb = UIStoryboard(name: "TKImagePicker", bundle: TKBundle.bundle())
        return sb.instantiateViewController(withIdentifier: "previewImagePicker") as! TKImagePickerViewController
    }
    
    lazy var albumsViewController: TKAlbumsViewController = {
        let vc = TKAlbumsViewController.create()
        vc.delegate = self
        vc.albumCollection = albumCollection
        return vc
    }()
    
    lazy var albumsSize: CGSize = {
        let height = UIScreen.main.bounds.height - navigationAreaView.frame.height
        return CGSize(width: UIScreen.main.bounds.width, height: height)
    }()
    
    lazy var albumsBottomOrigin: CGPoint = {
        let point = CGPoint(x: UIScreen.main.bounds.minX, y: UIScreen.main.bounds.maxY)
        return point
    }()
    
    lazy var albumsTopOrigin: CGPoint = {
        let pivotFrame = navigationAreaView.frame
        let point = CGPoint(x: pivotFrame.minX, y: pivotFrame.maxY)
        return point
    }()
    
    
    func presentAlbums() {
        let fromFrame = CGRect(origin: albumsBottomOrigin, size: albumsSize)
        add(childViewController: albumsViewController, frame: fromFrame)
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let `self` = self else { return }
            self.albumsViewController.view.frame.origin = self.albumsTopOrigin
            self.cancelButton.alpha = 0
            self.addButton.alpha = 0
        })
    }
    
    func dismissAlbums() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let `self` = self else { return }
            self.albumsViewController.view.frame.origin = self.albumsBottomOrigin
            self.cancelButton.alpha = 1
            self.addButton.alpha = 1
        }, completion: { [weak self] _ in
            guard let `self` = self else { return }
            self.remove(childViewController: self.albumsViewController)
        })
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupAlbums()
    }
    
    private func setupAlbums() {
        albumCollection.albumSelected = { [weak self] album in
            self?.albumTitleLabel.text = album.albumTitle
            self?.collectionView.reloadData()
        }
        albumCollection.fetchPhotoAlbums(onCompletion: { [weak self] in
            self?.collectionView.reloadData()
        })
    }
    
    @IBAction func addButtonTapped() {
        delegate?.imagePickerViewControllerDidCancel(self)
    }
    
    @IBAction func cancelButtonTapped() {
        delegate?.imagePickerViewControllerDidCancel(self)
    }
    
    
    @IBAction func albumButtonTapped(_ sender: UIButton) {
        if albumsPresented { dismissAlbums() }
        else { presentAlbums() }
        
        albumsPresented = !albumsPresented
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
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TKPhotoCell,
            let currentAlbum = albumCollection.currentAlbum else {
                return UICollectionViewCell()
        }
        
        let photoAsset = currentAlbum.photo(at: indexPath)
        cell.model = photoAsset
        return cell
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


extension TKImagePickerViewController: TKAlbumsViewControllerDelegate {
    
    func albumsViewController(_ viewController: UIViewController, didSelectItemAt indexPath: IndexPath) {
        albumCollection.selectAlbum(at: indexPath)
        dismissAlbums()
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
            videoPlayTimeLabel.isHidden = true
            loadPhoto()
        case .video:
            videoPlayTimeLabel.isHidden = false
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








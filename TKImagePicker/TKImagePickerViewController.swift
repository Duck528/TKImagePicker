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
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var previewAreaView: UIView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var previewTapAreaView: UIView!
    
    private let cellIdentifier = "PhotoCell"
    
    public weak var delegate: TKImagePickerViewControllerDelegate?
    
    private var albumCollection = TKAlbumCollection()
    private var albumsPresented = false
    
    private var previewPresented = true
    private var priorContentOffset: CGPoint?
    
    private let maxPreviewTopDistance: CGFloat = -376
    private let needToCloseRatio: CGFloat = 0.7
    
    private lazy var topDistance: CGFloat = {
        return navigationBarView.bounds.height + previewAreaView.bounds.height
    }()
    
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
        let height = UIScreen.main.bounds.height - navigationBarView.frame.height
        return CGSize(width: UIScreen.main.bounds.width, height: height)
    }()
    
    lazy var albumsBottomOrigin: CGPoint = {
        let point = CGPoint(x: UIScreen.main.bounds.minX, y: UIScreen.main.bounds.maxY)
        return point
    }()
    
    lazy var albumsTopOrigin: CGPoint = {
        let pivotFrame = navigationBarView.frame
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
        setupViews()
        setupAlbums()
    }
    
    private func setupViews() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(movePreviewIfNeeded(_:)))
        panGestureRecognizer.delegate = self
        collectionView.addGestureRecognizer(panGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openPreviewIfNeeded(_:)))
        previewTapAreaView.addGestureRecognizer(tapGestureRecognizer)
        
        collectionView.contentInset.top = 1
    }
    
    @objc private func openPreviewIfNeeded(_ tapGestureRecognizer: UITapGestureRecognizer) {
        if !previewPresented { openPreview() }
    }
    
    @objc private func movePreviewIfNeeded(_ panGestureRecognizer: UIPanGestureRecognizer) {
        if !previewPresented { return }
        
        let pointInView = panGestureRecognizer.location(in: view)
        let distance = min(max(pointInView.y - topDistance, maxPreviewTopDistance), 0)
        let ratioScroll = abs(distance / topDistance)
        
        switch panGestureRecognizer.state {
        case .changed:
            navigationBarView.snp.updateConstraints { (make) in
                make.top.equalToSuperview().offset(distance)
            }
            
            if let priorContentOffset = priorContentOffset, ratioScroll > 0 {
                collectionView.contentOffset = priorContentOffset
            }
            
            priorContentOffset = collectionView.contentOffset

        case .ended:
            if ratioScroll > needToCloseRatio {
                closePreview()
            } else {
                openPreview()
            }
        default:
            break
        }
    }
    
    private func closePreview() {
        navigationBarView.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(maxPreviewTopDistance)
        }
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
        
        previewPresented = false
    }
    
    private func openPreview() {
        navigationBarView.snp.updateConstraints { (make) in
            make.top.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
        
        previewPresented = true
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
    
    public override var prefersStatusBarHidden: Bool { return true }
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


extension TKImagePickerViewController: TKAlbumsViewControllerDelegate {
    
    func albumsViewController(_ viewController: UIViewController, didSelectItemAt indexPath: IndexPath) {
        albumCollection.selectAlbum(at: indexPath)
        dismissAlbums()
    }
}


extension TKImagePickerViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


extension TKImagePickerViewController: UICollectionViewDelegate {
    
    private func loadImage(at indexPath: IndexPath, size: CGSize, onSuccess: @escaping ((UIImage) -> ())) {
        guard let phAsset = albumCollection.currentAlbum?.photo(at: indexPath) else { return }
        PHImageManager.default().requestImage(
            for: phAsset, targetSize: size,
            contentMode: .aspectFill, options: nil,
            resultHandler: { image, _ in
                guard let image = image else { return }
                DispatchQueue.main.async {
                    onSuccess(image)
                }
        })
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
        loadImage(at: indexPath, size: previewImageView.frame.size, onSuccess: { [weak self] image in
            self?.previewImageView.image = image
        })
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








//
//  TKAlbumViewController.swift
//  TKImagePicker
//
//  Created by 안덕환 on 2018. 3. 11..
//  Copyright © 2018년 안덕환. All rights reserved.
//

import UIKit

class TKAlbumViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let cellIdentifier = "AlbumCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    }
}

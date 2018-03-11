//
//  TKImagePickerViewController.swift
//  TKImagePicker
//
//  Created by 안덕환 on 2018. 3. 11..
//  Copyright © 2018년 안덕환. All rights reserved.
//

import UIKit
import SnapKit

public class TKImagePickerViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var albumLabel: UIButton!
    @IBOutlet weak var albumArrowIndicatorView: UIImageView!
    @IBOutlet weak var previewImageView: UIImageView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public static func create() -> TKImagePickerViewController {
        let sb = UIStoryboard(name: "TKImagePicker", bundle: TKBundle.bundle())
        return sb.instantiateViewController(withIdentifier: "previewImagePicker") as! TKImagePickerViewController
    }
}

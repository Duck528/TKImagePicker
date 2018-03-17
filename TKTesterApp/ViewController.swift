//
//  ViewController.swift
//  TKTesterApp
//
//  Created by 안덕환 on 2018. 3. 11..
//  Copyright © 2018년 안덕환. All rights reserved.
//

import UIKit
import TKImagePicker


class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func imagePickerButtonTapped() {
        let vc = TKImagePickerViewController.create()
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
}


extension ViewController: TKImagePickerViewControllerDelegate {
    
    func imagePickerViewControllerDidCancel(_ imagePicker: TKImagePickerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerViewControllerDidAdd(_ imagePicker: TKImagePickerViewController, image: UIImage?) {
        imageView.image = image
        dismiss(animated: true, completion: nil)
    }
}

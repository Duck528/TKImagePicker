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

    @IBAction func imagePickerButtonTapped() {
        let vc = TKImagePickerViewController.create()
        present(vc, animated: true, completion: nil)
    }
}


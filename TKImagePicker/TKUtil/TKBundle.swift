//
//  TKBundle.swift
//  TKImagePicker
//
//  Created by 안덕환 on 2018. 3. 11..
//  Copyright © 2018년 안덕환. All rights reserved.
//

import Foundation


public class TKBundle {
    public static func bundle() -> Bundle {
        return Bundle(for: TKImagePickerViewController.self)
    }
}

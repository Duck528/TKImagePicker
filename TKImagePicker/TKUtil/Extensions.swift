//
//  Extensions.swift
//  TKImagePicker
//
//  Created by 안덕환 on 2018. 3. 11..
//  Copyright © 2018년 안덕환. All rights reserved.
//

import Foundation
import Photos


extension PHFetchOptions {
    
    static func sortByTime() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchOptions
    }
}


extension Int {
    
    func formattedByDecimal() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self))
    }
}


extension UIViewController {
    
    func add(childViewController: UIViewController, frame: CGRect) {
        willMove(toParentViewController: self)
        addChildViewController(childViewController)
        view.addSubview(childViewController.view)
        childViewController.view.frame = frame
        didMove(toParentViewController: self)
    }
    
    func remove(childViewController: UIViewController) {
        willMove(toParentViewController: self)
        childViewController.removeFromParentViewController()
        didMove(toParentViewController: self)
    }
}

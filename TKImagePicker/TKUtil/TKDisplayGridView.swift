//
//  TKDisplayGridView.swift
//  TKImagePicker
//
//  Created by 안덕환 on 2018. 3. 26..
//  Copyright © 2018년 안덕환. All rights reserved.
//

import Foundation


class TKDisplayGridView: UIView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let v = super.hitTest(point, with: event)
        if v == self {
            displayGrid(duration: 0.2)
            return nil
        }
        else { return v }
    }
    
    private func displayGrid(duration: Double) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(clear), object: nil)
        perform(#selector(clear), with: nil, afterDelay: duration)
        drawGrid(color: .white, lineWidth: 0.6)
    }
    
    @objc private func clear() {
        layer.sublayers?.removeAll()
    }
}

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
    
    private func timeString() -> String {
        if self < 10 { return "0\(self)" }
        else { return String(self) }
    }
    
    private func parseToTime() -> (hour: Int, minutes: Int, seconds: Int) {
        let hours = self / 3600
        let minutes = self % 3600 / 60
        let seconds = self % 3600 % 60
        return (hours, minutes, seconds)
    }
    
    func formattedTimeString() -> String {
        let time = parseToTime()
        let hours = time.hour.timeString()
        let minutes = time.minutes.timeString()
        let seconds = time.seconds.timeString()
        if time.hour > 0 { return "\(hours):\(minutes):\(seconds)" }
        else { return "\(minutes):\(seconds)" }
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


extension UIView {
    
    func drawGrid(color: UIColor, lineWidth: CGFloat) {
        let height = bounds.height
        let width = bounds.width
        let lineColor = color.cgColor
        
        drawLine(start: CGPoint(x: bounds.minX, y: height * 0.33),
                 end: CGPoint(x: bounds.maxX, y: height * 0.33), lineColor: lineColor, lineWidth: lineWidth)
        drawLine(start: CGPoint(x: bounds.minX, y: height * 0.66),
                 end: CGPoint(x: bounds.maxX, y: height * 0.66), lineColor: lineColor, lineWidth: lineWidth)
        
        drawLine(start: CGPoint(x: width * 0.33, y: bounds.minY),
                 end: CGPoint(x: width * 0.33, y: bounds.maxY), lineColor: lineColor, lineWidth: lineWidth)
        drawLine(start: CGPoint(x: width * 0.66, y: bounds.minY),
                 end: CGPoint(x: width * 0.66, y: bounds.maxY), lineColor: lineColor, lineWidth: lineWidth)
    }
    
    func drawLine(start: CGPoint, end: CGPoint, lineColor: CGColor, lineWidth: CGFloat) {
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor
        shapeLayer.lineWidth = lineWidth
        layer.addSublayer(shapeLayer)
        path.close()
    }
}

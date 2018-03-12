//
//  TKGridLayout.swift
//  TKImagePicker
//
//  Created by 안덕환 on 2018. 3. 13..
//  Copyright © 2018년 안덕환. All rights reserved.
//

import UIKit

class TKGridLayout: UICollectionViewLayout {
    
    var cachedAttributes: [UICollectionViewLayoutAttributes] = []
    
    var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let inset = collectionView.contentInset
        return collectionView.bounds.width - (inset.left + inset.right)
    }
    
    var verticalDistance: CGFloat {
        return attributeSize.height + interItemVerticalSpacing
    }
    
    var contentHeight: CGFloat = 0
    
    @IBInspectable var numberOfAttributesInRow = 4
    @IBInspectable var interItemHorizontalSpacing: CGFloat = 1
    @IBInspectable var interItemVerticalSpacing: CGFloat = 1
    
    var attributeSize: CGSize {
        let adjustedContentWidth = contentWidth - (CGFloat((numberOfAttributesInRow - 1)) * interItemHorizontalSpacing)
        let len = adjustedContentWidth / CGFloat(numberOfAttributesInRow)
        return CGSize(width: len, height: len)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    private func newLineForAttribute() {
        contentHeight += verticalDistance
    }
    
    override func prepare() {
        guard let collectionView = collectionView else { return }
        
        var leftSpacing = collectionView.contentInset.left
        var verticalSpacing = collectionView.contentInset.top
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        
        for i in 0 ..< numberOfItems {
            
            if i % numberOfAttributesInRow == 0 {
                leftSpacing = collectionView.contentInset.left
                verticalSpacing += verticalDistance
                newLineForAttribute()
            }
            
            let attribute = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: 0))
            attribute.frame = CGRect(origin: CGPoint(x: leftSpacing, y: verticalSpacing), size: attributeSize)
            cachedAttributes.append(attribute)
            
            leftSpacing += (attributeSize.width + interItemHorizontalSpacing)
        }
        
        if numberOfItems % numberOfAttributesInRow > 0 { newLineForAttribute() }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cachedAttributes.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.item >= 0, indexPath.item < cachedAttributes.count else { return nil }
        return cachedAttributes[indexPath.item]
    }
}

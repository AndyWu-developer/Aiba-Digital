//
//  PagingCollectionViewLayout.swift
//  Example
//
//  Created by Alex Kerendian on 8/11/19.
//  Copyright © 2019 Alexander Kerendian. All rights reserved.
//

import UIKit

class PagingCollectionViewLayout: UICollectionViewFlowLayout {
    
    var velocityThresholdPerPage: CGFloat = 2
    var numberOfItemsPerPage: CGFloat = 1
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }
        
        let pageLength: CGFloat
        let approxPage: CGFloat
        let currentPage: CGFloat
        let speed: CGFloat
        
        if scrollDirection == .horizontal {
            pageLength = (self.itemSize.width + self.minimumLineSpacing) * numberOfItemsPerPage
            approxPage = collectionView.contentOffset.x / pageLength
            speed = velocity.x
        } else {
            pageLength = (self.itemSize.height + self.minimumLineSpacing) * numberOfItemsPerPage
            approxPage = collectionView.contentOffset.y / pageLength
            speed = velocity.y
        }
        
        if speed < 0 {
            currentPage = ceil(approxPage)
        } else if speed > 0 {
            currentPage = floor(approxPage)
        } else {
            currentPage = round(approxPage)
        }
        
        guard speed != 0 else {
            if scrollDirection == .horizontal {
                return CGPoint(x: currentPage * pageLength, y: 0)
            } else {
                return CGPoint(x: 0, y: currentPage * pageLength)
            }
        }
        
        var nextPage: CGFloat = currentPage + (speed > 0 ? 1 : -1)
        
        let increment = speed / velocityThresholdPerPage
        nextPage += (speed < 0) ? ceil(increment) : floor(increment)
        
        if scrollDirection == .horizontal {
            return CGPoint(x: nextPage * pageLength, y: 0)
        } else {
            return CGPoint(x: 0, y: nextPage * pageLength)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect)
        -> [UICollectionViewLayoutAttributes]? {
            guard let cv = self.collectionView else { return nil }
            let r = CGRect(origin:cv.contentOffset, size:cv.bounds.size)
            let arr = super.layoutAttributesForElements(in: rect)!
            return arr.map { atts in
                let atts = atts.copy() as! UICollectionViewLayoutAttributes
                if atts.representedElementCategory == .cell {
                    if atts.frame.intersects(r) {
                        let d = abs(r.midX - atts.center.x)
                        let act = CGFloat(170)
                        let nd = d/act
                        if d < act {
                            let scale = 1 + 0.2*(1-(abs(nd)))
                            let t = CATransform3DMakeScale(scale,scale,1)
                            atts.transform3D = t
                        }
                    }
                }
                return atts
            }
    }
    
    override func shouldInvalidateLayout(
        forBoundsChange newBounds: CGRect) -> Bool {
            return true
    }
}

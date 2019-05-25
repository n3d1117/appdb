//
//  ETCollectionViewWaterFallLayout.swift
//  ETCollectionViewWaterFallLayout
//
//  Created by Volley on 2017/4/20.
//  Copyright © 2017年 Elegant Team. All rights reserved.
//

import UIKit

public enum ETCollectionViewWaterfallLayoutItemRenderDirection {
    case shortestFirst
    case leftToRight
    case rightToLeft
}

@objc protocol ETCollectionViewDelegateWaterfallLayout: class, UICollectionViewDelegate {
    
    @objc func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeAt indexPath: IndexPath) -> CGSize
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, columnCountFor section: Int) -> Int
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, heightForHeaderIn section: Int) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, heightForFooterIn section: Int) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, insetForSectionAt index: Int) -> UIEdgeInsets
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, insetForHeaderIn section: Int) -> UIEdgeInsets
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, insetForFooterIn section: Int) -> UIEdgeInsets
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt index: Int) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, minimumColumnSpacingForSectionAt index: Int) -> CGFloat
}

class ETCollectionViewWaterfallLayout: UICollectionViewLayout {
    
    open var columnCount: Int = 2 {
        didSet {
            if columnCount != oldValue {
                self.invalidateLayout()
            }
        }
    }
    
    open var minimumColumnSpacing: CGFloat = 10.0 {
        didSet {
            if minimumColumnSpacing != oldValue {
                self.invalidateLayout()
            }
        }
    }
    
    open var minimumInteritemSpacing: CGFloat = 10.0 {
        didSet {
            if minimumInteritemSpacing != oldValue {
                self.invalidateLayout()
            }
        }
    }
    
    open var headerHeight: CGFloat = 0.0 {
        didSet {
            if headerHeight != oldValue {
                self.invalidateLayout()
            }
        }
    }
    
    open var footerHeight: CGFloat = 0.0 {
        didSet {
            if footerHeight != oldValue {
                self.invalidateLayout()
            }
        }
    }
    
    open var headerInset: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            if headerInset != oldValue {
                self.invalidateLayout()
            }
        }
    }
    
    open var footerInset: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            if footerInset != oldValue {
                self.invalidateLayout()
            }
        }
    }
    
    open var sectionInset: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            if sectionInset != oldValue {
                self.invalidateLayout()
            }
        }
    }
    
    open var itemRenderDirection: ETCollectionViewWaterfallLayoutItemRenderDirection = .shortestFirst {
        didSet {
            if itemRenderDirection != oldValue {
                self.invalidateLayout()
            }
        }
    }
    
    open var minimumContentHeight: CGFloat = 0.0
    
    fileprivate weak var delegate: ETCollectionViewDelegateWaterfallLayout! {
        return self.collectionView?.delegate as? ETCollectionViewDelegateWaterfallLayout
    }
    
    fileprivate var columnHeights: [[CGFloat]] = []
    
    fileprivate var sectionItemAttributes: [[UICollectionViewLayoutAttributes]] = []
    
    fileprivate var allItemAttributes: [UICollectionViewLayoutAttributes] = []
    
    fileprivate var headersAttributes: [Int: UICollectionViewLayoutAttributes] = [:]
    
    fileprivate var footersAttributes: [Int: UICollectionViewLayoutAttributes] = [:]
    
    fileprivate var unionRects: [CGRect] = []
    
    fileprivate let unionSize = 20
    
    
    // MARK: - function
    fileprivate func columnCount(forSection section: Int) -> Int {
        if delegate.responds(to: #selector(ETCollectionViewDelegateWaterfallLayout.collectionView(_:layout:columnCountFor:))) {
            return delegate.collectionView!(self.collectionView!, layout: self, columnCountFor: section)
        }
        
        return columnCount
    }
    
    fileprivate func evaluatedSectionInsetForSection(at index: Int) -> UIEdgeInsets {
        if delegate.responds(to: #selector(ETCollectionViewDelegateWaterfallLayout.collectionView(_:layout:insetForSectionAt:))) {
            return delegate.collectionView!(self.collectionView!, layout: self, insetForSectionAt: index)
        }
        
        return sectionInset
    }
    
    fileprivate func evaluatedMinimumColumnSpacing(at index: Int) -> CGFloat {
        if delegate.responds(to: #selector(ETCollectionViewDelegateWaterfallLayout.collectionView(_:layout:minimumColumnSpacingForSectionAt:))) {
            return delegate.collectionView!(self.collectionView!, layout: self, minimumColumnSpacingForSectionAt: index)
        }
        
        return minimumColumnSpacing
    }
    
    fileprivate func evaluatedMinimumInteritemSpaing(at index: Int) -> CGFloat {
        if delegate.responds(to: #selector(ETCollectionViewDelegateWaterfallLayout.collectionView(_:layout:minimumInteritemSpacingForSectionAt:))) {
            return delegate.collectionView!(self.collectionView!, layout: self, minimumInteritemSpacingForSectionAt: index)
        }
        
        return minimumInteritemSpacing
    }
    
    open func itemWidthInSection(at index: Int) -> CGFloat {
        let sectionInset = evaluatedSectionInsetForSection(at: index)
        
        let width = (self.collectionView?.bounds.size.width)! - sectionInset.left - sectionInset.right
        let columnCount = CGFloat(self.columnCount(forSection: index))
        let columnSpacing = evaluatedMinimumColumnSpacing(at: index)
        
        return (width - (columnCount - 1) * columnSpacing) / columnCount
    }
    
    // MARK: - methods to override
    override func prepare() {
        super.prepare()
        
        headersAttributes.removeAll()
        footersAttributes.removeAll()
        unionRects.removeAll()
        columnHeights.removeAll()
        allItemAttributes.removeAll()
        sectionItemAttributes.removeAll()
        
        guard self.collectionView?.numberOfSections != 0 else {
            return
        }
        
        assert(delegate!.conforms(to: ETCollectionViewDelegateWaterfallLayout.self), "UICollectionView's delegate should conform to ETCollectionViewDelegateWaterfallLayout protocol")
        assert(columnCount > 0, "WaterfallLayout's columnCount should be greater than 0")
        
        let numberOfsections = (self.collectionView?.numberOfSections)!
        
        // Initialize variables
        for index in 0 ..< numberOfsections{
            let columnCount = self.columnCount(forSection: index)
            let sectionColumnHeights = Array(repeatElement(CGFloat(0), count: columnCount))
            self.columnHeights.append(sectionColumnHeights)
        }
        
        // Create attributes
        var top: CGFloat = 0
        
        for section in 0 ..< numberOfsections {
            
            /*
             * 1. Get section-specific metrics (minimumInteritemSpacing, sectionInset)
             */
            let interitemSpacing = evaluatedMinimumInteritemSpaing(at: section)
            let columnSpacing = evaluatedMinimumColumnSpacing(at: section)
            let sectionInset = evaluatedSectionInsetForSection(at: section)
            
            let width = (self.collectionView?.bounds.size.width)! - sectionInset.left - sectionInset.right
            let columnCount = self.columnCount(forSection: section)
            let itemWidth = (width - (CGFloat(columnCount - 1)) * columnSpacing) / CGFloat(columnCount)
            
            /*
             * 2. Section header
             */
            var headerHeight = self.headerHeight
            if delegate.responds(to: #selector(ETCollectionViewDelegateWaterfallLayout.collectionView(_:layout:heightForHeaderIn:))) {
                headerHeight = delegate.collectionView!(self.collectionView!, layout: self, heightForHeaderIn: section)
            }
            
            var headerInset = self.headerInset
            if delegate.responds(to: #selector(ETCollectionViewDelegateWaterfallLayout.collectionView(_:layout:insetForHeaderIn:))) {
                headerInset = delegate.collectionView!(self.collectionView!, layout: self, insetForHeaderIn: section)
            }
            
            top += headerInset.top
            
            if headerHeight > 0 {
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: headerInset.left,
                                          y: top,
                                          width: (self.collectionView?.bounds.size.width)! - headerInset.left - headerInset.right,
                                          height: headerHeight)
                self.headersAttributes[section] = attributes
                self.allItemAttributes.append(attributes)
                
                top = attributes.frame.maxY + headerInset.bottom
            }
            
            top += sectionInset.top
            for idx in 0 ..< columnCount {
                self.columnHeights[section][idx] = top
            }
            
            /*
             * 3. Section items
             */
            let itemCount = (self.collectionView?.numberOfItems(inSection: section))!
            var itemAttributes: [UICollectionViewLayoutAttributes] = []
            
            for idx in 0 ..< itemCount {
                
                let indexPath = IndexPath(item: idx, section: section)
                let columnIndex = nextColumnIndex(forItem: idx, section: section)
                let xOffset = sectionInset.left + (itemWidth + columnSpacing) * CGFloat(columnIndex)
                let yOffset = self.columnHeights[section][columnIndex]
                let itemSize = delegate.collectionView(self.collectionView!, layout: self, sizeAt: indexPath)
                var itemHeight: CGFloat = 0
                if itemSize.width > 0 {
                    itemHeight = itemSize.height// * itemWidth / itemSize.width
                }
                
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemWidth, height: itemHeight)
                itemAttributes.append(attributes)
                self.allItemAttributes.append(attributes)
                self.columnHeights[section][columnIndex] = attributes.frame.maxY + interitemSpacing
            }
            
            self.sectionItemAttributes.append(itemAttributes)
            
            /*
             * 4. Section footer
             */
            let columnIndex = longestColumnIndexIn(section: section)
            top = self.columnHeights[section][columnIndex] - interitemSpacing + sectionInset.bottom
            
            var footerHeight = self.footerHeight
            if delegate.responds(to: #selector(ETCollectionViewDelegateWaterfallLayout.collectionView(_:layout:heightForFooterIn:))) {
                footerHeight = delegate.collectionView!(self.collectionView!, layout: self, heightForFooterIn: section)
            }
            
            var footerInset = self.footerInset
            if delegate.responds(to: #selector(ETCollectionViewDelegateWaterfallLayout.collectionView(_:layout:insetForFooterIn:))) {
                footerInset = delegate.collectionView!(self.collectionView!, layout: self, insetForFooterIn: section)
            }
            
            top += footerInset.top
            
            if footerHeight > 0 {
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: footerInset.left,
                                          y: top,
                                          width: (self.collectionView?.bounds.size.width)! - (footerInset.left + footerInset.right),
                                          height: footerHeight)
                self.footersAttributes[section] = attributes
                self.allItemAttributes.append(attributes)
                
                top = attributes.frame.maxY + footerInset.bottom
            }
            
            for idx in 0 ..< columnCount {
                self.columnHeights[section][idx] = top
            }
        }
        
        // Build union rects
        var idx = 0
        let itemCounts = self.allItemAttributes.count
        while idx < itemCounts {
            var unionRect = self.allItemAttributes[idx].frame
            let rectEndIndex = min(idx + unionSize, itemCounts)
            
            for i in idx+1 ..< rectEndIndex {
                unionRect = unionRect.union(self.allItemAttributes[i].frame)
            }
            
            idx = rectEndIndex
            
            self.unionRects.append(unionRect)
        }
    }
    
    override var collectionViewContentSize: CGSize {
        
        let numberOfSections = (self.collectionView?.numberOfSections)!
        if numberOfSections == 0 {
            return CGSize.zero
        }
        
        var contentSize = self.collectionView?.bounds.size
        contentSize?.height = (self.columnHeights.last?.first)!
        
        if (contentSize?.height)! < minimumContentHeight {
            contentSize?.height = self.minimumContentHeight
        }
        
        return contentSize!
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.section < self.sectionItemAttributes.count
            && indexPath.item < self.sectionItemAttributes[indexPath.section].count else {
                return nil
        }
        
        return self.sectionItemAttributes[indexPath.section][indexPath.item]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        if elementKind == UICollectionView.elementKindSectionHeader {
            return self.headersAttributes[indexPath.section]
        }
        
        if elementKind == UICollectionView.elementKindSectionFooter {
            return self.footersAttributes[indexPath.section]
        }
        
        return nil
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var begin = 0, end = 0
        
        var attrs: [UICollectionViewLayoutAttributes] = []
        
        for i in 0 ..< self.unionRects.count {
            if rect.intersects(self.unionRects[i]) {
                begin = i * unionSize
                break
            }
        }
        
        var idx = self.unionRects.count - 1
        while idx >= 0 {
            if rect.intersects(self.unionRects[idx]) {
                end = min((idx+1) * unionSize, self.allItemAttributes.count)
                break
            }
            idx -= 1
        }
        
        for i in begin ..< end {
            let attr = self.allItemAttributes[i]
            if rect.intersects(attr.frame) {
                attrs.append(attr)
            }
        }
        return attrs
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let oldBounds = (self.collectionView?.bounds)!
        if newBounds.width != oldBounds.width {
            return true
        }
        
        return false
    }
    
    // MARK: - Find the shortest column
    fileprivate func shortestColumnIndexIn(section: Int) -> Int {
        
        var index = 0
        var shortestHeight = CGFloat.greatestFiniteMagnitude
        
        for (idx, height) in self.columnHeights[section].enumerated() {
            if height < shortestHeight {
                shortestHeight = height
                index = idx
            }
        }
        
        return index
    }
    
    /**
     *  Find the longest column.
     *
     *  @return index for the longest column
     */
    fileprivate func longestColumnIndexIn(section: Int) -> Int {
        
        var index = 0
        var longestHeight: CGFloat = 0
        
        for (idx, height) in self.columnHeights[section].enumerated() {
            if height > longestHeight {
                longestHeight = height
                index = idx
            }
        }
        
        return index
    }
    
    /**
     *  Find the index for the next column.
     *
     *  @return index for the next column
     */
    fileprivate func nextColumnIndex(forItem item: Int, section: Int) -> Int {
        
        var index = 0
        let columnCount = self.columnCount(forSection: section)
        
        switch itemRenderDirection {
        case .shortestFirst:
            index = shortestColumnIndexIn(section: section)
            
        case .leftToRight:
            index = item % columnCount
            
        case .rightToLeft:
            index = (columnCount - 1) - (item % columnCount)
        }
        
        return index
    }
}

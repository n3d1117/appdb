//
//  TagListView.swift
//  appdb
//
//  Created by ned on 12/10/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import SwiftTheme

protocol TagListViewDelegate {
    func tagPressed(_ title: String) -> Void
}

class TagListView: UIView {
    
    func randomColor() -> String {
        let color = remainingColors.randomElement() ?? ""
        usedColors.append(color)
        if usedColors.count == flatColors.count { usedColors = [] }
        return color
    }

    var remainingColors: [String] {
        return flatColors.filter({ !usedColors.contains($0) })
    }
    var usedColors: [String] = []
    var flatColors: [String] = ["#F44336", "#E91E63", "#9C27B0", "#673AB7", "#3F51B5", "#2196F3", "#009688", "#4CAF50", "#FF9800", "#FF5722", "#795548", "#607D8B"]
    
    var cornerRadius: CGFloat = 10 {
        didSet {
            for tagView in tagViews {
                tagView.cornerRadius = cornerRadius
            }
        }
    }
    
    var paddingX: CGFloat = 8
    var paddingY: CGFloat = 8
    var marginX: CGFloat = 10
    var marginY: CGFloat = 12
    
    var textFont: UIFont = UIFont.systemFont(ofSize: 18) {
        didSet {
            for tagView in tagViews {
                tagView.textFont = textFont
            }
            rearrangeViews()
        }
    }
    
    var delegate: TagListViewDelegate?
    
    open private(set) var tagViews: [TagButton] = []
    private(set) var tagBackgroundViews: [UIView] = []
    private(set) var rowViews: [UIView] = []
    private(set) var tagViewHeight: CGFloat = 0
    private(set) var rows = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    // MARK: - Init
    
    convenience init(textColor: UIColor = .white, tagBackgroundColor: UIColor = UIColor.gray, tagSelectedBackgroundColor: UIColor?) {
        self.init(frame: .zero)
    }
    
    // MARK: - Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        rearrangeViews()
    }
    
    // Source: https://github.com/ElaWorkshop/TagListView
    
    private func rearrangeViews() {
        let views = tagViews as [UIView] + tagBackgroundViews + rowViews
        for view in views {
            view.removeFromSuperview()
        }
        rowViews.removeAll(keepingCapacity: true)
        
        var currentRow = 0
        var currentRowView: UIView!
        var currentRowTagCount = 0
        var currentRowWidth: CGFloat = 0
        for (index, tagView) in tagViews.enumerated() {
            tagView.frame.size = tagView.intrinsicContentSize
            tagViewHeight = tagView.frame.height
            
            if currentRowTagCount == 0 || currentRowWidth + tagView.frame.width > frame.width {
                currentRow += 1
                currentRowWidth = 0
                currentRowTagCount = 0
                currentRowView = UIView()
                currentRowView.frame.origin.y = CGFloat(currentRow - 1) * (tagViewHeight + marginY)
                
                rowViews.append(currentRowView)
                addSubview(currentRowView)
                
                tagView.frame.size.width = min(tagView.frame.size.width, frame.width)
            }
            
            let tagBackgroundView = tagBackgroundViews[index]
            tagBackgroundView.frame.origin = CGPoint(x: currentRowWidth, y: 0)
            tagBackgroundView.frame.size = tagView.bounds.size
            tagBackgroundView.layer.shadowPath = UIBezierPath(roundedRect: tagBackgroundView.bounds, cornerRadius: cornerRadius).cgPath
            tagBackgroundView.addSubview(tagView)
            currentRowView.addSubview(tagBackgroundView)
            
            currentRowTagCount += 1
            currentRowWidth += tagView.frame.width + marginX
            
            currentRowView.frame.origin.x = 0
            currentRowView.frame.size.width = currentRowWidth
            currentRowView.frame.size.height = max(tagViewHeight, currentRowView.frame.height)
        }
        rows = currentRow
        
        invalidateIntrinsicContentSize()
    }
    
    // MARK: - Manage tags
    
    override open var intrinsicContentSize: CGSize {
        var height = CGFloat(rows) * (tagViewHeight + marginY)
        if rows > 0 {
            height -= marginY
        }
        return CGSize(width: frame.width, height: height)
    }
    
    private func createNewTagView(_ title: String) -> TagButton {
        let tagView = TagButton(title: title)
        
        tagView.titleLabel?.textColor = .white
        tagView.backgroundColor = UIColor(rgba: randomColor()).withAlphaComponent(0.4)
        tagView.setBackgroundImage(tagView.backgroundColor?.imageValue, for: .normal)
        tagView.titleLabel?.lineBreakMode = .byTruncatingTail
        tagView.cornerRadius = cornerRadius
        tagView.paddingX = paddingX
        tagView.paddingY = paddingY
        tagView.textFont = textFont
        tagView.addTarget(self, action: #selector(tagPressed(_:)), for: .touchUpInside)
        
        return tagView
    }
    
    @discardableResult
    open func addTags(_ titles: [String]) -> [TagButton] {
        var tagViews: [TagButton] = []
        for title in titles {
            tagViews.append(createNewTagView(title))
        }
        return addTagViews(tagViews)
    }
    
    @discardableResult
    open func addTagViews(_ tagViews: [TagButton]) -> [TagButton] {
        for tagView in tagViews {
            self.tagViews.append(tagView)
            tagBackgroundViews.append(UIView(frame: tagView.bounds))
        }
        rearrangeViews()
        return tagViews
    }
    
    @discardableResult
    open func addTagView(_ tagView: TagButton) -> TagButton {
        tagViews.append(tagView)
        tagBackgroundViews.append(UIView(frame: tagView.bounds))
        rearrangeViews()
        
        return tagView
    }
    
    open func removeAllTags() {
        let views = tagViews as [UIView] + tagBackgroundViews
        for view in views {
            view.removeFromSuperview()
        }
        tagViews = []
        tagBackgroundViews = []
        rearrangeViews()
    }
    
    // MARK: - Events
    
    @objc func tagPressed(_ sender: TagButton!) {
        delegate?.tagPressed(sender.currentTitle ?? "")
        sender.isSelected = !sender.isSelected
    }
    
}

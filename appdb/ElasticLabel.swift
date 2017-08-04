//
//  ElasticLabel.swift
//  appdb
//
//  Created by ned on 04/08/2017.
//  Copyright © 2017 ned. All rights reserved.

//
import Foundation
import UIKit

protocol ElasticLabelDelegate {
    func expand(_ label: ElasticLabel)
}

class ElasticLabel: UILabel {
    
    var delegated: ElasticLabelDelegate?
    var maxNumberOfCollapsedLines: Int = 5
    var collapsed: Bool = true { didSet { numberOfLines = collapsed ? maxNumberOfCollapsedLines : 0 } }
    var recognizer: UITapGestureRecognizer!
    var expandedText: String! = ""
    
    open override var text: String? {
        didSet {
            if let text = text, text != "", collapsed, willBeTruncated {
                addTrailing()
            }
        }
    }
    
    convenience init() { self.init(text: "", delegate: nil) }
    
    convenience init(text: String, delegate: ElasticLabelDelegate? = nil) {
        self.init(frame: .zero)
        
        self.text = text
        if let delegate = delegate { self.delegated = delegate }
        
        font = .systemFont(ofSize: (13.5~~12.5))
        contentMode = .top
        textAlignment = .left
        lineBreakMode = .byClipping
        isUserInteractionEnabled = true
        collapsed = true
        
        recognizer = UITapGestureRecognizer(target: self, action: #selector(self.expand))
        recognizer.numberOfTouchesRequired = 1
        
    }
    
    // Replaces text with collapsed text, adds "... more" to the end
    func addTrailing() {
        let attributed = NSAttributedString(string: text!).copyWithAddedFontAttribute(font)
        if attributed.length > 0 {
            if !((self.gestureRecognizers ?? []).contains(self.recognizer)) { self.addGestureRecognizer(self.recognizer) }
            expandedText = text
            self.attributedText = getCollapsedText(for: NSAttributedString(string: text!), moreText: "more".localized(), moreTextColor: Color.mainTint)
        }
    }
    
    // Replaces collapsed text with expanded text, removes any attributed text
    func removeTrailing() {
        if (self.gestureRecognizers ?? []).contains(recognizer) { removeGestureRecognizer(recognizer) }
        collapsed = false
        attributedText = nil
        text = expandedText
    }
    
    @objc private func expand() {
        removeTrailing()
        delegated?.expand(self)
    }
    
}

extension ElasticLabel {
    
    // Returns 'true' if the text of the label can't fit in maxNumberOfCollapsedLines given 'self.bounds.width'
    var willBeTruncated: Bool {
        let text = NSAttributedString(string: self.text!).copyWithAddedFontAttribute(font)
        if text.length > 0 {
            layoutIfNeeded() /* DO NOT REMOVE! */
            let lines = text.lines(for: self.bounds.width)
            return numberOfLines > 0 && numberOfLines < lines.count
        }; return false
    }
    
    // Returns collapsed text that fits in maxNumberOfCollapsedLines
    fileprivate func getCollapsedText(for text: NSAttributedString?, moreText: String, moreTextColor: ThemeColorPicker) -> NSAttributedString? {
        guard let text = text else { return nil }
        let link = NSAttributedString(string: moreText, attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: font.pointSize), NSForegroundColorAttributeName: Color.get(from: moreTextColor)])
        let lines = text.lines(for: bounds.width)
        if numberOfLines > 0 && numberOfLines < lines.count {
            collapsed = true
            let lastLineRef = lines[numberOfLines-1] as CTLine
            let lineIndex = findLineWithWords(lastLine: lastLineRef, text: text, lines: lines)
            let modifiedLastLineText = textWithLinkReplacement(lineIndex, text: text, linkName: link)
            let collapsedLines = NSMutableAttributedString()
            let differenceFromStart = (numberOfLines-1) - lineIndex.index
            let emptyLineIndent = (2 + differenceFromStart)
            if numberOfLines-emptyLineIndent > 0 {
                for index in 0...numberOfLines-emptyLineIndent {
                    collapsedLines.append(text.text(for: lines[index]))
                }
            } else {
                collapsedLines.append(text.text(for: lines[0]))
            }
            collapsedLines.append(modifiedLastLineText)
            return collapsedLines
        }
        collapsed = false
        return text
    }
    
    fileprivate func findLineWithWords(lastLine: CTLine, text: NSAttributedString, lines: [CTLine]) -> (line: CTLine, index: Int) {
        var lastLineRef = lastLine
        var lastLineIndex = numberOfLines - 1
        var lineWords = spiltIntoWords(str: text.text(for: lastLineRef).string as NSString)
        while lineWords.count < 2 && lastLineIndex > 0 {
            lastLineIndex -=  1
            lastLineRef = lines[lastLineIndex] as CTLine
            lineWords = spiltIntoWords(str: text.text(for: lastLineRef).string as NSString)
        }
        return (lastLineRef, lastLineIndex)
    }
    
    fileprivate func spiltIntoWords(str: NSString) -> [String] {
        var strings: [String] = []
        str.enumerateSubstrings(in: NSRange(location: 0, length: str.length), options: [.byWords, .reverse]) { (word, subRange, enclosingRange, stop) -> Void in
            if let unwrappedWord = word {
                strings.append(unwrappedWord)
            }
            if strings.count > 1 { stop.pointee = true }
        }
        return strings
    }
    
    fileprivate func textWithLinkReplacement(_ lineIndex: (line: CTLine, index: Int), text: NSAttributedString, linkName: NSAttributedString) -> NSAttributedString {
        let lineText = text.text(for: lineIndex.line)
        var lineTextWithLink = lineText
        (lineText.string as NSString).enumerateSubstrings(in: NSRange(location: 0, length: lineText.length), options: [.byWords, .reverse]) { (word, subRange, enclosingRange, stop) -> Void in
            let lineTextWithLastWordRemoved = lineText.attributedSubstring(from: NSRange(location: 0, length: subRange.location))
            let lineTextWithAddedLink = NSMutableAttributedString(attributedString: lineTextWithLastWordRemoved)
            let ellipsis = NSAttributedString(string: "...")
            lineTextWithAddedLink.append(ellipsis)
            lineTextWithAddedLink.append(NSAttributedString(string: " ", attributes: [NSFontAttributeName: self.font]))
            lineTextWithAddedLink.append(linkName)
            let fits = self.textFitsWidth(lineTextWithAddedLink)
            if fits {
                lineTextWithLink = lineTextWithAddedLink
            }
        }
        return lineTextWithLink
    }
    
    fileprivate func textFitsWidth(_ text: NSAttributedString) -> Bool {
        return (text.boundingRect(for: bounds.width).size.height <= font.lineHeight) as Bool
    }
    
}

private extension NSAttributedString {
    
    var hasFontAttribute: Bool {
        guard !self.string.isEmpty else { return false }
        let font = self.attribute(NSFontAttributeName, at: 0, effectiveRange: nil) as? UIFont
        return font != nil
    }
    
    func copyWithAddedFontAttribute(_ font: UIFont) -> NSAttributedString {
        if !hasFontAttribute {
            let copy = NSMutableAttributedString(attributedString: self)
            copy.addAttribute(NSFontAttributeName, value: font, range: NSRange(location: 0, length: copy.length))
            return copy
        }
        return self.copy() as! NSAttributedString
    }
    
    func lines(for width: CGFloat) -> [CTLine] {
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        let frameSetterRef: CTFramesetter = CTFramesetterCreateWithAttributedString(self as CFAttributedString)
        let frameRef: CTFrame = CTFramesetterCreateFrame(frameSetterRef, CFRange(location: 0, length: 0), path.cgPath, nil)
        
        let linesNS: NSArray  = CTFrameGetLines(frameRef)
        let linesAO: [AnyObject] = linesNS as [AnyObject]
        let lines: [CTLine] = linesAO as! [CTLine]
        
        return lines
    }
    
    func text(for lineRef: CTLine) -> NSAttributedString {
        let lineRangeRef: CFRange = CTLineGetStringRange(lineRef)
        let range: NSRange = NSRange(location: lineRangeRef.location, length: lineRangeRef.length)
        return self.attributedSubstring(from: range)
    }
    
    func boundingRect(for width: CGFloat) -> CGRect {
        return self.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
    }
    
}


//
// String+Truncation.swift by PopcornTimeTV/PopcornTimeTV
//

import UIKit

extension String {

    func truncateToSize(size: CGSize, ellipses: String, trailingText: String, attributes: [NSAttributedString.Key: Any], trailingAttributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        if !willFit(to: size, attributes: attributes) {
            let indexOfLastCharacterThatFits = indexThatFits(size: size, ellipses: ellipses, trailingText: trailingText, attributes: attributes, min: 0, max: self.count)
            let range = startIndex..<self.index(startIndex, offsetBy: indexOfLastCharacterThatFits)
            let substring = String(self[range])
            let attributedString = NSMutableAttributedString(string: substring + ellipses, attributes: attributes)
            let attributedTrailingString = NSAttributedString(string: trailingText, attributes: trailingAttributes)
            attributedString.append(attributedTrailingString)
            return attributedString
        } else {
            return NSAttributedString(string: self, attributes: attributes)
        }
    }

    func willFit(to size: CGSize, ellipses: String = "", trailingText: String = "", attributes: [NSAttributedString.Key: Any]) -> Bool {
        let text = (self + ellipses + trailingText) as NSString
        let boundedSize = CGSize(width: size.width, height: .greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let boundedRect = text.boundingRect(with: boundedSize, options: options, attributes: attributes, context: nil)
        return boundedRect.height <= size.height
    }

    // MARK: - Private

    private func indexThatFits(size: CGSize, ellipses: String, trailingText: String, attributes: [NSAttributedString.Key: Any], min: Int, max: Int) -> Int {
        guard max - min != 1 else { return min }
        let midIndex = (min + max) / 2
        let range = startIndex..<self.index(startIndex, offsetBy: midIndex)
        let substring = String(self[range])
        if !substring.willFit(to: size, ellipses: ellipses, trailingText: trailingText, attributes: attributes) {
            return indexThatFits(size: size, ellipses: ellipses, trailingText: trailingText, attributes: attributes, min: min, max: midIndex)
        } else {
            return indexThatFits(size: size, ellipses: ellipses, trailingText: trailingText, attributes: attributes, min: midIndex, max: max)
        }
    }
}

//
//  RoundedBackgroundLabel.swift
//  RoundedText
//
//  Created by Igor Vedeneev on 18/02/2025.
//

import UIKit
import SwiftUI

class RoundedBackgroundLabel: UILabel {
    var textPadding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    var backgroundFillColor: UIColor = .blue
    var cornerRadius: CGFloat = 8
    
    let drawingUtil = TextBackgroundDrawingUtil()

    override func drawText(in rect: CGRect) {
        guard let attributedText else { return }
        
        drawingUtil.drawTextBackground(
            attributedText: attributedText,
            backgroundFillColor: backgroundFillColor,
            rect: rect,
            textPadding: textPadding,
            numberOfLines: numberOfLines,
            lineBreakMode: lineBreakMode,
            cornerRadius: cornerRadius
        )
        super.drawText(in: rect.inset(by: textPadding))
    }

    override var intrinsicContentSize: CGSize {
        let originalSize = super.intrinsicContentSize
        return CGSize(
            width: originalSize.width + textPadding.left + textPadding.right,
            height: originalSize.height + textPadding.top + textPadding.bottom
        )
    }
}

//
//  RoundedBackgroundLabelSwiftUI.swift
//  RoundedText
//
//  Created by Igor Vedeneev on 24/02/2025.
//

import SwiftUI

struct RoundedBackgroundLabelSwiftUI: UIViewRepresentable {
    
    let text: String
    let alignment: NSTextAlignment
    let font: UIFont
    let padding: UIEdgeInsets
    let backgroundColor: UIColor

    func makeUIView(context: Context) -> RoundedBackgroundLabel {
        let label = RoundedBackgroundLabel()
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.numberOfLines = 0
        label.backgroundFillColor = backgroundColor
        label.textPadding = padding
        
        return label
    }
    
    func updateUIView(_ uiView: RoundedBackgroundLabel, context: Context) {
        uiView.attributedText = makeAttributedString()
        uiView.textPadding = padding
    }
    
    private func makeAttributedString() -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        paragraphStyle.lineSpacing = padding.top
        
        // Create attributed string
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle,
        ]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
}

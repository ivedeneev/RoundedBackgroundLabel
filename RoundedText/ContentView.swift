//
//  ContentView.swift
//  RoundedText
//
//  Created by Igor Vedeneev on 19/02/2025.
//

import SwiftUI

struct ContentView: View {
    
    @State var textAlignment: NSTextAlignment = .center
    @State var spacingText = "6"
    @State var spacing: CGFloat = 0
    
    var body: some View {
        Form {
            Section("Settings") {
                Picker("Text Alignment", selection: $textAlignment) {
                    ForEach(NSTextAlignment.allCases, id: \.self) { alignment in
                        Image(systemName: alignment.iconName)
                    }
                }
                .pickerStyle(.segmented)
                
                HStack {
                    Text("Padding")
                    Spacer()
                    Text(spacing.description).foregroundStyle(.secondary)
                    Stepper("", value: $spacing, in: 0...20).labelsHidden()
                }
            }
            
            Section("Result") {
                RoundedBackgroundLabelSwiftUI(
                    text: text,
                    alignment: textAlignment,
                    font: UIFont.systemFont(ofSize: 30, weight: .semibold, width: .condensed),
                    padding: UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing),
                    backgroundColor: UIColor.systemYellow
                )
            }
        }
        .onChange(of: spacingText, initial: true) { old, new in
            spacing = CGFloat(Double(new) ?? 0)
        }
    }
    
    var text = """
I have
the best dogs in the world
and i love steaks
and 🐈
"""
}
//and i wanna find a new job so baaaaad

#Preview {
    ContentView()
}


extension NSTextAlignment: @retroactive CaseIterable {
    public static var allCases: [NSTextAlignment] { [.left, .center, .right, ] }
    
    var iconName: String {
        switch self {
        case .left:
            return "text.alignleft"
        case .right:
            return "text.alignright"
        case .center:
            return "text.aligncenter"
        default:
            return ""
        }
    }
}

//
//  ViewController.swift
//  RoundedText
//
//  Created by Igor Vedeneev on 18/02/2025.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let label = RoundedBackgroundLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .systemBlue
        label.clipsToBounds = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 30)
        ])
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
//        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = label.textPadding.top
        
        // Create attributed string
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .medium),
            .paragraphStyle: paragraphStyle,
        ]
        
        var text = """
I have
the best pom in the world
and i love Kristina
and cats
and i wanna find a new job so baaaaad
"""
        
//        text = """
//I have
//the best pom in the world
//"""
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        
        label.attributedText = attributedText
    }


}



extension CGPoint {
    var desc: String {
        "(\(Int(x) ), \(Int(y)))"
    }
}

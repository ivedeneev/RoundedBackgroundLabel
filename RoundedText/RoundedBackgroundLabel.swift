//
//  RoundedBackgroundLabel.swift
//  RoundedText
//
//  Created by Igor Vedeneev on 18/02/2025.
//

import UIKit

class RoundedBackgroundLabel: UILabel {
    var textPadding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8) // Padding around text
    var backgroundFillColor: UIColor = .blue // Background color
    var cornerRadius: CGFloat = 10 // Corner radius

    override func drawText(in rect: CGRect) {
        guard let attributedText else { return }
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(backgroundFillColor.cgColor)

        // Create text container and layout manager
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize(width: rect.width - textPadding.left - textPadding.right, height: CGFloat.greatestFiniteMagnitude))
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.lineBreakMode = lineBreakMode

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Get the number of lines
        var points: [CGPoint] = []
        var lineRects = [CGRect]()
        layoutManager.enumerateLineFragments(
            forGlyphRange: NSRange(location: 0, length: layoutManager.numberOfGlyphs)
        ) { [unowned self] (_, usedRect, textContainer, glyphRange, _) in
            let lineOrigin = usedRect.origin
            
            // Calculate the background rect for this line
            let adjustedRect = CGRect(
                x: lineOrigin.x + self.textPadding.left,
                y: lineOrigin.y + self.textPadding.top,
                width: usedRect.width,
                height: usedRect.height
            )
            let padding = UIEdgeInsets(top: -self.textPadding.top, left: -self.textPadding.left, bottom: 0, right: -self.textPadding.left)
            lineRects.append(adjustedRect.inset(by: padding))
            
            if points.isEmpty {
                points.append(adjustedRect.origin)
            } else {
                if adjustedRect.maxX > points.last!.x {
                    var lastPoint = points.removeLast()
                    lastPoint.y -= 2*self.textPadding.top
                    points.append(lastPoint)
                } else if adjustedRect.maxX < points.last!.x {
                    var lastPoint = points.removeLast()
                    lastPoint.y -= self.textPadding.top
                    points.append(lastPoint)
                }
            }
            
            let bla = adjustedRect.maxX < points.last!.x ? self.textPadding.top : 0
            points.append(.init(x: adjustedRect.maxX, y: adjustedRect.minY + bla))
            points.append(.init(x: adjustedRect.maxX, y: adjustedRect.maxY))
        }
        
        var last = lineRects.removeLast()
        last = last.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: -self.textPadding.top, right: 0))
        lineRects.append(last)
        
        for i in 0..<lineRects.count - 1 {
            if lineRects[i].width < lineRects[i + 1].width {
                var last = lineRects.remove(at: i)
                last = last.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: self.textPadding.top, right: 0))
                lineRects.insert(last, at: i)
            } else {
                var last = lineRects.remove(at: i + 1)
                last = last.inset(by: UIEdgeInsets(top: self.textPadding.top, left: 0, bottom: 0, right: 0))
                lineRects.insert(last, at: i + 1)
            }
        }
        
        points.append(.init(x: 0, y: rect.maxY))
        
        UIColor.systemBlue.withAlphaComponent(0.2).setFill()
        UIColor.systemBlue.setStroke()
        
        test(rect: rect, linesRects: lineRects)
        super.drawText(in: rect.inset(by: textPadding))
    }

    override var intrinsicContentSize: CGSize {
        let originalSize = super.intrinsicContentSize
        return CGSize(width: originalSize.width + textPadding.left + textPadding.right,
                      height: originalSize.height + textPadding.top + textPadding.bottom)
    }
    
    func roundedPath(from points: [CGPoint], cornerRadius: CGFloat, boundingRect: CGRect) -> UIBezierPath {
        guard points.count > 2 else { return UIBezierPath() }

            let path = UIBezierPath()
            var startPoint: CGPoint = points[0]
            startPoint.x += cornerRadius
            path.move(to: startPoint)
        
            for i in 1..<points.count - 1 {
                let prev = points[i - 1]
                let curr = points[i]
                let next = points[i + 1]
                
                draw(path: path, curr: curr, next: next, prev: prev)
                
            }
        
            draw(path: path, curr: points.last!, next: points[0], prev: points[points.count - 2])
            draw(path: path, curr: points[0], next: points[1], prev: points.last!)
        
            path.close()
            return path
    }
    
    func draw(path: UIBezierPath, curr: CGPoint, next: CGPoint, prev: CGPoint) {
        
        let prevX = prev.x.rounded(.down)
        let prevY = prev.y.rounded(.down)
        let currX = curr.x.rounded(.down)
        let currY = curr.y.rounded(.down)
        let nextY = next.y.rounded(.down)
        
        var arcStartX = curr.x
        var arcStartY = curr.y
        
        var arcEndX = curr.x
        var arcEndY = curr.y
        
        if currY < nextY {
            arcEndY += cornerRadius
        } else if currY > nextY {
            arcEndY -= cornerRadius
        }
        
        if prevX > currX {
            arcStartX += cornerRadius
        } else if prevX < currX {
            arcStartX -= cornerRadius
        } else {
            if currY > prevY {
                arcStartY -= cornerRadius
            } else if currY < prevY {
                arcStartY += cornerRadius
            }
            
            let mult: CGFloat = next.x < curr.x ? 1.0 : -1.0
            arcEndX -= cornerRadius * mult
        }
        
        let arcStartPoint = CGPoint(x: arcStartX, y: arcStartY)
        let arcEndPoint = CGPoint(x: arcEndX, y: arcEndY)
        path.addLine(to: arcStartPoint)
        path.addQuadCurve(to: arcEndPoint, controlPoint: curr)
    }
    
    func test(rect: CGRect, linesRects: [CGRect]) {
        
        var rightPoints = [CGPoint]()
        var leftPoints = [CGPoint]()
        for i in 0..<linesRects.count {
            let lineRect = linesRects[i]
 
            if rightPoints.count > 1, lineRect.maxX == rightPoints[rightPoints.count - 2].x {
                rightPoints.removeLast()
            } else {
                rightPoints.append(.init(x: lineRect.maxX, y: lineRect.minY))
            }
            
            if leftPoints.count > 1, lineRect.minX == leftPoints[leftPoints.count - 2].x {
                leftPoints.removeLast()
            } else {
                leftPoints.append(.init(x: lineRect.minX, y: lineRect.minY))
            }
            
            rightPoints.append(.init(x: lineRect.maxX, y: lineRect.maxY))
            leftPoints.append(.init(x: lineRect.minX, y: lineRect.maxY))
        }
        
        let lastLeft = leftPoints.removeFirst()
        rightPoints.insert(lastLeft, at: 0)
        rightPoints.append(contentsOf: leftPoints.reversed())
        let path = roundedPath(from: rightPoints, cornerRadius: cornerRadius, boundingRect: rect)
        path.fill()
    }
}

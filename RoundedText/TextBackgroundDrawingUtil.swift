//
//  TextBackgroundDrawingUtil.swift
//  RoundedText
//
//  Created by Igor Vedeneev on 21/02/2025.
//

import UIKit

class TextBackgroundDrawingUtil {
    func drawTextBackground(
        attributedText: NSAttributedString,
        backgroundFillColor: UIColor,
        rect: CGRect,
        textPadding: UIEdgeInsets,
        numberOfLines: Int,
        lineBreakMode: NSLineBreakMode,
        cornerRadius: CGFloat
    ) {
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

        var lineRects = [CGRect]()
        let range = NSRange(location: 0, length: layoutManager.numberOfGlyphs)
        
        // TODO: use this for partial selection
    //        layoutManager.enumerateEnclosingRects(forGlyphRange: range, withinSelectedGlyphRange: range, in: textContainer) { usedRect, _ in
    //            print(usedRect)
    //            lineRects.append(self.lineRect(rawRect: usedRect))
    //        }
        
        layoutManager.enumerateLineFragments(
            forGlyphRange: range
        ) { (_, usedRect, textContainer, glyphRange, _) in
            lineRects.append(self.adjustedLineRect(rawRect: usedRect, textPadding: textPadding))
        }
        
        var last = lineRects.removeLast()
        last = last.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: -textPadding.top, right: 0))
        lineRects.append(last)
        
        for i in 0..<lineRects.count - 1 {
            if lineRects[i].width < lineRects[i + 1].width {
                var last = lineRects.remove(at: i)
                last = last.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: textPadding.top, right: 0))
                lineRects.insert(last, at: i)
            } else {
                var last = lineRects.remove(at: i + 1)
                last = last.inset(by: UIEdgeInsets(top: textPadding.top, left: 0, bottom: 0, right: 0))
                lineRects.insert(last, at: i + 1)
            }
        }
        
        backgroundFillColor.setFill()
        
        let points = pointsForBackgroundPath(rect: rect, linesRects: lineRects, cornerRadius: cornerRadius)
        let path = roundedPath(from: points, cornerRadius: cornerRadius, boundingRect: rect)
        path.fill()
    }

    private func adjustedLineRect(rawRect: CGRect, textPadding: UIEdgeInsets) -> CGRect {
        let lineOrigin = rawRect.origin
        
        let adjustedRect = CGRect(
            x: lineOrigin.x + textPadding.left,
            y: lineOrigin.y + textPadding.top,
            width: rawRect.width,
            height: rawRect.height
        )
        let padding = UIEdgeInsets(top: -textPadding.top, left: -textPadding.left, bottom: 0, right: -textPadding.left)
        
        return adjustedRect.inset(by: padding)
    }

    private func roundedPath(from points: [CGPoint], cornerRadius: CGFloat, boundingRect: CGRect) -> UIBezierPath {
        guard points.count > 2 else { return UIBezierPath() }

            let path = UIBezierPath()
            var startPoint: CGPoint = points[0]
            startPoint.x += cornerRadius
            path.move(to: startPoint)
        
            for i in 1..<points.count - 1 {
                let prev = points[i - 1]
                let curr = points[i]
                let next = points[i + 1]
                
                drawBackgroundPath(path: path, curr: curr, next: next, prev: prev, cornerRadius: cornerRadius)
                
            }
        
            drawBackgroundPath(path: path, curr: points.last!, next: points[0], prev: points[points.count - 2], cornerRadius: cornerRadius)
            drawBackgroundPath(path: path, curr: points[0], next: points[1], prev: points.last!, cornerRadius: cornerRadius)
        
            path.close()
            return path
    }

    private func drawBackgroundPath(path: UIBezierPath, curr: CGPoint, next: CGPoint, prev: CGPoint, cornerRadius: CGFloat) {
        
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

    func pointsForBackgroundPath(rect: CGRect, linesRects: [CGRect], cornerRadius: CGFloat) -> [CGPoint] {
        
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
        
        return rightPoints
    }
}

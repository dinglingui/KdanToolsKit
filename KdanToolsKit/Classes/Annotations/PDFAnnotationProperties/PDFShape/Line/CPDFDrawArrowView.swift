//
//  CPDFDrawArrowView.swift
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import UIKit

enum CPDFDrawSelectedIndex: Int {
    case nones = 0
    case arrow
    case triangle
    case square
    case circle
    case diamond
}

class CPDFDrawArrowView: UIView {
    var selectIndex: Int = 0
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()
        let start = CGPoint(x: rect.minX + 10, y: rect.midY)
        let end = CGPoint(x: rect.maxX - 10, y: rect.midY)
        drawArrow(context!, startPoint: start, endPoint: end)
    }
    
    func drawArrow(_ context: CGContext, startPoint: CGPoint, endPoint: CGPoint) {
        context.setStrokeColor(UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0).cgColor)
        context.setLineWidth(2)
        switch CPDFDrawSelectedIndex(rawValue: selectIndex) {
        case .nones:
            context.move(to: startPoint)
            context.addLine(to: endPoint)
            context.strokePath()
        case .arrow:
            context.move(to: startPoint)
            context.addLine(to: endPoint)
            
            context.move(to: CGPoint(x: endPoint.x-5, y: endPoint.y-5))
            context.addLine(to: endPoint)
            context.addLine(to: CGPoint(x: endPoint.x-5, y: endPoint.y+5))
            context.strokePath()
        case .triangle:
            context.move(to: CGPoint(x: startPoint.x-5, y: startPoint.y))
            context.addLine(to: CGPoint(x: endPoint.x-5, y: endPoint.y))
            context.strokePath()
            
            context.move(to: CGPoint(x: endPoint.x-5, y: endPoint.y-5))
            context.addLine(to: endPoint)
            context.addLine(to: CGPoint(x: endPoint.x-5, y: endPoint.y+5))
            context.closePath()
            context.strokePath()
        case .square:
            context.move(to: startPoint)
            context.addLine(to: CGPoint(x: endPoint.x-10, y: endPoint.y))
            context.strokePath()
            
            context.move(to: CGPoint(x: endPoint.x-10, y: endPoint.y-5))
            context.addLine(to: CGPoint(x: endPoint.x-10, y: endPoint.y+5))
            context.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y+5))
            context.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y-5))
            context.closePath()
            context.strokePath()
        case .circle:
            context.move(to: startPoint)
            context.addLine(to: CGPoint(x: endPoint.x-10, y: endPoint.y))
            context.strokePath()
            
            context.addArc(center: CGPoint(x: endPoint.x-7, y: endPoint.y), radius: 5, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: false)
            context.drawPath(using: .stroke)
        case .diamond:
            context.move(to: startPoint)
            context.addLine(to: CGPoint(x: endPoint.x-10, y: endPoint.y))
            context.strokePath()
            
            context.move(to: CGPoint(x: endPoint.x-10, y: endPoint.y))
            context.addLine(to: CGPoint(x: endPoint.x-5, y: endPoint.y+5))
            context.addLine(to: endPoint)
            context.addLine(to: CGPoint(x: endPoint.x-5, y: endPoint.y-5))
            context.closePath()
            context.strokePath()
        case .none:
            context.move(to: startPoint)
            context.addLine(to: endPoint)
            context.strokePath()
        }
        
    }
    
    
    func shotShareImage() -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: self.layer.bounds.size.width, height: self.layer.bounds.size.height))
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        self.layer.render(in: context)
        let tImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tImage
    }
    
}


//
//  CPDFAnnotationBarButton.swift
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import UIKit

class CPDFAnnotationBarButton: UIButton {
    var lineColor: UIColor?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let imageFrame:CGRect = self.imageView?.frame ?? CGRect.zero
        ctx.setStrokeColor(self.lineColor?.cgColor ?? UIColor.clear.cgColor)
        let type:CPDFViewAnnotationMode = CPDFViewAnnotationMode(rawValue: self.tag) ?? .CPDFViewAnnotationModenone
        if type == .highlight {
            ctx.move(to: CGPoint(x: imageFrame.minX - 2, y: imageFrame.midY))
            ctx.setLineWidth(imageFrame.height)
            ctx.addLine(to: CGPoint(x: imageFrame.maxX + 2, y: imageFrame.midY))
        } else if type == .underline {
            ctx.move(to: CGPoint(x: imageFrame.minX, y: imageFrame.maxY))
            ctx.setLineWidth(2.0)
            ctx.addLine(to: CGPoint(x: imageFrame.maxX, y: imageFrame.maxY))
        } else if type == .strikeout {
            ctx.move(to: CGPoint(x: imageFrame.minX, y: imageFrame.midY))
            ctx.setLineWidth(2.0)
            ctx.addLine(to: CGPoint(x:  imageFrame.maxX, y: imageFrame.midY))
        } else if type == .squiggly {
            let tWidth: CGFloat = imageFrame.size.width / 6.0
            ctx.move(to: CGPoint(x: imageFrame.minX, y: imageFrame.maxY))
            ctx.setLineWidth(2.0)
            ctx.addCurve(to: CGPoint(x: imageFrame.minX + tWidth, y: imageFrame.maxY + 4), control1: CGPoint(x: imageFrame.minX + tWidth * 2.0, y: imageFrame.maxY - 4), control2: CGPoint(x: imageFrame.minX + tWidth * 3.0, y: imageFrame.maxY))
            ctx.addCurve(to: CGPoint(x: imageFrame.minX + tWidth * 4.0, y: imageFrame.maxY + 4), control1: CGPoint(x: imageFrame.minX + tWidth * 5.0, y: imageFrame.maxY - 4), control2: CGPoint(x: imageFrame.minX + tWidth * 6.0, y: imageFrame.maxY))
        } else if type == .ink {
            let tWidth = imageFrame.size.width / 6.0
            ctx.move(to: CGPoint(x: imageFrame.minX, y: imageFrame.maxY))
            ctx.setLineWidth(2.0)
            ctx.addCurve(to: CGPoint(x: imageFrame.minX+tWidth, y: imageFrame.maxY+4),
                         control1: CGPoint(x: imageFrame.minX+tWidth, y: imageFrame.maxY-4),
                         control2: CGPoint(x: imageFrame.minX+tWidth*2.0, y: imageFrame.maxY))
            ctx.addCurve(to: CGPoint(x: imageFrame.minX+tWidth*4.0, y: imageFrame.maxY+4),
                         control1: CGPoint(x: imageFrame.minX+tWidth*4.0, y: imageFrame.maxY-4),
                         control2: CGPoint(x: imageFrame.minX+tWidth*5.0, y: imageFrame.maxY))
            ctx.addLine(to: CGPoint(x: imageFrame.minX+tWidth*6.0, y: imageFrame.maxY))
        }
        ctx.strokePath()
        
    }
}

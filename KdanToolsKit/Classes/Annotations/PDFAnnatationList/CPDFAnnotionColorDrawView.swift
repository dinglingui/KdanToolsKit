//
//  CPDFAnnotionColorDrawView.swift
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

enum CPDFAnnotionMarkUpType: Int {
    case highlight
    case underline
    case strikeout
    case squiggly
    case freehand
}


class CPDFAnnotionColorDrawView: UIView {
    
    var lineColor:UIColor?
    var markUpType:CPDFAnnotionMarkUpType = .highlight
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.alpha = 0.7
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let currentColor:UIColor = lineColor ?? UIColor.clear
        
        ctx.setStrokeColor(currentColor.cgColor)
        
        if markUpType == .underline || markUpType == .strikeout {
            ctx.move(to: CGPoint(x: 0, y: 0))
            ctx.setLineWidth(frame.size.width)
            ctx.addLine(to: CGPoint(x: frame.size.width, y: 0))
        } else if markUpType == .highlight {
            ctx.move(to: CGPoint(x: 0, y: frame.size.height/2))
            ctx.setLineWidth(frame.size.height)
            ctx.addLine(to: CGPoint(x: frame.size.width, y: frame.size.height/2))
        } else if markUpType == .squiggly || markUpType == .freehand {
            let tWidth = frame.size.width / 6.0
            ctx.move(to: CGPoint(x: 0, y: frame.size.height/2.0))
            ctx.setLineWidth(2.0)
            ctx.addCurve(to: CGPoint(x: tWidth*3.0, y: frame.size.height/2.0),
                         control1: CGPoint(x: tWidth, y: frame.size.height),
                         control2: CGPoint(x: tWidth*2.0, y: 0.0))
            ctx.addCurve(to: CGPoint(x: tWidth*6.0, y: frame.size.height/2.0),
                         control1: CGPoint(x: tWidth*4.0, y: frame.size.height),
                         control2: CGPoint(x: tWidth*5.0, y: 0.0))
        }
        
        ctx.strokePath()
        
    }
    
}

//
//  CTileWatermarkPreView.swift
//  PDFViewer-Swift
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import UIKit
import ComPDFKit

class CTileWatermarkPreView: UIView {
    var waterString: String?
    var waterImageView: UIImageView?
    var horizontalSpacing: CGFloat = 0
    var verticalSpacing: CGFloat = 0
    var stransform: CGAffineTransform = .identity
    var fontColor: UIColor = .black
    var fontSize: CGFloat = 0
    var familyName: String?
    var fontStyleName: String?
    var centerPoint: CGPoint = .zero
    
    override init(frame: CGRect) {
        waterString = NSLocalizedString("Watermark", comment: "")
        horizontalSpacing = 30
        verticalSpacing = 30
        fontSize = 20
        fontColor = UIColor.black
        stransform = CGAffineTransform.identity
        familyName = "Helvetica"
        fontStyleName = "Regular"

        super.init(frame: frame)
        
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let w = rect.size.width
        let h = rect.size.height
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let width = sqrt(rect.size.height * rect.size.height + rect.size.width * rect.size.width)
        let newRect = CGRect(x: -(width - rect.size.width)/2, y: -(width - rect.size.height)/2, width: width, height: width)
        let new_w = newRect.size.width
        let new_h = newRect.size.height
        
        if waterString != nil && (waterImageView == nil) {
            context.translateBy(x: centerPoint.x, y: centerPoint.y)
            context.concatenate(stransform)
            context.translateBy(x: -(centerPoint.x), y: -(centerPoint.y))
                      
            let cfont = CPDFFont(familyName: familyName ?? "Helvetica", fontStyle: fontStyleName ?? "")

           let font = UIFont(name: CPDFFont.convertAppleFont(cfont) ?? "Helvetica", size: fontSize)
            
            guard let contentRealSizes = waterString?.boundingRect(with: CGSize(width: new_w, height: new_h), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font ?? UIFont.systemFont(ofSize: fontSize) ], context: nil).size else {
                return
            }
            let verticalWidth = contentRealSizes.width + horizontalSpacing
            let horizontalHeight = contentRealSizes.height + verticalSpacing
            var line = Int(new_h - verticalSpacing) / Int(horizontalHeight)
            var row = Int(new_w - horizontalSpacing) / Int(verticalWidth)
            
            if CGFloat(fmod(h, horizontalHeight)) != 0 {
                line += 1
            }
            
            if CGFloat(fmod(w, verticalWidth)) != 0 {
                row += 1
            }
            
            let attributes: [NSAttributedString.Key: Any] = [
                   NSAttributedString.Key.font: font!,
                   NSAttributedString.Key.foregroundColor: fontColor
               ]
            
            let point = CGPoint(x: centerPoint.x - contentRealSizes.width/2, y: centerPoint.y - contentRealSizes.height/2)
            for i in 0..<line {
                for j in 0..<row {
                    waterString?.draw(in: CGRect(x: point.x + CGFloat(j) * verticalWidth, y: point.y + CGFloat(i) * horizontalHeight, width: contentRealSizes.width, height: contentRealSizes.height), withAttributes: attributes)
                }
            }
            for i in 1..<line {
                for j in 0..<row {
                    waterString?.draw(in: CGRect(x: point.x + CGFloat(j) * verticalWidth, y: point.y - CGFloat(i) * horizontalHeight, width: contentRealSizes.width, height: contentRealSizes.height), withAttributes: attributes)
                }
            }
            
            for i in 0..<line {
                for j in 1..<row {
                    waterString?.draw(in: CGRect(x: point.x - CGFloat(j) * verticalWidth, y: point.y + CGFloat(i) * horizontalHeight, width: contentRealSizes.width, height: contentRealSizes.height), withAttributes: [NSAttributedString.Key.font: font ?? UIFont(), NSAttributedString.Key.foregroundColor: fontColor])
                }
            }
            
            for i in 1..<line {
                for j in 1..<row {
                    waterString?.draw(in: CGRect(x: point.x - CGFloat(j) * verticalWidth, y: point.y - CGFloat(i) * horizontalHeight, width: contentRealSizes.width, height: contentRealSizes.height), withAttributes: [NSAttributedString.Key.font: font ?? UIFont(), NSAttributedString.Key.foregroundColor: fontColor])
                }
            }
            
        } else if (waterImageView != nil) && waterImageView?.image?.size.width ?? 0 > 0 && waterImageView?.image?.size.height ?? 0 > 0 {
            context.translateBy(x: centerPoint.x, y: centerPoint.y)
            context.concatenate(stransform)
            context.scaleBy(x: 1, y: -1)
            context.translateBy(x: -(centerPoint.x), y: -(centerPoint.y))
            context.setAlpha(waterImageView?.alpha ?? 0)
            let verticalWidth = (waterImageView?.bounds.size.width ?? 0) + horizontalSpacing
            let horizontalHeight = (waterImageView?.bounds.size.height ?? 0) + verticalSpacing
            var line = Int(new_h - verticalSpacing) / Int(horizontalHeight)
            var row = Int(new_w - horizontalSpacing) / Int(verticalWidth)
            
            if CGFloat(fmod(h, horizontalHeight)) != 0 {
                line += 1
            }
            
            if CGFloat(fmod(w, verticalWidth)) != 0 {
                row += 1
            }
            let point = CGPoint(x: centerPoint.x - (waterImageView?.bounds.size.width ?? 0)/2, y: centerPoint.y - (waterImageView?.bounds.size.height ?? 0)/2)
            for i in 0..<line {
                for j in 0..<row {
                    let area = CGRect(x: point.x + CGFloat(j) * verticalWidth, y: point.y + CGFloat(i) * horizontalHeight, width: waterImageView?.bounds.size.width ?? 0, height: waterImageView?.bounds.size.height ?? 0)
                    context.draw((waterImageView?.image!.cgImage)!, in: area)
                }
            }
            
            for i in 1..<line {
                for j in 0..<row {
                    let area = CGRect(x: point.x + CGFloat(j) * verticalWidth, y: point.y - CGFloat(i) * horizontalHeight, width: waterImageView?.bounds.size.width ?? 0, height: waterImageView?.bounds.size.height ?? 0)
                    context.draw((waterImageView?.image!.cgImage)!, in: area)
                }
            }
            
            for i in 0..<line {
                for j in 1..<row {
                    let area = CGRect(x: point.x - CGFloat(j) * verticalWidth, y: point.y + CGFloat(i) * horizontalHeight, width: waterImageView?.bounds.size.width ?? 0, height: waterImageView?.bounds.size.height ?? 0)
                    context.draw((waterImageView?.image!.cgImage)!, in: area)
                }
            }
            
            for i in 1..<line {
                for j in 1..<row {
                    let area = CGRect(x: point.x - CGFloat(j) * verticalWidth, y: point.y - CGFloat(i) * horizontalHeight, width: waterImageView?.bounds.size.width ?? 0, height: waterImageView?.bounds.size.height ?? 0)
                    context.draw((waterImageView?.image!.cgImage)!, in: area)
                }
            }
        }
    }
    
    // Helper function to convert degrees to radians
    func radians(_ degrees: Double) -> Double {
        return degrees * .pi / 180
    }
    
}

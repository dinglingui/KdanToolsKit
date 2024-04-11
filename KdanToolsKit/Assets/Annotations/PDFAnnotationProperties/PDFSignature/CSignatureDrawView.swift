//
//  CSignatureDrawView.swift
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

@objc protocol CSignatureDrawViewDelegate: AnyObject {
    @objc optional func signatureDrawViewStart(_ signatureDrawView: CSignatureDrawView)
}

enum CSignatureDrawSelectedIndex: Int {
    case text = 0
    case image
}

class CSignatureDrawView: UIView {
    
    static var points: [CGPoint] = [
        CGPoint(x: 0, y: 0),
        CGPoint(x: 1, y: 1),
        CGPoint(x: 2, y: 2),
        CGPoint(x: 3, y: 3),
        CGPoint(x: 4, y: 4)
    ]
    var color: UIColor?
    var lineWidth: CGFloat = 0
    var image: UIImage?
    weak var delegate: CSignatureDrawViewDelegate?
    var selectIndex: CSignatureDrawSelectedIndex = .text
    
    private var _index: NSInteger = 0
    
    private var bezierPath: UIBezierPath?
    private var textRect: CGRect = .zero
    private var context: CGContext?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bezierPath = UIBezierPath()
        lineWidth = 1
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay(bounds)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        context = UIGraphicsGetCurrentContext()
        
        if selectIndex == .text {
            color?.set()
            bezierPath?.lineWidth = lineWidth
            bezierPath?.lineCapStyle = .round
            bezierPath?.lineJoinStyle = .round
            bezierPath?.stroke()
        } else if selectIndex == .image {
            if let image = image {
                let imageFrame = imageFrameInRect(rect)
                image.draw(in: imageFrame)
                delegate?.signatureDrawViewStart?(self)
            }
        }
        
    }
    
    // MARK: - Draw Methods
    
    func imageFrameInRect(_ rect: CGRect) -> CGRect {
        var imageRect: CGRect = CGRect.zero
        if(image != nil) {
            if image!.size.width < rect.size.width && image!.size.height < rect.size.height {
                imageRect.origin.x = (rect.size.width - image!.size.width) / 2.0
                imageRect.origin.y = (rect.size.height - image!.size.height) / 2.0
                imageRect.size = image!.size
            } else {
                if image!.size.width / image!.size.height > rect.size.width / rect.size.height {
                    imageRect.size.width = rect.size.width
                    imageRect.size.height = rect.size.width * image!.size.height / image!.size.width
                } else {
                    imageRect.size.height = rect.size.height
                    imageRect.size.width = rect.size.height * image!.size.width / image!.size.height
                }
                imageRect.origin.x = (rect.size.width - imageRect.size.width) / 2.0
                imageRect.origin.y = (rect.size.height - imageRect.size.height) / 2.0
            }
        }
        return imageRect
    }
    
    // MARK: - Public Methods
    
    func signatureImage() -> UIImage? {
        var rect: CGRect = .zero
        let imageFrame = imageFrameInRect(frame)
        if image != nil {
            if bezierPath?.isEmpty ?? true {
                rect = imageFrame
            } else {
                let pathFrame = bezierPath?.bounds ?? .zero
                rect.origin.x = min(imageFrame.minX, pathFrame.minX)
                rect.origin.y = min(imageFrame.minY, pathFrame.minY)
                rect.size.width = max(imageFrame.maxX, pathFrame.maxX) - rect.origin.x
                rect.size.height = max(imageFrame.maxY, pathFrame.maxY) - rect.origin.y
            }
        } else {
            if bezierPath?.isEmpty ?? true {
                return nil
            } else {
                rect = bezierPath?.bounds ?? .zero
            }
        }
        let size = CGSize(width: rect.size.width + (bezierPath?.lineWidth ?? 0),
                          height: rect.size.height + (bezierPath?.lineWidth ?? 0))
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let transform = CGAffineTransform(translationX: -rect.origin.x + (bezierPath?.lineWidth ?? 0) / 2.0,
                                          y: -rect.origin.y + (bezierPath?.lineWidth ?? 0) / 2.0)
        context.concatenate(transform)
        if let image = image {
            image.draw(in: imageFrame)
        }
        if !(bezierPath?.isEmpty ?? true) {
            if let color = color?.cgColor {
                context.setStrokeColor(color)
            }
            context.setLineWidth(bezierPath?.lineWidth ?? 0)
            context.setLineCap(bezierPath?.lineCapStyle ?? .butt)
            context.setLineJoin(bezierPath?.lineJoinStyle ?? .miter)
            if let path = bezierPath?.cgPath {
                context.addPath(path)
            }
            context.strokePath()
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
        
    }
    
    func signatureClear() {
        image = nil
        bezierPath?.removeAllPoints()
        setNeedsDisplay()
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_clear(_ button: UIButton) {
        image = nil
        bezierPath?.removeAllPoints()
        setNeedsDisplay()
    }
    
    // MARK: - Touch Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let point = touches.first?.location(in: self) {
            _index = 0
            CSignatureDrawView.points[0] = point
            delegate?.signatureDrawViewStart?(self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if let point = touches.first?.location(in: self) {
            _index += 1
            CSignatureDrawView.points[_index] = point
            if _index == 4 {
                CSignatureDrawView.points[3] = CGPoint(x: (CSignatureDrawView.points[2].x + CSignatureDrawView.points[4].x) / 2.0,
                                                                          y: (CSignatureDrawView.points[2].y + CSignatureDrawView.points[4].y) / 2.0)
                bezierPath?.move(to: CSignatureDrawView.points[0])
                bezierPath?.addCurve(to: CSignatureDrawView.points[3],
                                     controlPoint1: CSignatureDrawView.points[1],
                                     controlPoint2: CSignatureDrawView.points[2])
                CSignatureDrawView.points[0] = CSignatureDrawView.points[3]
                CSignatureDrawView.points[1] = CSignatureDrawView.points[4]
                _index = 1
                setNeedsDisplay()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if _index < 4 {
            for i in 0..<_index {
                bezierPath?.move(to: CSignatureDrawView.points[i])
            }
            setNeedsDisplay()
        }
    }

}


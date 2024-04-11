//
//  CStampPreview.swift
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

enum TextStampType: Int {
    case center = 0
    case left
    case right
    case none
}

enum TextStampColorType: Int {
    case black = 0
    case red
    case green
    case blue
}

class CStampPreview: UIView {
    var colors: [Double] = [0.0, 0.0, 0.0]
    var textStampStyle: TextStampType = .center
    var textStampColorStyle: TextStampColorType = .black {
        didSet {
            if .red == textStampColorStyle {
                colors[0] = 0.57
                colors[1] = 0.06
                colors[2] = 0.02
            } else if .green == textStampColorStyle {
                colors[0] = 0.25
                colors[1] = 0.42
                colors[2] = 0.13
            } else if .blue == textStampColorStyle {
                colors[0] = 0.09
                colors[1] = 0.15
                colors[2] = 0.39
            } else if .black == textStampColorStyle {
                colors[0] = 0
                colors[1] = 0
                colors[2] = 0
            }
        }
    }
    var textStampHaveDate: Bool = false
    var textStampHaveTime: Bool = false
    var textStampText: String?
    var dateTime: String?
    var stampBounds: CGRect = .zero
    var scale: Float = 0.0
    var leftMargin: CGFloat = 0.0
    var color: UIColor?
    
    let kStampPreview_OnlyText_Size: CGFloat = 48.0
    let kStampPreview_Text_Size: CGFloat = 30.0
    let kStampPreview_Date_Size: CGFloat = 20.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        scale = (UIScreen.main.scale == 2.0) ? 2.0 : 1.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func getDateTime() -> String {
        let timename = TimeZone.current
        let outputFormatter = DateFormatter()
        outputFormatter.timeZone = timename
        var tDate: String? = nil
        
        if textStampHaveDate && !textStampHaveTime {
            outputFormatter.dateFormat = "yyyy/MM/dd"
            tDate = outputFormatter.string(from: Date())
        } else if textStampHaveTime && !textStampHaveDate {
            outputFormatter.dateFormat = "HH:mm:ss"
            tDate = outputFormatter.string(from: Date())
        } else if textStampHaveDate && textStampHaveTime {
            outputFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            tDate = outputFormatter.string(from: Date())
        }
        
        return tDate ?? ""
        
    }
    
    // Calculate Rect based on text
    
    func fitStampRect() {
        var tTextFont: UIFont?
        var tTimeFont: UIFont?
        var drawText: String?
        var dateText: String?
        if (textStampText?.count ?? 0 < 1) && (dateTime?.count ?? 0 < 1) {
            drawText = "StampText"
            tTextFont = UIFont(name: "Helvetica", size: kStampPreview_OnlyText_Size)
        } else if (textStampText?.count ?? 0 > 0) && (dateTime?.count ?? 0 > 0) {
            tTextFont = UIFont(name: "Helvetica", size: kStampPreview_Text_Size)
            tTimeFont = UIFont(name: "Helvetica", size: kStampPreview_Date_Size)
            drawText = textStampText
            dateText = dateTime
        } else {
            if ((dateTime?.count ?? 0 > 0)) {
                drawText = dateTime
            } else {
                drawText = textStampText
            }
            tTextFont = UIFont(name: "Helvetica", size: kStampPreview_OnlyText_Size)
        }
        
        let tTextSize = drawText?.size(withAttributes: [.font: tTextFont as Any]) ?? .zero
        var tTimeSize = CGSize.zero
        if let tTimeFont = tTimeFont {
            tTimeSize = dateText?.size(withAttributes: [.font: tTimeFont]) ?? .zero
        }
        
        var w = max(tTextSize.width, tTimeSize.width)
        var count:CGFloat = 0
        if let drawText = drawText {
            for i in 0..<drawText.count {
                let aStr = String(drawText[drawText.index(drawText.startIndex, offsetBy: i)])
                if aStr == " " {
                    count += 1
                }
            }
        }
        if tTextSize.width < tTimeSize.width {
            w += 15
        } else {
            w += 13.0 + 5 * count
        }
        
        var h = tTextSize.height + 5
        if let _ = dateText {
            h = tTextSize.height + tTimeSize.height + 8.011
        }
        
        if textStampStyle == .left {
            w = CGFloat(Int(Double(w) + Double(h) * 0.618033))
        } else if textStampStyle == .right {
            w = CGFloat(Int(Double(w) + Double(h) * 0.618033))
        }
        
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        
        scale = 1.0
        let maxW: CGFloat = 300 - leftMargin
        if CGFloat(w) > maxW {
            scale = Float(maxW / CGFloat(w))
            h = CGFloat(Int(Double(h) * Double(scale)))
            x = frame.size.width / 2.0 - maxW / 2.0
            y = frame.size.height / 2.0 - CGFloat(h) / 2.0
            stampBounds = CGRect(x: x + leftMargin, y: y, width: maxW, height: h)
        } else {
            x = frame.size.width / 2.0 - CGFloat(w) / 2.0
            y = frame.size.height / 2.0 - CGFloat(h) / 2.0
            stampBounds = CGRect(x: x + leftMargin, y: y, width: CGFloat(w), height: h)
        }
        
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    override func draw(_ rect: CGRect) {
        dateTime = getDateTime()
        fitStampRect()
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.setFillColor(CPDFColorUtils.CAnnotationSampleDrawBackgoundColor().cgColor)
        context.fill(bounds)
        
        if textStampStyle != .none {
            drawBounder(context: context)
        }
        
        drawText(context)
    }
    
    func drawBounder(context: CGContext?) {
        guard let context = context else {
            return
        }
        context.saveGState()
        var c01 = 1.0, c02 = 1.0, c03 = 1.0, c11 = 1.0, c12 = 1.0, c13 = 1.0
        if colors[0] > colors[1] && colors[0] > colors[2] {
            c01 = 1.0
            c02 = 0.78
            c03 = 0.78
            
            c11 = 0.98
            c12 = 0.92
            c13 = 0.91
        } else if colors[1] > colors[0] && colors[1] > colors[2] {
            c01 = 0.81
            c02 = 0.88
            c03 = 0.78
            
            c11 = 0.95
            c12 = 0.95
            c13 = 0.95
        } else if colors[2] > colors[0] && colors[2] > colors[1] {
            c01 = 0.79
            c02 = 0.81
            c03 = 0.89
            
            c11 = 0.90
            c12 = 0.95
            c13 = 1.0
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors: [CGFloat] = [
            c01, c02, c03, 0.9,
            c11, c12, c13, 0.9
        ]
        guard let gradient = CGGradient(colorSpace: colorSpace, colorComponents: colors, locations: nil, count: colors.count/4) else {
            return
        }

        let startPoint = CGPoint(x: stampBounds.origin.x + stampBounds.size.width * 0.75, y: stampBounds.origin.y + stampBounds.size.width * 0.25)
        let endPoint = CGPoint(x: stampBounds.origin.x + stampBounds.size.width * 0.25, y: stampBounds.origin.y + stampBounds.size.width * 0.75)
        
        if textStampStyle == TextStampType.center {
            drawNormalRect(context: context)
        } else if textStampStyle == TextStampType.left {
            drawLeftBounder(context)
        } else if textStampStyle == TextStampType.right {
            drawRightBounder(context)
        }
        context.clip()
        
        context.saveGState()
        if let context = UIGraphicsGetCurrentContext() {
            context.saveGState()
            context.addRect(stampBounds)
            context.clip()
            context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
            context.restoreGState()
        }
        
        if textStampStyle == TextStampType.center {
            drawNormalRect(context: context)
        } else if textStampStyle == TextStampType.left {
            drawLeftBounder(context)
        } else if textStampStyle == TextStampType.right {
            drawRightBounder(context)
        }
        context.strokePath()
        
    }
    
    func drawNormalRect(context: CGContext) {
        let tmpHeight = 11.0 * stampBounds.size.height/50
        let tmpWidth = 3.0 * stampBounds.size.height/50
        let hw1 = 5.54492 * stampBounds.size.height/50
        let hw2 = 4.40039 * stampBounds.size.height/50
        context.beginPath()
        
        context.move(to: CGPoint(x: stampBounds.origin.x+tmpWidth, y: stampBounds.origin.y+stampBounds.size.height-tmpHeight))
        
        context.addCurve(to: CGPoint(x: stampBounds.origin.x+tmpHeight, y: stampBounds.origin.y+stampBounds.size.height-tmpWidth),
                         control1: CGPoint(x: stampBounds.origin.x+tmpWidth, y: stampBounds.origin.y+stampBounds.size.height-tmpHeight+hw2),
                         control2: CGPoint(x: stampBounds.origin.x+tmpHeight-hw1, y: stampBounds.origin.y+stampBounds.size.height-tmpWidth))
        
        context.addLine(to: CGPoint(x: stampBounds.origin.x+stampBounds.size.width-tmpHeight, y: stampBounds.origin.y+stampBounds.size.height-tmpWidth))
        
        context.addCurve(to: CGPoint(x: stampBounds.origin.x+stampBounds.size.width-tmpWidth, y: stampBounds.origin.y+stampBounds.size.height-tmpHeight),
                         control1: CGPoint(x: stampBounds.origin.x+stampBounds.size.width-tmpHeight+hw1, y: stampBounds.origin.y+stampBounds.size.height-tmpWidth),
                         control2: CGPoint(x: stampBounds.origin.x+stampBounds.size.width-tmpWidth, y: stampBounds.origin.y+stampBounds.size.height-tmpHeight+hw2))
        
        context.addLine(to: CGPoint(x: stampBounds.origin.x+stampBounds.size.width-tmpWidth, y: stampBounds.origin.y+tmpHeight))
        
        context.addCurve(to: CGPoint(x: stampBounds.origin.x+stampBounds.size.width-tmpHeight, y: stampBounds.origin.y+tmpWidth),
                         control1: CGPoint(x: stampBounds.origin.x+stampBounds.size.width-tmpWidth, y: stampBounds.origin.y+tmpHeight-hw2),
                         control2: CGPoint(x: stampBounds.origin.x+stampBounds.size.width-tmpHeight+hw1, y: stampBounds.origin.y+tmpWidth))
        
        context.addLine(to: CGPoint(x: stampBounds.origin.x+tmpHeight, y: stampBounds.origin.y+tmpWidth))
        
        context.addCurve(to: CGPoint(x: stampBounds.origin.x+tmpWidth, y: stampBounds.origin.y+tmpHeight),
                         control1: CGPoint(x: stampBounds.origin.x+tmpHeight-hw1, y: stampBounds.origin.y+tmpWidth),
                         control2: CGPoint(x: stampBounds.origin.x+tmpWidth, y: stampBounds.origin.y+tmpHeight-hw2))
        
        context.addLine(to: CGPoint(x: stampBounds.origin.x+tmpWidth, y: stampBounds.origin.y+stampBounds.size.height-tmpHeight))
        
        context.closePath()
        
    }
    
    func drawLeftBounder(_ context: CGContext) {
        let tmpHeight = 11.0 * stampBounds.size.height/50
        let tmpWidth = 3.0 * stampBounds.size.height/50
        let hw1 = 5.54492 * stampBounds.size.height/50
        let hw2 = 4.40039 * stampBounds.size.height/50
        let x0 = stampBounds.origin.x + stampBounds.size.height * 0.618033
        let y0 = stampBounds.origin.y
        
        let x1 = stampBounds.origin.x + stampBounds.size.width
        let y1 = stampBounds.origin.y + stampBounds.size.height
        
        let xp = stampBounds.origin.x
        let yp = stampBounds.origin.y + stampBounds.size.height / 2.0
        
        context.beginPath()
        
        context.move(to: CGPoint(x: x0 + tmpHeight, y: y1 - tmpWidth))
        context.addLine(to: CGPoint(x: x1 - tmpHeight, y: y1 - tmpWidth))
        context.addCurve(to: CGPoint(x: x1 - tmpWidth, y: y1 - tmpHeight),
                         control1: CGPoint(x: x1 - tmpHeight + hw1, y: y1 - tmpWidth),
                         control2: CGPoint(x: x1 - tmpWidth, y: y1 - tmpHeight + hw2))
        context.addLine(to: CGPoint(x: x1 - tmpWidth, y: y0 + tmpHeight))
        context.addCurve(to: CGPoint(x: x1 - tmpHeight, y: y0 + tmpWidth),
                         control1: CGPoint(x: x1 - tmpWidth, y: y0 + tmpHeight - hw2),
                         control2: CGPoint(x: x1 - tmpHeight + hw1, y: y0 + tmpWidth))

        context.addLine(to: CGPoint(x: x0 + tmpHeight, y: y0 + tmpWidth))
        context.addLine(to: CGPoint(x: xp + tmpHeight, y: yp))
        context.addLine(to: CGPoint(x: x0 + tmpHeight, y: y1 - tmpWidth))
        
        context.closePath()
        
    }
    
    func drawRightBounder(_ context: CGContext) {
        let tmpHeight = 11.0 * stampBounds.size.height/50
        let tmpWidth = 3.0 * stampBounds.size.height/50
        let hw1 = 5.54492 * stampBounds.size.height/50
        let hw2 = 4.40039 * stampBounds.size.height/50
        let x0 = stampBounds.origin.x
        let y0 = stampBounds.origin.y
        
        let x1 = stampBounds.origin.x + stampBounds.size.width - stampBounds.size.height * 0.618033
        let y1 = stampBounds.origin.y + stampBounds.size.height
        
        let xp = stampBounds.origin.x + stampBounds.size.width
        let yp = stampBounds.origin.y + stampBounds.size.height / 2.0
        
        context.beginPath()
        
        context.move(to: CGPoint(x: x0 + tmpWidth, y: y1 - tmpHeight))
        context.addCurve(to: CGPoint(x: x0 + tmpHeight, y: y1 - tmpWidth),
                         control1: CGPoint(x: x0 + tmpWidth, y: y1 - tmpHeight + hw2),
                         control2: CGPoint(x: x0 + tmpHeight - hw1, y: y1 - tmpWidth))
        context.addLine(to: CGPoint(x: x1 - tmpHeight, y: y1 - tmpWidth))
        context.addLine(to: CGPoint(x: xp - tmpHeight, y: yp))
        context.addLine(to: CGPoint(x: x1 - tmpHeight, y: y0 + tmpWidth))
        context.addLine(to: CGPoint(x: x0 + tmpHeight, y: y0 + tmpWidth))
        context.addCurve(to: CGPoint(x: x0 + tmpWidth, y: y0 + tmpHeight),
                         control1: CGPoint(x: x0 + tmpHeight - hw1, y: y0 + tmpWidth),
                         control2: CGPoint(x: x0 + tmpWidth, y: y0 + tmpHeight - hw2))
        context.addLine(to: CGPoint(x: x0 + tmpWidth, y: y1 - tmpHeight))

        
        context.closePath()
        
    }
    
    func drawText(_ context: CGContext?) {
        guard let context = context else {
            return
        }
        
        context.textMatrix = CGAffineTransform(scaleX: 1.0, y: -1.0)

        var drawText: String?
        var dateText: String?
        if (textStampText?.count ?? 0 < 1) && (dateTime?.count ?? 0 < 1) {
            drawText = "StampText"
        } else if (textStampText?.count ?? 0 > 0) && (dateTime?.count ?? 0 > 0) {
            drawText = textStampText
            dateText = dateTime
        }else {
            if((dateTime?.count ?? 0 > 0)) {
                drawText = dateTime
            } else {
                drawText = textStampText
            }
        }
        
        if (dateText?.count ?? 0 < 1) {
            let fontsize = Float(kStampPreview_OnlyText_Size) * scale
            let font = UIFont(name: "Helvetica", size: CGFloat(fontsize))
            var rt = stampBounds.insetBy(dx: 0, dy: 0)
            rt.origin.x += CGFloat(8.093 * scale)
            
            if textStampStyle == .left {
                rt.origin.x += rt.size.height * 0.618033
            }
            
            UIGraphicsPushContext(context)
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font as Any,
                .paragraphStyle: NSParagraphStyle.default,
                    .foregroundColor: UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1)
            ]

            drawText?.draw(in: rt, withAttributes: attributes)
            UIGraphicsPopContext()
            
        } else {
            var tFontSize = Float(kStampPreview_Text_Size) * Float(scale)
            var tFont = UIFont(name: "Helvetica", size: CGFloat(tFontSize))
            
            var tTextRT = stampBounds.insetBy(dx: 0, dy: 0)
            tTextRT.origin.x += CGFloat(8.093 * scale)
            
            if textStampStyle == .left {
                tTextRT.origin.x += tTextRT.size.height * 0.618033
            }
            
            UIGraphicsPushContext(context)
            UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1).set()
            
            if !(drawText?.isEmpty == true) {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: tFont as Any,
                    .paragraphStyle: NSParagraphStyle.default,
                        .foregroundColor: UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1)

                ]

                drawText?.draw(in: tTextRT, withAttributes: attributes)
                
                var tDateRT = stampBounds.insetBy(dx: 0, dy: 0)
                tDateRT.origin.x += CGFloat(8.093 * Float(scale))
                
                if textStampStyle == .left {
                    tDateRT.origin.x += tDateRT.size.height * 0.618033
                }
                
                tDateRT.origin.y = tDateRT.origin.y + CGFloat(tFontSize) + CGFloat(6.103 * scale)
                
                tFontSize = Float(kStampPreview_Date_Size) * Float(scale)
                tFont = UIFont(name: "Helvetica", size: CGFloat(tFontSize))
                
                let attributess: [NSAttributedString.Key: Any] = [
                    .font: tFont as Any,
                    .paragraphStyle: NSParagraphStyle.default,
                        .foregroundColor: UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1)

                ]

                dateText?.draw(in: tDateRT, withAttributes: attributess)
            } else {
                let fontsize = Float(kStampPreview_Date_Size) * Float(scale)
                let font = UIFont(name: "Helvetica", size: CGFloat(tFontSize))
                
                var rt = stampBounds.insetBy(dx: 0, dy: 0)
                rt.origin.x += CGFloat(8.093 * scale)
                
                if textStampStyle == .left {
                    rt.origin.x += rt.size.height * 0.618033
                }
                
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font as Any,
                    .paragraphStyle: NSParagraphStyle.default,
                        .foregroundColor: UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: 1)

                ]

                dateText?.draw(in: rt, withAttributes: attributes)
            }
            
            UIGraphicsPopContext()
        }
        
    }
    
    
    func renderImage() -> UIImage? {
        // Implementation for rendering an image
        let image = renderImageFromView(self)
        return image
    }
    
    /* Convert UIView to UIImage */
    func renderImageFromView(_ view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.translateBy(x: 1.0, y: 1.0)
        
        view.layer.render(in: context)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
        
    }
    
    
}


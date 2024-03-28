//
//  CPDFSampleView.swift
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

enum CPDFSamplesSelectedIndex: Int {
    case note = 0
    case highlight
    case underline
    case strikeout
    case squiggly
    case freehand
    case shapeCircle
    case shapeSquare
    case shapeArrow
    case shapeLine
    case freeText
    case signature
    case stamp
    case image
    case link
    case sound
}

enum CPDFArrowStyle: Int {
    case none = 0
    case openArrow = 1
    case closedArrow = 2
    case square = 3
    case circle = 4
    case diamond = 5
}

class CPDFSampleView: UIView {
    
    var selecIndex:CPDFSamplesSelectedIndex = .highlight
    var startArrowStyleIndex:CPDFArrowStyle = .none
    var endArrowStyleIndex:CPDFArrowStyle = .none
    
    var color:UIColor?
    var interiorColor:UIColor?
    var opcity:CGFloat = 0
    var thickness:CGFloat = 0
    var dotted:CGFloat = 0
    var fontName:String?
    var isBold:Bool = false
    var isItalic:Bool = false
    var textAlignment:NSTextAlignment = .center
    
    var centerRect:CGRect = CGRect.zero
    var arrowRect:CGRect = CGRect.zero
    var textRect:CGRect = CGRect.zero
    var inkRect:CGRect = CGRect.zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        centerRect = rect.insetBy(dx: (bounds.size.width/20)*9, dy: (bounds.size.height/8)*3)
        let centerPoint = CGPoint(x: rect.midX, y: rect.midY)
        arrowRect = CGRect(x: centerPoint.x-bounds.size.height/4, y: centerPoint.y-bounds.size.height/4, width: bounds.size.height/2, height: bounds.size.height/2)
        
        textRect = rect.insetBy(dx: bounds.size.width/3+3, dy: bounds.size.height/3)
        inkRect = rect.insetBy(dx: bounds.size.width/4, dy: bounds.size.height/3)
        
        context.setFillColor(CPDFColorUtils.CAnnotationSampleDrawBackgoundColor().cgColor)
        context.fill(rect)
        
        drawSamples(context: context, rect: centerRect)
    }
    
    func drawSamples(context: CGContext, rect: CGRect) {
        
        switch selecIndex {
        case .note:
            context.setStrokeColor(red: 0, green: 0, blue: 0, alpha: 1.0)
            
            if let color = self.color {
                var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
                color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                let updatedColor = UIColor(red: red, green: green, blue: blue, alpha: self.opcity)
                context.setFillColor(updatedColor.cgColor)
            } else {
                context.setStrokeColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
                context.setFillColor(UIColor.clear.cgColor)
            }
            
            // Draw outer boxes.
            let width: CGFloat = 1.0
            let size: CGFloat = rect.size.height / 5
            var outerRect1 = rect.insetBy(dx: 0, dy: 0)
            outerRect1.size.height -= size
            var outerRect2 = outerRect1
            outerRect2.origin.x += size
            outerRect2.origin.y += size*4
            outerRect2.size.width = size
            outerRect2.size.height = size
            
            context.setLineWidth(width)
            context.move(to: CGPoint(x: outerRect1.minX, y: outerRect1.minY))
            context.addLine(to: CGPoint(x: outerRect1.minX, y: outerRect1.maxY))
            context.addLine(to: CGPoint(x: outerRect2.minX, y: outerRect2.minY))
            context.addLine(to: CGPoint(x: outerRect2.midX, y: outerRect2.maxY))
            context.addLine(to: CGPoint(x: outerRect2.midX, y: outerRect2.minY))
            context.addLine(to: CGPoint(x: outerRect1.maxX, y: outerRect1.maxY))
            context.addLine(to: CGPoint(x: outerRect1.maxX, y: outerRect1.minY))
            context.closePath()
            context.drawPath(using: .fillStroke)
            
            // Draw inner lines.
            let count = 3
            let xDelta = rect.size.width / 10
            let yDelta = outerRect1.size.height / CGFloat(count + 1)
            
            var lineRect = outerRect1
            lineRect.origin.x += xDelta
            lineRect.size.width -= 2*xDelta
            
            for i in 0..<count {
                let y = lineRect.maxY - yDelta * CGFloat(i + 1)
                context.move(to: CGPoint(x: lineRect.minX, y: y))
                context.addLine(to: CGPoint(x: lineRect.maxX, y: y))
                context.strokePath()
            }
            
        case .highlight:
            let colorComponents = self.color?.cgColor.components
            let red = colorComponents?[0]
            let green = colorComponents?[1]
            let blue = colorComponents?[2]
           
            let fillColor = UIColor(red: red ?? 0, green: green ?? 0, blue: blue ?? 0, alpha: self.opcity).cgColor
            context.setFillColor(fillColor)
            context.fill(self.textRect)
            let sampleStr = "Sample"
            let font = UIFont.systemFont(ofSize: 27)
            let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.black]
            sampleStr.draw(in: self.textRect, withAttributes: attributes)
            
        case .underline:
            let sampleStr = "Sample"
            let colorComponents = self.color?.cgColor.components
            let red = colorComponents?[0]
            let green = colorComponents?[1]
            let blue = colorComponents?[2]
            
            let fillColor = UIColor(red: red ?? 0, green: green ?? 0, blue: blue ?? 0, alpha: self.opcity).cgColor
            context.setFillColor(fillColor)
            let strikeoutRect = self.textRect.insetBy(dx: 0, dy: (self.textRect.size.height/7) * 3)
            let underLineRect = strikeoutRect.offsetBy(dx: 0, dy: (self.textRect.size.height/7) * 3)
            context.fill(underLineRect)
            let font = UIFont.systemFont(ofSize: 27)
            let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.black]
            sampleStr.draw(in: self.textRect, withAttributes: attributes)
            
        case .strikeout:
            let sampleStr = "Sample"
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            self.color?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            let fillColor = UIColor(red: red, green: green, blue: blue, alpha: self.opcity).cgColor
            context.setFillColor(fillColor)
            let strikeoutRect = self.textRect.insetBy(dx: 0, dy: (self.textRect.size.height/7)*3)
            let underLineRect = strikeoutRect.offsetBy(dx: 0, dy: (self.textRect.size.height/7))
            context.fill(underLineRect)
            let font = UIFont.systemFont(ofSize: 27)
            let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.black]
            sampleStr.draw(in: self.textRect, withAttributes: attributes)
            
        case .squiggly:
            let sampleStr = "Sample"
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            self.color?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            context.setStrokeColor(UIColor(red: red, green: green, blue: blue, alpha: opcity).cgColor)
            let tWidth = self.textRect.size.width / 12.0
            context.move(to: CGPoint(x: self.textRect.minX, y: self.textRect.maxY))
            context.setLineWidth(2.0)
            
            context.addCurve(to: CGPoint(x: self.textRect.minX + tWidth, y: self.textRect.maxY + 5),
                             control1: CGPoint(x: self.textRect.minX + tWidth * 2.0, y: self.textRect.maxY - 5),
                             control2: CGPoint(x: self.textRect.minX + tWidth * 3.0, y: self.textRect.maxY))
            context.addCurve(to: CGPoint(x: self.textRect.minX + tWidth * 3.0, y: self.textRect.maxY),
                             control1: CGPoint(x: self.textRect.minX + tWidth * 4.0, y: self.textRect.maxY + 5),
                             control2: CGPoint(x: self.textRect.minX + tWidth * 5.0, y: self.textRect.maxY - 5))
            context.addCurve(to: CGPoint(x: self.textRect.minX + tWidth * 6.0, y: self.textRect.maxY),
                             control1: CGPoint(x: self.textRect.minX + tWidth * 7.0, y: self.textRect.maxY + 5),
                             control2: CGPoint(x: self.textRect.minX + tWidth * 8.0, y: self.textRect.maxY - 5))
            context.addCurve(to: CGPoint(x: self.textRect.minX + tWidth * 9.0, y: self.textRect.maxY),
                             control1: CGPoint(x: self.textRect.minX + tWidth * 10.0, y: self.textRect.maxY + 5),
                             control2: CGPoint(x: self.textRect.minX + tWidth * 11.0, y: self.textRect.maxY - 5))
            context.addCurve(to: CGPoint(x: self.textRect.minX + tWidth * 12.0, y: self.textRect.maxY),
                             control1: CGPoint(x: self.textRect.minX + tWidth * 12.0, y: self.textRect.maxY),
                             control2: CGPoint(x: self.textRect.minX + tWidth * 12.0, y: self.textRect.maxY))
            context.strokePath()
            let font = UIFont.systemFont(ofSize: 27)
            let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.black]
            sampleStr.draw(in: self.textRect, withAttributes: attributes)
        case .freehand:
            let colorComponents = self.color?.cgColor.components
            let red = colorComponents?[0]
            let green = colorComponents?[1]
            let blue = colorComponents?[2]
            
            let strokeColor = UIColor(red: red ?? 0, green: green ?? 0, blue: blue ?? 0, alpha: self.opcity).cgColor
            context.setStrokeColor(strokeColor)
            let tWidth = self.inkRect.size.width / 3.0
            context.move(to: CGPoint(x: self.inkRect.minX, y: self.inkRect.midY))
            context.setLineWidth(self.thickness)
            context.addCurve(to: CGPoint(x: self.inkRect.minX + tWidth * 3.0, y: self.inkRect.midY),
                              control1: CGPoint(x: self.inkRect.minX + tWidth, y: self.inkRect.midY - 20),
                              control2: CGPoint(x: self.inkRect.minX + tWidth * 2.0, y: self.inkRect.midY + 20))
            context.strokePath()
            
        case .shapeCircle:
            let colorComponents = self.color?.cgColor.components
            let red = colorComponents?[0]
            let green = colorComponents?[1]
            let blue = colorComponents?[2]
            
            let strokeColor = UIColor(red: red ?? 0, green: green ?? 0, blue: blue ?? 0, alpha: self.opcity).cgColor
            context.setStrokeColor(strokeColor)
            if self.interiorColor != UIColor.clear  &&  self.interiorColor != nil {
                let interColorComponents = self.interiorColor?.cgColor.components
                let interRed = interColorComponents?[0]
                let interGreen = interColorComponents?[1]
                let interBlue = interColorComponents?[2]
                
                let fillColor = UIColor(red: interRed ?? 0, green: interGreen ?? 0, blue: interBlue ?? 0, alpha: self.opcity).cgColor
                context.setFillColor(fillColor)
            } else {
                context.setFillColor(UIColor.clear.cgColor)
            }
            let dashLengths: [CGFloat] = [6.0, self.dotted]
            context.setLineDash(phase: 0, lengths: dashLengths)
            context.setLineWidth(self.thickness)
            context.addArc(center: CGPoint(x: self.bounds.maxX/2, y: self.bounds.maxY/2), radius: 30, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
            context.drawPath(using: .stroke)
            context.addArc(center: CGPoint(x: self.bounds.maxX/2, y: self.bounds.maxY/2), radius: 30, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
            context.drawPath(using: .fill)
            
        case .shapeSquare:
            let colorComponents = self.color?.cgColor.components
            let red = colorComponents?[0]
            let green = colorComponents?[1]
            let blue = colorComponents?[2]
            
            let strokeColor = UIColor(red: red ?? 0, green: green ?? 0, blue: blue ?? 0, alpha: self.opcity).cgColor
            context.setStrokeColor(strokeColor)
            if self.interiorColor != UIColor.clear  &&  self.interiorColor != nil {
                let interColorComponents = self.interiorColor?.cgColor.components
                let interRed = interColorComponents?[0]
                let interGreen = interColorComponents?[1]
                let interBlue = interColorComponents?[2]
               
                let fillColor = UIColor(red: interRed ?? 0, green: interGreen ?? 0, blue: interBlue ?? 0, alpha: self.opcity).cgColor
                context.setFillColor(fillColor)
            } else {
                context.setFillColor(UIColor.clear.cgColor)
            }
            context.setLineWidth(self.thickness)
            let dashLengths: [CGFloat] = [6.0, self.dotted]
            context.setLineDash(phase: 0, lengths: dashLengths)
            context.move(to: CGPoint(x: self.centerRect.minX, y: self.centerRect.minY))
            context.addLine(to: CGPoint(x: self.centerRect.maxX + 0.1, y: self.centerRect.minY))
            context.addLine(to: CGPoint(x: self.centerRect.maxX, y: self.centerRect.maxY))
            context.addLine(to: CGPoint(x: self.centerRect.minX, y: self.centerRect.maxY))
            context.addLine(to: CGPoint(x: self.centerRect.minX, y: self.centerRect.minY))
            context.addLine(to: CGPoint(x: self.centerRect.minX + 0.1, y: self.centerRect.minY))
            context.strokePath()
            context.fill(rect)
            
        case .shapeArrow:
            let colorComponents = self.color?.cgColor.components
            let red = colorComponents?[0]
            let green = colorComponents?[1]
            let blue = colorComponents?[2]
            
            let strokeColor = UIColor(red: red ?? 0, green: green ?? 0, blue: blue ?? 0, alpha: self.opcity).cgColor
            context.setStrokeColor(strokeColor)
            context.setLineWidth(self.thickness)
            let start = CGPoint(x: self.arrowRect.minX, y: self.arrowRect.maxY)
            let end = CGPoint(x: self.arrowRect.maxX, y: self.arrowRect.minY)
            self.drawEndArrow(context: context, startPoint: start, endPoint: end)
            self.drawStartArrow(context: context, startPoint: start, endPoint: end)
            let dashLengths: [CGFloat] = [6.0, self.dotted]
            context.setLineDash(phase: 0, lengths: dashLengths)
            context.move(to: start)
            context.addLine(to: end)
            context.strokePath()
            
        case .shapeLine:
            let colorComponents = self.color?.cgColor.components
            let red = colorComponents?[0]
            let green = colorComponents?[1]
            let blue = colorComponents?[2]
           
            let strokeColor = UIColor(red: red ?? 0, green: green ?? 0, blue: blue ?? 0, alpha: self.opcity).cgColor
            context.setStrokeColor(strokeColor)
            context.setLineWidth(self.thickness)
            let start = CGPoint(x: self.arrowRect.minX, y: self.arrowRect.maxY)
            let end = CGPoint(x: self.arrowRect.maxX, y: self.arrowRect.minY)
            self.drawEndArrow(context: context, startPoint: start, endPoint: end)
            self.drawStartArrow(context: context, startPoint: start, endPoint: end)
            let dashLengths: [CGFloat] = [6.0, self.dotted]
            context.setLineDash(phase: 0, lengths: dashLengths)
            context.move(to: start)
            context.addLine(to: end)
            context.strokePath()
        case .freeText:
            let colorComponents = self.color?.cgColor.components
            let red = colorComponents?[0]
            let green = colorComponents?[1]
            let blue = colorComponents?[2]
        
            var sampleStr = "Sample"
            var font = UIFont(name: self.fontName ?? "", size: self.thickness)
            if font == nil {
                font = UIFont.systemFont(ofSize: self.thickness)
            }
            if self.color == nil {
                self.color = UIColor.white
            }
            let attributedText = NSAttributedString(string: sampleStr, attributes: [NSAttributedString.Key.font: font!, NSAttributedString.Key.foregroundColor: UIColor(red: red ?? 0, green: green ?? 0, blue: blue ?? 0, alpha: self.opcity)])
            let textSize = attributedText.boundingRect(with: self.bounds.size, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).size
            var x: CGFloat = 0
            var y: CGFloat = 0
            switch self.textAlignment {
            case .left:
                x = self.bounds.origin.x
                y = self.bounds.origin.y + (self.bounds.size.height - textSize.height) / 2.0
            case .center:
                x = self.bounds.origin.x + (self.bounds.size.width - textSize.width) / 2.0
                y = self.bounds.origin.y + (self.bounds.size.height - textSize.height) / 2.0
            case .right:
                x = self.bounds.origin.x + (self.bounds.size.width - textSize.width)
                y = self.bounds.origin.y + (self.bounds.size.height - textSize.height) / 2.0
            default:
                x = self.bounds.origin.x + (self.bounds.size.width - textSize.width) / 2.0
                y = self.bounds.origin.y + (self.bounds.size.height - textSize.height) / 2.0
            }
            let center = CGPoint(x: x, y: y)
            attributedText.draw(at: center)
            
        default:break
        }
        
    }
    
    func drawStartArrow(context: CGContext, startPoint: CGPoint, endPoint: CGPoint) {
        switch self.startArrowStyleIndex {
        case .openArrow:
            context.move(to: CGPoint(x: startPoint.x + 10, y: startPoint.y))
            context.addLine(to: startPoint)
            context.addLine(to: CGPoint(x: startPoint.x, y: startPoint.y - 10))
            context.strokePath()
        case .closedArrow:
            context.move(to: CGPoint(x: startPoint.x - 5, y: startPoint.y - 5))
            context.addLine(to: CGPoint(x: startPoint.x - 5, y: startPoint.y + 5))
            context.addLine(to: CGPoint(x: startPoint.x + 5, y: startPoint.y + 5))
            context.closePath()
            context.strokePath()
        case .square:
            context.move(to: CGPoint(x: startPoint.x - 2.5, y: startPoint.y - 2.5))
            context.addLine(to: CGPoint(x: startPoint.x - 7.5, y: startPoint.y + 2.5))
            context.addLine(to: CGPoint(x: startPoint.x - 2.5, y: startPoint.y + 7.5))
            context.addLine(to: CGPoint(x: startPoint.x + 2.5, y: startPoint.y + 2.5))
            context.closePath()
            context.strokePath()
        case .circle:
            context.addArc(center: CGPoint(x: startPoint.x - 2.5, y: startPoint.y + 2.5), radius: 5, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)
            context.drawPath(using: .stroke)
        case .diamond:
            context.move(to: startPoint)
            context.addLine(to: CGPoint(x: startPoint.x - 5, y: startPoint.y))
            context.addLine(to: CGPoint(x: startPoint.x - 5, y: startPoint.y + 5))
            context.addLine(to: CGPoint(x: startPoint.x, y: startPoint.y + 5))
            context.closePath()
            context.strokePath()
        default:break
        }
    }
    
    func drawEndArrow(context: CGContext, startPoint: CGPoint, endPoint: CGPoint) {
        switch self.endArrowStyleIndex {
        case .openArrow:
            context.move(to: CGPoint(x: endPoint.x - 10, y: endPoint.y))
            context.addLine(to: endPoint)
            context.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y + 10))
            context.strokePath()
        case .closedArrow:
            context.move(to: CGPoint(x: endPoint.x - 5, y: endPoint.y - 5))
            context.addLine(to: CGPoint(x: endPoint.x + 5, y: endPoint.y - 5))
            context.addLine(to: CGPoint(x: endPoint.x + 5, y: endPoint.y + 5))
            context.closePath()
            context.strokePath()
        case .square:
            context.move(to: CGPoint(x: endPoint.x - 2.5, y: endPoint.y - 2.5))
            context.addLine(to: CGPoint(x: endPoint.x + 2.5, y: endPoint.y + 2.5))
            context.addLine(to: CGPoint(x: endPoint.x + 7.5, y: endPoint.y - 2.5))
            context.addLine(to: CGPoint(x: endPoint.x + 2.5, y: endPoint.y - 7.5))
            context.closePath()
            context.strokePath()
        case .circle:
            context.addArc(center: CGPoint(x: endPoint.x + 2.5, y: endPoint.y - 2.5), radius: 5, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)
            context.drawPath(using: .stroke)
        case .diamond:
            context.move(to: endPoint)
            context.addLine(to: CGPoint(x: endPoint.x + 5, y: endPoint.y))
            context.addLine(to: CGPoint(x: endPoint.x + 5, y: endPoint.y - 5))
            context.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y - 5))
            context.closePath()
            context.strokePath()
        default:break
        }
    }
    
}

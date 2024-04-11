//
//  CAnnotStyle.swift
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
import ComPDFKit

public class CAnnotStyle: NSObject {
    
    var isSelectAnnot:Bool = false
    var annotations:[CPDFAnnotation] = []
    var annotMode:CPDFViewAnnotationMode = .CPDFViewAnnotationModenone
    var headKeys:[String] = []
    var trialKeys:[String] = []
    
    init(annotionMode: CPDFViewAnnotationMode, annotations: [CPDFAnnotation]?) {
        super.init()
        if annotations?.count ?? 0 > 0 {
            isSelectAnnot = true
            self.annotations = annotations ?? []
            annotMode = convertAnnotationType()
        } else {
            isSelectAnnot = false
            annotMode = annotionMode
        }
        
    }
    var annotation: CPDFAnnotation? {
        return annotations.first
    }
    
    func convertAnnotationType() -> CPDFViewAnnotationMode {
        var annotationType: CPDFViewAnnotationMode = .CPDFViewAnnotationModenone
        
        if(annotation != nil) {
            
            if annotation is CPDFFreeTextAnnotation {
                annotationType = .freeText
            } else if annotation is CPDFTextAnnotation {
                annotationType = .note
            } else if annotation is CPDFCircleAnnotation {
                annotationType = .circle
            } else if annotation is CPDFSquareAnnotation {
                annotationType = .square
            } else if annotation is CPDFMarkupAnnotation {
                let markupAnnotation:CPDFMarkupAnnotation = annotation as? CPDFMarkupAnnotation ?? CPDFMarkupAnnotation()
                if markupAnnotation.markupType() == .highlight {
                    annotationType = .highlight
                } else if markupAnnotation.markupType() == .strikeOut {
                    annotationType = .strikeout
                } else if markupAnnotation.markupType() == .underline {
                    annotationType = .underline
                } else if markupAnnotation.markupType() == .squiggly {
                    annotationType = .squiggly
                }
            } else if annotation is CPDFLineAnnotation {
                let lineAnnotation:CPDFLineAnnotation = annotation as? CPDFLineAnnotation ?? CPDFLineAnnotation()
                
                if lineAnnotation.endLineStyle == .none && lineAnnotation.startLineStyle == .none {
                    annotationType = .line
                } else {
                    annotationType = .arrow
                }
            } else if annotation is CPDFInkAnnotation {
                annotationType = .ink
            } else if annotation is CPDFLinkAnnotation {
                annotationType = .link
            } else if annotation is CPDFSignatureAnnotation {
                annotationType = .signature
            } else if annotation is CPDFStampAnnotation {
                annotationType = .stamp
            } else if annotation is CPDFSoundAnnotation {
                annotationType = .sound
            } else if annotation is CPDFTextWidgetAnnotation {
                annotationType = .formModeText
            } else if annotation is CPDFButtonWidgetAnnotation {
                let buttonWidgetAnnotation:CPDFButtonWidgetAnnotation = annotation as? CPDFButtonWidgetAnnotation ?? CPDFButtonWidgetAnnotation()
                
                if buttonWidgetAnnotation.controlType() == .checkBoxControl {
                    annotationType = .formModeCheckBox
                } else if buttonWidgetAnnotation.controlType() == .radioButtonControl {
                    annotationType = .formModeRadioButton
                } else if buttonWidgetAnnotation.controlType() == .pushButtonControl {
                    annotationType = .formModeButton
                }
            } else if annotation is CPDFChoiceWidgetAnnotation {
                let choiceWidgetAnnotation:CPDFChoiceWidgetAnnotation = annotation as? CPDFChoiceWidgetAnnotation ?? CPDFChoiceWidgetAnnotation()
                
                if choiceWidgetAnnotation.isListChoice {
                    annotationType = .formModeList
                } else {
                    annotationType = .formModeCombox
                }
            }
        }
        
        return annotationType
    }
    
    
    // MARK: - Common
    var color: UIColor? {
        if isSelectAnnot {
            return annotation?.color
        } else {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .note:
                return userDefaults.PDFListViewColorForKey(CAnchoredNoteColorKey)
            case .circle:
                return userDefaults.PDFListViewColorForKey(CCircleNoteColorKey)
            case .square:
                return userDefaults.PDFListViewColorForKey(CSquareNoteColorKey)
            case .highlight:
                return userDefaults.PDFListViewColorForKey(CHighlightNoteColorKey)
            case .underline:
                return userDefaults.PDFListViewColorForKey(CUnderlineNoteColorKey)
            case .strikeout:
                return userDefaults.PDFListViewColorForKey(CStrikeOutNoteColorKey)
            case .squiggly:
                return userDefaults.PDFListViewColorForKey(CSquigglyNoteColorKey)
            case .line:
                return userDefaults.PDFListViewColorForKey(CLineNoteColorKey)
            case .arrow:
                return userDefaults.PDFListViewColorForKey(CArrowNoteColorKey)
            case .ink:
                return CPDFKitConfig.sharedInstance().freehandAnnotationColor()
            default:
                return nil
            }
        }
    }
    func setColor(_ color: UIColor?) {
        if isSelectAnnot {
            annotations.forEach { annotation in
                annotation.color = color
            }
        } else {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .note:
                userDefaults.setPDFListViewColor(color, forKey: CAnchoredNoteColorKey)
            case .circle:
                userDefaults.setPDFListViewColor(color, forKey: CCircleNoteColorKey)
            case .square:
                userDefaults.setPDFListViewColor(color, forKey: CSquareNoteColorKey)
            case .highlight:
                userDefaults.setPDFListViewColor(color, forKey: CHighlightNoteColorKey)
            case .underline:
                userDefaults.setPDFListViewColor(color, forKey: CUnderlineNoteColorKey)
            case .strikeout:
                userDefaults.setPDFListViewColor(color, forKey: CStrikeOutNoteColorKey)
            case .squiggly:
                userDefaults.setPDFListViewColor(color, forKey: CSquigglyNoteColorKey)
            case .line:
                userDefaults.setPDFListViewColor(color, forKey: CLineNoteColorKey)
            case .arrow:
                userDefaults.setPDFListViewColor(color, forKey: CArrowNoteColorKey)
            case .ink:
                CPDFKitConfig.sharedInstance().setFreehandAnnotationColor(color)
                userDefaults.setPDFListViewColor(color, forKey: CInkNoteColorKey)
            default:
                break
            }
            userDefaults.synchronize()
        }
    }
    
    var opacity: CGFloat {
        var opacity: CGFloat = 0
        if isSelectAnnot {
            opacity = annotation?.opacity ?? 1.0
        } else {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .freeText:
                opacity = CGFloat(userDefaults.float(forKey: CFreeTextNoteOpacityKey))
            case .note:
                opacity = CGFloat(userDefaults.float(forKey: CAnchoredNoteOpacityKey))
            case .circle:
                opacity = CGFloat(userDefaults.float(forKey: CCircleNoteOpacityKey))
            case .square:
                opacity = CGFloat(userDefaults.float(forKey: CSquareNoteOpacityKey))
            case .highlight:
                opacity = CGFloat(userDefaults.float(forKey: CHighlightNoteOpacityKey))
            case .underline:
                opacity = CGFloat(userDefaults.float(forKey: CUnderlineNoteOpacityKey))
            case .strikeout:
                opacity = CGFloat(userDefaults.float(forKey: CStrikeOutNoteOpacityKey))
            case .squiggly:
                opacity = CGFloat(userDefaults.float(forKey: CSquigglyNoteOpacityKey))
            case .line:
                opacity = CGFloat(userDefaults.float(forKey: CLineNoteOpacityKey))
            case .arrow:
                opacity = CGFloat(userDefaults.float(forKey: CArrowNoteOpacityKey))
            case .ink:
                opacity = CPDFKitConfig.sharedInstance().freehandAnnotationOpacity() / 100.0
            default:
                break
            }
        }
        return opacity
    }
    func setOpacity(_ opacity: CGFloat) {
        if isSelectAnnot {
            for annotation in annotations {
                annotation.opacity = opacity
            }
        } else {
            let userDefaults = UserDefaults.standard
            switch self.annotMode {
            case .freeText:
                userDefaults.set(opacity, forKey: CFreeTextNoteOpacityKey)
            case .note:
                userDefaults.set(opacity, forKey: CAnchoredNoteOpacityKey)
            case .circle:
                userDefaults.set(opacity, forKey: CCircleNoteOpacityKey)
            case .square:
                userDefaults.set(opacity, forKey: CSquareNoteOpacityKey)
            case .highlight:
                userDefaults.set(opacity, forKey: CHighlightNoteOpacityKey)
            case .underline:
                userDefaults.set(opacity, forKey: CUnderlineNoteOpacityKey)
            case .strikeout:
                userDefaults.set(opacity, forKey: CStrikeOutNoteOpacityKey)
            case .squiggly:
                userDefaults.set(opacity, forKey: CSquigglyNoteOpacityKey)
            case .line:
                userDefaults.set(opacity, forKey: CLineNoteOpacityKey)
            case .arrow:
                userDefaults.set(opacity, forKey: CArrowNoteOpacityKey)
            case .ink:
                CPDFKitConfig.sharedInstance().setFreehandAnnotationOpacity(opacity * 100)
                userDefaults.set(opacity, forKey: CInkNoteOpacityKey)
            default:
                break
            }
            
            userDefaults.synchronize()
        }
    }
    
    var style: CPDFBorderStyle {
        var style: CPDFBorderStyle = .solid
        if isSelectAnnot {
            style = annotation?.border.style ?? .solid
        } else {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .freeText:
                style = CPDFBorderStyle(rawValue: userDefaults.integer(forKey: CFreeTextNoteLineStyleKey)) ?? .solid
            case .circle:
                style = CPDFBorderStyle(rawValue: userDefaults.integer(forKey: CCircleNoteLineStyleKey)) ?? .solid
            case .square:
                style = CPDFBorderStyle(rawValue: userDefaults.integer(forKey: CSquareNoteLineStyleKey)) ?? .solid
            case .line:
                style = CPDFBorderStyle(rawValue: userDefaults.integer(forKey: CLineNoteLineStyleKey)) ?? .solid
            case .arrow:
                style = CPDFBorderStyle(rawValue: userDefaults.integer(forKey: CArrowNoteLineStyleKey)) ?? .solid
            case .ink:
                style = CPDFBorderStyle(rawValue: userDefaults.integer(forKey: CInkNoteLineStyleyKey)) ?? .solid
            default:
                break
            }
        }
        return style
    }
    
    func setStyle(_ style: CPDFBorderStyle) {
        if isSelectAnnot {
            for annotation in annotations {
                let oldBorder = annotation.border
                var dashPattern: [CGFloat] = []
                if style == .dashed {
                    dashPattern.append(5)
                }
                let border = CPDFBorder(style: style, lineWidth: oldBorder?.lineWidth ?? 0, dashPattern: dashPattern)
                annotation.border = border
                
            }
        } else {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .freeText:
                userDefaults.set(style.rawValue, forKey: CFreeTextNoteLineStyleKey)
            case .circle:
                userDefaults.set(style.rawValue, forKey: CCircleNoteLineStyleKey)
            case .square:
                userDefaults.set(style.rawValue, forKey: CSquareNoteLineStyleKey)
            case .line:
                userDefaults.set(style.rawValue, forKey: CLineNoteLineStyleKey)
            case .arrow:
                userDefaults.set(style.rawValue, forKey: CArrowNoteLineStyleKey)
            case .ink:
                userDefaults.set(style.rawValue, forKey: CInkNoteLineStyleyKey)
            default:
                break
            }
            userDefaults.synchronize()
        }
    }
    
    var dashPattern: [NSNumber] {
        if isSelectAnnot {
            if annotation?.border.style == .dashed {
                return annotation?.border.dashPattern as? [NSNumber] ?? [0]
            } else {
                return [0]
            }
        } else {
            let userDefaults = UserDefaults.standard
            var dashPattern = 0
            switch annotMode {
            case .freeText:
                dashPattern = userDefaults.integer(forKey: CFreeTextNoteDashPatternKey)
            case .circle:
                dashPattern = UserDefaults.standard.integer(forKey: CCircleNoteDashPatternKey)
            case .square: dashPattern = UserDefaults.standard.integer(forKey: CSquareNoteDashPatternKey)
            case .line: dashPattern = UserDefaults.standard.integer(forKey: CLineNoteDashPatternKey)
            case .arrow: dashPattern = UserDefaults.standard.integer(forKey: CArrowNoteDashPatternKey)
            case .ink: dashPattern = UserDefaults.standard.integer(forKey: CInkNoteDashPatternKey)
            default: break
                
            }
            if self.style != .dashed {
                dashPattern = 0
            }
            return [dashPattern] as [NSNumber]
        }
    }
    
    func setDashPattern(_ dashPatterns: [NSNumber]) {
        if self.isSelectAnnot {
            for annotation in self.annotations {
                let oldBorder = annotation.border
                let border = CPDFBorder(style: oldBorder?.style ?? .solid, lineWidth: oldBorder?.lineWidth ?? 0, dashPattern: dashPatterns)
                annotation.border = border
            }
        } else {
            let dashPattern = dashPatterns.first?.intValue ?? 0
            let userDefaults = UserDefaults.standard
            switch self.annotMode {
            case .freeText:
                userDefaults.set(dashPattern, forKey: CFreeTextNoteDashPatternKey)
            case .circle:
                userDefaults.set(dashPattern, forKey: CCircleNoteDashPatternKey )
            case .square:
                userDefaults.set(dashPattern, forKey:  CSquareNoteDashPatternKey )
            case .line:
                userDefaults.set(dashPattern, forKey:  CLineNoteDashPatternKey )
            case .arrow:
                userDefaults.set(dashPattern, forKey:  CArrowNoteDashPatternKey )
            case .ink:
                userDefaults.set(dashPattern, forKey:  CInkNoteDashPatternKey )
            default:
                break
            }
            userDefaults.synchronize()
        }
    }
    
    var lineWidth: CGFloat {
        var zLineWidth: CGFloat = 0
        if self.isSelectAnnot {
            zLineWidth = self.annotation?.lineWidth ?? 0
        } else {
            let userDefaults = UserDefaults.standard
            switch self.annotMode {
            case .circle:
                zLineWidth = CGFloat(userDefaults.float(forKey: CCircleNoteLineWidthKey))
            case .square:
                zLineWidth = CGFloat(userDefaults.float(forKey: CSquareNoteLineWidthKey ))
            case .line:
                zLineWidth = CGFloat(userDefaults.float(forKey: CLineNoteLineWidthKey ))
            case .arrow:
                zLineWidth = CGFloat(userDefaults.float(forKey: CArrowNoteLineWidthKey ))
            case .ink:
                zLineWidth = CPDFKitConfig.sharedInstance().freehandAnnotationBorderWidth()
            default:
                break
            }
        }
        return zLineWidth
    }
    
    func setLineWidth(_ lineWidth: CGFloat) {
        if self.isSelectAnnot {
            for annotation in self.annotations {
                annotation.borderWidth = lineWidth
            }
        } else {
            let userDefaults = UserDefaults.standard
            switch self.annotMode {
            case .circle:
                userDefaults.set(Float(lineWidth), forKey: CCircleNoteLineWidthKey )
            case .square:
                userDefaults.set(Float(lineWidth), forKey: CSquareNoteLineWidthKey )
            case .line:
                userDefaults.set(Float(lineWidth), forKey: CLineNoteLineWidthKey )
            case .arrow:
                userDefaults.set(Float(lineWidth), forKey: CArrowNoteLineWidthKey )
            case .ink:
                CPDFKitConfig.sharedInstance().setFreehandAnnotationBorderWidth(lineWidth)
                userDefaults.set(Float(lineWidth), forKey: CInkNoteLineWidthKey )
            default:
                break
            }
            userDefaults.synchronize()
        }
    }
    var startLineStyle: CPDFLineStyle {
        var zstartLineStyle: CPDFLineStyle = .none
        if self.isSelectAnnot {
            if let lineAnnotation = self.annotation as? CPDFLineAnnotation {
                zstartLineStyle = lineAnnotation.startLineStyle
            }
        } else {
            let userDefaults = UserDefaults.standard
            switch self.annotMode {
            case .arrow:
                zstartLineStyle = CPDFLineStyle(rawValue: userDefaults.integer(forKey: CArrowNoteStartStyleKey)) ?? .none
            case .line:
                zstartLineStyle = CPDFLineStyle(rawValue: userDefaults.integer(forKey: CLineNoteStartStyleKey)) ?? .none
            default:
                break
            }
        }
        return zstartLineStyle
    }
    
    func setStartLineStyle(_ startLineStyle: CPDFLineStyle) {
        if self.isSelectAnnot {
            for annotation in self.annotations {
                if let lineAnnotation = annotation as? CPDFLineAnnotation {
                    lineAnnotation.startLineStyle = startLineStyle
                }
            }
        } else {
            let userDefaults = UserDefaults.standard
            switch self.annotMode {
            case .arrow:
                userDefaults.set(startLineStyle.rawValue, forKey: CArrowNoteStartStyleKey)
            case .line:
                userDefaults.set(startLineStyle.rawValue, forKey: CLineNoteStartStyleKey)
            default:
                break
            }
            userDefaults.synchronize()
        }
    }
    var endLineStyle: CPDFLineStyle {
        var zendLineStyle: CPDFLineStyle = .none
        if self.isSelectAnnot {
            if let lineAnnotation = self.annotation as? CPDFLineAnnotation {
                zendLineStyle = lineAnnotation.endLineStyle
            }
        } else {
            let userDefaults = UserDefaults.standard
            switch self.annotMode {
            case .arrow:
                zendLineStyle = CPDFLineStyle(rawValue: userDefaults.integer(forKey: CArrowNoteEndStyleKey)) ?? .none
            case .line:
                zendLineStyle = CPDFLineStyle(rawValue: userDefaults.integer(forKey: CLineNoteEndStyleKey)) ?? .none
            default:
                break
            }
        }
        return zendLineStyle
    }
    
    func setEndLineStyle(_ endLineStyle: CPDFLineStyle) {
        if self.isSelectAnnot {
            for annotation in self.annotations {
                if let lineAnnotation = annotation as? CPDFLineAnnotation {
                    lineAnnotation.endLineStyle = endLineStyle
                }
            }
        } else {
            let userDefaults = UserDefaults.standard
            switch self.annotMode {
            case .arrow:
                userDefaults.set(endLineStyle.rawValue, forKey: CArrowNoteEndStyleKey)
            case .line:
                userDefaults.set(endLineStyle.rawValue, forKey: CLineNoteEndStyleKey)
            default:
                break
            }
            userDefaults.synchronize()
        }
    }
    
    // MARK: - FreeText
    var fontColor: UIColor? {
        
        var zfontColor: UIColor? = nil
        if self.isSelectAnnot {
            if let freeTextAnnotation = self.annotation as? CPDFFreeTextAnnotation {
                zfontColor = freeTextAnnotation.fontColor
            }
        } else {
            let userDefaults = UserDefaults.standard
            switch self.annotMode {
            case .freeText:
                zfontColor = userDefaults.PDFListViewColorForKey(CFreeTextNoteFontColorKey)
            default:
                break
            }
        }
        return zfontColor
    }
    
    func setFontColor(_ fontColor: UIColor?) {
        if self.isSelectAnnot {
            for annotation in self.annotations {
                if let freeTextAnnotation = annotation as? CPDFFreeTextAnnotation {
                    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
                    fontColor?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                    freeTextAnnotation.fontColor = UIColor(red: red, green: green, blue: blue, alpha: self.opacity)
                }
            }
        } else {
            let userDefaults = UserDefaults.standard
            switch self.annotMode {
            case .freeText:
                userDefaults.setPDFListViewColor(fontColor, forKey: CFreeTextNoteFontColorKey)
            default:
                break
            }
            userDefaults.synchronize()
        }
    }
    var fontSize: CGFloat {
        var zfontSize: CGFloat = 11
        if self.isSelectAnnot {
            if let freeTextAnnotation = self.annotation as? CPDFFreeTextAnnotation {
                zfontSize = freeTextAnnotation.fontSize
            }
        } else {
            let userDefaults = UserDefaults.standard
            switch self.annotMode {
            case .freeText:
                zfontSize = CGFloat(userDefaults.float(forKey: CFreeTextNoteFontSizeKey))
            default:
                break
            }
        }
        return zfontSize
    }
    
    func setFontSize(_ fontSize: CGFloat) {
        if self.isSelectAnnot {
            for annotation in self.annotations {
                if let freeTextAnnotation = annotation as? CPDFFreeTextAnnotation {
                    let cFont = freeTextAnnotation.cFont
                    freeTextAnnotation.fontSize = fontSize
                    
                    let appleFont = UIFont.init(name: CPDFFont.convertAppleFont(cFont ?? CPDFFont(familyName: "Helvetica", fontStyle: "")) ?? "Helvetica", size: fontSize)
                    let attributes: [NSAttributedString.Key: Any] = [.font: appleFont ?? UIFont.systemFont(ofSize: 11.0)]
                    let bounds = annotation.bounds
                    
                    let rect = freeTextAnnotation.contents.boundingRect(with: CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
                    var newBounds = bounds
                    newBounds.origin.y = bounds.maxY - rect.size.height
                    newBounds.size.height = rect.size.height + 6
                    
                    annotation.bounds = newBounds

                }
            }
        } else {
            let userDefaults = UserDefaults.standard
            switch self.annotMode {
            case .freeText:
                userDefaults.set(Float(fontSize), forKey: CFreeTextNoteFontSizeKey)
            default:
                break
            }
            userDefaults.synchronize()
        }
    }
    
    var newCFont: CPDFFont {
        var cfont: CPDFFont = CPDFFont.init(familyName: "Helvetica", fontStyle: "")

        if self.isSelectAnnot {
            if let freeTextAnnotation = self.annotation as? CPDFFreeTextAnnotation {
                cfont = freeTextAnnotation.cFont
            }
        } else {
            let userDefaults = UserDefaults.standard
            switch self.annotMode {
            case .freeText:
               let zfontName = userDefaults.string(forKey: CFreeTextNoteFontFamilyNameKey)
               let zfontStyle = userDefaults.string(forKey: CFreeTextNoteFontNewStyleKey)
                cfont = CPDFFont.init(familyName: zfontName ?? "Helvetica", fontStyle: zfontStyle ?? "")
                break
            default:
                break
            }
        }
        return cfont
    }
    
    func setNewCFont(_ font: CPDFFont) {
        if self.isSelectAnnot {
            for annotation in self.annotations {
                if let freeTextAnnotation = annotation as? CPDFFreeTextAnnotation {
                    freeTextAnnotation.cFont = font
                }
            }
        } else {
            let userDefaults = UserDefaults.standard
            switch self.annotMode {
            case .freeText:
                let styleName = font.styleName
                let familyName = font.familyName
                if styleName?.count != 0 {
                    userDefaults.set(styleName, forKey: CFreeTextNoteFontNewStyleKey)
                } else {
                    userDefaults.set("", forKey: CFreeTextNoteFontNewStyleKey)
                }
                
                if familyName.count != 0 {
                    userDefaults.set(familyName, forKey: CFreeTextNoteFontFamilyNameKey)
                } else {
                    userDefaults.set("Helvetica", forKey: CFreeTextNoteFontNewStyleKey)
                }

                break
            default:
                break
            }
            userDefaults.synchronize()
        }
    }
    
    var alignment: NSTextAlignment {
        
        var zalignment: NSTextAlignment = .left
        if self.isSelectAnnot {
            if let freeTextAnnotation = self.annotation as? CPDFFreeTextAnnotation {
                zalignment = freeTextAnnotation.alignment
            }
        } else {
            let userDefaults = UserDefaults.standard
            switch self.annotMode {
            case .freeText:
                zalignment = NSTextAlignment(rawValue: userDefaults.integer(forKey: CFreeTextNoteAlignmentKey)) ?? .left
            default:
                break
            }
        }
        return zalignment
    }
    func setAlignment(_ alignment: NSTextAlignment) {
        if self.isSelectAnnot {
            for annotation in self.annotations {
                if let freeTextAnnotation = annotation as? CPDFFreeTextAnnotation {
                    freeTextAnnotation.alignment = alignment
                }
            }
        } else {
            let userDefaults = UserDefaults.standard
            switch self.annotMode {
            case .freeText:
                userDefaults.set(alignment.rawValue, forKey: CFreeTextNoteAlignmentKey)
            default:
                break
            }
            userDefaults.synchronize()
        }
    }
    
    // MARK: - Circle&Square
    var interiorColor: UIColor? {
        
        var zinteriorColor: UIColor? = nil
        if self.isSelectAnnot {
            if(self.annotation is CPDFCircleAnnotation ) {
                guard let circleAnnotation = self.annotation as? CPDFCircleAnnotation else {
                    return UIColor.clear
                }

                zinteriorColor = circleAnnotation.interiorColor
            } else if (self.annotation is CPDFSquareAnnotation) {
                let squareAnnotation:CPDFSquareAnnotation = self.annotation as! CPDFSquareAnnotation
                zinteriorColor = squareAnnotation.interiorColor
            } else if let freeTextAnnotation = self.annotation as? CPDFFreeTextAnnotation {
                zinteriorColor = freeTextAnnotation.color
            }
        } else {
            let userDefaults = UserDefaults.standard
            switch self.annotMode {
            case .circle:
                zinteriorColor = userDefaults.PDFListViewColorForKey(CCircleNoteInteriorColorKey)
            case .square:
                zinteriorColor = userDefaults.PDFListViewColorForKey( CSquareNoteInteriorColorKey)
            default:
                break
            }
        }
        return zinteriorColor
    }
    
    func setInteriorColor(_ interiorColor: UIColor?) {
        if self.isSelectAnnot {
            for annotation in self.annotations {
                if let circleAnnotation = annotation as? CPDFCircleAnnotation {
                    circleAnnotation.interiorColor = interiorColor
                } else if let squareAnnotation = annotation as? CPDFSquareAnnotation {
                    squareAnnotation.interiorColor = interiorColor
                } else if let freeTextAnnotation = annotation as? CPDFFreeTextAnnotation {
                    freeTextAnnotation.color = interiorColor
                }
            }
        } else {
            let userDefaults = UserDefaults.standard
            switch self.annotMode {
            case .circle:
                userDefaults.setPDFListViewColor(interiorColor, forKey: CCircleNoteInteriorColorKey)
            case .square:
                userDefaults.setPDFListViewColor(interiorColor, forKey: CSquareNoteInteriorColorKey)
            default:
                break
            }
        }
    }
    var interiorOpacity: CGFloat {
        var zinteriorOpacity: CGFloat = 0
        if self.isSelectAnnot {
            if let circleAnnotation = annotation as? CPDFCircleAnnotation {
                zinteriorOpacity = circleAnnotation.interiorOpacity
            } else if let squareAnnotation = annotation as? CPDFSquareAnnotation {
                zinteriorOpacity = squareAnnotation.interiorOpacity
            } else {
                zinteriorOpacity = self.annotation?.opacity ?? 1.0
            }
        } else {
            let userDefaults = UserDefaults.standard
            switch self.annotMode {
            case .circle:
                zinteriorOpacity = CGFloat(userDefaults.float(forKey: CCircleNoteInteriorOpacityKey))
            case .square:
                zinteriorOpacity = CGFloat(userDefaults.float(forKey: CSquareNoteInteriorOpacityKey))
            default:
                break
            }
        }
        return zinteriorOpacity
    }
    
    func setInteriorOpacity(_ interiorOpacity: CGFloat) {
        if self.isSelectAnnot {
            for annotation in self.annotations {
                if let circleAnnotation = annotation as? CPDFCircleAnnotation {
                    circleAnnotation.interiorOpacity = interiorOpacity
                } else if let squareAnnotation = annotation as? CPDFSquareAnnotation {
                    squareAnnotation.interiorOpacity = interiorOpacity
                } else {
                    annotation.opacity = interiorOpacity
                }
            }
        } else {
            let userDefaults = UserDefaults.standard
            switch self.annotMode {
            case .circle:
                userDefaults.set(Float(interiorOpacity), forKey: CCircleNoteInteriorOpacityKey)
            case .square:
                userDefaults.set(Float(interiorOpacity), forKey: CSquareNoteInteriorOpacityKey)
            default:
                break
            }
            userDefaults.synchronize()
        }
    }
    
}

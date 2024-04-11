//
//  CAnnotationManage.swift
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

public class CAnnotationManage: NSObject {
    
    public var pdfListView:CPDFListView?
    public var annotation:CPDFAnnotation?
    public var annotStyle:CAnnotStyle?
    
    public init(pdfListView: CPDFListView) {
        self.pdfListView = pdfListView
        super.init()
    }
    
    public func setAnnotStyle(from annotations: [CPDFAnnotation]) {
        annotStyle = CAnnotStyle(annotionMode: .CPDFViewAnnotationModenone, annotations: annotations)
    }
    
    public func refreshPage(with annotations: [CPDFAnnotation]) {
        var pages = [CPDFPage]()
        for annotation in annotations {
            if annotation.page != nil {
                let page:CPDFPage = annotation.page!
                if !pages.contains(page) {
                    pages.append(page)
                }
            }
        }
        for page in pages {
            self.pdfListView?.setNeedsDisplayFor(page)
        }
    }
    
    public func setAnnotStyle(from annotationMode: CPDFViewAnnotationMode) {
        self.annotStyle = CAnnotStyle(annotionMode: annotationMode, annotations: [])
    }
    
    static func highlightAnnotationColor() -> UIColor? {
        let annotStyle = CAnnotStyle(annotionMode: .highlight, annotations: [])
        let colorComponents = annotStyle.color?.cgColor.components ?? [0, 0, 0, 0]
        let red = CGFloat(colorComponents[0])
        let green = CGFloat(colorComponents[1])
        let blue = CGFloat(colorComponents[2])
        let alpha = annotStyle.opacity
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    static func underlineAnnotationColor() -> UIColor? {
        let annotStyle = CAnnotStyle(annotionMode: .underline, annotations: [])
        let colorComponents = annotStyle.color?.cgColor.components ?? [0, 0, 0, 0]
        let red = CGFloat(colorComponents[0])
        let green = CGFloat(colorComponents[1])
        let blue = CGFloat(colorComponents[2])
        let alpha = annotStyle.opacity
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    static func strikeoutAnnotationColor() -> UIColor? {
        let annotStyle = CAnnotStyle(annotionMode: .strikeout, annotations: [])
        let colorComponents = annotStyle.color?.cgColor.components ?? [0, 0, 0, 0]
        let red = CGFloat(colorComponents[0])
        let green = CGFloat(colorComponents[1])
        let blue = CGFloat(colorComponents[2])
        let alpha = annotStyle.opacity
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    static func squigglyAnnotationColor() -> UIColor? {
        let annotStyle = CAnnotStyle(annotionMode: .squiggly, annotations: [])
        let colorComponents = annotStyle.color?.cgColor.components ?? [0, 0, 0, 0]
        let red = CGFloat(colorComponents[0])
        let green = CGFloat(colorComponents[1])
        let blue = CGFloat(colorComponents[2])
        let alpha = annotStyle.opacity
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    static func freehandAnnotationColor() -> UIColor? {
        let annotStyle = CAnnotStyle(annotionMode: .ink, annotations: [])
        let colorComponents = annotStyle.color?.cgColor.components ?? [0, 0, 0, 0]
        let red = CGFloat(colorComponents[0])
        let green = CGFloat(colorComponents[1])
        let blue = CGFloat(colorComponents[2])
        let alpha = annotStyle.opacity
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
}

//
//  CPDFAnnotation+PDFListView.swift
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import ComPDFKit

extension CPDFAnnotation {
    @objc func keysForValuesToObserveForUndo() -> Set<String> {
        let keys: Set<String> = [CPDFAnnotationBoundsKey,
                                 CPDFAnnotationborderWidthKey,
                                 CPDFAnnotationBorderKey,
                                 CPDFAnnotationOpacityKey,
                                 CPDFAnnotationColorKey]
        return keys
    }
    
    func borderStyle() -> CPDFBorderStyle {
        return self.border.style
    }
    
    func setBorderStyle(_ style: CPDFBorderStyle) {
        let oldBorder = self.border
        var dashPattern: [CGFloat] = []
        if style == .dashed {
            dashPattern.append(5)
        }
        let border = CPDFBorder(style: style, lineWidth: oldBorder?.lineWidth ?? 0, dashPattern: dashPattern)
        self.border = border
    }

    var lineWidth: CGFloat {
        return self.borderWidth
    }

    func setLineWidth(_ width: CGFloat) {
        let oldBorder = self.border
        let border = CPDFBorder(style: oldBorder?.style ?? .solid, lineWidth: width, dashPattern: oldBorder?.dashPattern ?? [])
        self.border = border
    }

    var dashPattern: [ Any] {
        return self.border.dashPattern
    }

    func setDashPattern(_ pattern: [CGFloat]) {
        let oldBorder = self.border
        let border = CPDFBorder(style: oldBorder?.style ?? .solid, lineWidth: oldBorder?.lineWidth ?? 0, dashPattern: pattern)
        self.border = border
    }

}

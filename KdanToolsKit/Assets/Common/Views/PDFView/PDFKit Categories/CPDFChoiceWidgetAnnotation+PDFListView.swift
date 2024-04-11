//
//  CPDFChoiceWidgetAnnotation+PDFListView.swift
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

extension CPDFChoiceWidgetAnnotation {
    @objc internal override func keysForValuesToObserveForUndo() -> Set<String> {
        let keys: Set<String> = [CPDFAnnotationBoundsKey,
                                 CPDFAnnotationborderWidthKey,
                                 CPDFAnnotationBorderKey,
                                 CPDFAnnotationOpacityKey,
                                 CPDFAnnotationColorKey,
                                 CPDFAnnotationFontKey,
                                 CPDFAnnotationFontSizeKey,
                                 CPDFAnnotationFontColorKey,
                                 CPDFAnnotationBorderColorKey,
                                 CPDFAnnotationBackgroundColorKey,
                                 CPDFAnnotationSelectItemAtIndexKey,
                                 CPDFAnnotationWidgetItemsKey]
        return keys
    }
}

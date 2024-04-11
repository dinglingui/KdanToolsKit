//
//  CPDFSignatureWidgetAnnotation+PDFListView.swift
//  PDFViewer-Swift
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import ComPDFKit

extension CPDFSignatureWidgetAnnotation {
    func appearanceImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
        if let imageContext = UIGraphicsGetCurrentContext() {
            imageContext.translateBy(x: -self.bounds.origin.x, y: -self.bounds.origin.y)
            self.draw(with: .mediaBox, in: imageContext)
            if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
                
                return newImage
            }
        }
        return nil
    }
}

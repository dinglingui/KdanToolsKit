//
//  CWatermarkModel.swift
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

public class CWatermarkModel: NSObject {
    var text: String?
    var textColor: UIColor?
    var fontName: String?
    var fontStyleName: String = ""
    var watermarkOpacity: CGFloat = 1.0
    var watermarkScale: CGFloat = 1.0
    var isTile: Bool = false
    var isFront: Bool = true
    var pageString: String?
    var tx: CGFloat = 0.0
    var ty: CGFloat = 0.0
    var watermarkRotation: CGFloat = 0.0
    var image: UIImage?
    var verticalSpacing: CGFloat = 0.0
    var horizontalSpacing: CGFloat = 0.0
    var fileURL: URL?
}

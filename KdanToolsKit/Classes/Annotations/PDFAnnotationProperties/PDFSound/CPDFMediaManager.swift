//
//  CPDFMediaManager.swift
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

public enum CPDFMediaState: Int {
    case stop = 0
    case readyRecord
    case audioRecord
    case videoPlaying
}

public class CPDFMediaManager: NSObject {
    public static let sharedManager = CPDFMediaManager()
    
    public var mediaState: CPDFMediaState = .stop
    public var pageNum: Int = 0
    public var ptInPdf: CGPoint = CGPoint.zero
    
}

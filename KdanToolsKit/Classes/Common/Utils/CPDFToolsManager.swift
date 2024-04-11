//
//  CPDFToolsManager.swift
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

public class CPDFToolsManager: NSObject {
    
    public var compdfkitFonts: [CPDFFont] = []

    static let defaultManager: CPDFToolsManager = {
        let singleton = CPDFToolsManager()
        return singleton
    }()
    
    private override init() {
        for familyName in CPDFFont.familyNames {
            let styles:[String] = CPDFFont.fontNames(forFamilyName: familyName)
            for style in styles {
                var cFont: CPDFFont = CPDFFont(familyName: "Helvetica", fontStyle: "")
                if style.isEmpty {
                    cFont = CPDFFont(familyName: familyName, fontStyle:"")
                } else {
                    cFont = CPDFFont(familyName: familyName, fontStyle:style)
                }
                compdfkitFonts.append(cFont)
            }
        }
        
    }
    
}

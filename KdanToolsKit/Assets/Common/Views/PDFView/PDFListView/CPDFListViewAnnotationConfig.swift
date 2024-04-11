//
//  CPDFListViewAnnotationConfig.swift
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

class CPDFListViewAnnotationConfig: NSObject {

    class func initializeAnnotationConfig() {
        guard let initialUserDefaultsURL = Bundle(for: self).url(forResource: "AnnotationUserDefaults", withExtension: "plist"),
              let initialUserDefaultsDict = NSDictionary(contentsOf: initialUserDefaultsURL),
              let initialValuesDict = initialUserDefaultsDict["RegisteredDefaults"] as? [String: Any] else {
            return
        }
        
        if UserDefaults.standard.float(forKey: "CInkNoteLineWidth") == 0.0 {
            CPDFKitConfig.sharedInstance().setFreehandAnnotationBorderWidth(10.0)
        }
        
        // Set the initial values in the standard user defaults
        UserDefaults.standard.register(defaults: initialValuesDict)
    }
    
}

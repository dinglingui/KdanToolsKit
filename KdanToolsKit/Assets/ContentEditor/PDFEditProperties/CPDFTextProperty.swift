//
//  CPDFTextProperty.swift
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

public class CPDFTextProperty: NSObject {
    
    public override init() {
        super.init()
    }

    public static let shared = CPDFTextProperty()
    
    public var fontColor: UIColor? {
         get {
             let userDefaults = UserDefaults.standard
             if (userDefaults.object(forKey: CPDFContentEditTextCreateFontColorKey) != nil) {
                 return userDefaults.PDFListViewColorForKey(CPDFContentEditTextCreateFontColorKey) ?? UIColor.black
             } else {
                 return UIColor.black
             }
         }
         set {
             let userDefaults = UserDefaults.standard
             if(newValue != nil) {
                 userDefaults.setPDFListViewColor(newValue, forKey: CPDFContentEditTextCreateFontColorKey)
             }
             userDefaults.synchronize()
         }
     }
    
    public var textOpacity: CGFloat {
         get {
             let userDefaults = UserDefaults.standard
             if userDefaults.bool(forKey: CPDFContentEditTextCreateFontOpacityKey) {
                 return CGFloat(userDefaults.float(forKey: CPDFContentEditTextCreateFontOpacityKey))
             } else {
                 return 1
             }
         }
         set {
             let userDefaults = UserDefaults.standard
             userDefaults.set(Float(newValue), forKey: CPDFContentEditTextCreateFontOpacityKey)

             userDefaults.synchronize()
         }
     }
    
    public var fontNewFamilyName: String {
         get {
             let userDefaults = UserDefaults.standard
             if (userDefaults.object(forKey: CPDFContentEditTextCreateFontNewNameKey) != nil) {
                 return (userDefaults.object(forKey: CPDFContentEditTextCreateFontNewNameKey) ?? "Helvetica") as! String
             } else {
                 return "Helvetica"
             }
         }
         set {
             let userDefaults = UserDefaults.standard
             userDefaults.set(newValue, forKey: CPDFContentEditTextCreateFontNewNameKey)
             
             userDefaults.synchronize()

         }
     }
    
    public var fontNewStyle: String {
         get {
             let userDefaults = UserDefaults.standard
             if (userDefaults.object(forKey: CPDFContentEditTextCreateFontNewStyleKey) != nil) {
                 return (userDefaults.object(forKey: CPDFContentEditTextCreateFontNewStyleKey) ?? "") as! String
             } else {
                 return ""
             }
         }
         set {
             let userDefaults = UserDefaults.standard
             userDefaults.set(newValue, forKey: CPDFContentEditTextCreateFontNewStyleKey)
             
             userDefaults.synchronize()

         }
     }
    
    public var fontSize: CGFloat  {
         get {
             let userDefaults = UserDefaults.standard
             if userDefaults.bool(forKey: CPDFContentEditTextCreateFontSizeKey) {
                 return CGFloat(userDefaults.float(forKey: CPDFContentEditTextCreateFontSizeKey))
             } else {
                 return 12
             }
         }
         set {
             let userDefaults = UserDefaults.standard
             userDefaults.set(Float(newValue), forKey: CPDFContentEditTextCreateFontSizeKey)

             userDefaults.synchronize()
         }
     }

    public var textAlignment: NSTextAlignment  {
         get {
             let userDefaults = UserDefaults.standard
             if userDefaults.bool(forKey: CPDFContentEditTextCreateFontAlignmentKey) {
                 return NSTextAlignment(rawValue: userDefaults.integer(forKey: CPDFContentEditTextCreateFontAlignmentKey)) ?? .center
             } else {
                 return .left
             }
         }
         set {
             let userDefaults = UserDefaults.standard
             userDefaults.set(newValue.rawValue, forKey: CPDFContentEditTextCreateFontAlignmentKey)
             userDefaults.synchronize()
         }
     }


}

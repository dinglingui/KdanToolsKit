//
//  CFormStyle.swift
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

public class CFormStyle: NSObject {
    
    var annotMode:CPDFViewAnnotationMode = .CPDFViewAnnotationModenone
    
    public init(formMode: CPDFViewAnnotationMode) {
        super.init()
        
        annotMode = formMode
    }
    
    // MARK: - Common
    var color: UIColor? {
        get {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeText:
                if (userDefaults.object(forKey: CTextFieldColorKey) != nil) {
                    return userDefaults.PDFListViewColorForKey(CTextFieldColorKey) ?? UIColor.black
                } else {
                    return UIColor.black
                }
            case .formModeCheckBox:
                if (userDefaults.object(forKey: CCheckBoxColorKey) != nil) {
                    return userDefaults.PDFListViewColorForKey(CCheckBoxColorKey) ?? UIColor.black
                } else {
                    return UIColor.black
                }
            case .formModeRadioButton:
                if (userDefaults.object(forKey: CRadioButtonColorKey) != nil) {
                    return userDefaults.PDFListViewColorForKey(CRadioButtonColorKey) ?? UIColor.black
                } else {
                    return UIColor.black
                }
            case .formModeCombox:
                if (userDefaults.object(forKey: CComboBoxColorKey) != nil) {
                    return userDefaults.PDFListViewColorForKey(CComboBoxColorKey) ?? UIColor.black
                } else {
                    return UIColor.black
                }
            case .formModeList:
                if (userDefaults.object(forKey: CListBoxColorKey) != nil) {
                    return userDefaults.PDFListViewColorForKey(CListBoxColorKey) ?? UIColor.black
                } else {
                    return UIColor.black
                }
            case .formModeButton:
                if (userDefaults.object(forKey: CPushButtonColorKey) != nil) {
                    return userDefaults.PDFListViewColorForKey(CPushButtonColorKey) ?? UIColor.black
                } else {
                    return UIColor.black
                }
            case .formModeSign:
                if (userDefaults.object(forKey: CSignaturesFieldsColorKey) != nil) {
                    return userDefaults.PDFListViewColorForKey(CSignaturesFieldsColorKey) ?? UIColor.black
                } else {
                    return UIColor.black
                }
            default:
                return nil
            }
        }
        set {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeText:
                userDefaults.setPDFListViewColor(newValue, forKey: CTextFieldColorKey)
            case .formModeCheckBox:
                userDefaults.setPDFListViewColor(newValue, forKey: CCheckBoxColorKey)
            case .formModeRadioButton:
                userDefaults.setPDFListViewColor(newValue, forKey: CRadioButtonColorKey)
            case .formModeCombox:
                userDefaults.setPDFListViewColor(newValue, forKey: CComboBoxColorKey)
            case .formModeList:
                userDefaults.setPDFListViewColor(newValue, forKey: CListBoxColorKey)
            case .formModeButton:
                userDefaults.setPDFListViewColor(newValue, forKey: CPushButtonColorKey)
            case .formModeSign:
                userDefaults.setPDFListViewColor(newValue, forKey: CSignaturesFieldsColorKey)
            default:
                break
            }
            userDefaults.synchronize()
        }
    }
    
    var interiorColor: UIColor? {
        get {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeText:
                if (userDefaults.object(forKey: CTextFieldInteriorColorKey) != nil) {
                    return userDefaults.PDFListViewColorForKey(CTextFieldInteriorColorKey) ?? UIColor(red: 233.0 / 255.0, green: 234.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
                } else {
                    return UIColor(red: 233.0 / 255.0, green: 234.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
                }
            case .formModeCheckBox:
                if (userDefaults.object(forKey: CCheckBoxInteriorColorKey) != nil) {
                    return userDefaults.PDFListViewColorForKey(CCheckBoxInteriorColorKey) ?? UIColor(red: 233.0 / 255.0, green: 234.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
                } else {
                    return UIColor(red: 233.0 / 255.0, green: 234.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
                }
            case .formModeRadioButton:
                if (userDefaults.object(forKey: CRadioButtonInteriorColorKey) != nil) {
                    return userDefaults.PDFListViewColorForKey(CRadioButtonInteriorColorKey) ?? UIColor(red: 233.0 / 255.0, green: 234.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
                } else {
                    return UIColor(red: 233.0 / 255.0, green: 234.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
                }
            case .formModeCombox:
                if (userDefaults.object(forKey: CComboBoxInteriorColorKey) != nil) {
                    return userDefaults.PDFListViewColorForKey(CComboBoxInteriorColorKey) ?? UIColor(red: 233.0 / 255.0, green: 234.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
                } else {
                    return UIColor(red: 233.0 / 255.0, green: 234.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
                }
            case .formModeList:
                if (userDefaults.object(forKey: CListBoxInteriorColorKey) != nil) {
                    return userDefaults.PDFListViewColorForKey(CListBoxInteriorColorKey) ?? UIColor(red: 233.0 / 255.0, green: 234.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
                } else {
                    return UIColor(red: 233.0 / 255.0, green: 234.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
                }
            case .formModeButton:
                if (userDefaults.object(forKey: CPushButtonInteriorColorKey) != nil) {
                    return userDefaults.PDFListViewColorForKey(CPushButtonInteriorColorKey) ?? UIColor(red: 233.0 / 255.0, green: 234.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
                } else {
                    return UIColor(red: 233.0 / 255.0, green: 234.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
                }
            case .formModeSign:
                if (userDefaults.object(forKey: CSignaturesFieldsInteriorColorKey) != nil) {
                    return userDefaults.PDFListViewColorForKey(CSignaturesFieldsInteriorColorKey) ?? UIColor(red: 233.0 / 255.0, green: 234.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
                } else {
                    return UIColor(red: 233.0 / 255.0, green: 234.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
                }
            default:
                return nil
            }
        }
        set {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeText:
                userDefaults.setPDFListViewColor(newValue, forKey: CTextFieldInteriorColorKey)
            case .formModeCheckBox:
                userDefaults.setPDFListViewColor(newValue, forKey: CCheckBoxInteriorColorKey)
            case .formModeRadioButton:
                userDefaults.setPDFListViewColor(newValue, forKey: CRadioButtonInteriorColorKey)
            case .formModeCombox:
                userDefaults.setPDFListViewColor(newValue, forKey: CComboBoxInteriorColorKey)
            case .formModeList:
                userDefaults.setPDFListViewColor(newValue, forKey: CListBoxInteriorColorKey)
            case .formModeButton:
                userDefaults.setPDFListViewColor(newValue, forKey: CPushButtonInteriorColorKey)
            case .formModeSign:
                userDefaults.setPDFListViewColor(newValue, forKey: CSignaturesFieldsInteriorColorKey)
            default:
                break
            }
            userDefaults.synchronize()
        }
    }
    
    var fontColor: UIColor? {
        get {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeText:
                if (userDefaults.object(forKey: CTextFieldFontColorKey) != nil) {
                    return userDefaults.PDFListViewColorForKey(CTextFieldFontColorKey) ?? UIColor.black
                } else {
                    return UIColor.black
                }
            case .formModeCombox:
                if (userDefaults.object(forKey: CComboBoxFontColorKey) != nil) {
                    return userDefaults.PDFListViewColorForKey(CComboBoxFontColorKey) ?? UIColor.black
                } else {
                    return UIColor.black
                }
            case .formModeList:
                if (userDefaults.object(forKey: CListBoxFontColorKey) != nil) {
                    return userDefaults.PDFListViewColorForKey(CListBoxFontColorKey) ?? UIColor.black
                } else {
                    return UIColor.black
                }
            case .formModeButton:
                if (userDefaults.object(forKey: CPushButtonFontColorKey) != nil) {
                    return userDefaults.PDFListViewColorForKey(CPushButtonFontColorKey) ?? UIColor.black
                } else {
                    return UIColor.black
                }
            default:
                return nil
            }
        }
        set {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeText:
                userDefaults.setPDFListViewColor(newValue, forKey: CTextFieldFontColorKey)
            case .formModeCombox:
                userDefaults.setPDFListViewColor(newValue, forKey: CComboBoxFontColorKey)
            case .formModeList:
                userDefaults.setPDFListViewColor(newValue, forKey: CListBoxFontColorKey)
            case .formModeButton:
                userDefaults.setPDFListViewColor(newValue, forKey: CPushButtonFontColorKey)
            default:
                break
            }
            userDefaults.synchronize()
        }
    }
    
    var checkedColor: UIColor? {
        get {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeCheckBox:
                if (userDefaults.object(forKey: CCheckBoxCheckedColorKey) != nil) {
                    return userDefaults.PDFListViewColorForKey(CCheckBoxCheckedColorKey) ?? UIColor.black
                } else {
                    return UIColor.black
                }
            case .formModeRadioButton:
                if (userDefaults.object(forKey: CRadioButtonCheckedColorKey) != nil) {
                    return userDefaults.PDFListViewColorForKey(CRadioButtonCheckedColorKey) ?? UIColor.black
                } else {
                    return UIColor.black
                }
            default:
                return nil
            }
        }
        set {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeCheckBox:
                userDefaults.setPDFListViewColor(newValue, forKey: CCheckBoxCheckedColorKey)
            case .formModeRadioButton:
                userDefaults.setPDFListViewColor(newValue, forKey: CRadioButtonCheckedColorKey)
            default:
                break
            }
            userDefaults.synchronize()
        }
    }
    
    var lineWidth: CGFloat {
        get {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeText:
                if userDefaults.bool(forKey: CTextFieldLineWidthKey) {
                    return CGFloat(userDefaults.float(forKey: CTextFieldLineWidthKey))
                } else {
                    return 1
                }
            case .formModeCheckBox:
                if userDefaults.bool(forKey: CCheckBoxLineWidthKey) {
                    return CGFloat(userDefaults.float(forKey: CCheckBoxLineWidthKey))
                } else {
                    return 1
                }
            case .formModeRadioButton:
                if userDefaults.bool(forKey: CRadioButtonLineWidthKey) {
                    return CGFloat(userDefaults.float(forKey: CRadioButtonLineWidthKey))
                } else {
                    return 1
                }
            case .formModeCombox:
                if userDefaults.bool(forKey: CComboBoxLineWidthKey) {
                    return CGFloat(userDefaults.float(forKey: CComboBoxLineWidthKey))
                } else {
                    return 1
                }
            case .formModeList:
                if userDefaults.bool(forKey: CListBoxLineWidthKey) {
                    return CGFloat(userDefaults.float(forKey: CListBoxLineWidthKey))
                } else {
                    return 1
                }
            case .formModeButton:
                if userDefaults.bool(forKey: CPushButtonLineWidthKey) {
                    return CGFloat(userDefaults.float(forKey: CPushButtonLineWidthKey))
                } else {
                    return 1
                }
            case .formModeSign:
                if userDefaults.bool(forKey: CSignaturesFieldsLineWidthKey) {
                    return CGFloat(userDefaults.float(forKey: CSignaturesFieldsLineWidthKey))
                } else {
                    return 1
                }
            default:
                return 0
            }
        }
        set {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeText:
                userDefaults.set(Float(newValue), forKey: CTextFieldLineWidthKey)
            case .formModeCheckBox:
                userDefaults.set(Float(newValue), forKey: CCheckBoxLineWidthKey)
            case .formModeRadioButton:
                userDefaults.set(Float(newValue), forKey: CRadioButtonLineWidthKey)
            case .formModeCombox:
                userDefaults.set(Float(newValue), forKey: CComboBoxLineWidthKey)
            case .formModeList:
                userDefaults.set(Float(newValue), forKey: CListBoxLineWidthKey)
            case .formModeButton:
                userDefaults.set(Float(newValue), forKey: CPushButtonLineWidthKey)
            case .formModeSign:
                userDefaults.set(Float(newValue), forKey: CSignaturesFieldsLineWidthKey)
            default:
                break
            }
            
            userDefaults.synchronize()
        }
    }
    
    var fontSize: CGFloat {
        get {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeText:
                if userDefaults.bool(forKey: CTextFieldFontSizeKey) {
                    return CGFloat(userDefaults.float(forKey: CTextFieldFontSizeKey))
                } else {
                    return 20
                }
            case .formModeCombox:
                if userDefaults.bool(forKey: CComboBoxFontSizeKey) {
                    return CGFloat(userDefaults.float(forKey: CComboBoxFontSizeKey))
                } else {
                    return 20
                }
            case .formModeList:
                if userDefaults.bool(forKey: CListBoxFontSizeKey) {
                    return CGFloat(userDefaults.float(forKey: CListBoxFontSizeKey))
                } else {
                    return 20
                }
            case .formModeButton:
                if userDefaults.bool(forKey: CPushButtonFontSizeKey) {
                    return CGFloat(userDefaults.float(forKey: CPushButtonFontSizeKey))
                } else {
                    return 20
                }
            default:
                return 0
            }
        }
        set {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeText:
                userDefaults.set(Float(newValue), forKey: CTextFieldLineWidthKey)
            case .formModeCombox:
                userDefaults.set(Float(newValue), forKey: CComboBoxFontSizeKey)
            case .formModeList:
                userDefaults.set(Float(newValue), forKey: CListBoxFontSizeKey)
            case .formModeButton:
                userDefaults.set(Float(newValue), forKey: CPushButtonFontSizeKey)
            default:
                break
            }
            
            userDefaults.synchronize()
        }
    }
    
    var isBold: Bool {
        get {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeText:
                if userDefaults.bool(forKey: CTextFieldIsBoldKey) {
                    return userDefaults.bool(forKey: CTextFieldIsBoldKey)
                } else {
                    return false
                }
            case .formModeCombox:
                if userDefaults.bool(forKey: CComboBoxIsBoldKey) {
                    return userDefaults.bool(forKey: CComboBoxIsBoldKey)
                } else {
                    return false
                }
            case .formModeList:
                if userDefaults.bool(forKey: CListBoxIsBoldKey) {
                    return userDefaults.bool(forKey: CListBoxIsBoldKey)
                } else {
                    return false
                }
            case .formModeButton:
                if userDefaults.bool(forKey: CPushButtonIsBoldKey) {
                    return userDefaults.bool(forKey: CPushButtonIsBoldKey)
                } else {
                    return false
                }
            default:
                return false
            }
        }
        set {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeText:
                userDefaults.set(newValue, forKey: CTextFieldIsBoldKey)
            case .formModeCombox:
                userDefaults.set(newValue, forKey: CComboBoxIsBoldKey)
            case .formModeList:
                userDefaults.set(newValue, forKey: CListBoxIsBoldKey)
            case .formModeButton:
                userDefaults.set(newValue, forKey: CPushButtonIsBoldKey)
            default:
               break
            }
            userDefaults.synchronize()
        }
    }
    
    var isItalic: Bool {
        get {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeText:
                if userDefaults.bool(forKey: CTextFieldIsItalicKey) {
                    return userDefaults.bool(forKey: CTextFieldIsItalicKey)
                } else {
                    return false
                }
            case .formModeCombox:
                if userDefaults.bool(forKey: CComboBoxIsItalicKey) {
                    return userDefaults.bool(forKey: CComboBoxIsItalicKey)
                } else {
                    return false
                }
            case .formModeList:
                if userDefaults.bool(forKey: CListBoxIsItalicKey) {
                    return userDefaults.bool(forKey: CListBoxIsItalicKey)
                } else {
                    return false
                }
            case .formModeButton:
                if userDefaults.bool(forKey: CPushButtonIsItalicKey) {
                    return userDefaults.bool(forKey: CPushButtonIsItalicKey)
                } else {
                    return false
                }
            default:
                return false
            }
        }
        set {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeText:
                userDefaults.set(newValue, forKey: CTextFieldIsItalicKey)
            case .formModeCombox:
                userDefaults.set(newValue, forKey: CComboBoxIsItalicKey)
            case .formModeList:
                userDefaults.set(newValue, forKey: CListBoxIsItalicKey)
            case .formModeButton:
                userDefaults.set(newValue, forKey: CPushButtonIsItalicKey)
            default:
               break
            }
            userDefaults.synchronize()
        }
    }
    
    var textAlignment: NSTextAlignment  {
        get {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeText:
                if userDefaults.bool(forKey: CTextFieldAlignmentKey) {
                    return NSTextAlignment(rawValue: userDefaults.integer(forKey: CTextFieldAlignmentKey)) ?? .center
                } else {
                    return .left
                }
            default:
                return .left
            }
        }
        set {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeText:
                userDefaults.set(newValue.rawValue, forKey: CTextFieldAlignmentKey)
            default:
               break
            }
            userDefaults.synchronize()
        }
    }
    
    var fontName: NSString? {
        get {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeText:
                if (userDefaults.object(forKey: CTextFieldFontNameKey) != nil) {
                    return userDefaults.object(forKey: CTextFieldFontNameKey) as? NSString
                } else {
                    return "Helvetica"
                }
            case .formModeCombox:
                if (userDefaults.object(forKey: CComboBoxFontNameKey) != nil) {
                    return userDefaults.object(forKey: CComboBoxFontNameKey) as? NSString
                } else {
                    return "Helvetica"
                }
            case .formModeList:
                if (userDefaults.object(forKey: CListBoxFontNameKey) != nil) {
                    return userDefaults.object(forKey: CListBoxFontNameKey) as? NSString
                } else {
                    return "Helvetica"
                }
            case .formModeButton:
                if (userDefaults.object(forKey: CPushButtonFontNameKey) != nil) {
                    return userDefaults.object(forKey: CPushButtonFontNameKey) as? NSString
                } else {
                    return "Helvetica"
                }
            default:
                return ""
            }
        }
        set {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeText:
                if(newValue != nil) {
                    userDefaults.set(newValue, forKey: CTextFieldFontNameKey)
                }
            case .formModeCombox:
                if(newValue != nil) {
                    userDefaults.set(newValue, forKey: CComboBoxFontNameKey)
                }
            case .formModeList:
                if(newValue != nil) {
                    userDefaults.set(newValue, forKey: CListBoxFontNameKey)
                }
            case .formModeButton:
                if(newValue != nil) {
                    userDefaults.set(newValue, forKey: CPushButtonFontNameKey)
                }
            default:
                break
            }
            userDefaults.synchronize()
        }
    }
    
    var isMultiline: Bool {
        get {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeText:
                if userDefaults.bool(forKey: CTextFieldIsMultilineKey) {
                    return userDefaults.bool(forKey: CTextFieldIsMultilineKey)
                } else {
                    return false
                }
            default:
                return false
            }
        }
        set {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeText:
                userDefaults.set(newValue, forKey: CTextFieldIsMultilineKey)
            default:
               break
            }
            userDefaults.synchronize()
        }
    }
    
    var isChecked: Bool {
        get {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeCheckBox:
                if userDefaults.bool(forKey: CCheckBoxIsCheckedKey) {
                    return userDefaults.bool(forKey: CCheckBoxIsCheckedKey)
                } else {
                    return false
                }
            case .formModeRadioButton:
                if userDefaults.bool(forKey: CRadioButtonIsCheckedKey) {
                    return userDefaults.bool(forKey: CRadioButtonIsCheckedKey)
                } else {
                    return false
                }
            default:
                return false
            }
        }
        set {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeCheckBox:
                userDefaults.set(newValue, forKey: CCheckBoxIsCheckedKey)
            case .formModeRadioButton:
                userDefaults.set(newValue, forKey: CRadioButtonIsCheckedKey)
            default:
               break
            }
            userDefaults.synchronize()
        }
    }
    
    var checkedStyle: CPDFWidgetButtonStyle {
        get {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeCheckBox:
                if userDefaults.bool(forKey: CCheckBoxCheckedStyleKey) {
                    return CPDFWidgetButtonStyle(rawValue: userDefaults.integer(forKey: CCheckBoxCheckedStyleKey)) ?? .check
                } else {
                    return .check
                }
            case .formModeRadioButton:
                if userDefaults.bool(forKey: CRadioButtonCheckedStyleKey) {
                    return CPDFWidgetButtonStyle(rawValue: userDefaults.integer(forKey: CRadioButtonCheckedStyleKey)) ?? .circle
                } else {
                    return .circle
                }
            default:
                return .none
            }
        }
        set {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeCheckBox:
                userDefaults.set(newValue, forKey: CCheckBoxCheckedStyleKey)
            case .formModeRadioButton:
                userDefaults.set(newValue, forKey: CRadioButtonCheckedStyleKey)
            default:
               break
            }
            userDefaults.synchronize()
        }
    }
    
    var style: CPDFBorderStyle {
        get {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeSign:
                if userDefaults.bool(forKey: CSignaturesFieldsLineStyleKey) {
                    return CPDFBorderStyle(rawValue: userDefaults.integer(forKey: CSignaturesFieldsLineStyleKey)) ?? .solid
                } else {
                    return .solid
                }
            default:
                return .solid
            }
        }
        set {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .signature:
                userDefaults.set(newValue, forKey: CSignaturesFieldsLineStyleKey)
            default:
               break
            }
            userDefaults.synchronize()
        }
    }
    
    var title: NSString? {
        get {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeButton:
                if (userDefaults.object(forKey: CPushButtonTitleKey) != nil) {
                    return userDefaults.object(forKey: CPushButtonTitleKey) as? NSString
                } else {
                    return "Button"
                }
            default:
                return ""
            }
        }
        set {
            let userDefaults = UserDefaults.standard
            switch annotMode {
            case .formModeButton:
                if(newValue != nil) {
                    userDefaults.set(newValue, forKey: CPushButtonTitleKey)
                }
            default:
                break
            }
            userDefaults.synchronize()
        }
    }
    
}

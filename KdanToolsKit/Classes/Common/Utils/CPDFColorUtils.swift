//
//  CPDFColorUtils.swift
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

public class CPDFColorUtils: NSObject {

    public class func CPDFViewControllerBackgroundColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CPDFViewControllerBackgroundColor", in: Bundle(for: self), compatibleWith: nil)!
        } else {
            return UIColor.white
        }
    }
    
    public class func CAnnotationBarSelectBackgroundColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CAnnotationBarSelectBackgroundColor", in: Bundle(for: self), compatibleWith: nil)!
        } else {
            return UIColor.init(red: 221.0/255.0, green: 233.0/255.0, blue: 1.0, alpha: 1.0)
        }
    }
    
    public class func CAnnotationSampleBackgoundColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CAnnotationSampleBackgoundColor", in: Bundle(for: self), compatibleWith: nil)!
        } else {
            return UIColor.init(red: 250.0/255.0, green: 252.0/255.0, blue: 1.0, alpha: 1.0)
        }
    }
    
    public class func CAnnotationSampleDrawBackgoundColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CAnnotationSampleDrawBackgoundColor", in: Bundle(for: self), compatibleWith: nil)!
        } else {
            return UIColor.white
        }
    }
    
    public class func CAnnotationPropertyViewControllerBackgoundColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CAnnotationPropertyViewControllerBackgoundColor", in: Bundle(for: self), compatibleWith: nil)!
        } else {
            return UIColor.white
        }
    }
    
    public class func CNoteOpenBackgooundColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CNoteOpenBackgooundColor", in: Bundle(for: self), compatibleWith: nil)!
        } else {
            return UIColor.init(red: 255.0/255.0, green: 244.0/255.0, blue: 213.0/255.0, alpha: 1.0)
        }
    }
    
    public class func CAnyReverseBackgooundColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CcommonReverseBackGroundColor", in: Bundle(for: self), compatibleWith: nil)!
        } else {
            return UIColor.black
        }
    }
    
    public class func CTableviewCellSplitColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CTableviewCellSplitColor", in: Bundle(for: self), compatibleWith: nil)!
        } else {
            return UIColor.init(red: 255.0/255.0, green: 244.0/255.0, blue: 213.0/255.0, alpha: 1.0)
        }
    }
    
    public class func CViewBackgroundColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CViewBackgroundColor", in: Bundle(for: self), compatibleWith: nil)!
        } else {
            return UIColor.init(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        }
    }
    
    public class func CPageEditToolbarFontColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CPageEditToolbarFontColor", in: Bundle(for: self), compatibleWith: nil)!
        } else {
            return UIColor.init(red: 61.0/255.0, green: 71.0/255.0, blue: 77.0/255.0, alpha: 1.0)
        }
    }
    
    public class func CAnnotationBarNoSelectBackgroundColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CAnnotationBarNoSelectBackgroundColor", in: Bundle(for: self), compatibleWith: nil)!
        } else {
            return UIColor.init(red: 253.0/255.0, green: 254.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        }
    }
    
    public class func CFormFontColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CFormFontColor", in: Bundle(for: self), compatibleWith: nil)!
        } else {
            return UIColor.black
        }
    }
    
    public class func CPDFKeyboardToolbarColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CPDFKeyboardToolbarColor", in: Bundle(for: self), compatibleWith: nil)!
        } else {
            return UIColor.init(red: 242.0/255.0, green: 243.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        }
    }
    
    public class func CNavBackgroundColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CNavBackgroundColor", in: Bundle(for: self), compatibleWith: nil)!
        } else {
            return UIColor.white
        }
    }
    
    public class func CMessageLabelColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CMessageLabelColor", in: Bundle(for: self), compatibleWith: nil)!
        } else {
            return UIColor.init(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        }
    }
    
    public class func CVerifySignatureBackgroundColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CVerifySignatureBackgroundColor", in: Bundle(for: self), compatibleWith: nil)!
        } else {
            return UIColor.init(red: 221.0/255.0, green: 233.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        }
    }
    
    public class func CContentBackgroundColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CContentBackgroundColor", in: Bundle(for: self), compatibleWith: nil)!
        } else {
            return UIColor.init(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        }
    }
    
}

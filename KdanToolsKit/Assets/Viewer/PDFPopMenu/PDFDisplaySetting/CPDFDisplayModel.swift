//
//  CPDFDisplayModel.swift
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import Foundation
import UIKit

class CPDFDisplayModel: NSObject {
    var image: UIImage?
    var titilName: String?
    var tag: CDisplayPDFType = .singlePage
    init(displayType: CDisplayPDFType) {
       super.init()
       switch displayType {
           case .singlePage:
               image = UIImage(named: "CDisplayImageNameSinglePage", in: Bundle(for: type(of: self)), compatibleWith: nil)
               titilName = NSLocalizedString("Single Page", comment: "")
           case .twoPages:
               image = UIImage(named: "CDisplayImageNameTwoPages", in: Bundle(for: type(of: self)), compatibleWith: nil)
               titilName = NSLocalizedString("Double Page", comment: "")
           case .bookMode:
               image = UIImage(named: "CDisplayImageNameBookMode", in: Bundle(for: type(of: self)), compatibleWith: nil)
               titilName = NSLocalizedString("Book Mode", comment: "")
           case .continuousScroll:
               image = UIImage(named: "CDisplayImageNameContinuousScroll", in: Bundle(for: type(of: self)), compatibleWith: nil)
               titilName = NSLocalizedString("Continuous Scrolling", comment: "")
           case .cropMode:
               image = UIImage(named: "CDisplayImageNameCropMode", in: Bundle(for: type(of: self)), compatibleWith: nil)
               titilName = NSLocalizedString("Crop Mode", comment: "")
           case .verticalScrolling:
               image = UIImage(named: "CDisplayImageNameVerticalScrolling", in: Bundle(for: type(of: self)), compatibleWith: nil)
               titilName = NSLocalizedString("Vertical Scrolling", comment: "")
           case .horizontalScrolling:
               image = UIImage(named: "CDisplayImageNameHorizontalScrolling", in: Bundle(for: type(of: self)), compatibleWith: nil)
               titilName = NSLocalizedString("Horizontal Scrolling", comment: "")
           case .themesLight:
               image = UIImage(named: "CDisplayImageNameThemesLight", in: Bundle(for: type(of: self)), compatibleWith: nil)
               titilName = NSLocalizedString("Light", comment: "")
           case .themesDark:
               image = UIImage(named: "CDisplayImageNameThemesDark", in: Bundle(for: type(of: self)), compatibleWith: nil)
               titilName = NSLocalizedString("Dark", comment: "")
           case .themesSepia:
               image = UIImage(named: "CDisplayImageNameThemesSepia", in: Bundle(for: type(of: self)), compatibleWith: nil)
               titilName = NSLocalizedString("Sepia", comment: "")
           case .themesReseda:
               image = UIImage(named: "CDisplayImageNameThemesReseda", in: Bundle(for: type(of: self)), compatibleWith: nil)
               titilName = NSLocalizedString("Reseda", comment: "")
       }
       tag = displayType
    }

}


//
//  CStampButton.swift
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

class CStampButton: UIView {
    var stampBtn: UIButton?
    var titleLabel: UILabel?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        stampBtn = UIButton()
        stampBtn?.layer.cornerRadius = 20
        stampBtn?.layer.masksToBounds = true
        if stampBtn != nil {
            addSubview(stampBtn!)
        }
        
        titleLabel = UILabel()
        titleLabel?.textColor = UIColor.white
        titleLabel?.backgroundColor = UIColor.clear
        if titleLabel != nil {
            addSubview(titleLabel!)
        }
        
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        stampBtn?.frame = CGRect(x: bounds.size.width - 40, y: 0, width: 40, height: bounds.size.height)
        titleLabel?.frame = CGRect(x: 0, y: 0, width: 120, height: bounds.size.height)
    }
    
}

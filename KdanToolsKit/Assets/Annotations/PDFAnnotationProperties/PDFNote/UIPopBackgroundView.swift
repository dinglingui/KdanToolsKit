//
//  UIPopBackgroundView.swift
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

class UIPopBackgroundView: UIPopoverBackgroundView {
    var fArrowOffset: CGFloat = 0
    var direction: UIPopoverArrowDirection = .any
    
    class func wantsDefaultContentAppearance() -> Bool {
        return false
    }
    
    override class func arrowBase() -> CGFloat {
        return 0
    }
    
    override class func contentViewInsets() -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override class func arrowHeight() -> CGFloat {
        return 0
    }
    
    override var arrowDirection: UIPopoverArrowDirection {
        get {
            return direction
        }
        set {
            direction = newValue
        }
    }
    
    override var arrowOffset: CGFloat {
       get {
           return fArrowOffset
       }
       set {
           fArrowOffset = newValue
       }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        layer.cornerRadius = 3.0
        
        let shadowView = UIView(frame: frame)
        shadowView.backgroundColor = backgroundColor
        addSubview(shadowView)
        shadowView.layer.shadowColor = UIColor(red: 163.0/255.0, green: 163.0/255.0, blue: 163.0/255.0, alpha: 0.5).cgColor
        shadowView.layer.shadowOpacity = 1.0
        shadowView.layer.shadowRadius = 1.0
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 1)
        shadowView.layer.cornerRadius = 3.0
        
        let maskLayer = CALayer()
        maskLayer.frame = shadowView.layer.bounds
        maskLayer.masksToBounds = true
        shadowView.layer.addSublayer(maskLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}

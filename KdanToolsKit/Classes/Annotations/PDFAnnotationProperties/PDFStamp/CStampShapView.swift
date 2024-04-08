//
//  CStampShapView.swift
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

@objc protocol CStampShapViewDelegate: AnyObject {
    @objc optional func stampShapView(_ stampShapView: CStampShapView, tag: Int)
}

class CStampShapView: UIView {
    weak var delegate: CStampShapViewDelegate?
    private var titleLabel: UILabel?
    private var centerButton: UIButton?
    private var leftButton: UIButton?
    private var rightButton: UIButton?
    private var noneButton: UIButton?
    private var shapeView: UIView?
    private var buttonArray: [UIButton] = []
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleLabel = UILabel()
        self.titleLabel?.text = NSLocalizedString("Style", comment: "")
        self.titleLabel?.autoresizingMask = .flexibleRightMargin
        self.titleLabel?.textColor = UIColor.gray
        self.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        if titleLabel != nil {
            self.addSubview(self.titleLabel!)
        }
        self.shapeView = UIView(frame: CGRect(x: 0, y: 30, width: self.bounds.size.width, height: 60))
        if shapeView != nil {
            self.addSubview(self.shapeView!)
        }
        
        self.buttonArray = []
        
        self.centerButton = UIButton()
        self.centerButton?.setImage(UIImage(named: "CPDFStampTextImageCenter", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        self.centerButton?.addTarget(self, action: #selector(buttonItemClicked_select(_:)), for: .touchUpInside)
        self.centerButton?.tag = 0
        self.centerButton?.layer.cornerRadius = 5.0
        self.centerButton?.layer.masksToBounds = true
        if centerButton != nil {
            self.shapeView?.addSubview(self.centerButton!)
            self.buttonArray.append(self.centerButton!)
        }
        
        self.centerButton?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
        
        self.leftButton = UIButton()
        self.leftButton?.setImage(UIImage(named: "CPDFStampTextImageLeft", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        self.leftButton?.addTarget(self, action: #selector(buttonItemClicked_select(_:)), for: .touchUpInside)
        self.leftButton?.tag = 1
        self.leftButton?.layer.cornerRadius = 5.0
        self.leftButton?.layer.masksToBounds = true
        if leftButton != nil {
            self.shapeView?.addSubview(self.leftButton!)
            self.buttonArray.append(self.leftButton!)
        }
        
        self.rightButton = UIButton()
        self.rightButton?.setImage(UIImage(named: "CPDFStampTextImageRight", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        self.rightButton?.addTarget(self, action: #selector(buttonItemClicked_select(_:)), for: .touchUpInside)
        self.rightButton?.tag = 2
        self.rightButton?.layer.cornerRadius = 5.0
        self.rightButton?.layer.masksToBounds = true
        if rightButton != nil {
            self.shapeView?.addSubview(self.rightButton!)
            self.buttonArray.append(self.rightButton!)
        }
        
        self.noneButton = UIButton()
        self.noneButton?.setImage(UIImage(named: "CPDFStampTextImageNone", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        self.noneButton?.addTarget(self, action: #selector(buttonItemClicked_select(_:)), for: .touchUpInside)
        self.noneButton?.tag = 3
        self.noneButton?.layer.cornerRadius = 5.0
        self.noneButton?.layer.masksToBounds = true
        if noneButton != nil {
            self.shapeView?.addSubview(self.noneButton!)
            self.buttonArray.append(self.noneButton!)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel?.frame = CGRect(x: 20, y: 0, width: 50, height: self.bounds.size.height/3)
        self.shapeView?.frame = CGRect(x: 0, y: self.bounds.size.height/3, width: self.bounds.size.width, height: (self.bounds.size.height/3)*2)
        self.centerButton?.frame = CGRect(x: (self.shapeView!.bounds.size.width - (44*4))/5, y: (self.shapeView!.bounds.size.height-44)/2, width: 44, height: 44)
        self.leftButton?.frame = CGRect(x: ((self.shapeView!.bounds.size.width - (44*4))/5)*2 + 44, y: (self.shapeView!.bounds.size.height-44)/2, width: 44, height: 44)
        let withs = (self.shapeView!.bounds.size.width - 44*4)/5
        self.rightButton?.frame = CGRect(x: withs*3 + 44*2, y: (self.shapeView!.bounds.size.height-44)/2, width: 44, height: 44)
        self.noneButton?.frame = CGRect(x: withs*4 + 44*3, y: (self.shapeView!.bounds.size.height-44)/2, width: 44, height: 44)
    }
    
    
    // MARK: - Action
    
    @objc func buttonItemClicked_select(_ button: UIButton) {
        // Handle button click event
        
        for i in 0..<buttonArray.count {
            buttonArray[i].backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        }
        buttonArray[button.tag].backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
        
        delegate?.stampShapView?(self, tag: button.tag)
    }
    
}


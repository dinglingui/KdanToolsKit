//
//  CPDFFontSettingSubView.swift
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

@objc protocol CPDFFontSettingViewDelegate: AnyObject {
    @objc optional func setCPDFFontSettingView(view: CPDFFontSettingSubView, isBold: Bool)
    @objc optional func setCPDFFontSettingView(view: CPDFFontSettingSubView, isItalic: Bool)
    @objc optional func setCPDFFontSettingView(view: CPDFFontSettingSubView, text: String)
    @objc optional func setCPDFFontSettingViewFontSelect(view: CPDFFontSettingSubView)
}

class CPDFFontSettingSubView: UIView {
    weak var delegate: CPDFFontSettingViewDelegate?
    
    var fontNameLabel: UILabel?
    var fontNameSelectLabel: UILabel?
    var isBold: Bool  = false {
        didSet {
            if isBold {
                boldBtn?.backgroundColor = UIColor(red: 221/255, green: 223/255, blue: 255/255, alpha: 1)
            } else {
                boldBtn?.backgroundColor = UIColor.clear
            }
            boldBtn?.isSelected = isBold
        }
    }
    var isItalic: Bool = false {
        didSet {
            if isItalic {
                italicBtn?.backgroundColor = UIColor(red: 221/255, green: 223/255, blue: 255/255, alpha: 1)
            } else {
                italicBtn?.backgroundColor = UIColor.clear
            }
            italicBtn?.isSelected = isItalic
        }
    }
    
    private var boldBtn: UIButton?
    private var italicBtn: UIButton?
    private var fontSelectBtn: UIButton?
    private var dropMenuView: UIView?
    private var splitView: UIView?
    private var styleView: UIView?
    private var dropDownIcon: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        fontNameLabel = UILabel()
        fontNameLabel?.text = NSLocalizedString("Font", comment: "")
        fontNameLabel?.font = UIFont.systemFont(ofSize: 14)
        fontNameLabel?.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        if(fontNameLabel != nil) {
            addSubview(fontNameLabel!)
        }

        fontNameSelectLabel = UILabel()

        italicBtn = UIButton(type: .custom)
        italicBtn?.setImage(UIImage(named: "CPDFEditItalicNormal", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        italicBtn?.setImage(UIImage(named: "CPDFEditItalicHighlight", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .selected)
        italicBtn?.addTarget(self, action: #selector(fontItalicAction(_:)), for: .touchUpInside)

        boldBtn = UIButton(type: .custom)
        boldBtn?.setImage(UIImage(named: "CPDFEditBoldNormal", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        boldBtn?.setImage(UIImage(named: "CPDFEditBoldHighlight", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .selected)
        boldBtn?.addTarget(self, action: #selector(fontBoldAction(_:)), for: .touchUpInside)

        dropMenuView = UIView()
        if(dropMenuView != nil) {
            addSubview(dropMenuView!)
        }

        splitView = UIView()
        splitView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        if(splitView != nil) {
            dropMenuView?.addSubview(splitView!)
        }

        dropDownIcon = UIImageView()
        dropDownIcon?.image = UIImage(named: "CPDFEditArrow", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        if(dropDownIcon != nil) {
            dropMenuView?.addSubview(dropDownIcon!)
        }

        fontNameSelectLabel = UILabel()
        fontNameSelectLabel?.adjustsFontSizeToFitWidth = true
        if(fontNameSelectLabel != nil) {
            dropMenuView?.addSubview(fontNameSelectLabel!)
        }
        fontNameSelectLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()

        fontSelectBtn = UIButton(type: .custom)
        fontSelectBtn?.backgroundColor = UIColor.clear
        fontSelectBtn?.addTarget(self, action: #selector(showFontNameAction(_:)), for: .touchUpInside)
        if(fontSelectBtn != nil) {
            dropMenuView?.addSubview(fontSelectBtn!)
        }

        styleView = UIView()
        styleView?.layer.cornerRadius = 4
        styleView?.backgroundColor = UIColor(red: 73/255, green: 130/255, blue: 230/255, alpha: 0.08)
        if(styleView != nil) {
            addSubview(styleView!)
        }
        if(italicBtn != nil) {
            styleView?.addSubview(italicBtn!)
        }
        if(boldBtn != nil) {
            styleView?.addSubview(boldBtn!)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fontNameLabel?.frame = CGRect(x: 20, y: 0, width: 30, height: 30)
        boldBtn?.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        italicBtn?.frame = CGRect(x: 40, y: 0, width: 40, height: 30)
        let labelMaxX = fontNameLabel?.frame.maxX ?? 0
        let width = frame.size.width - labelMaxX - 20 - 20 - 80 - 20
        let finalWidth = max(width, 0)

        dropMenuView?.frame = CGRect(x: labelMaxX + 20, y: 0, width: finalWidth, height: 30)

        splitView?.frame = CGRect(x: 0, y: 29, width: dropMenuView?.bounds.size.width ?? 0, height: 1)
        
        dropDownIcon?.frame = CGRect(x: (dropMenuView?.bounds.size.width ?? 0) - 24 - 5, y: 3, width: 24, height: 24)
        fontNameSelectLabel?.frame = CGRect(x: 10, y: 0, width: (dropMenuView?.bounds.size.width ?? 0) - 40, height: 29)
        
        fontSelectBtn?.frame = dropMenuView?.bounds ?? CGRect.zero
        styleView?.frame = CGRect(x: frame.size.width - 100, y: 0, width: 80, height: 30)
        
        if boldBtn != nil {
            //bold
            let maskPath = UIBezierPath(roundedRect: boldBtn!.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: 4, height: 4))
            let maskLayer = CAShapeLayer()
            maskLayer.frame = boldBtn!.bounds
            maskLayer.path = maskPath.cgPath
            boldBtn!.layer.mask = maskLayer
        }
        if italicBtn != nil {
            //italic
            let maskPath1 = UIBezierPath(roundedRect: italicBtn!.bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: 4, height: 4))
            let maskLayer1 = CAShapeLayer()
            maskLayer1.frame = italicBtn!.bounds
            maskLayer1.path = maskPath1.cgPath
            italicBtn!.layer.mask = maskLayer1
        }
    }
    
    
    // MARK: - Action
    @objc func fontItalicAction(_ button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            italicBtn?.backgroundColor = UIColor(red: 221/255, green: 223/255, blue: 255/255, alpha: 1)
        } else {
            italicBtn?.backgroundColor = UIColor.clear
        }
        
        delegate?.setCPDFFontSettingView?(view: self, isItalic: button.isSelected)
    }
    
    @objc func fontBoldAction(_ button: UIButton) {
        button.isSelected = !button.isSelected
        
        if button.isSelected {
            boldBtn?.backgroundColor = UIColor(red: 221/255, green: 223/255, blue: 255/255, alpha: 1)
        } else {
            boldBtn?.backgroundColor = UIColor.clear
        }
        
        delegate?.setCPDFFontSettingView?(view: self, isBold: button.isSelected)
    }
    
    @objc func showFontNameAction(_ button: UIButton) {
        delegate?.setCPDFFontSettingViewFontSelect?(view: self)
    }
    
}

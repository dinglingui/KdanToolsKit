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
    @objc optional func setCPDFFontSettingViewFontSelect(view: CPDFFontSettingSubView,isFontStyle:Bool)
    
}

class CPDFFontSettingSubView: UIView {
    weak var delegate: CPDFFontSettingViewDelegate?
    
    public var fontNameLabel: UILabel?
    public var fontNameSelectLabel: UILabel?
    private var fontSelectBtn: UIButton?
    private var dropMenuView: UIView?
    private var splitView: UIView?
    private var dropDownIcon: UIImageView?
    
    public var fontStyleNameLabel: UILabel?
    public var fontStyleNameSelectLabel: UILabel?
    private var fontStyleSelectBtn: UIButton?
    private var dropStyleMenuView: UIView?
    private var splitStyleView: UIView?
    private var dropStyleDownIcon: UIImageView?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configSubView()

    }
    
    func configSubView () {
        fontNameLabel = UILabel()
        fontNameLabel?.text = NSLocalizedString("Font", comment: "")
        fontNameLabel?.font = UIFont.systemFont(ofSize: 14)
        fontNameLabel?.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        if(fontNameLabel != nil) {
            addSubview(fontNameLabel!)
        }
        
        fontNameSelectLabel = UILabel()
        
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
        
        fontStyleNameSelectLabel = UILabel()
        
        dropStyleMenuView = UIView()
        if(dropStyleMenuView != nil) {
            addSubview(dropStyleMenuView!)
        }
        
        splitStyleView = UIView()
        splitStyleView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        if(splitStyleView != nil) {
            dropStyleMenuView?.addSubview(splitStyleView!)
        }
        
        dropStyleDownIcon = UIImageView()
        dropStyleDownIcon?.image = UIImage(named: "CPDFEditArrow", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        if(dropStyleDownIcon != nil) {
            dropStyleMenuView?.addSubview(dropStyleDownIcon!)
        }
        
        fontStyleNameSelectLabel = UILabel()
        fontStyleNameSelectLabel?.adjustsFontSizeToFitWidth = true
        if(fontStyleNameSelectLabel != nil) {
            dropStyleMenuView?.addSubview(fontStyleNameSelectLabel!)
        }
        fontStyleNameSelectLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
        
        fontStyleSelectBtn = UIButton(type: .custom)
        fontStyleSelectBtn?.backgroundColor = UIColor.clear
        fontStyleSelectBtn?.addTarget(self, action: #selector(showFontStyleNameAction(_:)), for: .touchUpInside)
        if(fontStyleSelectBtn != nil) {
            dropStyleMenuView?.addSubview(fontStyleSelectBtn!)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fontNameLabel?.frame = CGRect(x: 20, y: 0, width: 30, height: 30)
        let labelMaxX = fontNameLabel?.frame.maxX ?? 0
        let width = frame.size.width - labelMaxX - 20 - 20
        let finalWidth = (max(width, 0) - 10) / 5 * 3
        let finalWidth2 = (max(width, 0) - 10) / 5 * 2

        dropMenuView?.frame = CGRect(x: labelMaxX + 20, y: 0, width: finalWidth, height: 30)
        
        splitView?.frame = CGRect(x: 0, y: 29, width: dropMenuView?.bounds.size.width ?? 0, height: 1)
        
        dropDownIcon?.frame = CGRect(x: (dropMenuView?.bounds.size.width ?? 0) - 24 - 5, y: 3, width: 24, height: 24)
        fontNameSelectLabel?.frame = CGRect(x: 10, y: 0, width: (dropMenuView?.bounds.size.width ?? 0) - 40, height: 29)
        
        fontSelectBtn?.frame = dropMenuView?.bounds ?? CGRect.zero
        
        dropStyleMenuView?.frame = CGRect(x: (dropMenuView?.frame.maxX ?? 0) + 10, y: 0, width: finalWidth2, height: 30)
        
        splitStyleView?.frame = CGRect(x: 0, y: 29, width: dropStyleMenuView?.bounds.size.width ?? 0, height: 1)
        
        dropStyleDownIcon?.frame = CGRect(x: (dropStyleMenuView?.bounds.size.width ?? 0) - 24 - 5, y: 3, width: 24, height: 24)
        fontStyleNameSelectLabel?.frame = CGRect(x: 10, y: 0, width: (dropStyleMenuView?.bounds.size.width ?? 0) - 40, height: 29)
        
        fontStyleSelectBtn?.frame = dropStyleMenuView?.bounds ?? CGRect.zero
    }
    
    
    // MARK: - Action
    @objc func showFontStyleNameAction(_ button: UIButton) {
        delegate?.setCPDFFontSettingViewFontSelect?(view: self, isFontStyle: true)
    }
    
    @objc func showFontNameAction(_ button: UIButton) {
        delegate?.setCPDFFontSettingViewFontSelect?(view: self, isFontStyle: false)
    }
    
}

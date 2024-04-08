//
//  CPDFFontAlignView.swift
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

@objc protocol CPDFFontAlignViewDelegate: AnyObject {
    @objc optional func setCPDFFontAlignView(view: CPDFFontAlignView, algnment: NSTextAlignment)
}

class CPDFFontAlignView: UIView {
    
    weak var delegate: CPDFFontAlignViewDelegate?
    
    var alignmentLabel: UILabel?
    var alignment: NSTextAlignment {
        didSet {
            if alignment == .left {
                leftAlignBtn?.isSelected = true
                centerAlignBtn?.isSelected = false
                rightAlignBtn?.isSelected = false
                leftAlignBtn?.backgroundColor = UIColor(red: 73/255, green: 130/255, blue: 230/255, alpha: 0.16)
                centerAlignBtn?.backgroundColor = UIColor.clear
                rightAlignBtn?.backgroundColor = UIColor.clear
            } else if alignment == .center {
                centerAlignBtn?.isSelected = true
                rightAlignBtn?.isSelected = false
                leftAlignBtn?.isSelected = false
                centerAlignBtn?.backgroundColor = UIColor(red: 73/255, green: 130/255, blue: 230/255, alpha: 0.16)
                leftAlignBtn?.backgroundColor = UIColor.clear
                rightAlignBtn?.backgroundColor = UIColor.clear
            } else if alignment == .right {
                rightAlignBtn?.isSelected = true
                leftAlignBtn?.isSelected = false
                centerAlignBtn?.isSelected = false
                rightAlignBtn?.backgroundColor = UIColor(red: 73/255, green: 130/255, blue: 230/255, alpha: 0.16)
                centerAlignBtn?.backgroundColor = UIColor.clear
                leftAlignBtn?.backgroundColor = UIColor.clear
            }
        }
    }
    
    private var leftAlignBtn: UIButton?
    private var centerAlignBtn: UIButton?
    private var rightAlignBtn: UIButton?
    private var alignmnetCoverView: UIView?
    private var lastSelectAlignBtn: UIButton?
    
    override init(frame: CGRect) {
        self.alignment = .left
        super.init(frame: frame)
        
        alignmentLabel = UILabel()
        alignmentLabel?.text = NSLocalizedString("Alignment", comment: "")
        alignmentLabel?.font = UIFont.systemFont(ofSize: 14)
        alignmentLabel?.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
       
        
        alignmnetCoverView = UIView()
        alignmnetCoverView?.layer.borderColor = UIColor(red: 0.886, green: 0.89, blue: 0.902, alpha: 1).cgColor
        alignmnetCoverView?.layer.borderWidth = 1
        
        leftAlignBtn = UIButton(type: .custom)
        rightAlignBtn = UIButton(type: .custom)
        centerAlignBtn = UIButton(type: .custom)
     
        leftAlignBtn?.setImage(UIImage(named: "CPDFEditAlignmentLeft", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        leftAlignBtn?.addTarget(self, action: #selector(fontAlignmentAction(_:)), for: .touchUpInside)
        
        rightAlignBtn?.setImage(UIImage(named: "CPDFEditAlignmentRight", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        rightAlignBtn?.addTarget(self, action: #selector(fontAlignmentAction(_:)), for: .touchUpInside)
        
        centerAlignBtn?.setImage(UIImage(named: "CPDFEditAligmentCenter", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        centerAlignBtn?.addTarget(self, action: #selector(fontAlignmentAction(_:)), for: .touchUpInside)
        if(alignmnetCoverView != nil) {
            addSubview(alignmnetCoverView!)
        }
        if(alignmentLabel != nil) {
            addSubview(alignmentLabel!)
        }
        
        if(leftAlignBtn != nil) {
            alignmnetCoverView?.addSubview(leftAlignBtn!)
        }
        
        if(centerAlignBtn != nil) {
            alignmnetCoverView?.addSubview(centerAlignBtn!)
        }
        
        if(rightAlignBtn != nil) {
            alignmnetCoverView?.addSubview(rightAlignBtn!)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        alignmentLabel?.frame = CGRect(x: 20, y: 9, width: 100, height: 30)
        
        leftAlignBtn?.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        centerAlignBtn?.frame = CGRect(x: 50, y: 0, width: 50, height: 30)
        rightAlignBtn?.frame = CGRect(x: 100, y: 0, width: 50, height: 30)
        alignmnetCoverView?.frame = CGRect(x: frame.size.width - 170, y: 9, width: 150, height: 30)
    }
    
    // MARK: - Action
    @objc func fontAlignmentAction(_ sender: UIButton) {
        
        if sender == lastSelectAlignBtn {
            return
        }
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            sender.backgroundColor = UIColor(red: 73/255, green: 130/255, blue: 230/255, alpha: 0.16)
        }
        
        if sender == leftAlignBtn && sender.isSelected {
            centerAlignBtn?.isSelected = false
            rightAlignBtn?.isSelected = false
            
            centerAlignBtn?.backgroundColor = UIColor.clear
            rightAlignBtn?.backgroundColor = UIColor.clear
            
            delegate?.setCPDFFontAlignView?(view: self, algnment: .left)
            lastSelectAlignBtn = leftAlignBtn
        } else if sender == centerAlignBtn && sender.isSelected {
            rightAlignBtn?.isSelected = false
            leftAlignBtn?.isSelected = false
            
            leftAlignBtn?.backgroundColor = UIColor.clear
            rightAlignBtn?.backgroundColor = UIColor.clear
            
            delegate?.setCPDFFontAlignView?(view: self, algnment: .center)
            lastSelectAlignBtn = centerAlignBtn
        } else if sender == rightAlignBtn && sender.isSelected {
            leftAlignBtn?.isSelected = false
            centerAlignBtn?.isSelected = false
            
            centerAlignBtn?.backgroundColor = UIColor.clear
            leftAlignBtn?.backgroundColor = UIColor.clear
            
            delegate?.setCPDFFontAlignView?(view: self, algnment: .right)
            lastSelectAlignBtn = rightAlignBtn
        } else {
            delegate?.setCPDFFontAlignView?(view: self, algnment: .natural)
        }
        
    }
}

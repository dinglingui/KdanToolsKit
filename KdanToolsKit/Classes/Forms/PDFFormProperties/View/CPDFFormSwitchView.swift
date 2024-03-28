//
//  CPDFFormSwitchView.swift
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

@objc protocol CPDFFormSwitchViewDelegate: AnyObject {
    
    @objc optional func switchAction(in view: CPDFFormSwitchView, switcher: UISwitch)
}

class CPDFFormSwitchView: UIView {
    
    weak var delegate: CPDFFormSwitchViewDelegate?
    
    var switcher: UISwitch?
    var titleLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel = UILabel()
        titleLabel?.text = NSLocalizedString("Field Name", comment: "")
        titleLabel?.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1.0)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        if(titleLabel != nil) {
            addSubview(titleLabel!)
        }
        
        switcher = UISwitch()
        if(switcher != nil) {
            addSubview(switcher!)
        }
        switcher?.addTarget(self, action: #selector(switchAction(_:)), for: .touchUpInside)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.frame = CGRect(x: 20, y: 12, width: bounds.size.width - 40, height: 20)
        switcher?.frame = CGRect(x: bounds.size.width - 70, y: 7, width: 70, height: 30)
    }
    
    @objc func switchAction(_ sender: UISwitch) {
        self.delegate?.switchAction?(in: self, switcher: sender)
    }
    
    
}

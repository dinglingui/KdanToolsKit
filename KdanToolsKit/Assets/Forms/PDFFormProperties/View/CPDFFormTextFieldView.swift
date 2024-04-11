//
//  CPDFFormTextFieldView.swift
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

@objc protocol CPDFFormTextFiledViewDelegate: AnyObject {
    
    @objc optional func setCPDFFormTextFieldView(_ view: CPDFFormTextFieldView, text: String)
}

class CPDFFormTextFieldView: UIView,UITextFieldDelegate {
    
    weak var delegate: CPDFFormTextFiledViewDelegate?
    
    var contentField: UITextField?
    var titleLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel = UILabel()
        titleLabel?.text = NSLocalizedString("Name", comment: "")
        titleLabel?.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1.0)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        if(titleLabel != nil) {
            addSubview(titleLabel!)
        }
        
        contentField = UITextField()
        contentField?.layer.cornerRadius = 1
        contentField?.layer.borderWidth = 1
        contentField?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        contentField?.delegate = self
        if(contentField != nil) {
            addSubview(contentField!)
        }
        
        backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.frame = CGRect(x: 20, y: 0, width: bounds.size.width - 40, height: 20)
        contentField?.frame = CGRect(x: 20, y: (titleLabel?.frame.maxY ?? 0) + 8, width: bounds.size.width - 40, height: 35)
    }
    
    
    
    // MARK: - UITextfieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate?.setCPDFFormTextFieldView?(self, text: textField.text ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return true
    }
    
}

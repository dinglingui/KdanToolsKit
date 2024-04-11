//
//  CPDFFormInputTextView.swift
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

@objc protocol CPDFFormInputTextViewDelegate: AnyObject {
    
    @objc optional func SetCPDFFormInputTextView(_ view: CPDFFormInputTextView, text: String)
}

class CPDFFormInputTextView: UIView,UITextViewDelegate {
    
    weak var delegate: CPDFFormInputTextViewDelegate?
    
    var contentField: UITextView?
    var titleLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel = UILabel()
        if(titleLabel != nil) {
            addSubview(titleLabel!)
        }
        
        contentField = UITextView()
        contentField?.layer.cornerRadius = 1
        contentField?.layer.borderWidth = 1
        contentField?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        contentField?.delegate = self
        contentField?.font = UIFont.systemFont(ofSize: 13)
        if(contentField != nil) {
            addSubview(contentField!)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.frame = CGRect(x: 20, y: 0, width: frame.size.width - 40, height: 30)
        contentField?.frame = CGRect(x: 20, y: (titleLabel?.frame.maxY ?? 0) + 8, width: frame.size.width - 40, height: 90)
        
    }
    
    // MARK: - UITextfieldDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.delegate?.SetCPDFFormInputTextView?(self, text: textView.text)
    }
    
    
}

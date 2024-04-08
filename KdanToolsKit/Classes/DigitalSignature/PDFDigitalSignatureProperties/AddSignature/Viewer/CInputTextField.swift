//
//  CInputTextField.swift
//  PDFViewer-Swift
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import UIKit

@objc protocol CInputTextFieldDelegate: AnyObject {
    @objc optional func setCInputTextFieldClear(_ inputTextField: CInputTextField)
    @objc optional func setCInputTextFieldBegin(_ inputTextField: CInputTextField)
    @objc optional func setCInputTextFieldChange(_ inputTextField: CInputTextField, text: String)
}

class CInputTextField: UIView, UITextFieldDelegate {
    weak var delegate: CInputTextFieldDelegate?
    var titleLabel: UILabel?
    var inputTextField: UITextField?
    var featureBtn: UIButton?
    var leftMargin: CGFloat = 0
    var rightMargin: CGFloat = 0
    var rightTitleMargin: CGFloat = 0
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel = UILabel()
        titleLabel?.textColor = UIColor.gray
        titleLabel?.font = UIFont.systemFont(ofSize: 13)
        if titleLabel != nil {
            addSubview(titleLabel!)
        }
        
        inputTextField = UITextField()
        inputTextField?.backgroundColor = UIColor.clear
        inputTextField?.borderStyle = .roundedRect
        inputTextField?.font = UIFont.systemFont(ofSize: 13)
        inputTextField?.delegate = self
        inputTextField?.addTarget(self, action: #selector(textFieldChange(_:)), for: .editingChanged)
        inputTextField?.autoresizingMask = .flexibleWidth
        if inputTextField != nil {
            addSubview(inputTextField!)
        }
        
        leftMargin = 0
        rightMargin = 0
        rightTitleMargin = 0
        
        backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel?.frame = CGRect(x: rightTitleMargin, y: 0, width: frame.size.width, height: frame.size.height / 2)
        inputTextField?.frame = CGRect(x: leftMargin, y: frame.size.height / 2, width: frame.size.width + leftMargin + rightMargin, height: frame.size.height / 2)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        delegate?.setCInputTextFieldClear?(self)
        return true
    }
    
    @objc func textFieldChange(_ sender: UITextField) {
        delegate?.setCInputTextFieldChange?(self, text: sender.text ?? "")
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        delegate?.setCInputTextFieldBegin?(self)
        return true
    }
}

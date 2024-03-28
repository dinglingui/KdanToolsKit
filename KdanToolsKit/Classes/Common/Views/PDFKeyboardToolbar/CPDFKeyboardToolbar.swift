//
//  CPDFKeyboardToolbar.swift
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

public protocol CPDFKeyboardToolbarDelegate: AnyObject {
    func keyboardShouldDissmiss(_ toolbar: CPDFKeyboardToolbar)
}

public class CPDFKeyboardToolbar: UIView {

    public weak var delegate: CPDFKeyboardToolbarDelegate?
    
    var doneButton:UIButton?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.doneButton = UIButton(type: .custom)
        self.doneButton?.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
        self.doneButton?.setTitleColor(UIColor(red: 0, green: 122.0/255.0, blue: 1.0, alpha: 1.0), for: .normal)
        self.doneButton?.setTitleColor(UIColor.lightGray, for: .highlighted)
        self.doneButton?.sizeToFit()
        self.doneButton?.addTarget(self, action: #selector(buttonItemClick_done(_:)), for: .touchUpInside)
        if doneButton != nil {
            self.addSubview(self.doneButton!)
        }
        
        self.backgroundColor = CPDFColorUtils.CPDFKeyboardToolbarColor()
    }

    public override func layoutSubviews() {
        if #available(iOS 11.0, *) {
            self.doneButton?.frame = CGRect(x: self.frame.size.width - (self.superview?.safeAreaInsets.right ?? 0) - 60, y: 0, width: 50, height: self.frame.size.height)
        } else {
            self.doneButton?.frame = CGRect(x: self.frame.size.width - 70, y: 0, width: 50, height: self.frame.size.height)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func bindToTextView(_ textView: UITextView) {
        textView.inputAccessoryView = self
    }
    
    public  func bindToTextField(_ textField: UITextField) {
        textField.inputAccessoryView = self
    }
    
    @objc func buttonItemClick_done(_ sender: Any) {
        self.delegate?.keyboardShouldDissmiss(self)
    }

}

//
//  CDocumentPasswordViewController.swift
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
import ComPDFKit

public protocol CDocumentPasswordViewControllerDelegate: AnyObject {
    func documentPasswordViewControllerCancel(_ documentPasswordViewController: CDocumentPasswordViewController)
    
    func documentPasswordViewControllerOpen(_ documentPasswordViewController: CDocumentPasswordViewController, document: CPDFDocument)
}

public class CDocumentPasswordViewController: UIViewController, UITextFieldDelegate {

    public weak var delegate: CDocumentPasswordViewControllerDelegate?
    
    var backBtn:UIButton?
    var passwordImageView:UIImageView?
    var titleLablel:UILabel?
    var enterView:UIView?
    var passLabel:UILabel?
    var splitVidew:UIView?
    var enterTextField:UITextField?
    var warningLabel:UILabel?
    var OKBtn:UIButton?
    var document:CPDFDocument?
    var clearButton:UIButton?
    
    public init(document: CPDFDocument) {
        super.init(nibName: nil, bundle: nil)
        self.document = document
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.backBtn = UIButton(type: .custom)
        self.backBtn?.setImage(UIImage(named: "CDocumentPasswordImageBack", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        self.backBtn?.addTarget(self, action: #selector(buttonItemClicked_back(_:)), for: .touchUpInside)
        if backBtn != nil {
            self.view.addSubview(self.backBtn!)
        }

        self.passwordImageView = UIImageView(image: UIImage(named: "CDocumentPasswordImagePassword", in: Bundle(for: self.classForCoder), compatibleWith: nil))
        if passwordImageView != nil {
            self.view.addSubview(self.passwordImageView!)
        }

        self.titleLablel = UILabel()
        self.titleLablel?.text = NSLocalizedString("Please Enter The Password", comment: "")
        self.titleLablel?.adjustsFontSizeToFitWidth = true
        if passwordImageView != nil {
            self.view.addSubview(self.passwordImageView!)
        }

        self.enterView = UIView()
        if enterView != nil {
            self.view.addSubview(self.enterView!)
        }
        initEnterView()

        self.warningLabel = UILabel()
        self.warningLabel?.text = NSLocalizedString("Wrong Password", comment: "")
        self.warningLabel?.textColor = UIColor.red
        if warningLabel != nil {
            self.view.addSubview(self.warningLabel!)
        }
        
        self.warningLabel?.isHidden = true

        self.OKBtn = UIButton(type: .custom)
        self.OKBtn?.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
        self.OKBtn?.addTarget(self, action: #selector(buttonItemClicked_ok(_:)), for: .touchUpInside)
        self.OKBtn?.setTitleColor(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0), for: .normal)
        self.OKBtn?.backgroundColor = UIColor(red: 221.0/255.0, green: 233.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        if OKBtn != nil {
            self.view.addSubview(self.OKBtn!)
        }

        self.view.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
    }
    
    public override func viewWillLayoutSubviews() {
        if #available(iOS 11.0, *) {
            self.backBtn?.frame = CGRect(x: self.view.frame.size.width - self.view.safeAreaInsets.right - 70, y: self.view.safeAreaInsets.top, width: 50, height: 50)
            self.passwordImageView?.frame = CGRect(x: (self.view.frame.size.width - 100)/2, y: self.backBtn?.frame.maxY ?? 0, width: 100, height: 100)
            self.titleLablel?.frame = CGRect(x: (self.view.frame.size.width - 200)/2, y: self.passwordImageView?.frame.maxY ?? 0, width: 200, height: 50)
            self.enterView?.frame = CGRect(x: (self.view.frame.size.width - 300)/2, y: self.titleLablel?.frame.maxY ?? 0, width: 300, height: 60)
            self.warningLabel?.frame = CGRect(x: (self.view.frame.size.width - 300)/2, y: self.enterView?.frame.maxY ?? 0, width: 300, height: 40)
            self.OKBtn?.frame = CGRect(x: (self.view.frame.size.width - 300)/2, y: self.warningLabel?.frame.maxY ?? 0, width: 300, height: 60)
        } else {
            self.backBtn?.frame = CGRect(x: self.view.frame.size.width - 60, y: 65, width: 50, height: 50)
            self.passwordImageView?.frame = CGRect(x: (self.view.frame.size.width - 100)/2, y: self.backBtn?.frame.maxY ?? 0, width: 100, height: 100)
            self.titleLablel?.frame = CGRect(x: (self.view.frame.size.width - 100)/2, y: self.passwordImageView?.frame.maxY ?? 0, width: 200, height: 50)
            self.enterView?.frame = CGRect(x: (self.view.frame.size.width - 300)/2, y: self.titleLablel?.frame.maxY ?? 0, width: 300, height: 60)
            self.warningLabel?.frame = CGRect(x: (self.view.frame.size.width - 300)/2, y: self.enterView?.frame.maxY ?? 0, width: 300, height: 40)
            self.OKBtn?.frame = CGRect(x: (self.view.frame.size.width - 300)/2, y: self.warningLabel?.frame.maxY ?? 0, width: 300, height: 60)
        }
        self.passLabel?.frame = CGRect(x: 0, y: 0, width: 80, height: (self.enterView?.frame.size.height ?? 0)-1)
        self.enterTextField?.frame = CGRect(x: 80, y: 0, width: (self.enterView?.frame.size.width ?? 0) - 80, height: (self.enterView?.frame.size.height ?? 0) - 1)
        self.splitVidew?.frame = CGRect(x: 0, y: (self.enterView?.frame.size.height ?? 0)-1, width: self.enterView?.frame.size.width ?? 0, height: 1)
        self.clearButton?.frame = CGRect(x: (self.enterView?.frame.size.width ?? 0) - 30, y: ((self.enterView?.frame.size.height ?? 0) - 24)/2, width: 24, height: 24)
    }
    
    func initEnterView() {
        self.passLabel = UILabel()
        self.passLabel?.text = NSLocalizedString("Password", comment: "")
        self.enterView?.addSubview(self.passLabel!)
        
        self.enterTextField = UITextField()
        self.enterTextField?.borderStyle = .none
        self.enterTextField?.isSecureTextEntry = true
        self.enterTextField?.delegate = self
        self.enterTextField?.font = UIFont.systemFont(ofSize: 13)
        self.enterTextField?.returnKeyType = .done
        self.enterTextField?.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        self.enterTextField?.leftViewMode = .always
        self.enterTextField?.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        self.enterTextField?.rightViewMode = .always
        self.enterTextField?.placeholder = NSLocalizedString("Please Enter the Password", comment: "")
        self.enterTextField?.becomeFirstResponder()
        self.enterTextField?.addTarget(self, action: #selector(textField_change(_:)), for: .editingChanged)
        self.enterView?.addSubview(self.enterTextField!)
        
        self.clearButton = UIButton(type: .custom)
        self.clearButton?.layer.cornerRadius = 12
        self.clearButton?.layer.masksToBounds = true
        self.clearButton?.setImage(UIImage(named: "CDocumentPasswordImageClear", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        self.clearButton?.addTarget(self, action: #selector(buttonItemClicked_clear(_:)), for: .touchUpInside)
        self.enterView?.addSubview(self.clearButton!)
        self.clearButton!.isHidden = true
        
        self.splitVidew = UIView()
        self.splitVidew?.backgroundColor = CPDFColorUtils.CTableviewCellSplitColor()
        self.enterView?.addSubview(self.splitVidew!)
    }
    
    // MARK: - Action
    @objc func buttonItemClicked_ok(_ sender: UIButton) {
        if ((self.document?.unlock(withPassword: self.enterTextField?.text)) == true) {
            self.dismiss(animated: true, completion: {
                self.delegate?.documentPasswordViewControllerOpen(self, document: self.document!)
            })
        } else {
            warningLabel?.isHidden = false
        }
    }
    
    @objc func buttonItemClicked_back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            self.delegate?.documentPasswordViewControllerCancel(self)
        })
    }
    
    @objc func buttonItemClicked_clear(_ sender: UIButton) {
        self.OKBtn?.backgroundColor = UIColor.init(red: 221.0/255.0, green: 233.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        self.warningLabel?.isHidden = true
        self.enterTextField?.text = ""
        self.clearButton?.isHidden = true
    }
    
    @objc func textField_change(_ sender: UITextField) {
        if sender.text?.count == 0 {
            self.OKBtn?.backgroundColor = UIColor(red: 221.0/255.0, green: 233.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            self.warningLabel?.isHidden = true
            self.clearButton?.isHidden = true
        } else {
            self.OKBtn?.backgroundColor = UIColor.blue
            self.clearButton?.isHidden = false
        }
    }

    // MARK: - UITextFieldDelegate
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.OKBtn?.backgroundColor = UIColor(red: 221.0/255.0, green: 233.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        self.warningLabel?.isHidden = true
        return true
    }

}

//
//  CPDFFormLinkViewController.swift
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

enum CPDFFormLinkType: Int {
    case link = 0
    case page
}


@objc protocol CPDFFormLinkViewControllerDelegate: AnyObject {
    @objc optional func linkViewController(_ linkViewController: CPDFFormLinkViewController, linkType: Int, linkString: String)
    
    @objc optional func linkViewControllerDismiss(_ linkViewController: CPDFFormLinkViewController, isLink: Bool)
}

class CPDFFormLinkViewController: UIViewController,UITextFieldDelegate {
    weak var delegate: CPDFFormLinkViewControllerDelegate?
    
    var pageCount: Int = 1
    var annotStyle: CAnnotStyle?
    var scrollView: UIScrollView?
    var backBtn: UIButton?
    var titleLabel: UILabel?
    var segmentedControl: UISegmentedControl?
    var pageTextField: UITextField?
    var urlTextField: UITextField?
    var saveButton: UIButton?
    var headerView: UIView?
    
    init(annotStyle: CAnnotStyle) {
        super.init(nibName: nil, bundle: nil)
        self.annotStyle = annotStyle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
        
        self.headerView = UIView()
        self.headerView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        self.headerView?.layer.borderWidth = 1.0
        self.headerView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if headerView != nil {
            self.view.addSubview(self.headerView!)
        }
        
        initWithView()
        let mAnnotation = self.annotStyle?.annotations.first
        
        if mAnnotation != nil && mAnnotation is CPDFButtonWidgetAnnotation {
            let buttonWidgetAnnotation:CPDFButtonWidgetAnnotation = mAnnotation as! CPDFButtonWidgetAnnotation
            
            self.segmentedControl?.selectedSegmentIndex = 0
            let mAction = buttonWidgetAnnotation.action()
            if  mAction is CPDFURLAction {
                self.linkType = .link
                let linkAction:CPDFURLAction = mAction as! CPDFURLAction
                
                self.urlTextField?.text = linkAction.url()
                if self.urlTextField?.text?.count ?? 0 > 0 {
                    saveButton?.isEnabled = true
                    saveButton?.backgroundColor = UIColor.systemBlue
                    saveButton?.setTitleColor(UIColor.white, for: .normal)
                }
            } else if mAction is CPDFGoToAction {
                let goAction:CPDFGoToAction = mAction as! CPDFGoToAction
                let pageIndex = goAction.destination().pageIndex
                
                self.linkType = .page
                self.pageTextField?.text = "\((pageIndex )+1)"
                self.segmentedControl?.selectedSegmentIndex = 1
                if self.pageTextField?.text?.count ?? 0 > 0 {
                    saveButton?.isEnabled = true
                    saveButton?.backgroundColor = UIColor.systemBlue
                    saveButton?.setTitleColor(UIColor.white, for: .normal)
                }
            } else {
                self.linkType = .link
                self.urlTextField?.text? = ""
                
            }
        }
        
        updatePreferredContentSize(with: self.traitCollection)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var currentTextField: UITextField?
        
        switch linkType {
        case .link:
            currentTextField = urlTextField
        default:
            currentTextField = pageTextField
        }
        
        currentTextField?.becomeFirstResponder()
    }
    
    var linkType: CPDFLinkType = .link {
        didSet {
            let currentTextField: UITextField?
            
            switch linkType {
            case .link:
                pageTextField?.isHidden = true
                urlTextField?.isHidden = false
                currentTextField = urlTextField
            default :
                urlTextField?.isHidden = true
                pageTextField?.isHidden = false
                currentTextField = pageTextField
            }
            
            currentTextField?.becomeFirstResponder()
            
            if let text = currentTextField?.text, !text.isEmpty {
                saveButton?.isEnabled = true
                saveButton?.backgroundColor = UIColor.systemBlue
                saveButton?.setTitleColor(UIColor.white, for: .normal)
            } else {
                saveButton?.isEnabled = false
                saveButton?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
                saveButton?.setTitleColor(UIColor.lightGray, for: .normal)
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        titleLabel?.frame = CGRect(x: (view.frame.size.width - 120)/2, y: 17.5, width: 120, height: 25)
        headerView?.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50)
        if #available(iOS 11.0, *) {
            backBtn?.frame = CGRect(x: view.frame.size.width - 60 - view.safeAreaInsets.right, y: 5, width: 50, height: 50)
        } else {
            backBtn?.frame = CGRect(x: view.frame.size.width - 60, y: 5, width: 50, height: 50)
        }
        if #available(iOS 11.0, *) {
            scrollView?.frame = CGRect(x: view.safeAreaInsets.left, y: 50, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: view.frame.size.height)
        } else {
            scrollView?.frame = CGRect(x: 0, y: 50, width: view.frame.size.width, height: view.frame.size.height)
        }
        scrollView?.contentSize = CGSize(width: scrollView?.frame.size.width  ?? 0, height: scrollView?.contentSize.height ?? 0)
        saveButton?.frame = CGRect(x: ((scrollView?.frame.size.width ?? 0) - 120)/2, y: saveButton?.frame.origin.y ?? 0, width: 120, height: 32)
        
    }
    
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSize(with: newCollection)
    }
    
    func updatePreferredContentSize(with traitCollection: UITraitCollection) {
        preferredContentSize = CGSize(width: view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? 350 : 600)
        urlTextField?.resignFirstResponder()
        pageTextField?.resignFirstResponder()
        
    }
    func initWithView() {
        titleLabel = UILabel()
        titleLabel?.autoresizingMask = .flexibleRightMargin
        titleLabel?.text = NSLocalizedString("Link to", comment: "")
        titleLabel?.textAlignment = .center
        titleLabel?.font = UIFont.systemFont(ofSize: 20)
        titleLabel?.adjustsFontSizeToFitWidth = true
        if titleLabel != nil {
            headerView?.addSubview(titleLabel!)
        }
        
        scrollView = UIScrollView()
        scrollView?.frame = CGRect(x: 0, y: 50, width: view.frame.size.width, height: view.frame.size.height)
        scrollView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView?.isScrollEnabled = true
        if scrollView != nil {
            view.addSubview(scrollView!)
        }
        
        backBtn = UIButton(type: .custom)
        if #available(iOS 11.0, *) {
            backBtn?.frame = CGRect(x: view.frame.size.width - 60 - view.safeAreaInsets.right, y: 5, width: 50, height: 50)
        } else {
            backBtn?.frame = CGRect(x: view.frame.size.width - 60, y: 5, width: 50, height: 50)
        }
        backBtn?.autoresizingMask = .flexibleLeftMargin
        backBtn?.setImage(UIImage(named: "CPDFAnnotationBaseImageBack", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        backBtn?.addTarget(self, action: #selector(buttonItemClicked_back(_:)), for: .touchUpInside)
        if backBtn != nil {
            headerView?.addSubview(backBtn!)
        }
        
        var offstY: CGFloat = 10
        segmentedControl = UISegmentedControl(items: [NSLocalizedString("URL", comment: ""), NSLocalizedString("Page", comment: "")])
        segmentedControl?.frame = CGRect(x: 30, y: offstY, width: scrollView!.frame.size.width - 30 * 2, height: 32.0)
        segmentedControl?.autoresizingMask = .flexibleWidth
        segmentedControl?.addTarget(self, action: #selector(segmentedControlValueChanged_Mode(_:)), for: .valueChanged)
        if segmentedControl != nil {
            scrollView?.addSubview(segmentedControl!)
        }
        offstY += segmentedControl?.frame.size.height ?? 0
        offstY += 32.0
        
        urlTextField = UITextField(frame: CGRect(x: 30.0, y: offstY, width: scrollView!.frame.size.width - 60.0, height: 28.0))
        urlTextField?.autoresizingMask = .flexibleWidth
        urlTextField?.layer.borderWidth = 1.0
        urlTextField?.layer.borderColor = UIColor.lightGray.cgColor
        urlTextField?.layer.cornerRadius = 5.0
        urlTextField?.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        urlTextField?.leftViewMode = .always
        urlTextField?.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        urlTextField?.rightViewMode = .always
        urlTextField?.delegate = self
        urlTextField?.isHidden = true
        urlTextField?.font = UIFont.systemFont(ofSize: 18.0)
        urlTextField?.placeholder = "https://www.compdf.com"
        if urlTextField != nil {
            scrollView?.addSubview(urlTextField!)
        }
        
        pageTextField = UITextField(frame: CGRect(x: 30.0, y: offstY, width: view.frame.size.width - 60.0, height: 28.0))
        pageTextField?.autoresizingMask = .flexibleWidth
        pageTextField?.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        pageTextField?.layer.borderColor = UIColor.lightGray.cgColor
        pageTextField?.leftViewMode = .always
        pageTextField?.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        pageTextField?.rightViewMode = .always
        pageTextField?.isHidden = true
        pageTextField?.layer.borderWidth = 1.0
        pageTextField?.layer.cornerRadius = 5.0
        pageTextField?.delegate = self
        pageTextField?.font = UIFont.systemFont(ofSize: 18.0)
        let str = String(format: "1~%ld", self.pageCount)
        pageTextField?.placeholder = NSLocalizedString(str, comment: "")
        pageTextField?.keyboardType = .numberPad
        if pageTextField != nil {
            scrollView?.addSubview(pageTextField!)
        }
        
        offstY += urlTextField?.frame.size.height ?? 0
        pageTextField?.addTarget(self, action: #selector(textFieldTextChange(_:)), for: .editingChanged)
        urlTextField?.addTarget(self, action: #selector(textFieldTextChange(_:)), for: .editingChanged)
        offstY += 30.0
        
        saveButton = UIButton(type: .custom)
        saveButton?.frame = CGRect(x: (scrollView?.frame.size.width ?? 0 - 120)/2, y: offstY, width: 120, height: 32)
        saveButton?.layer.cornerRadius = 5.0
        saveButton?.autoresizingMask = .flexibleLeftMargin
        saveButton?.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        saveButton?.setTitleColor(.white, for: .normal)
        saveButton?.addTarget(self, action: #selector(buttonItemClicked_Save(_:)), for: .touchUpInside)
        saveButton?.backgroundColor = .systemBlue
        if saveButton != nil {
            scrollView?.addSubview(saveButton!)
        }
        
        offstY += saveButton?.frame.size.height ?? 0
        scrollView?.contentSize = CGSize(width: view.frame.size.width, height: view.frame.size.height)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidez(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Action
    @objc func buttonItemClicked_back(_ button: UIButton) {
        var currentTextField: String?
        switch segmentedControl?.selectedSegmentIndex {
        case 0:
            currentTextField = urlTextField?.text
        default:
            currentTextField = pageTextField?.text
        }
        let isLink: Bool
        if let currentTextField = currentTextField, !currentTextField.isEmpty {
            isLink = true
        } else {
            isLink = false
        }
        dismiss(animated: true) {
            self.delegate?.linkViewControllerDismiss?(self, isLink: isLink)
        }
    }
    
    @objc func segmentedControlValueChanged_Mode(_ button: UISegmentedControl) {
        switch segmentedControl?.selectedSegmentIndex {
        case 0:
            self.linkType = .link
        default :
            self.linkType = .page
        }
        
    }
    
    @objc func buttonItemClicked_Save(_ button: UIButton) {
        var string: String?
        if .link == self.linkType {
            string = urlTextField?.text?.lowercased()
            if !(string?.hasPrefix("https://") ?? false) && !(string?.hasPrefix("http://") ?? false) {
                string = "https://\(string!)"
            }
        } else if .page == self.linkType {
            string = pageTextField?.text
            let annotation = annotStyle?.annotations.first
            let document = annotation?.page?.document
            let pageNumber = Int(string ?? "")
            
            if (pageNumber != nil) {
                if pageNumber! > document?.pageCount ?? 0 || pageNumber!  < 1 {
                    let alert = UIAlertController(title: "", message: NSLocalizedString("Config Error", comment: ""), preferredStyle: .alert)
                    let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { action in
                        self.pageTextField?.text = ""
                    }
                    alert.addAction(okAction)
                    present(alert, animated: true, completion: nil)
                    return
                }
            } else {
                let alert = UIAlertController(title: "", message: NSLocalizedString("Config Error", comment: ""), preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { action in
                    self.pageTextField?.text = ""
                }
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
                return
            }
        }
        if let mAnnotation = self.annotStyle?.annotations.first as? CPDFButtonWidgetAnnotation {
            if self.linkType == .link {
                let urlAction = CPDFURLAction(url: string)
                mAnnotation.setAction(urlAction)
            } else if self.linkType == .page {
                let pageIndex = (Int(string ?? "0") ?? 1) - 1
                let destination = CPDFDestination(document: mAnnotation.page.document, pageIndex: pageIndex)
                let goToAction = CPDFGoToAction(destination: destination)
                mAnnotation.setAction(goToAction)
            }
        }
        
        dismiss(animated: true) {
            self.delegate?.linkViewController?(self, linkType: self.linkType.rawValue, linkString: string ?? "")
        }
    }
    
    @objc func textFieldTextChange(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            saveButton?.isEnabled = true
            saveButton?.backgroundColor = UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0)
            saveButton?.setTitleColor(.white, for: .normal)
        } else {
            saveButton?.isEnabled = false
            saveButton?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            saveButton?.setTitleColor(.lightGray, for: .normal)
        }
        if textField == pageTextField {
            if let pageText = pageTextField?.text, let pageNumber = Int(pageText), pageNumber > pageCount {
                saveButton?.isEnabled = false
                saveButton?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
                saveButton?.setTitleColor(.lightGray, for: .normal)
            }
        }
        
    }
    
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillHidez(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let textFieldFrame = urlTextField?.convert(urlTextField?.frame ?? CGRect.zero, to: view)
        
        if textFieldFrame?.maxY ?? 0 > view.frame.size.height - keyboardFrame.size.height {
            var insets = scrollView?.contentInset
            insets?.bottom = keyboardFrame.size.height + (urlTextField?.frame.size.height ?? 0)
            scrollView?.contentInset = insets ?? UIEdgeInsets.zero
        }
        
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        var insets = scrollView?.contentInset
        insets?.bottom = 0
        scrollView?.contentInset = insets ?? UIEdgeInsets.zero
    }
    
}

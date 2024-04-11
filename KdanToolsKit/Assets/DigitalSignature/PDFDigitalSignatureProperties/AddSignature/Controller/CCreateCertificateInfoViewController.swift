//
//  CCreateCertificateInfoViewController.swift
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
import ComPDFKit

@objc public protocol CreateCertificateInfoViewControllerDelegate: AnyObject {
    @objc optional func createCertificateInfoViewControllerSave(_ createCertificateInfoViewController: CCreateCertificateInfoViewController, PKCS12Cert path: String, password: String, config: CPDFSignatureConfig)
    @objc optional func createCertificateInfoViewControllerCancel(_ createCertificateInfoViewController: CCreateCertificateInfoViewController)
}

public class CCreateCertificateInfoViewController: UIViewController,CHeaderViewDelegate,CInputTextFieldDelegate,CreateCertificateViewControllerDelegate,CDigitalPropertyTableViewDelegate {
    public weak var delegate: CreateCertificateInfoViewControllerDelegate?
    
    private var headerView: CHeaderView?
    private var nameTextField: CInputTextField?
    private var unitTextField: CInputTextField?
    private var unitNameTextField: CInputTextField?
    private var emailTextField: CInputTextField?
    private var countryTextField: CInputTextField?
    private var countryBtn: UIButton?
    private var purposeTextField: CInputTextField?
    private var purposeBtn: UIButton?
    private var messageLabel: UILabel?
    private var saveLabel: UILabel?
    private var saveSwitch: UISwitch?
    private var scrollView: UIScrollView?
    private var OKBtn: UIButton?
    private var codes: [String] = []
    private var coutryCodes: [String] = []
    private var coutryCode: String = "CN"
    private var annotation: CPDFSignatureWidgetAnnotation?
    private var coutryPropertyTableView: CDigitalPropertyTableView?
    private var purposePropertyTableView: CDigitalPropertyTableView?
    
    // MARK: - Initializers
    
    public init(annotation: CPDFSignatureWidgetAnnotation) {
        super.init(nibName: nil, bundle: nil)
        self.annotation = annotation
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Viewcontroller Methods
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView = UIScrollView()
        scrollView?.isScrollEnabled = true
        if scrollView != nil {
            view.addSubview(scrollView!)
        }
        
        headerView = CHeaderView()
        headerView?.titleLabel?.text = NSLocalizedString("Create A Self-Signed Digital ID", comment: "")
        headerView?.cancelBtn?.isHidden = true
        headerView?.delegate = self
        headerView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        headerView?.layer.borderWidth = 1.0
        headerView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if headerView != nil {
            view.addSubview(headerView!)
        }
        
        messageLabel = UILabel()
        messageLabel?.font = UIFont.systemFont(ofSize: 12)
        messageLabel?.numberOfLines = 3
        messageLabel?.layer.cornerRadius = 4.0
        messageLabel?.layer.masksToBounds = true
        messageLabel?.text = NSLocalizedString("Digital IDs that are self-signed by individuals do not provide the assurance that the identifying information is valid. For this reason, they may not be accepted in some cases.", comment: "")
        messageLabel?.adjustsFontSizeToFitWidth = true
        messageLabel?.backgroundColor = CPDFColorUtils.CMessageLabelColor()
        messageLabel?.sizeToFit()
        if messageLabel != nil {
            scrollView?.addSubview(messageLabel!)
        }
        
        nameTextField = CInputTextField()
        nameTextField?.delegate = self
        nameTextField?.titleLabel?.attributedText = mergeAttributeString(NSLocalizedString("Names", comment: ""))
        nameTextField?.inputTextField?.placeholder = NSLocalizedString("Please enter your name", comment: "")
        if nameTextField != nil {
            scrollView?.addSubview(nameTextField!)
        }
        
        unitTextField = CInputTextField()
        unitTextField?.delegate = self
        unitTextField?.titleLabel?.text = NSLocalizedString("Organization Unit", comment: "")
        unitTextField?.inputTextField?.placeholder = NSLocalizedString("Enter the name of the organization unit", comment: "")
        if unitTextField != nil {
            scrollView?.addSubview(unitTextField!)
        }
        
        unitNameTextField = CInputTextField()
        unitNameTextField?.delegate = self
        unitNameTextField?.titleLabel?.text = NSLocalizedString("Organization Name", comment: "")
        unitNameTextField?.inputTextField?.placeholder = NSLocalizedString("Enter the name of the organization", comment: "")
        if unitNameTextField != nil {
            scrollView?.addSubview(unitNameTextField!)
        }
        
        emailTextField = CInputTextField()
        emailTextField?.delegate = self
        emailTextField?.titleLabel?.attributedText = mergeAttributeString(NSLocalizedString("Email Address", comment: ""))
        emailTextField?.inputTextField?.placeholder = NSLocalizedString("Please enter your email address", comment: "")
        if emailTextField != nil {
            scrollView?.addSubview(emailTextField!)
        }
        
        countryTextField = CInputTextField()
        countryTextField?.delegate = self
        let hiddenView1 = UIView(frame: CGRect.zero)
        countryTextField?.inputTextField?.inputView = hiddenView1
        countryTextField?.titleLabel?.text = NSLocalizedString("Country/Region", comment: "")
        countryTextField?.inputTextField?.text = NSLocalizedString("CN - China mainland", comment: "")
        if countryTextField != nil {
            scrollView?.addSubview(countryTextField!)
        }
        
        countryBtn = UIButton()
        countryBtn?.backgroundColor = UIColor.clear
        countryBtn?.addTarget(self, action: #selector(buttonItemClicked_country(_:)), for: .touchUpInside)
        if countryBtn != nil {
            countryTextField?.addSubview(countryBtn!)
        }
        
        purposeTextField = CInputTextField()
        purposeTextField?.delegate = self
        let hiddenView2 = UIView(frame: CGRect.zero)
        purposeTextField?.inputTextField?.inputView = hiddenView2
        purposeTextField?.titleLabel?.text = NSLocalizedString("Use Digital ID for", comment: "")
        purposeTextField?.inputTextField?.text = NSLocalizedString("Digital Signatures", comment: "")
        if purposeTextField != nil {
            scrollView?.addSubview(purposeTextField!)
        }
        
        purposeBtn = UIButton()
        purposeBtn?.backgroundColor = UIColor.clear
        purposeBtn?.addTarget(self, action: #selector(buttonItemClicked_purpose(_:)), for: .touchUpInside)
        if purposeBtn != nil {
            purposeTextField?.addSubview(purposeBtn!)
        }
        
        saveLabel = UILabel()
        saveLabel?.text = NSLocalizedString("Save to File", comment: "")
        if saveLabel != nil {
            scrollView?.addSubview(saveLabel!)
        }
        
        saveSwitch = UISwitch()
        saveSwitch?.addTarget(self, action: #selector(selectChange_switch(_:)), for: .valueChanged)
        saveSwitch?.isOn = true
        if saveSwitch != nil {
            scrollView?.addSubview(saveSwitch!)
        }
        
        OKBtn = UIButton(type: .custom)
        OKBtn?.setTitle(NSLocalizedString("OK", comment: ""), for: .normal)
        OKBtn?.isEnabled = false
        OKBtn?.addTarget(self, action: #selector(buttonItemClicked_ok(_:)), for: .touchUpInside)
        OKBtn?.setTitleColor(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0), for: .normal)
        OKBtn?.backgroundColor = UIColor(red: 221.0/255.0, green: 233.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        if OKBtn != nil {
            scrollView?.addSubview(OKBtn!)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        view.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        reloadData()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var top: CGFloat = 0
        var bottom: CGFloat = 0
        var left: CGFloat = 0
        var right: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            bottom += self.view.safeAreaInsets.bottom
            top += self.view.safeAreaInsets.top
            left += self.view.safeAreaInsets.left
            right += self.view.safeAreaInsets.right
        }
        
        self.headerView?.frame = CGRect(x: 0, y: top, width: self.view.frame.size.width, height: 55)
        
        let currentOrientation = UIApplication.shared.statusBarOrientation
        if currentOrientation == .portrait || currentOrientation == .portraitUpsideDown {
            self.scrollView?.frame = CGRect(x: 0, y: 60, width: self.view.frame.size.width, height: self.view.frame.size.height - 70)
            self.scrollView?.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        } else {
            self.scrollView?.frame = CGRect(x: 0, y: (self.headerView?.frame.maxY ?? 0) + 5, width: self.view.frame.size.width, height: self.view.frame.size.height + 400)
            self.scrollView?.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height + 850)
        }
        
        self.messageLabel?.frame = CGRect(x: 25 + left, y: 20, width: self.view.frame.size.width - 50 - left - right, height: 90)
        self.nameTextField?.frame = CGRect(x: 25 + left, y: self.messageLabel?.frame.maxY ?? 0, width: self.view.frame.size.width - 50 - left - right, height: 90)
        self.unitTextField?.frame = CGRect(x: 25 + left, y: self.nameTextField?.frame.maxY ?? 0, width: self.view.frame.size.width - 50 - left - right, height: 90)
        self.unitNameTextField?.frame = CGRect(x: 25 + left, y: self.unitTextField?.frame.maxY ?? 0, width: self.view.frame.size.width - 50 - left - right, height: 90)
        self.emailTextField?.frame = CGRect(x: 25 + left, y: self.unitNameTextField?.frame.maxY ?? 0, width: self.view.frame.size.width - 50 - left - right, height: 90)
        self.countryTextField?.frame = CGRect(x: 25 + left, y: self.emailTextField?.frame.maxY ?? 0, width: self.view.frame.size.width - 50 - left - right, height: 90)
        self.purposeTextField?.frame = CGRect(x: 25 + left, y: self.countryTextField?.frame.maxY ?? 0, width: self.view.frame.size.width - 50 - left - right, height: 90)
        self.saveLabel?.frame = CGRect(x: 25 + left, y: self.purposeTextField?.frame.maxY ?? 0, width: 100, height: 50)
        self.saveSwitch?.frame = CGRect(x: self.view.frame.size.width - 75 - right, y: (self.purposeTextField?.frame.maxY ?? 0) + 5, width: 50, height: 50)
        self.OKBtn?.frame = CGRect(x: 25 + left, y: (self.saveLabel?.frame.maxY ?? 0) + 10, width: self.view.frame.size.width - 50 - left - right, height: 50)
        self.countryBtn?.frame = self.countryTextField?.bounds ?? .zero
        self.purposeBtn?.frame = self.purposeTextField?.bounds ?? .zero
        
        if let coutryPropertyTableView = self.coutryPropertyTableView {
            coutryPropertyTableView.frame = self.view.frame
        }
        
        if let purposePropertyTableView = self.purposePropertyTableView {
            purposePropertyTableView.frame = self.view.frame
        }
    }
    
    // MARK: - CHeaderViewDelegate
    
    func CHeaderViewBack(_ headerView: CHeaderView) {
        dismiss(animated: true)
    }
    
    func CHeaderViewCancel(_ headerView: CHeaderView) {
        dismiss(animated: true)
    }
    
    // MARK: - CCreateCertificateViewControllerDelegate
    
    func createCertificateViewController(_ createCertificateViewController: CreateCertificateViewPasswordController, PKCS12Cert path: String, password: String, config: CPDFSignatureConfig) {
        delegate?.createCertificateInfoViewControllerSave?(self, PKCS12Cert: path, password: password, config: config)
    }
    
    func createCertificateViewPasswordControllerCancel(_ createCertificateViewController: CreateCertificateViewPasswordController) {
        delegate?.createCertificateInfoViewControllerCancel?(self)
    }
    
    // MARK: - CInputTextFieldDelegate
    
    func setCInputTextFieldBegin(_ inputTextField: CInputTextField) {
        if countryTextField == inputTextField {
            
        }
    }
    
    func setCInputTextFieldChange(_ inputTextField: CInputTextField, text: String) {
        if (nameTextField?.inputTextField?.text?.count ?? 0) > 0 && (emailTextField?.inputTextField?.text?.count ?? 0) > 0 {
            OKBtn?.backgroundColor = .blue
            OKBtn?.isEnabled = true
        } else {
            OKBtn?.backgroundColor = UIColor(red: 221.0/255.0, green: 233.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            OKBtn?.isEnabled = false
        }
    }
    
    // MARK: - Private Methodds
    
    private func reloadData() {
        let countryCodes = Locale.isoRegionCodes
        self.codes = countryCodes
        var codes: [String] = []
        
        let localeID = Locale.current.identifier
        let components = Locale.components(fromIdentifier: localeID)
        
        if let countryCode = components[NSLocale.Key.countryCode.rawValue] {
            for countryCode in countryCodes {
                let identifier = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: countryCode])
                let country = (NSLocale(localeIdentifier: "en_UK").displayName(forKey: .identifier, value: identifier))
                codes.append("\(countryCode) - \(String(describing: country))")
            }
        }
        
        self.coutryCodes = codes
        
        if let dex = countryCodes.firstIndex(of: NSLocale.current.regionCode ?? "") {
            if dex >= 0 && dex < countryCodes.count {
                // Handle index as needed
            }
        }
        
        let sud = UserDefaults.standard
        
        var loginName = CPDFKitConfig.sharedInstance().annotationAuthor()
        if loginName == nil {
            loginName = NSFullUserName()
        }
        self.nameTextField?.inputTextField?.text = loginName
        self.unitTextField?.inputTextField?.text = sud.string(forKey: "CAuthenticationDepartment") ?? ""
        self.unitNameTextField?.inputTextField?.text = sud.string(forKey: "CAuthenticationCompanyName") ?? ""
        self.emailTextField?.inputTextField?.text = sud.string(forKey: "CAuthenticationEmailAddress") ?? ""
    }
    
    private func validateEmail(_ strEmail: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: strEmail)
    }

    private func popoverWarning() {
        let OKAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
            // Handler code here
        }
        let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Your message conforms to the format of an email.", comment: ""), preferredStyle: .alert)
        alert.addAction(OKAction)
        present(alert, animated: true, completion: nil)
    }

    private func tagString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss SS"
        let dateString = formatter.string(from: Date())
        return dateString
    }

    private func mergeAttributeString(_ normalText: String) -> NSAttributedString {
        let requiredText = "*"
        let attributedText = NSMutableAttributedString(string: normalText)

        let requiredAttributedText = NSMutableAttributedString(string: requiredText)
        requiredAttributedText.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location: 0, length: requiredAttributedText.length))

        attributedText.append(requiredAttributedText)
        return attributedText
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_ok(_ button: UIButton) {
        
        if !validateEmail(emailTextField?.inputTextField?.text ?? "") {
            popoverWarning()
            return
        }
        
        if (nameTextField?.inputTextField?.text?.count ?? 0) > 50 {
            let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil)
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Sorry, your name is too long. Creation failed.", comment: ""), preferredStyle: .alert)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
            
            nameTextField?.inputTextField?.text = ""
            
            OKBtn?.backgroundColor = UIColor(red: 221.0/255.0, green: 233.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            OKBtn?.isEnabled = false
            
            return
        }
        
        var certificateInfo = [String: Any]()
        certificateInfo["CN"] = nameTextField?.inputTextField?.text
        certificateInfo["emailAddress"] = emailTextField?.inputTextField?.text
        certificateInfo["C"] = coutryCode
        
        if let unitText = unitTextField?.inputTextField?.text, !unitText.isEmpty {
            certificateInfo["OU"] = unitText
        }
        
        if let unitNameText = unitNameTextField?.inputTextField?.text, !unitNameText.isEmpty {
            certificateInfo["O"] = unitNameText
        }
        
        let purposes = [NSLocalizedString("Digital Signatures", comment: ""), NSLocalizedString("Data Encryption", comment: ""), NSLocalizedString("Digital Signatures and Data Encryption", comment: "")]
        if let certUsage = purposes.firstIndex(of: purposeTextField?.inputTextField?.text ?? "") {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let writeDirectoryPath = path.appendingPathComponent("Signature")
            
            if !FileManager.default.fileExists(atPath: writeDirectoryPath.path) {
                do {
                    try FileManager.default.createDirectory(at: writeDirectoryPath, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Failed to create directory: \(error.localizedDescription)")
                }
            }
            
            let currentDateString = tagString()
            let writeFilePath = writeDirectoryPath.appendingPathComponent("CSignature-\(currentDateString).pfx")
            
            let createCertificateViewPasswordController = CreateCertificateViewPasswordController.init(annotation: annotation!)
            createCertificateViewPasswordController.delegate = self
            createCertificateViewPasswordController.isSaveFile = saveSwitch?.isOn ?? false
            createCertificateViewPasswordController.certUsage = .digSig
            createCertificateViewPasswordController.certificateInfo = certificateInfo
            createCertificateViewPasswordController.filePath = writeFilePath.path
            present(createCertificateViewPasswordController, animated: true, completion: nil)
        }
    }

    @objc func buttonItemClicked_country(_ button: UIButton) {
        coutryPropertyTableView = CDigitalPropertyTableView(frame: view.frame, height: 300)
        coutryPropertyTableView?.dataArray = coutryCodes
        coutryPropertyTableView?.data = countryTextField?.inputTextField?.text ?? ""
        coutryPropertyTableView?.delegate = self
        coutryPropertyTableView?.frame = view.frame
        coutryPropertyTableView?.showinView(view)
    }

    @objc func buttonItemClicked_purpose(_ button: UIButton) {
        purposePropertyTableView = CDigitalPropertyTableView(frame: view.frame, height: 150)
        purposePropertyTableView?.dataArray = [NSLocalizedString("Digital Signatures", comment: ""), NSLocalizedString("Data Encryption", comment: ""), NSLocalizedString("Digital Signatures and Data Encryption", comment: "")]
        purposePropertyTableView?.data = purposeTextField?.inputTextField?.text ?? ""
        purposePropertyTableView?.delegate = self
        purposePropertyTableView?.frame = view.frame
        purposePropertyTableView?.showinView(view)
    }

    @objc func selectChange_switch(_ sender: UISwitch) {
        // Handle switch state change
    }
    
    // MARK: - CDigitalPropertyTableViewDelegate
    
    func digitalPropertyTableViewSelect(_ digitalPropertyTableView: CDigitalPropertyTableView, text: String, index: Int) {
        if coutryPropertyTableView == digitalPropertyTableView {
            countryTextField?.inputTextField?.text = text
            coutryCode = codes[index]
            countryTextField?.inputTextField?.resignFirstResponder()
        } else if purposePropertyTableView == digitalPropertyTableView {
            purposeTextField?.inputTextField?.text = text
            purposeTextField?.inputTextField?.resignFirstResponder()
        }
    }
    
    // MARK: - NSNotification
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let frame = frameValue.cgRectValue
            let rect = emailTextField?.inputTextField?.convert(emailTextField?.inputTextField?.frame ?? CGRect.zero, to: self.view) ?? .zero
            if rect.maxY > self.view.frame.size.height - frame.size.height {
                var insets = self.scrollView?.contentInset
                insets?.bottom = frame.size.height + (self.emailTextField?.frame.size.height)!
                self.scrollView?.contentInset = insets!
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        var insets = self.scrollView?.contentInset
        insets?.bottom = 0
        self.scrollView?.contentInset = insets!
    }
    
}

//
//  CImportCertificateViewController.swift
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
import MobileCoreServices

@objc public protocol CImportCertificateViewControllerDelegate: NSObjectProtocol {
    @objc optional func importCertificateViewControllerSave(_ importCertificateViewController: CImportCertificateViewController, PKCS12Cert path: String, password: String, config: CPDFSignatureConfig)
    @objc optional func importCertificateViewControllerCancel(_ importCertificateViewController: CImportCertificateViewController)
}

public class CImportCertificateViewController: UIViewController,CHeaderViewDelegate,CInputTextFieldDelegate,CAddSignatureViewControllerDelegate,CPDFSignatureEditViewControllerDelegate,UIDocumentPickerDelegate {
    
    public weak var delegate: CImportCertificateViewControllerDelegate?
    
    var headerView: CHeaderView?
    var documentTextField: CInputTextField?
    var documentButton: UIButton?
    var passwordTextField: CInputTextField?
    var messageLabel: UILabel?
    var filePath: URL?
    var signatureCertificate: CPDFSignatureCertificate?
    var annotation: CPDFSignatureWidgetAnnotation?
    var scrollView: UIScrollView?
    var OKBtn: UIButton?
    var warningLabel: UILabel?
    var password: String?
    var digitalSignatureEditViewController: CPDFDigitalSignatureEditViewController?
    
    // MARK: - Initializers
    
    public init(p12FilePath filePath: URL, annotation: CPDFSignatureWidgetAnnotation) {
        super.init(nibName: nil, bundle: nil)
        
        self.filePath = filePath
        self.annotation = annotation
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Viewcontroller Methods
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.scrollView = UIScrollView()
        self.scrollView?.isScrollEnabled = true
        if scrollView != nil {
            self.view.addSubview(self.scrollView!)
        }
        
        self.password = ""
        
        self.headerView = CHeaderView()
        self.headerView?.titleLabel?.text = NSLocalizedString("Add A Digital ID", comment: "")
        self.headerView?.delegate = self
        self.headerView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        self.headerView?.layer.borderWidth = 1.0
        self.headerView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if headerView != nil {
            self.view.addSubview(self.headerView!)
        }
        
        self.messageLabel = UILabel()
        self.messageLabel?.numberOfLines = 3
        self.messageLabel?.font = UIFont.systemFont(ofSize: 12)
        self.messageLabel?.layer.cornerRadius = 4.0
        self.messageLabel?.layer.masksToBounds = true
        self.messageLabel?.adjustsFontSizeToFitWidth = true
        self.messageLabel?.text = NSLocalizedString("Browse a digital ID file. Digital ID cards are password-protected. If you do not know the password, you cannot obtain a digital ID card.", comment: "")
        self.messageLabel?.backgroundColor = CPDFColorUtils.CMessageLabelColor()
        self.messageLabel?.sizeToFit()
        if messageLabel != nil {
            scrollView?.addSubview(messageLabel!)
        }
        
        let button1 = UIButton(type: .system)
        button1.setImage(UIImage(named: "CDigitalSignatureViewControllerRight", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        button1.tintColor = UIColor.black
        button1.addTarget(self, action: #selector(buttonItemClicked_select(_:)), for: .touchUpInside)
        
        let button2 = UIButton(type: .system)
        button2.setImage(UIImage(named: "CDigitalSignatureViewControllerCancel", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        button2.tintColor = UIColor.gray
        button2.addTarget(self, action: #selector(buttonItemClicked_cancel(_:)), for: .touchUpInside)
        
        self.documentTextField = CInputTextField()
        self.documentTextField?.titleLabel?.text = NSLocalizedString("Certificate File", comment: "")
        self.documentTextField?.inputTextField?.text = self.filePath?.lastPathComponent
        self.documentTextField?.inputTextField?.rightView = button1
        self.documentTextField?.inputTextField?.rightViewMode = .always
        if documentTextField != nil {
            scrollView?.addSubview(documentTextField!)
        }
        
        self.documentButton = UIButton()
        self.documentButton?.backgroundColor = UIColor.clear
        self.documentButton?.addTarget(self, action: #selector(buttonItemClicked_select(_:)), for: .touchUpInside)
        if documentButton != nil {
            documentTextField?.addSubview(documentButton!)
        }
        
        self.passwordTextField = CInputTextField()
        self.passwordTextField?.delegate = self
        self.passwordTextField?.titleLabel?.text = NSLocalizedString("Passwords", comment: "")
        self.passwordTextField?.inputTextField?.placeholder = NSLocalizedString("Enter the password of the certificate file", comment: "")
        self.passwordTextField?.inputTextField?.isSecureTextEntry = true
        self.passwordTextField?.inputTextField?.clearButtonMode = .always
        if passwordTextField != nil {
            scrollView?.addSubview(passwordTextField!)
        }
        
        self.warningLabel = UILabel()
        self.warningLabel?.text = NSLocalizedString("Wrong Password", comment: "")
        self.warningLabel?.textColor = UIColor.red
        self.warningLabel?.font = UIFont.systemFont(ofSize: 13)
        if warningLabel != nil {
            scrollView?.addSubview(warningLabel!)
        }
        self.warningLabel?.isHidden = true
        
        self.OKBtn = UIButton(type: .custom)
        self.OKBtn?.setTitle(NSLocalizedString("OK", comment: ""), for: .normal)
        self.OKBtn?.addTarget(self, action: #selector(buttonItemClicked_ok(_:)), for: .touchUpInside)
        self.OKBtn?.setTitleColor(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0), for: .normal)
        self.OKBtn?.backgroundColor = UIColor(red: 221.0/255.0, green: 233.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        if OKBtn != nil {
            scrollView?.addSubview(OKBtn!)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.view.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
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
            self.scrollView?.frame = CGRect(x: 0, y: (self.headerView?.frame.maxY ?? 0) + 5, width: self.view.frame.size.width, height: self.view.frame.size.height - 100)
            self.scrollView?.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.OKBtn?.frame = CGRect(x: 25 + left, y: (self.scrollView?.frame.maxY ?? 0) - 140 - bottom, width: self.view.frame.size.width - 50 - left - right, height: 50)
        } else {
            self.scrollView?.frame = CGRect(x: 0, y: (self.headerView?.frame.maxY ?? 0) + 5, width: self.view.frame.size.width, height: self.view.frame.size.height + 100)
            self.scrollView?.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height + 200)
            self.OKBtn?.frame = CGRect(x: 25 + left, y: (self.scrollView?.frame.maxY ?? 0) - 140 - bottom, width: self.view.frame.size.width - 50 - left - right, height: 50)
        }
        
        self.messageLabel?.frame = CGRect(x: 25 + left, y: 20, width: self.view.frame.size.width - 50 - left - right, height: 90)
        self.documentTextField?.frame = CGRect(x: 25 + left, y: (self.messageLabel?.frame.maxY ?? 0) + 10, width: self.view.frame.size.width - 50 - left - right, height: 90)
        self.documentButton?.frame = self.documentTextField?.bounds ?? .zero
        self.passwordTextField?.frame = CGRect(x: 25 + left, y: (self.documentTextField?.frame.maxY ?? 0) + 10, width: self.view.frame.size.width - 50 - left - right, height: 90)
        self.warningLabel?.frame = CGRect(x: 25 + left, y: (self.passwordTextField?.frame.maxY ?? 0) + 10, width: 120, height: 30)
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_select(_ button: UIButton) {
        let documentTypes: [String] = [kUTTypePKCS12 as String]
        let documentPickerViewController = UIDocumentPickerViewController(documentTypes: documentTypes, in: .open)
        documentPickerViewController.delegate = self
        
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                self.present(documentPickerViewController, animated: true, completion: nil)
            }
        }
    }
    
    @objc func buttonItemClicked_cancel(_ button: UIButton) {
        OKBtn?.backgroundColor = UIColor(red: 221.0/255.0, green: 233.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        warningLabel?.isHidden = true
        passwordTextField?.inputTextField?.text = ""
    }
    
    @objc func buttonItemClicked_ok(_ button: UIButton) {
        signatureCertificate = CPDFSignatureCertificate(pkcs12Path: filePath?.path, password: password)
        if signatureCertificate != nil {
            digitalSignatureEditViewController = CPDFDigitalSignatureEditViewController()
            digitalSignatureEditViewController?.delegate = self
            let presentationController = SignatureCustomPresentationController(presentedViewController: digitalSignatureEditViewController!, presenting: self)
            digitalSignatureEditViewController?.transitioningDelegate = presentationController
            present(digitalSignatureEditViewController!, animated: true, completion: nil)
        } else {
            warningLabel?.isHidden = false
        }
    }
    
    // MARK: - Private Methods
    
    private func sortContents(_ contents: [CPDFSignatureConfigItem]) -> [CPDFSignatureConfigItem] {
        var tContents = [CPDFSignatureConfigItem]()
        
        var nameItem: CPDFSignatureConfigItem?
        var dnItem: CPDFSignatureConfigItem?
        var reaItem: CPDFSignatureConfigItem?
        var locaItem: CPDFSignatureConfigItem?
        var dateItem: CPDFSignatureConfigItem?
        var verItem: CPDFSignatureConfigItem?
        
        for item in contents {
            switch item.key {
            case NAME_KEY:
                nameItem = item
            case DN_KEY:
                dnItem = item
            case REASON_KEY:
                reaItem = item
            case LOCATION_KEY:
                locaItem = item
            case DATE_KEY:
                dateItem = item
            case VERSION_KEY:
                verItem = item
            default:
                break
            }
        }
        
        if let nameItem = nameItem {
            tContents.append(nameItem)
        }
        if let dateItem = dateItem {
            tContents.append(dateItem)
        }
        
        if let reaItem = reaItem {
            tContents.append(reaItem)
        }
        
        if let dnItem = dnItem {
            tContents.append(dnItem)
        }
        
        if let verItem = verItem {
            tContents.append(verItem)
        }
        if let locaItem = locaItem {
            tContents.append(locaItem)
        }
        
        return tContents
    }
    
    // MARK: - CHeaderViewDelegate
    
    func CHeaderViewBack(_ headerView: CHeaderView) {
        dismiss(animated: true)
    }
    
    func CHeaderViewCancel(_ headerView: CHeaderView) {
        dismiss(animated: true)
    }
    
    // MARK: - CInputTextFieldDelegate
    
    func setCInputTextFieldClear(_ inputTextField: CInputTextField) {
        OKBtn?.backgroundColor = UIColor(red: 221.0/255.0, green: 233.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        warningLabel?.isHidden = true
    }
    
    func setCInputTextFieldChange(_ inputTextField: CInputTextField, text: String) {
        if text.count == 0 {
            OKBtn?.backgroundColor = UIColor(red: 221.0/255.0, green: 233.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            warningLabel?.isHidden = true
        } else {
            OKBtn?.backgroundColor = UIColor.blue
            warningLabel?.isHidden = true
        }
        password = text
    }
    
    // MARK: - NSNotification
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let frame = frameValue.cgRectValue
            let rect = passwordTextField?.inputTextField?.convert(passwordTextField?.inputTextField?.frame ?? CGRect.zero, to: self.view) ?? .zero
            if rect.maxY > self.view.frame.size.height - frame.size.height {
                var insets = self.scrollView?.contentInset
                insets?.bottom = frame.size.height + (self.passwordTextField?.frame.size.height)!
                self.scrollView?.contentInset = insets!
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        var insets = self.scrollView?.contentInset
        insets?.bottom = 0
        self.scrollView?.contentInset = insets!
    }
    
    // MARK: - UIDocumentPickerDelegate
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let fileURL = urls.first {
            let fileUrlAuthorized = fileURL.startAccessingSecurityScopedResource()
            
            if fileUrlAuthorized {
                let fileCoordinator = NSFileCoordinator()
                var error: NSError?
                
                fileCoordinator.coordinate(readingItemAt: fileURL, options: [], error: &error) { newURL in
                    let documentFolder = NSHomeDirectory() + "/Documents/Files"
                    
                    if !FileManager.default.fileExists(atPath: documentFolder) {
                        try? FileManager.default.createDirectory(at: URL(fileURLWithPath: documentFolder), withIntermediateDirectories: true, attributes: nil)
                    }
                    
                    let documentPath = documentFolder + "/" + newURL.lastPathComponent
                    
                    if !FileManager.default.fileExists(atPath: documentPath) {
                        try? FileManager.default.copyItem(at: newURL, to: URL(fileURLWithPath: documentPath))
                    }
                    
                    let url = URL(fileURLWithPath: documentPath)
                    self.filePath = url
                    self.documentTextField?.inputTextField?.text = url.lastPathComponent
                }
                
                fileURL.stopAccessingSecurityScopedResource()
            }
        }
    }
    
    // MARK: - CPDFSignatureEditViewControllerDelegate
    
    func signatureEditViewController(_ signatureEditViewController: CPDFSignatureEditViewController, image: UIImage) {
        let signatureConfig = CPDFSignatureConfig()
        
        if signatureEditViewController.customType == .none {
            signatureConfig.image = nil
            signatureConfig.text = nil
            signatureConfig.isDrawOnlyContent = true
        } else {
            signatureConfig.image = image
        }
        
        signatureConfig.isContentAlginLeft = false
        signatureConfig.isDrawLogo = true
        signatureConfig.isDrawKey = true
        signatureConfig.logo = UIImage(named: "ImageNameDigitalSignature", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        
        var contents = signatureConfig.contents ?? []
        
        let configItem = CPDFSignatureConfigItem()
        configItem.key = NAME_KEY
        configItem.value = NSLocalizedString(self.signatureCertificate?.issuerDict["CN"] as? String ?? "", comment: "")
        contents.append(configItem)
        
        let configItem1 = CPDFSignatureConfigItem()
        configItem1.key = DATE_KEY
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        configItem1.value = dateFormatter.string(from: Date())
        contents.append(configItem1)
        
        
        signatureConfig.contents = sortContents(contents)
        
        annotation?.signAppearanceConfig(signatureConfig)
        
        let addSignatureViewController = CAddSignatureViewController(annotation: annotation!, signatureConfig: signatureConfig)
        addSignatureViewController.customType = signatureEditViewController.customType
        addSignatureViewController.delegate = self
        addSignatureViewController.signatureCertificate = signatureCertificate
        let presentationController = AAPLCustomPresentationController(presentedViewController: addSignatureViewController, presenting: signatureEditViewController)
        addSignatureViewController.transitioningDelegate = presentationController
        signatureEditViewController.present(addSignatureViewController, animated: true, completion: nil)
    }
    
    func signatureEditViewControllerCancel(_ signatureEditViewController: CPDFSignatureEditViewController) {
        delegate?.importCertificateViewControllerCancel?(self)
    }
    
    // MARK: - CAddSignatureViewControllerDelegate
    
    func CAddSignatureViewControllerSave(_ addSignatureViewController: CAddSignatureViewController, signatureConfig config: CPDFSignatureConfig) {
        password = passwordTextField?.inputTextField?.text
        delegate?.importCertificateViewControllerSave?(self, PKCS12Cert: filePath!.path, password: password ?? "", config: config)
        dismiss(animated: false)
    }
    
    func CAddSignatureViewControllerCancel(_ addSignatureViewController: CAddSignatureViewController) {
        digitalSignatureEditViewController?.refreshViewController()
    }
    
}

//
//  CCreateCertificateViewPasswordController.swift
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

@objc protocol CreateCertificateViewControllerDelegate: AnyObject {
    @objc optional func createCertificateViewController(_ createCertificateViewController: CreateCertificateViewPasswordController, PKCS12Cert path: String, password: String, config: CPDFSignatureConfig)
    @objc optional func createCertificateViewPasswordControllerCancel(_ createCertificateViewController: CreateCertificateViewPasswordController)
}

class CreateCertificateViewPasswordController: UIViewController, UIDocumentPickerDelegate, CHeaderViewDelegate, CInputTextFieldDelegate, CPDFSignatureEditViewControllerDelegate, CAddSignatureViewControllerDelegate {
    
    weak var delegate: CreateCertificateViewControllerDelegate?
    var isSaveFile: Bool = false
    var filePath: String?
    var certUsage: CPDFCertUsage = .digSig
    var certificateInfo: [String: Any]?
    
    private var headerView: CHeaderView?
    private var messageLabel: UILabel?
    private var fileTextField: CInputTextField?
    private var passwordTextField: CInputTextField?
    private var confirmPasswordTextField: CInputTextField?
    private var warningLabel: UILabel?
    private var OKBtn: UIButton?
    private var scrollView: UIScrollView?
    private var annotation: CPDFSignatureWidgetAnnotation?
    private var signatureCertificate: CPDFSignatureCertificate?
    private var shareBtn: UIButton?
    private var password: String?
    private var tempFilePath: String?
    private var digitalSignatureEditViewController: CPDFDigitalSignatureEditViewController?
    
    // MARK: - Initializers
    
    init(annotation: CPDFSignatureWidgetAnnotation) {
        self.annotation = annotation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Viewcontroller Methods
    
    override func viewDidLoad() {
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
        messageLabel?.text = NSLocalizedString("After you create and save this Digital ID, it can be used again.", comment: "")
        messageLabel?.backgroundColor = CPDFColorUtils.CMessageLabelColor()
        messageLabel?.adjustsFontSizeToFitWidth = true
        messageLabel?.sizeToFit()
        if messageLabel != nil {
            scrollView?.addSubview(messageLabel!)
        }
        
        if isSaveFile {
            fileTextField = CInputTextField()
            fileTextField?.delegate = self
            fileTextField?.titleLabel?.text = NSLocalizedString("Save Location", comment: "")
            fileTextField?.inputTextField?.text = filePath
            let hiddenView = UIView(frame: .zero)
            fileTextField?.inputTextField?.inputView = hiddenView
            if fileTextField != nil {
                scrollView?.addSubview(fileTextField!)
            }
            
            shareBtn = UIButton()
            shareBtn?.backgroundColor = .clear
            shareBtn?.addTarget(self, action: #selector(buttonItemClicked_share(_:)), for: .touchUpInside)
            fileTextField?.addSubview(shareBtn!)
        }
        
        passwordTextField = CInputTextField()
        passwordTextField?.delegate = self
        passwordTextField?.titleLabel?.text = NSLocalizedString("Set A Password", comment: "")
        passwordTextField?.inputTextField?.placeholder = NSLocalizedString("Please enter your password", comment: "")
        if passwordTextField != nil {
            scrollView?.addSubview(passwordTextField!)
        }
        
        confirmPasswordTextField = CInputTextField()
        confirmPasswordTextField?.delegate = self
        confirmPasswordTextField?.titleLabel?.text = NSLocalizedString("Confirm the Password", comment: "")
        confirmPasswordTextField?.inputTextField?.placeholder = NSLocalizedString("Enter the password again", comment: "")
        if confirmPasswordTextField != nil {
            scrollView?.addSubview(confirmPasswordTextField!)
        }
        
        warningLabel = UILabel()
        warningLabel?.text = NSLocalizedString("Password and confirm password does not match", comment: "")
        warningLabel?.textColor = .red
        warningLabel?.font = UIFont.systemFont(ofSize: 12)
        if warningLabel != nil {
            scrollView?.addSubview(warningLabel!)
        }
        warningLabel?.isHidden = true
        
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
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var top: CGFloat = 0
        var bottom: CGFloat = 0
        var left: CGFloat = 0
        var right: CGFloat = 0

        if #available(iOS 11.0, *) {
            bottom += view.safeAreaInsets.bottom
            top += view.safeAreaInsets.top
            left += view.safeAreaInsets.left
            right += view.safeAreaInsets.right
        }

        headerView?.frame = CGRect(x: 0, y: top, width: view.frame.size.width, height: 55)

        let currentOrientation = UIApplication.shared.statusBarOrientation

        if currentOrientation == .portrait || currentOrientation == .portraitUpsideDown {
            scrollView?.frame = CGRect(x: 0, y: 60, width: view.frame.size.width, height: view.frame.size.height - 70)
            scrollView?.contentSize = CGSize(width: view.frame.size.width, height: view.frame.size.height)
            OKBtn?.frame = CGRect(x: 25 + left, y: (scrollView?.frame.maxY ?? 0) - 150 - bottom, width: view.frame.size.width - 50 - left - right, height: 50)
        } else {
            scrollView?.frame = CGRect(x: 0, y: 60, width: view.frame.size.width, height: view.frame.size.height + 200)
            scrollView?.contentSize = CGSize(width: view.frame.size.width, height: view.frame.size.height + 450)
            OKBtn?.frame = CGRect(x: 25 + left, y: (scrollView?.frame.maxY ?? 0) - 150, width: view.frame.size.width - left - right - 50, height: 50)
        }

        messageLabel?.frame = CGRect(x: 25 + left, y: 20, width: view.frame.size.width - 50 - left - right, height: 90)

        if isSaveFile {
            fileTextField?.frame = CGRect(x: 25 + left, y: (messageLabel?.frame.maxY ?? 0) + 10, width: view.frame.size.width - 50 - left - right, height: 90)
            passwordTextField?.frame = CGRect(x: 25 + left, y: (fileTextField?.frame.maxY ?? 0) + 10, width: view.frame.size.width - 50 - left - right, height: 90)
            confirmPasswordTextField?.frame = CGRect(x: 25 + left, y: (passwordTextField?.frame.maxY ?? 0) + 10, width: view.frame.size.width - 50 - left - right, height: 90)
            warningLabel?.frame = CGRect(x: 25 + left, y: (confirmPasswordTextField?.frame.maxY ?? 0) + 10, width: view.frame.size.width - 50 - left - right, height: 30)
            shareBtn?.frame = fileTextField?.bounds ?? .zero
        } else {
            passwordTextField?.frame = CGRect(x: 25 + left, y: (messageLabel?.frame.maxY ?? 0) + 10, width: view.frame.size.width - 50 - left - right, height: 90)
            confirmPasswordTextField?.frame = CGRect(x: 25 + left, y: (passwordTextField?.frame.maxY ?? 0) + 10, width: view.frame.size.width - 50 - left - right, height: 90)
            warningLabel?.frame = CGRect(x: 25 + left, y: (confirmPasswordTextField?.frame.maxY ?? 0) + 10, width: view.frame.size.width - 50 - left - right, height: 30)
            shareBtn?.frame = fileTextField?.bounds ?? CGRect.zero
        }
    }
    
    // MARK: - CHeaderViewDelegate
    
    func CHeaderViewBack(_ headerView: CHeaderView) {
        dismiss(animated: true)
    }
    
    func CHeaderViewCancel(_ headerView: CHeaderView) {
        dismiss(animated: true)
    }
    
    // MARK: - CInputTextFieldDelegate
    
    func setCInputTextFieldChange(_ inputTextField: CInputTextField, text: String) {
        fileTextField?.inputTextField?.layer.borderWidth = 0.0
        passwordTextField?.inputTextField?.layer.borderWidth = 0.0
        confirmPasswordTextField?.inputTextField?.layer.borderWidth = 0.0
        fileTextField?.inputTextField?.borderStyle = .roundedRect
        passwordTextField?.inputTextField?.borderStyle = .roundedRect
        confirmPasswordTextField?.inputTextField?.borderStyle = .roundedRect
        warningLabel?.isHidden = true

        if isSaveFile {
            if fileTextField?.inputTextField?.text?.count ?? 0 > 0 {
                OKBtn?.isEnabled = true
                OKBtn?.backgroundColor = UIColor.blue
            } else {
                OKBtn?.isEnabled = false
                OKBtn?.backgroundColor = UIColor(red: 221.0/255.0, green: 233.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                fileTextField?.inputTextField?.borderStyle = .none
                fileTextField?.inputTextField?.layer.borderWidth = 1.0
                fileTextField?.inputTextField?.layer.borderColor = UIColor.red.cgColor
            }
        } else {
            if passwordTextField?.inputTextField?.text?.count ?? 0 > 0 && confirmPasswordTextField?.inputTextField?.text?.count ?? 0 > 0 {
                OKBtn?.isEnabled = true
                OKBtn?.backgroundColor = UIColor.blue
                fileTextField?.inputTextField?.layer.borderColor = UIColor.red.cgColor
            } else {
                OKBtn?.isEnabled = false
                OKBtn?.backgroundColor = UIColor(red: 221.0/255.0, green: 233.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            }
        }
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_ok(_ button: UIButton) {
        if confirmPasswordTextField?.inputTextField?.text == passwordTextField?.inputTextField?.text {
            var dic = [String: Any]()
            dic[SAVEFILEPATH_KEY] = self.fileTextField?.inputTextField?.text ?? ""
            if passwordTextField?.inputTextField?.text?.count ?? 0 > 0 {
                dic[PASSWORD_KEY] = passwordTextField?.inputTextField?.text
            }

            switch self.certUsage {
            case .digSig:
                self.certUsage = .digSig
            case .dataEnc:
                self.certUsage = .dataEnc
            default:
                self.certUsage = .all
            }

            let save = CPDFSignature.generatePKCS12Cert(withInfo: self.certificateInfo, password: passwordTextField?.inputTextField?.text, toPath: self.filePath, certUsage: self.certUsage)

            if !save {
                print("Save failed!")
            }

            self.signatureCertificate = CPDFSignatureCertificate(pkcs12Path: filePath ?? "", password: passwordTextField?.inputTextField?.text ?? "")

            self.password = passwordTextField?.inputTextField?.text ?? ""

            self.digitalSignatureEditViewController = CPDFDigitalSignatureEditViewController()
            self.digitalSignatureEditViewController?.delegate = self
            var presentationController: SignatureCustomPresentationController? // NS_VALID_UNTIL_END_OF_SCOPE;
            presentationController = SignatureCustomPresentationController(presentedViewController: self.digitalSignatureEditViewController!, presenting: self)
            self.digitalSignatureEditViewController?.transitioningDelegate = presentationController
            self.present(self.digitalSignatureEditViewController!, animated: true, completion: nil)
        } else {
            OKBtn?.isEnabled = false
            warningLabel?.isHidden = false
            OKBtn?.backgroundColor = UIColor(red: 221.0/255.0, green: 233.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            passwordTextField?.inputTextField?.borderStyle = .none
            passwordTextField?.inputTextField?.layer.borderWidth = 1.0
            confirmPasswordTextField?.inputTextField?.borderStyle = .none
            confirmPasswordTextField?.inputTextField?.layer.borderWidth = 1.0
            passwordTextField?.inputTextField?.layer.borderColor = UIColor.red.cgColor
            confirmPasswordTextField?.inputTextField?.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    @objc func buttonItemClicked_share(_ button: UIButton) {
        let path = NSHomeDirectory() + "/Documents"
        let writeDirectoryPath = "\(path)/Signature"
        tempFilePath = "\(writeDirectoryPath)/\(URL(fileURLWithPath: filePath ?? "").lastPathComponent)"

        CPDFSignature.generatePKCS12Cert(withInfo: certificateInfo, password: "1", toPath: tempFilePath, certUsage: .digSig)

        let documentPicker = UIDocumentPickerViewController(url: URL(fileURLWithPath: tempFilePath ?? ""), in: .exportToService)
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
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
    
    private func openFile(with url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityVC.definesPresentationContext = true
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityVC.popoverPresentationController?.sourceView = self.fileTextField
            activityVC.popoverPresentationController?.sourceRect = self.fileTextField?.bounds ?? .zero
        }
        present(activityVC, animated: true)
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
        delegate?.createCertificateViewPasswordControllerCancel?(self)
    }
    
    // MARK: - UIDocumentPickerDelegate
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let pickedURL = urls.first {
            pickedURL.startAccessingSecurityScopedResource()

            self.filePath = pickedURL.path
            self.fileTextField?.inputTextField?.text = self.filePath ?? ""

            // Remove the tempFilePath, if it exists
            if FileManager.default.fileExists(atPath: self.tempFilePath ?? "") {
                try? FileManager.default.removeItem(atPath: self.tempFilePath ?? "")
            }

            // Check if pickedURL exists before changing its permissions
            if FileManager.default.fileExists(atPath: pickedURL.path) {
                do {
                    try FileManager.default.setAttributes([.posixPermissions: NSNumber(value: 0o644)], ofItemAtPath: pickedURL.path)
                } catch {
                    print("Failed to set file permissions: \(error.localizedDescription)")
                }
            } else {
                print("File does not exist at path: \(pickedURL.path)")
            }

            // Check if self.filePath exists before attempting to delete it
            if FileManager.default.fileExists(atPath: self.filePath ?? "") {
                do {
                    try FileManager.default.removeItem(atPath: self.filePath ?? "")
                } catch {
                    print("File deletion failure: \(error.localizedDescription)")
                }
            } else {
                print("File does not exist at path: \(self.filePath ?? "")")
            }
        }
    }
    
    // MARK: - NSNotification
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let frame = frameValue.cgRectValue
            let rect = confirmPasswordTextField?.inputTextField?.convert(confirmPasswordTextField?.inputTextField?.frame ?? CGRect.zero, to: self.view) ?? .zero
            if rect.maxY > self.view.frame.size.height - frame.size.height {
                var insets = self.scrollView?.contentInset
                insets?.bottom = frame.size.height + (self.confirmPasswordTextField?.frame.size.height)!
                self.scrollView?.contentInset = insets!
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        var insets = self.scrollView?.contentInset
        insets?.bottom = 0
        self.scrollView?.contentInset = insets!
    }
    
    // MARK: - CAddSignatureViewControllerDelegate
    
    func CAddSignatureViewControllerSave(_ addSignatureViewController: CAddSignatureViewController, signatureConfig config: CPDFSignatureConfig) {
        password = passwordTextField?.inputTextField?.text
        delegate?.createCertificateViewController?(self, PKCS12Cert: filePath ?? "", password: password ?? "", config: config)
        dismiss(animated: false)
    }
    
    func CAddSignatureViewControllerCancel(_ addSignatureViewController: CAddSignatureViewController) {
        digitalSignatureEditViewController?.refreshViewController()
    }
    
}

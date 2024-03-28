//
//  CPDFSecureViewController.swift
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

public class CPDFSecureViewController: UIViewController, UITextFieldDelegate {
    private var pdfDocument:CPDFDocument?
    
    private var filePath:String!
    
    private var password:String?
    
    private var shareBtn: UIButton?
    
    private var scrollView: UIScrollView?
    
    private var openPasswordLabel:UILabel?
    
    private var openPasswordSwitch:UISwitch?
    private var openPasswordField:UITextField?
    
    private var line1:UIView?
    
    private var owerPasswordLabel:UILabel?
    
    private var owerPasswordSwitch:UISwitch?
    private var owerPasswordField:UITextField?
    
    private var line2:UIView?
    private var line3:UIView?
    
    private var printBtn:UIButton?
    private var copyBtn:UIButton?
    private var printViewBtn:UIButton?
    private var copyViewBtn:UIButton?
    private var printLabel:UILabel?
    private var copyLabel:UILabel?
    
    private var levelLabel:UILabel?
    private var levelSubLabel:UILabel?
    private var levelImage:UIImageView?
    private var levelBtn:UIButton?
    
    private var contentView1:UIView?
    private var contentView2:UIView?
    private var levelType:CPDFDocumentEncryptionLevel = .noEncryptAlgo
    
    private var isHaveOpenPassword = false
    
    public init(filePath: String,password:String?) {
        super.init(nibName: nil, bundle: nil)
        
        self.filePath = filePath
        
        self.password = password;
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Security Settings", comment: "");
        
        shareBtn = UIButton()
        shareBtn?.setTitle(NSLocalizedString("Share", comment: ""), for: .normal)
        shareBtn?.addTarget(self, action: #selector(buttonItemClick_Share(_:)), for: .touchUpInside)
        shareBtn?.sizeToFit()
        if shareBtn != nil {
            let shareBarItem = UIBarButtonItem(customView: shareBtn!)
            self.navigationItem.rightBarButtonItems = [shareBarItem]
        }

        let backItem = UIBarButtonItem(image: UIImage(named: "CPDFViewImageBack", in: Bundle(for: self.classForCoder), compatibleWith: nil), style: .plain, target: self, action: #selector(buttonItemClicked_back(_:)))
        self.navigationItem.leftBarButtonItems = [backItem]
        
        let document = CPDFDocument(url: NSURL.fileURL(withPath: self.filePath))
        // have open PassWord or have open+ower
        if(document?.isLocked == true) {
            isHaveOpenPassword = true
        }
        if((self.password?.count ?? 0) > 0) {
            if ((document?.unlock(withPassword: self.password)) == false) {
                dismiss(animated: true)
                return
            }
        }
        pdfDocument = document
        
        configUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        refreshShareButton()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        var offstX = 10
        if #available(iOS 11.0, *) {
            offstX += Int(self.view.safeAreaInsets.left)
        }
        
        var offstR = 10
        if #available(iOS 11.0, *) {
            offstR += Int(self.view.safeAreaInsets.right)
        }
        
        var offstY = 0
        openPasswordSwitch?.frame = CGRect(x: Int((scrollView?.frame.size.width ?? 0)) - Int(openPasswordSwitch?.width ?? 0) - offstR, y: offstY+7, width: Int(openPasswordSwitch?.width ?? 0), height: 30)
        let w = Int(scrollView?.frame.size.width ?? 0) - offstX - Int(openPasswordSwitch?.frame.size.width ?? 0) - offstR  - 5
        openPasswordLabel?.frame = CGRect(x: offstX, y: offstY, width:w, height: 20)
        openPasswordLabel?.centerY = openPasswordSwitch?.centerY ?? 0
        offstY = Int((openPasswordSwitch?.frame.maxY ?? 0) + 7)
        
        line1?.frame = CGRect(x: offstX, y: offstY, width: Int(scrollView?.frame.size.width ?? 0) - offstX - offstR, height: 1)
        offstY += 1
        
        let w1 = Int(self.scrollView?.frame.width ?? 0) - offstX - offstR
        openPasswordField?.frame = CGRect(x: offstX, y: offstY+12, width: w1, height: 25)
        offstY = Int(((openPasswordField?.frame.maxY ?? 0) + 12))
        
        contentView1?.frame = CGRect(x: 0, y: offstY, width: Int(scrollView?.frame.size.width ?? 0), height: 20)
        offstY += 20
        
        owerPasswordSwitch?.frame = CGRect(x: Int(scrollView?.frame.size.width ?? 0) - Int(owerPasswordSwitch?.width ?? 0) - offstR, y: offstY+7, width: Int(owerPasswordSwitch?.width ?? 0), height: 30)
        owerPasswordLabel?.frame = CGRect(x: offstX, y: offstY, width:Int(scrollView?.frame.size.width ?? 0) - offstX - Int(openPasswordSwitch?.frame.size.width ?? 0) - 5 - offstR, height: 20)
        owerPasswordLabel?.centerY = owerPasswordSwitch?.centerY ?? 0
        offstY = Int(((owerPasswordSwitch?.frame.maxY ?? 0) + 7))
        
        line2?.frame = CGRect(x: offstX, y: offstY, width: Int(scrollView?.frame.size.width ?? 0) - offstX - offstR, height: 1)
        offstY += 1
        
        let w2 = Int(self.scrollView?.frame.width ?? 0) - offstX - offstR
        owerPasswordField?.frame = CGRect(x: offstX, y: offstY+12, width: w2, height: 20)
        offstY = Int(((owerPasswordField?.frame.maxY ?? 0) + 12))
        
        line3?.frame = CGRect(x: offstX, y: offstY, width: Int((scrollView?.frame.size.width ?? 0)) - offstX - offstR, height: 1)
        offstY += 1
        
        printBtn?.frame = CGRect(x: offstX, y: offstY+12, width: 20, height: 20)
        printLabel?.frame = CGRect(x: (printBtn?.frame.maxX ?? 0) + 5, y: CGFloat(offstY + 12), width: self.view.width - 35, height: 20)
        printViewBtn?.frame = CGRect(x:0, y: CGFloat(offstY), width: self.scrollView?.width ?? 0, height:44)
        offstY = Int(((printBtn?.frame.maxY ?? 0) + 12))
        
        
        copyBtn?.frame = CGRect(x: offstX, y: offstY+12, width: 20, height: 20)
        copyLabel?.frame = CGRect(x: (copyBtn?.frame.maxX ?? 0) + 5, y: CGFloat(offstY + 12), width: self.view.width - 35, height: 20)
        copyViewBtn?.frame = CGRect(x:0, y:CGFloat(offstY), width: self.scrollView?.width ?? 0, height:44)
        offstY = Int(((copyBtn?.frame.maxY ?? 0) + 12))
        
        contentView2?.frame = CGRect(x: 0, y: offstY, width: Int(scrollView?.frame.size.width ?? 0), height:20)
        offstY += 20
        
        levelImage?.frame = CGRect(x: Int(self.scrollView?.width ?? 0) - 20 - offstR, y: offstY + 12, width: 20, height: 20)
        levelSubLabel?.frame = CGRect(x: Int(self.scrollView?.width ?? 0) - Int(levelImage?.frame.width ?? 0) - 5 - offstR - 120, y: offstY + 12, width: 120, height: 20)
        levelLabel?.frame = CGRect(x: offstX, y: offstY+12, width: Int((self.scrollView?.width ?? 0) - (levelSubLabel?.frame.width ?? 0) - 5) - offstR - 20, height: 20)
        levelBtn?.frame = CGRect(x: 0, y: CGFloat(offstY), width: self.scrollView?.width ?? 0, height: 44.0)
        offstY = Int(((levelBtn?.frame.maxY ?? 0) + 10))
        
        scrollView?.contentSize = CGSize(width: scrollView?.frame.width ?? 0, height: CGFloat(offstY))
    }
    
    // MARK: - Action
    @objc func buttonItemClick_Share(_ button: UIBarButtonItem) {
        let openPassWord = self.openPasswordField?.text
        let owerPassWord = self.owerPasswordField?.text
        
        if self.owerPasswordSwitch?.isOn == true && self.openPasswordSwitch?.isOn == true && (openPassWord?.count ?? 0) > 0 && (owerPassWord?.count ?? 0) > 0 && openPassWord == owerPassWord {
            errMsgTip(NSLocalizedString("The password can't be empty.", comment: ""))
            return
        }
        
        if self.openPasswordSwitch?.isOn == true && openPassWord?.count == 0 {
            errMsgTip(NSLocalizedString("The password can't be empty.", comment: ""))
            return
        }
        
        if self.owerPasswordSwitch?.isOn == true && owerPassWord?.count == 0 {
            errMsgTip(NSLocalizedString("The password can't be empty.", comment: ""))
            return
        }
        
        if (!(FileManager.default.fileExists(atPath: TEMPOARTFOLDER))) {
            try? FileManager.default.createDirectory(atPath: TEMPOARTFOLDER, withIntermediateDirectories: true, attributes: nil)
        }
        
        guard let lastPathComponent = self.pdfDocument?.documentURL.deletingPathExtension().lastPathComponent else { return  }
        
        var isSuccess = false
        
        var secPath = ""
        
        if(self.openPasswordSwitch?.isOn == false && self.owerPasswordSwitch?.isOn == false) {
            
            secPath = TEMPOARTFOLDER + "/" + lastPathComponent + "_Password_Removed.pdf"
            do {
                try FileManager.default.removeItem(atPath: secPath)
            } catch {
                // Handle the error, e.g., print an error message or perform other actions
            }
            
            
            
            isSuccess = ((pdfDocument?.writeDecrypt(to: NSURL(fileURLWithPath: secPath) as URL)) == true)
        } else {
            secPath = TEMPOARTFOLDER + "/" + lastPathComponent + "_Encrypted.pdf"
            do {
                try FileManager.default.removeItem(atPath: secPath)
            } catch {
                // Handle the error, e.g., print an error message or perform other actions
            }
            
            var options:[CPDFDocumentWriteOption: Any] = [:]
            if(openPassWord?.count ?? 0 > 0) {
                options[CPDFDocumentWriteOption.userPasswordOption] = openPassWord
            }
            
            if(owerPassWord?.count ?? 0 > 0) {
                options[CPDFDocumentWriteOption.ownerPasswordOption] = owerPassWord
            }
            
            if self.printBtn?.isSelected == true {
                options[CPDFDocumentWriteOption.allowsPrintingOption] = false
            } else {
                options[CPDFDocumentWriteOption.allowsPrintingOption] = true
            }
            
            if self.copyBtn?.isSelected == true {
                options[CPDFDocumentWriteOption.allowsCopyingOption] = false
            } else {
                options[CPDFDocumentWriteOption.allowsCopyingOption] = true
            }
            
            options[CPDFDocumentWriteOption.encryptionLevelOption] = NSNumber(value: self.levelType.rawValue)
            
            isSuccess = (pdfDocument?.write(to: NSURL(fileURLWithPath: secPath) as URL, withOptions: options) == true)
        }
        
        if isSuccess == true {
            self.shareAction(url: NSURL(fileURLWithPath: secPath) as URL)
        }
        
    }
    
    func shareAction(url: URL?) {
        if (url != nil) {
            let activityVC = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
            activityVC.definesPresentationContext = true
            if UI_USER_INTERFACE_IDIOM() == .pad {
                activityVC.popoverPresentationController?.sourceView = self.navigationController?.navigationBar ?? self.view
                activityVC.popoverPresentationController?.sourceRect = CGRect(x:self.navigationController?.navigationBar.width ?? 0, y:0, width: 0, height: 0)
            }
            self.present(activityVC, animated: true) {
                self.navigationController?.popViewController(animated: false)
            }
            activityVC.completionWithItemsHandler = { (activityType, completed, returnedItems, activityError) in
                if completed {
                    print("Success!")
                } else {
                    print("Failed Or Canceled!")
                    
                }
            }
        }
    }
    
    func refreshShareButton() {
        let openPassWord = self.openPasswordField?.text ?? ""
        let owerPassWord = self.owerPasswordField?.text ?? ""
        
        if self.owerPasswordSwitch?.isOn == true && self.openPasswordSwitch?.isOn == true && openPassWord.count > 0 && owerPassWord.count > 0 && openPassWord == owerPassWord {
            shareBtn?.setTitleColor(.gray, for: .normal)
            return
        } else {
            shareBtn?.setTitleColor(UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0), for: .normal)
        }
        
        if self.openPasswordSwitch?.isOn == true && openPassWord.count == 0 {
            shareBtn?.setTitleColor(.gray, for: .normal)
            return
        } else {
            shareBtn?.setTitleColor(UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0), for: .normal)
        }
        
        if self.owerPasswordSwitch?.isOn == true && owerPassWord.count == 0 {
            shareBtn?.setTitleColor(.gray, for: .normal)
            return
        } else {
            shareBtn?.setTitleColor(UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0), for: .normal)
        }
        
    }
    
    @objc func buttonItemClicked_back(_ button: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func buttonItemClicked_openPassword(_ button: UISwitch) {
       
        if (openPasswordSwitch?.isOn == true) {
            openPasswordField?.isEnabled = true
            
        } else {
            openPasswordField?.text = ""
            openPasswordField?.isEnabled = false
        }
        
        hiddenLevel()
        refreshShareButton()
    }
    
    @objc func buttonItemClicked_owerPassword(_ button: UISwitch) {
       
        if (owerPasswordSwitch?.isOn == true) {
            printViewBtn?.isEnabled = true
            copyViewBtn?.isEnabled = true
            
            owerPasswordField?.isEnabled = true
            
            if #available(iOS 13.0, *) {
                printLabel?.textColor = UIColor.label
                copyLabel?.textColor = UIColor.label
                
            } else {
                printLabel?.textColor = UIColor.black
                copyLabel?.textColor = UIColor.black
                
            }
        } else {
            printViewBtn?.isEnabled = false
            copyViewBtn?.isEnabled = false
            
            owerPasswordField?.text = ""
            
            owerPasswordField?.isEnabled = false
            
            if #available(iOS 13.0, *) {
                printLabel?.textColor = UIColor.secondaryLabel
                copyLabel?.textColor = UIColor.secondaryLabel
                
            } else {
                printLabel?.textColor = UIColor.init(red: 153.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: 1.0)
                copyLabel?.textColor = UIColor.init(red: 153.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: 1.0)
                
            }
        }
        hiddenLevel()
        refreshShareButton()
    }
    
    @objc func buttonItemClicked_print(_ button: UIButton) {
        if printBtn?.isSelected == true {
            printBtn?.isSelected = false
        } else {
            printBtn?.isSelected = true
        }
    }
    
    @objc func buttonItemClicked_copy(_ button: UIButton) {
        if copyBtn?.isSelected == true {
            copyBtn?.isSelected = false
        } else {
            copyBtn?.isSelected = true
        }
    }
    
    @objc func buttonItemClicked_showOwerPassword(_ button: UIButton) {
        if button.isSelected == true {
            button.isSelected = false
            owerPasswordField?.isSecureTextEntry = true
        } else {
            button.isSelected = true
            owerPasswordField?.isSecureTextEntry = false
            
        }
    }
    
    @objc func buttonItemClicked_showOpenPassword(_ button: UIButton) {
        if button.isSelected == true {
            button.isSelected = false
            openPasswordField?.isSecureTextEntry = true
        } else {
            button.isSelected = true
            openPasswordField?.isSecureTextEntry = false
            
        }
    }
    
    
    @objc func buttonItemClicked_level(_ button: UIButton) {
        self.view.endEditing(true)
        
        let actionSheetController = UIAlertController(title: nil, message: NSLocalizedString("Encryption Level", comment: ""), preferredStyle: .alert)
        
        // Cancel
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
        }
        
        // 128-bit RC4
        let RC4Action = UIAlertAction(title: NSLocalizedString("128-bit RC4", comment: ""), style: .destructive) { (action) in
            self.levelSubLabel?.text = NSLocalizedString("128-bit RC4", comment: "")
            self.levelType = .RC4
        }
        
        // 128-bit AES
        let AES128Action = UIAlertAction(title: NSLocalizedString("128-bit AES" , comment: ""), style: .destructive) { (action) in
            self.levelSubLabel?.text = NSLocalizedString("128-bit AES", comment: "")
            self.levelType = .AES128
        }
        
        // 256-bit AES
        let AES256Action = UIAlertAction(title: NSLocalizedString("256-bit AES" , comment: ""), style: .destructive) { (action) in
            self.levelSubLabel?.text = NSLocalizedString("256-bit AES", comment: "")
            self.levelType = .AES256
        }
        
        actionSheetController.addAction(cancelAction)
        actionSheetController.addAction(RC4Action)
        actionSheetController.addAction(AES128Action)
        actionSheetController.addAction(AES256Action)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            actionSheetController.popoverPresentationController?.sourceView = button
            actionSheetController.popoverPresentationController?.sourceRect = button.bounds
        }
        
        present(actionSheetController, animated: true, completion: nil)
    }
    
    func errMsgTip(_ msg: String) {
        let alvc = UIAlertController(title: msg, message: "", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: NSLocalizedString("OK",comment: ""), style: .destructive) { (action) in
            // Add your action code here
        }
        
        alvc.addAction(okAction)
        present(alvc, animated: true, completion: nil)
    }
    
    
    private func configUI() {
        scrollView = UIScrollView()
        scrollView?.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
        scrollView?.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        scrollView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if scrollView != nil {
            view.addSubview(scrollView!)
        }
        
        openPasswordLabel = UILabel()
        openPasswordLabel?.font = UIFont.systemFont(ofSize: 15.0)
        openPasswordLabel?.text = NSLocalizedString("Password to Open the Document", comment: "")
        openPasswordLabel?.adjustsFontSizeToFitWidth = true
        if openPasswordLabel != nil {
            scrollView?.addSubview(openPasswordLabel!)
        }
        
        openPasswordSwitch = UISwitch()
        openPasswordSwitch?.addTarget(self, action: #selector(buttonItemClicked_openPassword(_:)), for: .valueChanged)
        if openPasswordSwitch != nil {
            scrollView?.addSubview(openPasswordSwitch!)
        }
        
        line1 = UIView(frame: CGRect.zero);
        line1?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.12)
        if line1 != nil {
            scrollView?.addSubview(line1!)
        }
        
        openPasswordField = UITextField()
        openPasswordField?.placeholder = NSLocalizedString("Please Enter the Password", comment: "")
        openPasswordField?.addTarget(self, action: #selector(textFieldTextChange(_:)), for: .editingChanged)
        openPasswordField?.borderStyle = .none
        openPasswordField?.textAlignment = .left
        openPasswordField?.isSecureTextEntry = true
        openPasswordField?.delegate = self
        openPasswordField?.font = UIFont.systemFont(ofSize: 13)
        openPasswordField?.returnKeyType = .done
        openPasswordField?.rightViewMode = .always
        if openPasswordField != nil {
            scrollView?.addSubview(openPasswordField!)
        }
        
        let openPasswordBtton = UIButton(type: .custom)
        openPasswordBtton.addTarget(self, action: #selector(buttonItemClicked_showOpenPassword(_:)), for: .touchUpInside)
        openPasswordBtton.setImage(UIImage(named: "CSecureImageInvisible", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        openPasswordBtton.setImage(UIImage(named: "CSecureImageVisible", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .selected)
        openPasswordBtton.frame = CGRect(x:0, y:0, width: 25, height: 25)
        openPasswordField?.rightView = openPasswordBtton
        
        contentView1 = UIView(frame: CGRect.zero);
        if contentView1 != nil {
            scrollView?.addSubview(contentView1!)
        }
        contentView1?.backgroundColor = CPDFColorUtils.CContentBackgroundColor()
        
        owerPasswordLabel = UILabel()
        openPasswordLabel?.font = UIFont.systemFont(ofSize: 15.0)
        owerPasswordLabel?.text = NSLocalizedString("Owner Password", comment: "")
        owerPasswordLabel?.adjustsFontSizeToFitWidth = true
        if owerPasswordLabel != nil {
            scrollView?.addSubview(owerPasswordLabel!)
        }
        
        owerPasswordSwitch = UISwitch()
        owerPasswordSwitch?.addTarget(self, action: #selector(buttonItemClicked_owerPassword(_:)), for: .valueChanged)
        if owerPasswordSwitch != nil {
            scrollView?.addSubview(owerPasswordSwitch!)
        }
        
        line2 = UIView(frame: CGRect.zero);
        line2?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.12)
        if line2 != nil {
            scrollView?.addSubview(line2!)
        }
        
        owerPasswordField = UITextField()
        owerPasswordField?.placeholder = NSLocalizedString("Please enter the owner's password", comment: "")
        owerPasswordField?.addTarget(self, action: #selector(textFieldTextChange(_:)), for: .editingChanged)
        owerPasswordField?.borderStyle = .none
        owerPasswordField?.textAlignment = .left
        owerPasswordField?.isSecureTextEntry = true
        owerPasswordField?.delegate = self
        owerPasswordField?.font = UIFont.systemFont(ofSize: 11)
        owerPasswordField?.returnKeyType = .done
        owerPasswordField?.rightViewMode = .always
        if owerPasswordField != nil {
            scrollView?.addSubview(owerPasswordField!)
        }
        let owerPasswordBtton = UIButton(type: .custom)
        owerPasswordBtton.addTarget(self, action: #selector(buttonItemClicked_showOwerPassword(_:)), for: .touchUpInside)
        owerPasswordBtton.setImage(UIImage(named: "CSecureImageInvisible", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        owerPasswordBtton.setImage(UIImage(named: "CSecureImageVisible", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .selected)
        owerPasswordBtton.frame = CGRect(x:0, y:0, width:25, height:25)
        owerPasswordField?.rightView = owerPasswordBtton
        
        line3 = UIView(frame: CGRect.zero);
        line3?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.12)
        if line3 != nil {
            scrollView?.addSubview(line3!)
        }
        
        printBtn = UIButton(type: .custom)
        printBtn?.setImage(UIImage(named: "CAddSignatureCellNoSelect", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        printBtn?.setImage(UIImage(named: "CAddSignatureCellSelect", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .selected)
        if printBtn != nil {
            scrollView?.addSubview(printBtn!)
        }
        
        printViewBtn = UIButton(type: .custom)
        printViewBtn?.addTarget(self, action: #selector(buttonItemClicked_print(_:)), for: .touchUpInside)
        if printViewBtn != nil {
            scrollView?.addSubview(printViewBtn!)
        }
        
        printLabel = UILabel()
        printLabel?.font = UIFont.systemFont(ofSize: 13.0)
        printLabel?.text = NSLocalizedString("Restrict document printing", comment: "")
        printLabel?.adjustsFontSizeToFitWidth = true
        if printLabel != nil {
            scrollView?.addSubview(printLabel!)
        }
        
        copyBtn = UIButton(type: .custom)
        copyBtn?.setImage(UIImage(named: "CAddSignatureCellNoSelect", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        copyBtn?.setImage(UIImage(named: "CAddSignatureCellSelect", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .selected)
        if copyBtn != nil {
            scrollView?.addSubview(copyBtn!)
        }
        
        copyViewBtn = UIButton(type: .custom)
        copyViewBtn?.addTarget(self, action: #selector(buttonItemClicked_copy(_:)), for: .touchUpInside)
        if copyViewBtn != nil {
            scrollView?.addSubview(copyViewBtn!)
        }
        
        copyLabel = UILabel()
        copyLabel?.font = UIFont.systemFont(ofSize: 13.0)
        copyLabel?.text = NSLocalizedString("Restrict content copying", comment: "")
        copyLabel?.adjustsFontSizeToFitWidth = true
        if copyLabel != nil {
            scrollView?.addSubview(copyLabel!)
        }
        
        contentView2 = UIView(frame: CGRect.zero);
        if contentView2 != nil {
            scrollView?.addSubview(contentView2!)
        }
        contentView2?.backgroundColor = CPDFColorUtils.CContentBackgroundColor()
        
        levelLabel = UILabel()
        levelLabel?.font = UIFont.systemFont(ofSize: 13.0)
        levelLabel?.text = NSLocalizedString("Encryption Level", comment: "")
        levelLabel?.adjustsFontSizeToFitWidth = true
        if levelLabel != nil {
            scrollView?.addSubview(levelLabel!)
        }
        
        levelSubLabel = UILabel()
        levelSubLabel?.font = UIFont.systemFont(ofSize: 13.0)
        levelSubLabel?.text = NSLocalizedString("128 - bit RC4", comment: "")
        levelSubLabel?.adjustsFontSizeToFitWidth = true
        levelSubLabel?.textAlignment = .right
        if levelSubLabel != nil {
            scrollView?.addSubview(levelSubLabel!)
        }
        
        levelImage = UIImageView()
        levelImage?.image = UIImage(named: "CSecureImageGo", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        if levelImage != nil {
            scrollView?.addSubview(levelImage!)
        }
        levelBtn = UIButton(type: .custom)
        levelBtn?.addTarget(self, action: #selector(buttonItemClicked_level(_:)), for: .touchUpInside)
        if levelBtn != nil {
            scrollView?.addSubview(levelBtn!)
        }
        
        if (self.pdfDocument?.password != nil) {
            if(self.isHaveOpenPassword) {
                openPasswordSwitch?.setOn(true, animated: true)
                openPasswordField?.isEnabled = true
                
            } else {
                openPasswordSwitch?.setOn(false, animated: true)
                openPasswordField?.isEnabled = false
                
            }
            
            if (self.pdfDocument?.checkOwnerPassword(self.pdfDocument?.password!) == true) {
                owerPasswordSwitch?.setOn(true, animated: true)
                
                printViewBtn?.isEnabled = true
                copyViewBtn?.isEnabled = true
                
                owerPasswordField?.isEnabled = true
                
                if #available(iOS 13.0, *) {
                    printLabel?.textColor = UIColor.label
                    copyLabel?.textColor = UIColor.label
                    
                } else {
                    printLabel?.textColor = UIColor.black
                    copyLabel?.textColor = UIColor.black
                    
                }
                
                self.owerPasswordField?.text = self.pdfDocument?.password
            } else {
                owerPasswordSwitch?.setOn(false, animated: true)
                
                printViewBtn?.isEnabled = false
                copyViewBtn?.isEnabled = false
                
                owerPasswordField?.isEnabled = false
                
                if #available(iOS 13.0, *) {
                    printLabel?.textColor = UIColor.label
                    copyLabel?.textColor = UIColor.label
                    
                } else {
                    printLabel?.textColor = UIColor.init(red: 153.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: 1.0)
                    copyLabel?.textColor = UIColor.init(red: 153.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: 1.0)
                    
                }
                if(isHaveOpenPassword) {
                    self.openPasswordField?.text = self.pdfDocument?.password
                }
            }
        } else {
            openPasswordSwitch?.setOn(false, animated: true)
            owerPasswordSwitch?.setOn(false, animated: true)
            
            printViewBtn?.isEnabled = false
            copyViewBtn?.isEnabled = false
            
            openPasswordField?.isEnabled = false
            owerPasswordField?.isEnabled = false
            
            if #available(iOS 13.0, *) {
                printLabel?.textColor = UIColor.secondaryLabel
                copyLabel?.textColor = UIColor.secondaryLabel
                
            } else {
                printLabel?.textColor = UIColor.init(red: 153.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: 1.0)
                copyLabel?.textColor = UIColor.init(red: 153.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: 1.0)
                
            }
            
        }
        
        if self.pdfDocument?.allowsPrinting == false {
            printBtn?.isSelected = true
        } else {
            printBtn?.isSelected = false
        }
        
        if self.pdfDocument?.allowsCopying == false {
            copyBtn?.isSelected = true
        } else {
            copyBtn?.isSelected = false
        }
        
        switch self.pdfDocument?.encryptionLevel {
        case .AES128:
            self.levelSubLabel?.text = NSLocalizedString("128-bit AES", comment: "")
            self.levelType = .AES128
        case .AES256:
            self.levelSubLabel?.text = NSLocalizedString("256-bit AES", comment: "")
            self.levelType = .AES256
        case .RC4:
            self.levelSubLabel?.text = NSLocalizedString("128-bit RC4", comment: "")
            self.levelType = .RC4
        default:
            self.levelSubLabel?.text = NSLocalizedString("No Encrypt Algo", comment: "")
            self.levelType = .noEncryptAlgo
        }
        
        hiddenLevel()
    }
    
    func hiddenLevel() {
        if openPasswordSwitch?.isOn == false && owerPasswordSwitch?.isOn == false {
            levelBtn?.isHidden = true
            levelLabel?.isHidden = true
            levelSubLabel?.isHidden = true
            levelImage?.isHidden = true
        } else {
            levelBtn?.isHidden = false
            levelLabel?.isHidden = false
            levelSubLabel?.isHidden = false
            levelImage?.isHidden = false
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldTextChange(_ textField: UITextField) {
        refreshShareButton()
    }
    
    // MARK: - NSNotification
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let textFied:UITextField?
                if self.openPasswordField?.isFirstResponder == true {
                    textFied = self.openPasswordField
                } else {
                    textFied = self.owerPasswordField
                }
                
                let frame = value.cgRectValue
                let rect = textFied?.frame ?? CGRect.zero
                if rect.maxY > self.view.frame.size.height - frame.size.height {
                    var insets = self.scrollView?.contentInset
                    insets?.bottom = frame.size.height + (self.owerPasswordField?.frame.size.height ?? 0)
                    self.scrollView?.contentInset = insets ?? UIEdgeInsets.zero
                }
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        var insets = self.scrollView?.contentInset
        insets?.bottom = 0
        self.scrollView?.contentInset = insets ?? UIEdgeInsets.zero
    }
    
    
}

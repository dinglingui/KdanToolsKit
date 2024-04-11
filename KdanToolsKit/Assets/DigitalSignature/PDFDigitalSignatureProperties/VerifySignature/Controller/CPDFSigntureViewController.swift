//
//  CPDFSigntureViewController.swift
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

struct CPromptSignaturesState: OptionSet {
    public let rawValue: UInt
    
    static let failure = CPromptSignaturesState(rawValue: 1 << 0)
    static let unknown = CPromptSignaturesState(rawValue: 1 << 1)
    static let success = CPromptSignaturesState(rawValue: 1 << 2)
}

public class CPDFSigntureViewController: UIViewController {
    public var callback: (() -> Void)?
    public var expiredTrust: Bool = false
    
    private var imageView: UIImageView?
    private var textLabel: UILabel?
    private(set) var signatures: [CPDFSignature] = []
    private(set) var button: UIButton?
    private var type: CPromptSignaturesState = .success
    
    // MARK: - Viewcontroller Methods
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
        
        imageView = UIImageView(frame: CGRect(x: 10, y: view.frame.size.height/2 - 16, width: 32, height: 32))
        if imageView != nil {
            view.addSubview(imageView!)
        }
        
        button = UIButton(type: .custom)
        button?.setTitle(NSLocalizedString("Details", comment: ""), for: .normal)
        button?.titleLabel?.adjustsFontSizeToFitWidth = true
        button?.sizeToFit()
        button?.frame = CGRect(x: view.frame.size.width - 10 - (button?.frame.size.width ?? 0),
                               y: (view.frame.size.height - (button?.frame.size.height ?? 0))/2,
                               width: 68,
                               height: button?.frame.size.height ?? 0)
        button?.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
        button?.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        button?.setTitleColor(UIColor.systemBlue, for: .normal)
        if button != nil {
            view.addSubview(button!)
        }
        textLabel = UILabel(frame: CGRect(x: (imageView?.frame.maxX ?? 0) + 8,
                                          y: (view.frame.size.height - 20)/2,
                                          width: view.frame.size.width - 44 - (button?.frame.size.width ?? 0),
                                          height: 20))
        textLabel?.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        if #available(iOS 13.0, *) {
            textLabel?.textColor = UIColor.label
        } else {
            textLabel?.textColor = .black
        }
        if textLabel != nil {
            view.addSubview(textLabel!)
        }
        
        textLabel?.text = NSLocalizedString("Authenticating…", comment: "")
        button?.setTitle(NSLocalizedString("Details", comment: ""), for: .normal)
        updateCertState(signatures)
        
        view.backgroundColor = CPDFColorUtils.CVerifySignatureBackgroundColor()
        expiredTrust = false
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        button?.frame = CGRect(x: view.frame.size.width - 10 - (button?.frame.size.width ?? 0),
                               y: (view.frame.size.height - (button?.frame.size.height ?? 0))/2,
                               width: button?.frame.size.width ?? 0,
                               height: button?.frame.size.height ?? 0)
        textLabel?.frame = CGRect(x: (imageView?.frame.maxX ?? 0) + 8,
                                  y: (view.frame.size.height - 20)/2,
                                  width: view.frame.size.width - 44 - (button?.frame.size.width ?? 0),
                                  height: 20)
        
        imageView?.frame = CGRect(x: 10, y: view.frame.size.height/2 - 16, width: 32, height: 32)
    }
    
    // MARK: - Public Methods
    
    public func updateCertState(_ signatures: [CPDFSignature]) {
        self.signatures = signatures
        
        reloadData()
    }
    
    func reloadData() {
        var isSignVerified = true
        var isCertTrusted = true
        
        for signature in signatures {

            let signers = signature.signers
            if (signers != nil) {
                let signer = signers!.first
                guard let certificate = signer?.certificates.first else {
                    continue
                }
                
                certificate.checkIsTrusted()
                
                if let isCertTrusteds = signer?.isCertTrusted, !(isCertTrusteds) {
                    isCertTrusted = false
                    break
                }
            }
        }
        
        for signature in signatures {
            let signers = signature.signers
            if (signers != nil) {
                let signer = signers!.first
                if let isSignVerifieds = signer?.isSignVerified {
                    if !(isSignVerifieds) {
                        isSignVerified = false
                        break
                    }
                } else {
                    isSignVerified = false
                    break
                }
            }
        }
        
        if isSignVerified && isCertTrusted {
            type = .success
            imageView?.image = UIImage(named: "ImageNameSigntureVerifySuccess",
                                       in: Bundle(for: Swift.type(of: self)),
                                       compatibleWith: nil)
            textLabel?.text = NSLocalizedString("The signature is valid.", comment: "")
        } else if isSignVerified && !isCertTrusted {
            type = .unknown
            imageView?.image = UIImage(named: "ImageNameSigntureTrustedFailure",
                                       in: Bundle(for: Swift.type(of: self)),
                                       compatibleWith: nil)
            textLabel?.text = NSLocalizedString("Signature validity is unknown.", comment: "")
        } else {
            type = .failure
            imageView?.image = UIImage(named: "ImageNameSigntureVerifyFailure",
                                       in: Bundle(for: Swift.type(of: self)),
                                       compatibleWith: nil)
            
            if signatures.count > 1 {
                textLabel?.text = NSLocalizedString("At least one signature is invalid.", comment: "")
            } else {
                textLabel?.text = NSLocalizedString("The signature is invalid.", comment: "")
            }
        }
    }
    
    // MARK: - Action
    
    @objc private func buttonAction(_ sender: UIButton) {
        // Handle button action
        if let callback = callback {
            // Call the callback
            callback()
        }
    }
    
}

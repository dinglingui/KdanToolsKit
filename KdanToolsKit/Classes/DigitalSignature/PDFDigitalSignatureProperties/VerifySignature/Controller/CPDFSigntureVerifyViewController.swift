//
//  CPDFSigntureVerifyViewController.swift
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

public let CSignatureHaveChangeDidChangeNotification = NSNotification.Name("CSignatureHaveChangeDidChangeNotification")
public let CSignatureTrustCerDidChangeNotification = NSNotification.Name("CSignatureTrustCerDidChangeNotification")

@objc public protocol CPDFSigntureVerifyViewControllerDelegate: AnyObject {
    @objc optional func signtureVerifyViewControllerUpdate(_ signtureVerifyViewController: CPDFSigntureVerifyViewController)
}

public class CPDFSigntureVerifyViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CPDFSigntureVerifyDetailsViewControllerDelegate {
    
    public weak var delegate: CPDFSigntureVerifyViewControllerDelegate?
    public var signatures: [CPDFSignature] = []
    public var PDFListView: CPDFListView?
    
    private var tableView: UITableView?
    private var expiredTrust: Bool = false
    
    // MARK: - Viewcontroller Methods
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Certification Authority Statement", comment: "")
        
        let backItem = UIBarButtonItem(image: UIImage(named: "CPDFViewImageBack", in: Bundle(for: CPDFSigntureVerifyViewController.self), compatibleWith: nil), style: .plain, target: self, action: #selector(buttonItemClicked_back))
        self.navigationItem.leftBarButtonItems = [backItem]
        
        tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.tableFooterView = UIView()
        tableView?.separatorStyle = .none
        tableView?.estimatedRowHeight = 60
        tableView?.rowHeight = UITableView.automaticDimension
//        tableView?.register(CPDFSignatureVerifyCells.self, forCellReuseIdentifier: "cell3")
        tableView?.register(UINib(nibName: "CPDFSigntureVerifyCells", bundle:Bundle(for: CPDFSigntureVerifyViewController.self)), forCellReuseIdentifier: "cell3")
       
        if tableView != nil {
            view.addSubview(tableView!)
        }
        
        expiredTrust = false
    }
    
    // MARK: - Public Methods
    
    public func reloadData() {
        tableView?.reloadData()
    }
    
    public func stateString(at row: Int) -> String {
        let signature = signatures[row]
        
        let signers = signature.signers
        if (signers == nil) {
            return ""
        }

        guard let signer = signature.signers.first,
              let certificate = signer.certificates.first else {
            return ""
        }
        
        var isSignVerified = true
        var isCertTrusted = true
        
        if !signer.isCertTrusted {
            isCertTrusted = false
        }

        if !signer.isSignVerified {
            isSignVerified = false
        }

        certificate.checkIsTrusted()
        
        let currentDate = Date()
        let result = currentDate.compare(certificate.validityEnds)
        
        if result == .orderedAscending {
            self.expiredTrust = true
        } else {
            self.expiredTrust = false
        }
        
        var array: [String] = []
        
        if !signer.isCertTrusted {
            isCertTrusted = false
            array.append(NSLocalizedString("The signer's identity is invalid.", comment: ""))
        } else {
            array.append(NSLocalizedString("The signer's identity is valid.", comment: ""))
        }
        
        if isSignVerified && isCertTrusted {
            array.append(NSLocalizedString("The signature is valid.", comment: ""))
        } else if isSignVerified && !isCertTrusted {
            array.append(NSLocalizedString("Signature validity is unknown because it has not been included in your list of trusted certificates and none of its parent certificates are trusted certificates.", comment: ""))
        } else if !isSignVerified && !isCertTrusted {
            array.append(NSLocalizedString("The signature is invalid.", comment: ""))
        } else {
            array.append(NSLocalizedString("The signature is invalid.", comment: ""))
        }
        
        var isNoExpired = true

        for certificate in signer.certificates {
            let result = currentDate.compare(certificate.validityEnds)
            if result == .orderedDescending {
                isNoExpired = false
                break
            }
        }
        
        if !isNoExpired {
            array.append(NSLocalizedString("The file was signed with a certificate that has expired. If you acquired this file recently, it may not be authentic.", comment: ""))
        }
        
        if let modifyInfos = signature.modifyInfos, modifyInfos.count > 0 {
            array.append(NSLocalizedString("The document has been altered or corrupted since it was signed by the current user.", comment: ""))
        } else {
            array.append(NSLocalizedString("The document has not been modified since this signature was applied.", comment: ""))
        }
        
        return array.joined()
    }
    
    func popWarning(_ signature: CPDFSignature) {
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        let OKAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (action) in
            self.PDFListView?.document.removeSignature(signature)
            
            if let signatureWidgetAnnotation = signature.signatureWidgetAnnotation(with: self.PDFListView?.document) {
                signatureWidgetAnnotation.updateAppearanceStream()
                if let page = signatureWidgetAnnotation.page {
                    self.PDFListView?.setNeedsDisplayFor(page)
                }
            }
            
            var datas = self.signatures
            
            if let index = datas.firstIndex(of: signature) {
                datas.remove(at: index)
                NotificationCenter.default.post(name: Notification.Name("CSignatureHaveChangeDidChangeNotification"), object: self.PDFListView)
                self.signatures = datas
                self.tableView?.reloadData()
            }
        }
        let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Are you sure to delete?", comment: ""), preferredStyle: .alert)
        alert.addAction(cancelAction)
        alert.addAction(OKAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Action
    
    @objc func buttonItemClicked_back(_ button: UIButton) {
        // Handle the back button click
        navigationController?.dismiss(animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return signatures.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! CPDFSignatureVerifyCells

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"

        let signature = signatures[indexPath.row]
        if let signer = signature.signers.first, let certificate = signer.certificates.first {
            certificate.checkIsTrusted()
            
            let currentDate = Date()
            let result = currentDate.compare(certificate.validityEnds)
            
            var isSignVerified = true
            var isCertTrusted = true

            if result == .orderedAscending {
                expiredTrust = true
            } else {
                expiredTrust = false
            }
            
            if !signer.isCertTrusted {
                isCertTrusted = false
            }
            
            if !signer.isSignVerified {
                isSignVerified = false
            }
            
            var imageName: String
            if isSignVerified && isCertTrusted {
                imageName = "ImageNameSigntureVerifySuccess"
            } else if isSignVerified && !isCertTrusted {
                imageName = "ImageNameSigntureTrustedFailure"
            } else {
                imageName = "ImageNameSigntureVerifyFailure"
            }
            
            if let image = UIImage(named: imageName, in: Bundle(for: Self.self), compatibleWith: nil) {
                cell.verifyImageView?.image = image
            }
            
            cell.grantorsubLabel?.text = signature.name
            cell.expiredDateSubLabel?.text = dateFormatter.string(from: signature.date)
            let stateString = self.stateString(at: indexPath.row)
            cell.stateSubLabel?.text = stateString
            cell.deleteCallback = { [weak self] in
                guard let self = self else { return }
                
                self.popWarning(signature)
            }
        }

        return cell 
    }
    
    // MARK: - UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let signature = signatures[indexPath.row]
        let vc = CPDFSigntureVerifyDetailsViewController()
        vc.delegate = self
        let nav = CNavigationController(rootViewController: vc)
        vc.signature = signature
        present(nav, animated: true, completion: nil)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: - CPDFSigntureVerifyDetailsViewControllerDelegate
    
    public func signtureVerifyDetailsViewControllerUpdate(_ signtureVerifyDetailsViewController: CPDFSigntureVerifyDetailsViewController) {
        tableView?.reloadData()
        delegate?.signtureVerifyViewControllerUpdate?(self)
    }
    
}


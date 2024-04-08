//
//  CPDFSigntureVerifyDetailsViewController.swift
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

@objc public protocol CPDFSigntureVerifyDetailsViewControllerDelegate: AnyObject {
    @objc optional func signtureVerifyDetailsViewControllerUpdate(_ signtureVerifyDetailsViewController: CPDFSigntureVerifyDetailsViewController)
}

public class CPDFSigntureVerifyDetailsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CPDFSigntureListViewControllerDelegate {
    public weak var delegate: CPDFSigntureVerifyDetailsViewControllerDelegate?
    public var signature: CPDFSignature?
    public var PDFListView: CPDFListView?
    
    private var tableView: UITableView?
    private var detailsButton: UIButton?
    private var detailsArray: [String]?
    private var expiredTrust: Bool = false
    
    // MARK: - Viewcontroller Methods
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = NSLocalizedString("Digital Signature Details", comment: "")
        
        let backItem = UIBarButtonItem(image: UIImage(named: "CPDFViewImageBack", in: Bundle(for: CPDFSigntureVerifyDetailsViewController.self), compatibleWith: nil), style: .plain, target: self, action: #selector(buttonItemClicked_back))
        self.navigationItem.leftBarButtonItems = [backItem]
        
        detailInfo()
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height - 100), style: .plain)
        tableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.separatorStyle = .none
        tableView?.tableFooterView = UIView()
        tableView?.register(UINib(nibName: "CPDFSigntureVerifyDetailsCells", bundle: Bundle(for: CPDFSigntureVerifyDetailsViewController.self)), forCellReuseIdentifier: "cell1")
        tableView?.register(CPDFSigntureVerifyDetailsTopCell.self, forCellReuseIdentifier: "cell2")
      
        if tableView != nil {
            view.addSubview(tableView!)
        }
        
        detailsButton = UIButton(type: .custom)
        detailsButton?.setTitle(NSLocalizedString("View Certificate", comment: ""), for: .normal)
        detailsButton?.sizeToFit()
        detailsButton?.frame = CGRect(x: 10, y: tableView?.frame.maxY ?? 0, width: self.view.frame.size.width - 20, height: 40)
        detailsButton?.autoresizingMask = .flexibleWidth
        detailsButton?.addTarget(self, action: #selector(buttonClickItem_Details), for: .touchUpInside)
        detailsButton?.layer.cornerRadius = 5.0
        detailsButton?.layer.borderWidth = 1.0
        detailsButton?.layer.borderColor = UIColor.systemBlue.cgColor
        detailsButton?.setTitleColor(UIColor.systemBlue, for: .normal)
        if detailsButton != nil {
            view.addSubview(detailsButton!)
        }
        
        self.view.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        self.expiredTrust = false
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        detailsButton?.frame = CGRect(x: 10, y: tableView?.frame.maxY ?? 0, width: view.frame.size.width - 20, height: 40)
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_back(_ button: UIButton) {
        // Handle the back button click
        navigationController?.dismiss(animated: true)
    }
    
    @objc func buttonClickItem_Details(_ button: UIButton) {
        // Handle the back button click
        if let signer = self.signature?.signers.first {
            let vc = CPDFSigntureListViewController()
            vc.delegate = self
            let nav = CNavigationController(rootViewController: vc)
            vc.signer = signer
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    // MARK: - Private Methods
    
    private func detailInfo() {
        var isSignVerified = true
        var isCertTrusted = true
        let signer = self.signature?.signers.first
        let certificate = signer?.certificates.first
        
        certificate?.checkIsTrusted()
        
        let currentDate = Date()
        let result = currentDate.compare(certificate?.validityEnds ?? Date())
        
        if !(signer?.isCertTrusted ?? false) {
            isCertTrusted = false
        }

        if !(signer?.isSignVerified ?? false) {
            isSignVerified = false
        }
        
        if result == .orderedAscending {
            self.expiredTrust = true
        } else {
            self.expiredTrust = false
        }

        var array = [String]()
        if !(signer?.isCertTrusted ?? false) {
            isCertTrusted = false
            array.append(NSLocalizedString("The signer's identity is invalid.", comment: ""))
        } else {
            array.append(NSLocalizedString("The signer's identity is valid.", comment: ""))
        }

        if !(signer?.isSignVerified ?? false) {
            isSignVerified = false
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

        for certificate in signer?.certificates ?? [] {
            let result = currentDate.compare(certificate.validityEnds)
            if result == .orderedDescending {
                isNoExpired = false
                break
            }
        }
            
        if !isNoExpired {
            array.append(NSLocalizedString("The file was signed with a certificate that has expired. If you acquired this file recently, it may not be authentic.", comment: ""))
        }
        
        if let modifyInfos = self.signature?.modifyInfos, modifyInfos.count > 0 {
            array.append(NSLocalizedString("The document has been altered or corrupted since it was signed by the current user.", comment: ""))
        } else {
            array.append(NSLocalizedString("The document has not been modified since this signature was applied.", comment: ""))
        }
        self.detailsArray = array
    }
    
    // MARK: - UITableViewDataSource
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return detailsArray?.count ?? 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let signer = self.signature?.signers.first
//        let cer = signer?.certificates.first
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! CPDFSigntureVerifyDetailsTopCell
                cell.nameLabel?.text = NSLocalizedString("Signer:", comment: "")
                cell.countLabel?.text = self.signature?.name
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! CPDFSigntureVerifyDetailsTopCell
                cell.nameLabel?.text = NSLocalizedString("Signing Time:", comment: "")
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                cell.countLabel?.text = dateFormatter.string(from: self.signature?.date ?? Date())
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! CPDFSigntureVerifyDetailsCells
            cell.titleLabel?.text = self.detailsArray?[indexPath.row]
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 20))
        view.autoresizingMask = [.flexibleWidth]

        let sublabel = UILabel()
        sublabel.font = UIFont.boldSystemFont(ofSize: 10)
        if #available(iOS 13.0, *) {
            sublabel.textColor = UIColor.label
        } else {
            sublabel.textColor = UIColor.black
        }
        sublabel.sizeToFit()
        sublabel.frame = CGRect(x: 10, y: 0, width: view.bounds.size.width - 20, height: view.bounds.size.height)
        sublabel.autoresizingMask = [.flexibleWidth]
        view.contentView.backgroundColor = CPDFColorUtils.CMessageLabelColor()
        view.contentView.addSubview(sublabel)

        view.backgroundColor = CPDFColorUtils.CMessageLabelColor()

        if section == 0 {
            sublabel.text = NSLocalizedString("Signatures", comment: "")
        } else if section == 1 {
            sublabel.text = NSLocalizedString("Certification Authority Statement", comment: "")
        }

        return view
    }
    
    // MARK: - UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - CPDFSigntureListViewControllerDelegate
    
    func signtureListViewControllerUpdate(_ signtureListViewController: CPDFSigntureListViewController) {
        detailInfo()
        tableView?.reloadData()
        delegate?.signtureVerifyDetailsViewControllerUpdate?(self)
    }
  
}

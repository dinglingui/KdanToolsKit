//
//  CPDFSigntureDetailsViewController.swift
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

@objc protocol CPDFSigntureDetailsViewControllerDelegate: AnyObject {
    @objc optional func signtureDetailsViewControllerTrust(_ signtureDetailsViewController: CPDFSigntureDetailsViewController)
}

class CPDFSigntureDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: CPDFSigntureDetailsViewControllerDelegate?
    var certificate: CPDFSignatureCertificate?
    
    private var tableView: UITableView?
    private var footView: CPDFSigntureDetailsFootView?
    private var expiredTrust: Bool = false
    
    // MARK: - Viewcontroller Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Details", comment: "")
        
        let backItem = UIBarButtonItem(image: UIImage(named: "CPDFViewImageBack", in: Bundle(for: CPDFSigntureDetailsViewController.self), compatibleWith: nil), style: .plain, target: self, action: #selector(buttonItemClicked_back))
        self.navigationItem.leftBarButtonItems = [backItem]
        
        self.view.backgroundColor = UIColor.white
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height - 230))
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.estimatedRowHeight = 60
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.separatorStyle = .none
        tableView?.register(UINib(nibName: "CPDFSigntureDetailsCells", bundle:Bundle(for: CPDFSigntureDetailsViewController.self)), forCellReuseIdentifier: "cell5")
        if tableView != nil {
            view.addSubview(tableView!)
        }
        
        footView = CPDFSigntureDetailsFootView(frame: CGRect(x: 0, y: (tableView?.frame.maxY ?? 0) + 5, width: self.view.bounds.size.width, height: 225))
        footView?.trustedButton?.addTarget(self, action: #selector(buttonItemClick_Trusted), for: .touchUpInside)
        if footView != nil {
            view.addSubview(footView!)
        }
        
        updateDatas()
        
        expiredTrust = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableView?.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height - 230)
        
        if #available(iOS 11.0, *) {
            footView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: (tableView?.frame.maxY ?? 0) + 5, width: self.view.bounds.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 225)
        } else {
            footView?.frame = CGRect(x: 0, y: (tableView?.frame.maxY ?? 0) + 5, width: self.view.bounds.size.width, height: 225)
        }
    }
    
    // MARK: - Private Methods
    
    private func updateDatas() {
        tableView?.reloadData()
        
        let currentDate = Date()
        let result = currentDate.compare(certificate?.validityEnds ?? Date())
        
        if result == .orderedAscending {
            expiredTrust = true
        } else {
            expiredTrust = false
        }
        
        if certificate?.isTrusted == true {
            footView?.certifyImage?.image = UIImage(named: "ImageNameSigntureTrustedIcon", in: Bundle(for: CPDFSigntureDetailsViewController.self), compatibleWith: nil)
            footView?.dataImage?.image = UIImage(named: "ImageNameSigntureTrustedIcon", in: Bundle(for: CPDFSigntureDetailsViewController.self), compatibleWith: nil)
            footView?.trustedButton?.isEnabled = false
            footView?.trustedButton?.setTitleColor(UIColor.systemGray, for: .normal)
            footView?.trustedButton?.layer.borderColor = UIColor.systemGray.cgColor
        } else {
            footView?.certifyImage?.image = UIImage(named: "ImageNameSigntureTrustedFailureIcon", in: Bundle(for: CPDFSigntureDetailsViewController.self), compatibleWith: nil)
            footView?.dataImage?.image = UIImage(named: "ImageNameSigntureTrustedFailureIcon", in: Bundle(for: CPDFSigntureDetailsViewController.self), compatibleWith: nil)
            footView?.trustedButton?.isEnabled = true
            footView?.trustedButton?.setTitleColor(UIColor.systemBlue, for: .normal)
            footView?.trustedButton?.layer.borderColor = UIColor.systemBlue.cgColor
        }
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_back() {
        // Handle the back button click
        navigationController?.dismiss(animated: true)
    }
    
    @objc func buttonItemClick_Trusted() {
        let success = self.certificate?.addToTrustedCertificates() ?? false
        if success {
            NotificationCenter.default.post(name: NSNotification.Name("CSignatureTrustCerDidChangeNotification"), object: nil)
            
            let alert = UIAlertController(title: NSLocalizedString("Trusted certificate Succeeded!", comment: ""), message: nil, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
            
            let addAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (action) in
                self.updateDatas()
            }
            
            alert.addAction(cancelAction)
            alert.addAction(addAction)
            present(alert, animated: true, completion: nil)
            
            delegate?.signtureDetailsViewControllerTrust?(self)
        } else {
            let alert = UIAlertController(title: NSLocalizedString("Trusted certificate Failure!", comment: ""), message: nil, preferredStyle: .alert)
            
            let addAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (action) in
            }
            
            alert.addAction(addAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        } else {
            return 18
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell5", for: indexPath) as! CPDFSigntureDetailsCells
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var titleLabelString: String = ""
        var content: String = ""
        var string: String = ""
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                titleLabelString = NSLocalizedString("Issued to:", comment: "")
                string = self.certificate?.subject.replacingOccurrences(of: ",", with: "\n") ?? ""
                content = string
            } else if indexPath.row == 1 {
                titleLabelString = NSLocalizedString("Issuer:", comment: "")
                string = self.certificate?.issuer.replacingOccurrences(of: ",", with: "\n") ?? ""
                content = string
            } else if indexPath.row == 2 {
                titleLabelString = NSLocalizedString("Valid from:", comment: "")
                content = dateFormatter.string(from: self.certificate?.validityStarts ?? Date())
            } else if indexPath.row == 3 {
                titleLabelString = NSLocalizedString("Valid to:", comment: "")
                content = dateFormatter.string(from: self.certificate?.validityEnds ?? Date())
            } else if indexPath.row == 4 {
                var innerAtt = [String]()
                
                if certificate?.keyUsage.contains(.encipherOnly) == true  {
                    innerAtt.append(NSLocalizedString("Encipher Only", comment: ""))
                }
                
                if certificate?.keyUsage.contains(.crlSignature) == true {
                    innerAtt.append(NSLocalizedString("CRL Signature", comment: ""))
                }
                
                if certificate?.keyUsage.contains(.certificateSignature) == true {
                    innerAtt.append(NSLocalizedString("Certificate Signature", comment: ""))
                }
                
                if certificate?.keyUsage.contains(.keyAgreement) == true {
                    innerAtt.append(NSLocalizedString("Key Agreement", comment: ""))
                }
                
                if certificate?.keyUsage.contains(.dataEncipherment) == true {
                    innerAtt.append(NSLocalizedString("Data Encipherment", comment: ""))
                }
                
                if certificate?.keyUsage.contains(.keyEncipherment) == true {
                    innerAtt.append(NSLocalizedString("Key Encipherment", comment: ""))
                }
                
                if certificate?.keyUsage.contains(.nonRepudiation) == true {
                    innerAtt.append(NSLocalizedString("Non-Repudiation", comment: ""))
                }
                
                if certificate?.keyUsage.contains(.digitalSignature) == true {
                    innerAtt.append(NSLocalizedString("Digital Signature", comment: ""))
                }
                
                if certificate?.keyUsage.contains(.dDecipherOnly) == true {
                    innerAtt.append(NSLocalizedString("Decipher Only", comment: ""))
                }
                
                var innerUsageString: String?
                
                for usz in innerAtt {
                    let us = NSLocalizedString(usz, comment: "")
                    
                    if var innerUsageString = innerUsageString {
                        innerUsageString += "," + us
                    } else {
                        innerUsageString = us
                    }
                }
                
                titleLabelString = NSLocalizedString("Intended Usage:", comment: "")
                content = innerUsageString ?? ""
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                titleLabelString = NSLocalizedString("Version:", comment: "")
                content = self.certificate?.version ?? ""
            } else if indexPath.row == 1 {
                titleLabelString = NSLocalizedString("Algorithm:", comment: "")
                var algorithmContent: String
                
                switch self.certificate?.signatureAlgorithmType {
                case .RSA_RSA:
                    algorithmContent = "RSA_RSA"
                    
                case .MD2RSA:
                    algorithmContent = "MD2RSA"
                    
                case .MD4RSA:
                    algorithmContent = "MD4RSA"
                    
                case .SHA1RSA:
                    algorithmContent = "SHA1RSA"
                    
                case .SHA256RSA:
                    algorithmContent = "SHA256RSA"
                    
                default:
                    algorithmContent = "SM3SM2"
                }
                
                content = "\(algorithmContent)(\(self.certificate?.signatureAlgorithmOID ?? ""))"
            } else if indexPath.row == 2 {
                titleLabelString = NSLocalizedString("Subject:", comment: "")
                content = self.certificate?.subject.replacingOccurrences(of: ",", with: "\n") ?? ""
            } else if indexPath.row == 3 {
                titleLabelString = NSLocalizedString("Issuer:", comment: "")
                string = self.certificate?.issuer.replacingOccurrences(of: ",", with: "\n") ?? ""
                content = string
            } else if indexPath.row == 4 {
                titleLabelString = NSLocalizedString("Serial Number:", comment: "")
                content = self.certificate?.serialNumber ?? ""
            } else if indexPath.row == 5 {
                titleLabelString = NSLocalizedString("Valid from:", comment: "")
                content = dateFormatter.string(from: self.certificate?.validityStarts ?? Date())
            } else if indexPath.row == 6 {
                titleLabelString = NSLocalizedString("Valid to:", comment: "")
                content = dateFormatter.string(from: self.certificate?.validityEnds ?? Date())
            } else if indexPath.row == 7 {
                titleLabelString = NSLocalizedString("Certificate Policy:", comment: "")
                content = self.certificate?.certificatePolicies ?? ""
            } else if indexPath.row == 8 {
                titleLabelString = NSLocalizedString("CRL Distribution Points:", comment: "")
                var innerString = ""
                
                guard let certificate = certificate else {
                    return cell
                }
                
                for tString in certificate.crlDistributionPoints {
                    if innerString.isEmpty {
                        innerString = tString
                    } else {
                        innerString += "\n" + tString
                    }
                }
                content = innerString
            } else if indexPath.row == 9 {
                titleLabelString = NSLocalizedString("Issuer Information Access:", comment: "")
                guard let certificate = certificate else {
                    return cell
                }
                for dic in certificate.authorityInfoAccess {
                    if content.isEmpty {
                        content = "\(dic["Method"] ?? "") = \(dic["Method"] ?? "")\n"
                        content += "URL = \(dic["URI"] ?? "")"
                    } else {
                        content += "\n\n"
                        content += "Method = \(dic["Method"] ?? "")\n"
                        content += "URL = \(dic["URI"] ?? "")"
                    }
                }
            } else if indexPath.row == 10 {
                titleLabelString = NSLocalizedString("Issuer‘s Key Identifier:", comment: "")
                content = (self.certificate?.authorityKeyIdentifier ?? "").uppercased()
            } else if indexPath.row == 11 {
                titleLabelString = NSLocalizedString("Subject‘s Key Identifier:", comment: "")
                content = (self.certificate?.subjectKeyIdentifier ?? "").uppercased()
            } else if indexPath.row == 12 {
                titleLabelString = NSLocalizedString("Basic Constraints:", comment: "")
                content = self.certificate?.basicConstraints ?? ""
            } else if indexPath.row == 13 {
                var innerAtt = [String]()
                
                if certificate?.keyUsage.contains(.encipherOnly) == true  {
                    innerAtt.append(NSLocalizedString("Encipher Only", comment: ""))
                }
                
                if certificate?.keyUsage.contains(.crlSignature) == true {
                    innerAtt.append(NSLocalizedString("CRL Signature", comment: ""))
                }
                
                if certificate?.keyUsage.contains(.certificateSignature) == true {
                    innerAtt.append(NSLocalizedString("Certificate Signature", comment: ""))
                }
                
                if certificate?.keyUsage.contains(.keyAgreement) == true {
                    innerAtt.append(NSLocalizedString("Key Agreement", comment: ""))
                }
                
                if certificate?.keyUsage.contains(.dataEncipherment) == true {
                    innerAtt.append(NSLocalizedString("Data Encipherment", comment: ""))
                }
                
                if certificate?.keyUsage.contains(.keyEncipherment) == true {
                    innerAtt.append(NSLocalizedString("Key Encipherment", comment: ""))
                }
                
                if certificate?.keyUsage.contains(.nonRepudiation) == true {
                    innerAtt.append(NSLocalizedString("Non-Repudiation", comment: ""))
                }
                
                if certificate?.keyUsage.contains(.digitalSignature) == true {
                    innerAtt.append(NSLocalizedString("Digital Signature", comment: ""))
                }
                
                if certificate?.keyUsage.contains(.dDecipherOnly) == true {
                    innerAtt.append(NSLocalizedString("Decipher Only", comment: ""))
                }
                
                var innerUsageString: String?
                
                for usz in innerAtt {
                    let us = NSLocalizedString(usz, comment: "")
                    
                    if var innerUsageString = innerUsageString {
                        innerUsageString += "," + us
                    } else {
                        innerUsageString = us
                    }
                }
                
                titleLabelString = NSLocalizedString("Key Usage:", comment: "")
                content = innerUsageString ?? ""
            } else if indexPath.row == 14 {
                titleLabelString = NSLocalizedString("Public Key:", comment: "")
                    content = self.certificate?.publicKey ?? ""
            } else if indexPath.row == 15 {
                titleLabelString = NSLocalizedString("X.509 Data:", comment: "")
                content = self.certificate?.x509Data ?? ""
            } else if indexPath.row == 16 {
                titleLabelString = NSLocalizedString("SHA1 Digest:", comment: "")
                    content = self.certificate?.sha1Digest ?? ""
            } else if indexPath.row == 17 {
                titleLabelString = NSLocalizedString("MD5 Digest:", comment: "")
                    content = self.certificate?.md5Digest ?? ""
            }
            
        }
        
        cell.titleLabel?.text = titleLabelString
        cell.contentLabel?.text = content.isEmpty ? " " : content
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
        view.autoresizingMask = .flexibleWidth

        let sublabel = UILabel()
        sublabel.font = UIFont.boldSystemFont(ofSize: 14)
        if #available(iOS 13.0, *) {
            sublabel.textColor = UIColor.label
        } else {
            sublabel.textColor = UIColor.black
        }
        sublabel.sizeToFit()
        sublabel.frame = CGRect(x: 10, y: 0, width: view.bounds.size.width - 20, height: view.bounds.size.height)
        sublabel.autoresizingMask = .flexibleWidth
        view.contentView.addSubview(sublabel)

        if section == 0 {
            sublabel.text = NSLocalizedString("Summary", comment: "")
        } else if section == 1 {
            sublabel.text = NSLocalizedString("Details", comment: "")
        }

        return view
    }
    
}

//
//  CPDFSigntureDetailsFootView.swift
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

class CPDFSigntureDetailsFootView: UIView {
    
    var dataImage: UIImageView?
    var dataLabel: UILabel?
    var certifyImage: UIImageView?
    var certifyLabel: UILabel?
    var trustedButton: UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = CPDFColorUtils.CViewBackgroundColor()
        
        let titleLabel = UILabel()
        titleLabel.font = .boldSystemFont(ofSize: 14)
        if #available(iOS 13.0, *) {
            titleLabel.textColor = .label
        } else {
            titleLabel.textColor = .black
        }
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.text = NSLocalizedString("Trust", comment: "")
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(x: 10, y: 0, width: self.bounds.size.width - 20, height: 18)
        titleLabel.autoresizingMask = .flexibleWidth
        addSubview(titleLabel)
        
        let sublabel = UILabel()
        sublabel.font = .systemFont(ofSize: 14)
        if #available(iOS 13.0, *) {
            sublabel.textColor = .label
        } else {
            sublabel.textColor = .black
        }
        sublabel.text = NSLocalizedString("This Certificate Is Trusted to:", comment: "")
        sublabel.sizeToFit()
        sublabel.font = .systemFont(ofSize: 12)
        sublabel.adjustsFontSizeToFitWidth = true
        sublabel.frame = CGRect(x: 10, y: titleLabel.frame.maxY + 20, width: self.bounds.size.width - 20, height: 18)
        sublabel.autoresizingMask = .flexibleWidth
        addSubview(sublabel)
        
        dataImage = UIImageView(image: UIImage(named: "ImageNameSigntureTrustedIcon", in: Bundle(for: type(of: self)), compatibleWith: nil))
        dataImage?.sizeToFit()
        dataImage?.frame = CGRect(x: 20, y: sublabel.frame.maxY + 16, width: 20, height: 20)
        if dataImage != nil {
            addSubview(dataImage!)
        }
        
        dataLabel = UILabel()
        dataLabel?.font = .systemFont(ofSize: 14)
        if #available(iOS 13.0, *) {
            dataLabel?.textColor = .label
        } else {
            dataLabel?.textColor = .black
        }
        dataLabel?.text = NSLocalizedString("Sign document or data", comment: "")
        dataLabel?.sizeToFit()
        dataLabel?.font = .systemFont(ofSize: 12)
        dataLabel?.adjustsFontSizeToFitWidth = true
        dataLabel?.frame = CGRect(x: (dataImage?.frame.maxX ?? 0) + 5, y: titleLabel.frame.maxY + 20, width: self.bounds.size.width - (dataImage?.frame.maxX ?? 0) - 15, height: 18)
        dataLabel?.center = CGPoint(x: dataLabel?.center.x ?? 0, y: dataImage?.center.y ?? 0)
        dataLabel?.autoresizingMask = .flexibleWidth
        if dataLabel != nil {
            addSubview(dataLabel!)
        }
        
        certifyImage = UIImageView(image: UIImage(named: "ImageNameSigntureTrustedIcon", in: Bundle(for: type(of: self)), compatibleWith: nil))
        certifyImage?.sizeToFit()
        certifyImage?.frame = CGRect(x: 20, y: (dataImage?.frame.maxY ?? 0) + 16, width: 20, height: 20)
        if certifyImage != nil {
            addSubview(certifyImage!)
        }
        
        certifyLabel = UILabel()
        certifyLabel?.font = .systemFont(ofSize: 12)
        if #available(iOS 13.0, *) {
            certifyLabel?.textColor = .label
        } else {
            certifyLabel?.textColor = .black
        }
        certifyLabel?.text = NSLocalizedString("Certify document", comment: "")
        certifyLabel?.sizeToFit()
        certifyLabel?.adjustsFontSizeToFitWidth = true
        certifyLabel?.frame = CGRect(x: (certifyImage?.frame.maxX ?? 0) + 5, y: (dataLabel?.frame.maxY ?? 0) + 20, width: self.bounds.size.width - (certifyImage?.frame.maxX ?? 0) - 15, height: 18)
        certifyLabel?.center = CGPoint(x: certifyLabel?.center.x ?? 0, y: certifyImage?.center.y ?? 0)
        certifyLabel?.autoresizingMask = .flexibleWidth
        if certifyLabel != nil {
            addSubview(certifyLabel!)
        }
        
        trustedButton = UIButton(type: .system)
        trustedButton?.setTitle(NSLocalizedString("Add to Trusted Certificates", comment: ""), for: .normal)
        trustedButton?.sizeToFit()
        trustedButton?.frame = CGRect(x: 10, y: (certifyLabel?.frame.maxY ?? 0) + 20, width: self.frame.size.width - 20, height: 40)
        trustedButton?.autoresizingMask = .flexibleWidth
        trustedButton?.layer.cornerRadius = 5.0
        trustedButton?.layer.borderWidth = 1.0
        trustedButton?.layer.borderColor = UIColor.systemBlue.cgColor
        trustedButton?.setTitleColor(UIColor.systemBlue, for: .normal)
        trustedButton?.setTitleColor(UIColor.gray, for: .disabled)
        if trustedButton != nil {
            addSubview(trustedButton!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

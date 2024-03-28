//
//  CPDFSignatureViewController.swift
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

protocol CPDFSignatureViewCellDelegate: AnyObject {
    func signatureViewCell(_ signatureViewCell: CPDFSignatureViewCell)
}

class CPDFSignatureViewCell: UITableViewCell {
    var signatureImageView: UIImageView?
    weak var deleteDelegate: CPDFSignatureViewCellDelegate?
    
    private var deleteButton: UIButton?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        signatureImageView = UIImageView()
        contentView.addSubview(signatureImageView!)
        
        deleteButton = UIButton()
        deleteButton?.setImage(UIImage(named: "CPDFSignatureImageDelete", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        deleteButton?.addTarget(self, action: #selector(buttonItemClicked_delete(_:)), for: .touchUpInside)
        if deleteButton != nil {
            contentView.addSubview(deleteButton!)
        }
        
        backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let height = contentView.bounds.size.height - 20
        if (signatureImageView != nil && signatureImageView?.image != nil) {
            var width = height * signatureImageView!.image!.size.width / signatureImageView!.image!.size.height
            width = min(width, contentView.bounds.size.width - 80.0)
            signatureImageView!.frame = CGRect(x: (bounds.size.width - width)/2.0, y: 10.0, width: width, height: height)
            signatureImageView!.center = contentView.center
            deleteButton?.frame = CGRect(x: bounds.size.width - 50, y: 0.0, width: 50, height: 50)
        }
        
    }
    
    @objc func buttonItemClicked_delete(_ sender: AnyObject) {
        deleteDelegate?.signatureViewCell(self)
    }
    
}


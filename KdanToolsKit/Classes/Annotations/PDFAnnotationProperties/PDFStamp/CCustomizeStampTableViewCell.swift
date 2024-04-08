//
//  CCustomizeStampTableViewCell.swift
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

@objc protocol CCustomizeStampTableViewCellDelegate: AnyObject {
    @objc optional func customizeStampTableViewCell(_ customizeStampTableViewCell: CCustomizeStampTableViewCell)
}

class CCustomizeStampTableViewCell: UITableViewCell {
    var customizeStampImageView: UIImageView?
    weak var deleteDelegate: CCustomizeStampTableViewCellDelegate?
    
    private var deleteButton: UIButton?
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.customizeStampImageView = UIImageView()
        if customizeStampImageView != nil {
            self.contentView.addSubview(self.customizeStampImageView!)
        }
        self.deleteButton = UIButton()
        self.deleteButton?.setImage(UIImage(named: "CPDFSignatureImageDelete", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        self.deleteButton?.addTarget(self, action: #selector(buttonItemClicked_delete(_:)), for: .touchUpInside)
        if deleteButton != nil {
        self.contentView.addSubview(self.deleteButton!)
        }
        self.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let height = self.contentView.bounds.size.height - 10
        var width = height * ((self.customizeStampImageView?.image?.size.width ?? 1.0) / (self.customizeStampImageView?.image?.size.height ?? 1.0))
        width = min(width, self.contentView.bounds.size.width - 80.0)
        self.customizeStampImageView?.frame = CGRect(x: (self.bounds.size.width - width) / 2.0, y: 5.0, width: width, height: height)
        self.customizeStampImageView?.center = self.contentView.center
        self.deleteButton?.frame = CGRect(x: self.bounds.size.width - 50, y: 0.0, width: 50, height: 50)
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_delete(_ button: UIButton) {
        deleteDelegate?.customizeStampTableViewCell?(self)
    }
    
}


//
//  StampCollectionHeaderView1.swift
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

@objc protocol StampHeaderViewDelegate: AnyObject {
    @objc optional func addText(with headerView: StampCollectionHeaderView1)
    @objc optional func addImage(with headerView: StampCollectionHeaderView1)
}

class StampCollectionHeaderView1: UICollectionReusableView {
    var textLabel: UILabel?
    weak var delegate: StampHeaderViewDelegate?
    
    private var headerView: UIView?
    private var textButton: UIButton?
    private var imageButton: UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        headerView = UIView()
        headerView?.backgroundColor = UIColor.clear
        if headerView != nil {
            addSubview(headerView!)
        }
        
        textButton = UIButton(type: .system)
        textButton?.setTitle(NSLocalizedString("New Text Stamp", comment: ""), for: .normal)
        textButton?.setTitleColor(UIColor(red: 36.0/255.0, green: 36.0/255.0, blue: 36.0/255.0, alpha: 1.0), for: .normal)
        textButton?.addTarget(self, action: #selector(buttonItemClicked_AddText(_ :)), for: .touchUpInside)
        textButton?.layer.borderWidth = 1
        textButton?.layer.cornerRadius = 5
        textButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        textButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        textButton?.layer.borderColor = UIColor(red: 17.0/255.0, green: 140.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        if textButton != nil {
            headerView?.addSubview(textButton!)
        }
        
        imageButton = UIButton(type: .system)
        imageButton?.setTitle(NSLocalizedString("New Image Stamp", comment: ""), for: .normal)
        imageButton?.setTitleColor(UIColor(red: 36.0/255.0, green: 36.0/255.0, blue: 36.0/255.0, alpha: 1.0), for: .normal)
        imageButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        imageButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        imageButton?.addTarget(self, action: #selector(buttonItemClicked_AddImage(_ :)), for: .touchUpInside)
        imageButton?.layer.borderWidth = 1
        imageButton?.layer.cornerRadius = 5
        imageButton?.layer.borderColor = UIColor(red: 17.0/255.0, green: 140.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        if imageButton != nil {
            headerView?.addSubview(imageButton!)
        }
        
        backgroundColor = UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1.0)
        
        textLabel = UILabel()
        textLabel?.textColor = UIColor(red: 36.0/255.0, green: 36.0/255.0, blue: 36.0/255.0, alpha: 1.0)
        textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        if textLabel != nil {
            addSubview(textLabel!)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        headerView?.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: 80)
        textButton?.frame = CGRect(x: 10, y: (headerView?.frame ?? .zero).minY+10, width: (bounds.size.width-40)/2, height: 60)
        imageButton?.frame = CGRect(x: 30 + (bounds.size.width-40)/2, y: (headerView?.frame ?? .zero).minY+10, width: (bounds.size.width-40)/2, height: 60)
        textLabel?.frame = CGRect(x: 10, y: (headerView?.frame ?? .zero).minY+80, width: bounds.size.width-20, height: 20)
    }
    
    // MARK: - Button Event Action
    
    @objc func buttonItemClicked_AddImage(_ sender: Any) {
        delegate?.addImage?(with: self)
    }
    
    @objc func buttonItemClicked_AddText(_ sender: Any) {
        delegate?.addText?(with: self)
    }
    
    
}


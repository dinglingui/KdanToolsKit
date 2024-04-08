//
//  CTileSelectView.swift
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

@objc protocol CTileSelectViewDelegate: AnyObject {
    @objc optional func tileSelectView(_ tileSelectView: CTileSelectView, isTile: Bool)
}

class CTileSelectView: UIView {
    
    weak var delegate: CTileSelectViewDelegate?

    private var titleLabel: UILabel?
    
    var tileSwitch: UISwitch?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        titleLabel = UILabel()
        titleLabel?.autoresizingMask = .flexibleRightMargin
        titleLabel?.text = NSLocalizedString("Tile", comment: "")
        titleLabel?.textColor = .gray
        titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        if titleLabel != nil {
            addSubview(titleLabel!)
        }
        
        tileSwitch = UISwitch()
        tileSwitch?.addTarget(self, action: #selector(switchItemClicked_Top(_ :)), for: .valueChanged)
        if tileSwitch != nil {
            addSubview(tileSwitch!)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel?.frame = CGRect(x: 20, y: 0, width: 200, height: 45)
        tileSwitch?.frame = CGRect(x: bounds.size.width - 80, y: 0, width: 60, height: 45)
    }
    
    // MARK: - Action
    
    @objc func switchItemClicked_Top(_ sender: UISwitch) {
        delegate?.tileSelectView?(self, isTile: sender.isOn)
    }
    
}

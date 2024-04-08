//
//  CPDFFormArrowStyleView.swift
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

@objc protocol CPDFFormArrowStyleViewDelegate: AnyObject {
    
    @objc optional func CPDFFormArrowStyleViewClicked(_ view: CPDFFormArrowStyleView)
}

class CPDFFormArrowStyleView: UIView {
    
    weak var delegate: CPDFFormArrowStyleViewDelegate?
    
    var arrowImageView: UIImageView?
    var titleLabel: UILabel?
    var selectButton: UIButton?
    private var arrowCoverView: UIView?
    private var arrowDirectionView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel = UILabel()
        if(titleLabel != nil) {
            addSubview(titleLabel!)
        }
        
        arrowCoverView = UIView()
        arrowCoverView?.layer.cornerRadius = 1
        arrowCoverView?.layer.borderWidth = 1
        arrowCoverView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        if(arrowCoverView != nil) {
            addSubview(arrowCoverView!)
        }
        
        arrowImageView = UIImageView()
        if(arrowImageView != nil) {
            arrowCoverView?.addSubview(arrowImageView!)
        }
        arrowImageView?.image = UIImage(named: "CPDFFormCircle", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        
        arrowDirectionView = UIImageView()
        if(arrowDirectionView != nil) {
            arrowCoverView?.addSubview(arrowDirectionView!)
        }
        arrowDirectionView?.image = UIImage(named: "CPDFFormEditRight", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        
        selectButton = UIButton(type: .custom)
        selectButton?.addTarget(self, action: #selector(buttonItemClick(_:)), for: .touchUpInside)
        if(selectButton != nil) {
            arrowCoverView?.addSubview(selectButton!)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.frame = CGRect(x: 20, y: 7, width: 120, height: 30)
        arrowCoverView?.frame = CGRect(x: frame.size.width - 100, y: 8, width: 80, height: 28)
        arrowImageView?.frame = CGRect(x: 18+10, y: 4, width: 20, height: 20)
        arrowDirectionView?.frame = CGRect(x: (arrowImageView?.frame.maxX ?? 0) + 10, y: 6.5, width: 15, height: 15)
        selectButton?.frame = arrowCoverView?.bounds ?? CGRect.zero
        
    }
    @objc func buttonItemClick(_ button: UIButton) {
        self.delegate?.CPDFFormArrowStyleViewClicked?(self)
    }
}

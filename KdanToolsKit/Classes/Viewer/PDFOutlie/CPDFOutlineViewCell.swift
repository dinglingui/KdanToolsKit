//
//  CPDFOutlineViewCell.swift
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

@objc protocol CPDFOutlineViewCellDelegate: AnyObject {
    @objc optional func buttonItemClickedArrow(_ cell: CPDFOutlineViewCell)
}

class CPDFOutlineViewCell: UITableViewCell {
    
    var arrowButton: UIButton?
    var nameLabel: UILabel?
    var countLabel: UILabel?
    
    var offsetX: NSLayoutConstraint = NSLayoutConstraint()
    
    var outline: CPDFOutlineModel {
        didSet {
            nameLabel?.text = outline.title
            countLabel?.text = "\(outline.number + 1)"
            offsetX.constant = CGFloat(10 * outline.level)
            
            if outline.count > 0 {
                arrowButton?.isHidden = false
                
                if outline.isShow {
                    arrowButton?.isSelected = true
                } else {
                    arrowButton?.isSelected = false
                }
            } else {
                arrowButton?.isHidden = true
            }
            
            nameLabel?.frame = CGRect(x: 25 + 10 * outline.level, y: 10, width: Int(bounds.size.width - offsetX.constant) - 100, height: 16)
            countLabel?.frame = CGRect(x: bounds.size.width - 55, y: 10, width: 55, height: 14)
        }
    }
    
    var isShow: Bool {
        didSet {
            outline.isShow = isShow
            
            if outline.count > 0 {
                if outline.isShow {
                    arrowButton?.isSelected = true
                } else {
                    arrowButton?.isSelected = false
                }
            }
        }
    }
    
    weak var delegate: CPDFOutlineViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        arrowButton = UIButton(frame: CGRect(x: 0, y: 4, width: 36, height: 26))
        nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        countLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        countLabel?.autoresizingMask = .flexibleLeftMargin;

        outline = CPDFOutlineModel()
        offsetX = NSLayoutConstraint()
        isShow = false
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        arrowButton?.addTarget(self, action: #selector(buttonItemClickedArrow(_:)), for: .touchUpInside)
        arrowButton?.setImage(UIImage(named: "CPDFOutlineImageBotaMore", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .selected)
        arrowButton?.setImage(UIImage(named: "CPDFOutlineImageBotaMoreLeft", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)

        nameLabel?.font = UIFont.systemFont(ofSize: 14)
        countLabel?.font = UIFont.systemFont(ofSize: 14)
        
        if arrowButton != nil, nameLabel != nil, countLabel != nil {
            
            contentView.addSubview(arrowButton!)
            contentView.addSubview(nameLabel!)
            contentView.addSubview(countLabel!)
        }
        
        // Add constraints for nameLabel and countLabel if needed
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Action
    
    @objc func buttonItemClickedArrow(_ sender: UIButton) {
        delegate?.buttonItemClickedArrow?(self)
    }
}

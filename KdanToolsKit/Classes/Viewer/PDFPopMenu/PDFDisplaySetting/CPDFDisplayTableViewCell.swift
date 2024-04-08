//
//  CPDFDisplayTableViewCell.swift
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

class CPDFDisplayTableViewCell: UITableViewCell {
    var checkImageView: UIImageView?
    var iconImageView: UIImageView?
    var titleLabel: UILabel?
    var modeSwitch: UISwitch?
    var switchBlock: (() -> Void)?
    var hiddenSplitView: Bool = false
    
    private var splitView: UIView?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        modeSwitch = UISwitch()
        modeSwitch?.isHidden = true
        modeSwitch?.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        modeSwitch?.sizeToFit()
        modeSwitch?.addTarget(self, action: #selector(switchAction(_:)), for: .valueChanged)
        if modeSwitch != nil {
            contentView.addSubview(modeSwitch!)
        }
        
        checkImageView = UIImageView()
        checkImageView?.image = UIImage(named: "CDisplayImageNameCheck", in: Bundle(for: type(of: self)), compatibleWith: nil)
        checkImageView?.isHidden = true
        if checkImageView != nil {
            contentView.addSubview(checkImageView!)
        }
        
        iconImageView = UIImageView()
        if iconImageView != nil {
            contentView.addSubview(iconImageView!)
        }
        
        titleLabel = UILabel()
        titleLabel?.font = UIFont.systemFont(ofSize: 17)
        if titleLabel != nil {
            contentView.addSubview(titleLabel!)
        }
        
        splitView = UIView()
        splitView?.backgroundColor = CPDFColorUtils.CTableviewCellSplitColor()
        if splitView != nil {
            contentView.addSubview(splitView!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        modeSwitch?.frame = CGRect(x: contentView.frame.size.width - 50, y: (contentView.frame.size.height - 25)/2, width: 30, height: 40)
        
        checkImageView?.frame = CGRect(x: contentView.frame.size.width - 40, y: (contentView.frame.size.height - 30)/2, width: 30, height: 30)
        iconImageView?.frame = CGRect(x: 20, y: 12, width: 20, height: 20)
        let width = contentView.frame.size.width - (modeSwitch?.frame.size.width ?? 0) - 40 - (iconImageView?.frame.size.width ?? 0)
        titleLabel?.frame = CGRect(x: (iconImageView?.frame.maxX ?? 0) + 10, y: 12, width: width, height: 20)
        splitView?.frame = CGRect(x: 0, y: contentView.frame.size.height-1, width: contentView.frame.size.width, height: 1)
    }
    
    // MARK: - Action
    
    @objc func switchAction(_ sender: UISwitch) {
        if let switchBlock = switchBlock {
            switchBlock()
        }
    }
    
    func setHiddenSplitView(_ hiddenSplitView: Bool) {
        self.hiddenSplitView = hiddenSplitView
        splitView!.isHidden = hiddenSplitView
    }
    
}



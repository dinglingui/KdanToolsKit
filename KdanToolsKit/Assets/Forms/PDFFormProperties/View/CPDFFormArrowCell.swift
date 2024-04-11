//
//  CPDFFormArrowCell.swift
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

class CPDFFormArrowCell: UITableViewCell {
    
    private var titleLabel: UILabel?
    private var selectView: UIImageView?
    private var iconView: UIImageView?
    
    var model: CPDFFormArrowModel? {
        didSet {
            if model?.isSelected == true {
                selectView?.image = UIImage(named: "CPDFFormOptionOn", in: Bundle(for: Self.self), compatibleWith: nil)
            } else {
                selectView?.image = UIImage(named: "CPDFFormOptionOff", in: Bundle(for: Self.self), compatibleWith: nil)
            }
            iconView?.image = model?.iconImage
            titleLabel?.text = model?.title ?? ""
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectView = UIImageView(frame: CGRect(x: 20, y: 15, width: 20, height: 20))
        iconView = UIImageView(frame: CGRect(x: (selectView?.frame.maxX ?? 0) + 10, y: 15, width: 20, height: 20))
        
        titleLabel = UILabel()
        titleLabel?.frame = CGRect(x: (iconView?.frame.maxX ?? 0) + 10, y: 15, width: 100, height: 20)
        titleLabel?.font = UIFont.systemFont(ofSize: 13)
        titleLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
        if(selectView != nil) {
            contentView.addSubview(selectView!)
        }
        if(iconView != nil) {
            contentView.addSubview(iconView!)
        }
        if(titleLabel != nil) {
            contentView.addSubview(titleLabel!)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

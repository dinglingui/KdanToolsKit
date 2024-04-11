//
//  CPDFPopMenuItem.swift
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

class CPDFPopMenuItem: UITableViewCell {
    var titleLabel: UILabel?
    var iconImage: UIImageView?
    
    private var splitView: UIView?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel = UILabel.init()
        titleLabel?.font = UIFont.systemFont(ofSize: 17)
        if titleLabel != nil {
            contentView.addSubview(titleLabel!)
        }
        
        iconImage = UIImageView()
        if iconImage != nil {
            contentView.addSubview(iconImage!)
        }
        
        splitView = UIView()
        contentView.addSubview(splitView!)
        splitView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.12)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconImage?.frame = CGRect(x: self.frame.size.width - 36, y: (self.frame.size.height - 20)/2, width: 20, height: 20)

        titleLabel?.frame = CGRect(x: 20, y: 2.5, width: self.frame.size.width - 56, height: self.frame.size.height - 5)
        splitView?.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func loadCPDFPopMenuItem() -> CPDFPopMenuItem? {
         let bundle = Bundle(for: self)
         return bundle.loadNibNamed("CPDFPopMenuItem", owner: nil, options: nil)?.last as? CPDFPopMenuItem
     }
    
     
     func hiddenLineView(_ isHidden: Bool) {
         self.splitView?.isHidden = isHidden
     }
}

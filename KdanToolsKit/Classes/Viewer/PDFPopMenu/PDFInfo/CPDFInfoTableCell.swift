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

let kDocumentInfoTitle: String = "kDocumentInfoTitle"
let kDocumentInfoValue: String = "kDocumentInfoValue"

class CPDFInfoTableCell: UITableViewCell {
    
    var titleLabel: UILabel?
    var infoLabel: UILabel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        titleLabel = UILabel(frame: .zero)
        infoLabel = UILabel(frame: .zero)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Configure the cell
        if(titleLabel != nil) {
            contentView.addSubview(titleLabel!)
        }
        if(infoLabel != nil) {
            contentView.addSubview(infoLabel!)
        }
        
        titleLabel?.backgroundColor = .clear
        titleLabel?.isOpaque = false
        titleLabel?.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        titleLabel?.highlightedTextColor = .lightGray
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        titleLabel?.numberOfLines = 2
        titleLabel?.textAlignment = .left
        
        infoLabel?.backgroundColor = .clear
        infoLabel?.isOpaque = false
        infoLabel?.textColor = UIColor(red: 20/255, green: 96/255, blue: 243/255, alpha: 1)
        infoLabel?.highlightedTextColor = .lightGray
        infoLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        infoLabel?.numberOfLines = 2
        infoLabel?.textAlignment = .right
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentRect = contentView.bounds
        titleLabel?.frame = CGRect(x: 16, y: -2, width: contentRect.size.width/2 - 16, height: contentRect.size.height)
        infoLabel?.frame = CGRect(x: contentRect.size.width/2 - 16, y: -2, width: contentRect.size.width/2, height: contentRect.size.height)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setDataDictionary(_ newDictionary: [String: Any]) {
        titleLabel?.text = newDictionary[kDocumentInfoTitle] as? String
        infoLabel?.text = newDictionary[kDocumentInfoValue] as? String
        
        setNeedsLayout()
    }

}



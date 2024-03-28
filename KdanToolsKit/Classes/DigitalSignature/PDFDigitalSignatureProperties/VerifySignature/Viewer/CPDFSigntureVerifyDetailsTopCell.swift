//
//  CPDFSigntureVerifyDetailsTopCell.swift
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

class CPDFSigntureVerifyDetailsTopCell: UITableViewCell {
    
    var nameLabel: UILabel?
    var countLabel: UILabel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        nameLabel = UILabel(frame: CGRect(x: 25, y: 0, width: 120, height: 26))
        nameLabel?.font = UIFont.systemFont(ofSize: 13)
        
        countLabel = UILabel()
        countLabel?.autoresizingMask = .flexibleLeftMargin
        countLabel?.numberOfLines = 0
        countLabel?.textAlignment = .right
        countLabel?.font = UIFont.systemFont(ofSize: 13)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        if nameLabel != nil, countLabel != nil {
            contentView.addSubview(nameLabel!)
            contentView.addSubview(countLabel!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let attributes = [NSAttributedString.Key.font: countLabel?.font]
        let rect = (countLabel?.text ?? "").boundingRect(
            with: CGSize(width: self.bounds.size.width - 150, height: CGFloat.greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: attributes as [NSAttributedString.Key : Any],
            context: nil
        )
        let height = rect.size.height > 26 ? rect.size.height : 26
        countLabel?.frame = CGRect(x: 145, y: 0, width: self.bounds.size.width - 150, height: height)
    }
    
}

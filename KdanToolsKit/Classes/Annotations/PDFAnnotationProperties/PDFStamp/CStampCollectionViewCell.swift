//
//  CStampCollectionViewCell.swift
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

class CStampCollectionViewCell: UICollectionViewCell {
    var stampImage: UIImageView?
    var editing: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        stampImage = UIImageView()
        stampImage?.backgroundColor = UIColor.clear
        stampImage?.contentMode = .scaleAspectFit
        if stampImage != nil {
            contentView.addSubview(stampImage!)
        }
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        stampImage?.frame = CGRect(x: 10, y: (contentView.bounds.size.height - 50)/2, width: contentView.bounds.size.width - 20, height: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

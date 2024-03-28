//
//  CPDFArrowStyleCell.swift
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

class CPDFArrowStyleCell: UICollectionViewCell {
    var contextView: CPDFDrawArrowView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contextView = CPDFDrawArrowView(frame: CGRect(x: 1, y: 1, width: self.bounds.size.width - 2, height: self.bounds.size.height - 2))
        self.contextView.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        self.contentView.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        self.addSubview(self.contextView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}


//
//  CPDFSigntureCell.swift
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

class CPDFSigntureCells: UITableViewCell {
    @IBOutlet var arrowButton: UIButton?
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var contentOffsetX: NSLayoutConstraint?
    
    var model: CPDFSigntureModel?
    var isShow: Bool = false
    var callback: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        arrowButton?.setImage(UIImage(named: "ImageNameSignCloseFolder", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        arrowButton?.setImage(UIImage(named: "ImageNameSignOpenFolder", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
    }

    func setIndentationLevel(_ indentationLevel: Int) {
     
        contentOffsetX?.constant = CGFloat(indentationLevel * 15 + 10)
    }

    func setIsShow(_ isShow: Bool) {
        self.isShow = isShow
        model?.isShow = isShow
        
        if let count = model?.count {
            if isShow {
                arrowButton?.isSelected = true
            } else {
                arrowButton?.isSelected = false
            }
        }
    }

    @IBAction func arrowButtonAction(_ sender: Any) {
        callback?()
    }
}

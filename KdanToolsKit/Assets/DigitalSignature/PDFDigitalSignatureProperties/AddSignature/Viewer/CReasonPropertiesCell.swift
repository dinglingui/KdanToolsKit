//
//  CReasonPropertiesCell.swift
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

class CReasonPropertiesCell: UITableViewCell {
    var resonSelectLabel: UILabel?

    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        accessoryType = selected ? .checkmark : .none
    }

    func setCellLabel(_ label: String) {
        if self.resonSelectLabel == nil {
            self.resonSelectLabel = UILabel(frame: CGRect(x: 10, y: 5, width: bounds.size.width - 60, height: 50))
        }
        self.resonSelectLabel?.text = label
        self.resonSelectLabel?.font = UIFont.systemFont(ofSize: 15)
        contentView.addSubview(self.resonSelectLabel!)
        backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
    }
}

//
//  CPDFSigntureVerifyCell.swift
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

class CPDFSignatureVerifyCells: UITableViewCell {
    @IBOutlet weak var verifyConetentView: UIView?
    @IBOutlet weak var verifyImageView: UIImageView?
    @IBOutlet weak var grantorLabel: UILabel?
    @IBOutlet weak var grantorsubLabel: UILabel?
    @IBOutlet weak var expiredDateLabel: UILabel?
    @IBOutlet weak var expiredDateSubLabel: UILabel?
    @IBOutlet weak var stateLabel: UILabel?
    @IBOutlet weak var stateSubLabel: UILabel?
    @IBOutlet weak var deleteButton: UIButton?

    var deleteCallback: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        verifyConetentView?.layer.borderWidth = 1.0
        verifyConetentView?.backgroundColor = CPDFColorUtils.CViewBackgroundColor()
        verifyConetentView?.layer.cornerRadius = 5.0

        stateLabel?.text = NSLocalizedString("Status:", comment: "")
        expiredDateLabel?.text = NSLocalizedString("Date:", comment: "")
        grantorLabel?.text = NSLocalizedString("Signed by:", comment: "")
        grantorsubLabel?.numberOfLines = 0
        grantorsubLabel?.adjustsFontSizeToFitWidth = true
        stateSubLabel?.adjustsFontSizeToFitWidth = true

        deleteButton?.setTitle("", for: .normal)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    @IBAction func buttonClickItem_Delete(_ sender: Any) {
        deleteCallback?()
    }
}

//
//  CHeaderView.swift
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

@objc protocol CHeaderViewDelegate: AnyObject {
    @objc optional func CHeaderViewBack(_ headerView: CHeaderView)
    @objc optional func CHeaderViewCancel(_ headerView: CHeaderView)
}

class CHeaderView: UIView {
    private var backBtn: UIButton?
    var cancelBtn: UIButton?
    var titleLabel: UILabel?
    weak var delegate: CHeaderViewDelegate?

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }

    private func setupSubviews() {
        titleLabel = UILabel()
        titleLabel?.autoresizingMask = [.flexibleWidth, .flexibleRightMargin]
        titleLabel?.textAlignment = .center
        titleLabel?.font = UIFont.systemFont(ofSize: 20)
        titleLabel?.adjustsFontSizeToFitWidth = true
        if titleLabel != nil {
            addSubview(titleLabel!)
        }

        backBtn = UIButton()
        backBtn?.autoresizingMask = [.flexibleRightMargin]
        backBtn?.setImage(UIImage(named: "CDigitalSignatureViewControllerBack", in: Bundle(for: CHeaderView.self), compatibleWith: nil), for: .normal)
        backBtn?.addTarget(self, action: #selector(buttonItemClickedBack(_:)), for: .touchUpInside)
        if backBtn != nil {
            addSubview(backBtn!)
        }

        cancelBtn = UIButton()
        // cancelBtn.autoresizingMask = [.flexibleRightMargin]
        cancelBtn?.setImage(UIImage(named: "CDigitalSignatureViewControllerCancel", in: Bundle(for: CHeaderView.self), compatibleWith: nil), for: .normal)
        cancelBtn?.addTarget(self, action: #selector(buttonItemClickedCancel(_:)), for: .touchUpInside)
        if cancelBtn != nil {
            addSubview(cancelBtn!)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        titleLabel?.frame = CGRect(x: 60, y: 5, width: frame.size.width - 120, height: 50)
        cancelBtn?.frame = CGRect(x: frame.size.width - 60, y: 5, width: 50, height: 50)
        backBtn?.frame = CGRect(x: 10, y: 5, width: 50, height: 50)
    }

    // MARK: Actions

    @objc private func buttonItemClickedCancel(_ button: UIButton) {
        delegate?.CHeaderViewCancel?(self)
    }

    @objc private func buttonItemClickedBack(_ button: UIButton) {
        delegate?.CHeaderViewBack?(self)
    }
}

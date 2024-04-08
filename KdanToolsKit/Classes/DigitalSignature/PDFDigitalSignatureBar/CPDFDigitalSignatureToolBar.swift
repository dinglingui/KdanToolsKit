//
//  CPDFDigitalSignatureToolBar.swift
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
import ComPDFKit

@objc public protocol CPDFDigitalSignatureToolBarDelegate: AnyObject {
    @objc optional func verifySignatureBar(_ pdfSignatureBar: CPDFDigitalSignatureToolBar, sourceButton: UIButton)
    @objc optional func addSignatureBar(_ pdfSignatureBar: CPDFDigitalSignatureToolBar, sourceButton: UIButton)
}

public class CPDFDigitalSignatureToolBar: UIView {
    private(set) var pdfListView: CPDFListView
    public weak var delegate: CPDFDigitalSignatureToolBarDelegate?
    public var parentVC: UIViewController?
    
    private var addDigitalSignatureBtn: UIButton?
    
    private var verifyDigitalSignatureBtn: UIButton?
    
    private var annotationManage: CAnnotationManage?
    
    // MARK: - Initialize
    
    public init(pdfListView: CPDFListView) {
        self.pdfListView = pdfListView
        self.annotationManage = CAnnotationManage(pdfListView: pdfListView)
        
        super.init(frame: .zero)
        self.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
        
        addDigitalSignatureBtn = UIButton(frame: .zero)
        addDigitalSignatureBtn?.setImage(UIImage(named: "CPDFDigitalSignatureAdd", in: Bundle(for: CPDFAddWatermarkViewController.classForCoder()), compatibleWith: nil), for: .normal)
        addDigitalSignatureBtn?.addTarget(self, action: #selector(buttonItemClickedAdd(_:)), for: .touchUpInside)
        verifyDigitalSignatureBtn = UIButton(frame: .zero)
        verifyDigitalSignatureBtn?.setImage(UIImage(named: "CPDFDigitalSignatureVerify", in: Bundle(for: CPDFAddWatermarkViewController.classForCoder()), compatibleWith: nil), for: .normal)
        verifyDigitalSignatureBtn?.addTarget(self, action: #selector(buttonItemClickedVerify(_:)), for: .touchUpInside)
        
        if addDigitalSignatureBtn != nil {
            configureButton(addDigitalSignatureBtn!, title: NSLocalizedString("Add a Signature Field", comment: ""), image: "CPDFDigitalSignatureAdd", action: #selector(buttonItemClickedAdd))
        }
        if addDigitalSignatureBtn != nil {
            configureButton(verifyDigitalSignatureBtn!, title: NSLocalizedString("Verify the Signature", comment: ""), image: "CPDFDigitalSignatureVerify", action: #selector(buttonItemClickedVerify))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        addDigitalSignatureBtn?.frame = CGRect(x: (frame.size.width - 310) / 2, y: 5, width: 140, height: 50)
        verifyDigitalSignatureBtn?.frame = CGRect(x: (addDigitalSignatureBtn?.frame.origin.x ?? 0) + 170, y: 5, width: 140, height: 50)
    }
    
    // MARK: - Action
    
    @objc func buttonItemClickedAdd(_ button: UIButton) {
        button.isSelected.toggle()
        if button.isSelected {
            button.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
            verifyDigitalSignatureBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
            pdfListView.setAnnotationMode(.signature)
            pdfListView.setToolModel(.form)
            annotationManage?.setAnnotStyle(from: .signature)
        } else {
            button.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
            pdfListView.setToolModel(.viewer)
            pdfListView.setAnnotationMode(CPDFViewAnnotationMode.CPDFViewAnnotationModenone)
        }
        
        delegate?.addSignatureBar?(self, sourceButton: button)
    }
    
    @objc func buttonItemClickedVerify(_ button: UIButton) {
        if button.isSelected {
            addDigitalSignatureBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        }
        delegate?.verifySignatureBar?(self, sourceButton: button)
    }
    
    private func configureButton(_ button: UIButton, title: String, image: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(CPDFColorUtils.CPageEditToolbarFontColor(), for: .normal)
        
        button.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.layer.cornerRadius = 10.0
        button.layer.masksToBounds = true
        addSubview(button)
    }
    
    // MARK: - Public Methods
    
    public func updateStatusWith(signatures: [CPDFSignature]?) {
        // Update the status with the provided signatures
        if (signatures?.count ?? 0) > 0 {
            verifyDigitalSignatureBtn?.setTitleColor(CPDFColorUtils.CPageEditToolbarFontColor(), for: .normal)
            verifyDigitalSignatureBtn?.isEnabled = true
        } else {
            verifyDigitalSignatureBtn?.setTitleColor(.gray, for: .normal)
            verifyDigitalSignatureBtn?.isEnabled = false
        }
    }
    
    // MARK: - Private Methods
    
    private func imageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}

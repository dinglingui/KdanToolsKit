//
//  CLocationSelectView.swift
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

@objc protocol CLocationSelectViewDelegate: AnyObject {
    @objc optional func locationSelectView(_ locationSelectView: CLocationSelectView, isFront: Bool)
}

class CLocationSelectView: UIView {
    
    weak var delegate: CLocationSelectViewDelegate?
    
    private var titleLabel: UILabel?
    
    private var topButton: UIButton?
    
    private var bottomButton: UIButton?

    // MARK: - Initializers
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        titleLabel = UILabel()
        titleLabel?.autoresizingMask = .flexibleRightMargin
        titleLabel?.text = NSLocalizedString("Layout Options", comment: "")
        titleLabel?.textColor = .gray
        titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        if titleLabel != nil {
            addSubview(titleLabel!)
        }
        
        topButton = UIButton()
        topButton?.setImage(UIImage(named: "CLocationSelectTopImage", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        topButton?.addTarget(self, action: #selector(buttonItemClicked_Top), for: .touchUpInside)
        if topButton != nil {
            addSubview(self.topButton!)
        }
        
        bottomButton = UIButton()
        bottomButton?.setImage(UIImage(named: "CLocationSelectBottomImage", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        bottomButton?.addTarget(self, action: #selector(buttonItemClicked_Bottom), for: .touchUpInside)
        if bottomButton != nil {
            addSubview(self.bottomButton!)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel?.frame = CGRect(x: 20, y: 0, width: 200, height: 30)
        topButton?.frame = CGRect(x: bounds.size.width - 65, y: 0, width: 45, height: 30)
        bottomButton?.frame = CGRect(x: bounds.size.width - 110, y: 0, width: 45, height: 30)
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_Top(_ sender: UIButton) {
        topButton?.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        bottomButton?.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        
        topButton?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
        
        delegate?.locationSelectView?(self, isFront: true)
    }
    
    @objc func buttonItemClicked_Bottom(_ sender: UIButton) {
        topButton?.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        bottomButton?.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        
        bottomButton?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
        
        delegate?.locationSelectView?(self, isFront: false)
    }
    
    func setLocation(_ isFront: Bool) {
        topButton?.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        bottomButton?.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        
        if isFront {
            topButton?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
        } else {
            bottomButton?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
        }
    }
    
}

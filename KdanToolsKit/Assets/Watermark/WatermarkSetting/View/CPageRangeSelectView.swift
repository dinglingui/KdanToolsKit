//
//  CPageRangeSelectView.swift
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

@objc protocol CPageRangeSelectViewDelegate: AnyObject {
    @objc optional func pageRangeSelectView(_ pageRangeSelectView: CPageRangeSelectView, pageRange: String)
}

class CPageRangeSelectView: UIView {
    
    weak var delegate: CPageRangeSelectViewDelegate?
    
    var parentVC: UIViewController?
    
    private var titleLabel: UILabel?
    
    var pageRangeView: UIView?
    
    var pageRangeLabel: UILabel?
    
    var pageRangeButton: UIButton?
    
    var pageRangeIcon: UIImageView?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        titleLabel = UILabel()
        titleLabel?.autoresizingMask = .flexibleRightMargin
        titleLabel?.text = NSLocalizedString("Page Range", comment: "")
        titleLabel?.textColor = .gray
        titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        if titleLabel != nil {
            addSubview(titleLabel!)
        }
        
        pageRangeView = UIView()
        pageRangeView?.autoresizingMask = .flexibleLeftMargin
        pageRangeView?.layer.borderColor = UIColor.gray.cgColor
        pageRangeView?.layer.borderWidth = 0.5
        pageRangeView?.layer.cornerRadius = 5
        pageRangeView?.layer.masksToBounds = true
        if pageRangeView != nil {
            addSubview(pageRangeView!)
        }
        
        pageRangeLabel = UILabel()
        pageRangeLabel?.text = NSLocalizedString("All Pages", comment: "")
        pageRangeLabel?.font = UIFont.systemFont(ofSize: 14)
        pageRangeLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
        pageRangeLabel?.textAlignment = .left
        if pageRangeLabel != nil {
            pageRangeView?.addSubview(pageRangeLabel!)
        }
        
        pageRangeIcon = UIImageView(image: UIImage(named: "CWatermarkPreImage", in: Bundle(for: self.classForCoder), compatibleWith: nil))
        if pageRangeIcon != nil {
            pageRangeView?.addSubview(pageRangeIcon!)
        }
        
        pageRangeButton = UIButton()
        pageRangeButton?.backgroundColor = .clear
        pageRangeButton?.addTarget(self, action: #selector(buttonItemClicked_range), for: .touchUpInside)
        if pageRangeButton != nil {
            pageRangeView?.addSubview(pageRangeButton!)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel?.frame = CGRect(x: 20, y: 0, width: 100, height: 30)
        pageRangeView?.frame = CGRect(x: bounds.size.width - 200, y: 0, width: 180, height: 30)
        pageRangeLabel?.frame = CGRect(x: 5, y: 0, width: 145, height: 30)
        pageRangeIcon?.frame = CGRect(x: 150, y: 5, width: 20, height: 20)
        pageRangeButton?.frame = pageRangeView?.bounds ?? .zero
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_range(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if UI_USER_INTERFACE_IDIOM() == .pad {
            alertController.popoverPresentationController?.sourceView = self.pageRangeButton
            alertController.popoverPresentationController?.sourceRect = ((self.pageRangeButton)?.bounds) ?? .zero
        }
        
        let defaultRange = UIAlertAction(title: NSLocalizedString("All Pages", comment: ""), style: .default) { (action) in
            self.pageRangeLabel?.text = NSLocalizedString("All Pages", comment: "")
            self.delegate?.pageRangeSelectView?(self, pageRange: "")
        }
        
        let customRange = UIAlertAction(title: NSLocalizedString("Current Page", comment: ""), style: .default) { (action) in
            self.pageRangeLabel?.text = NSLocalizedString("Current Page", comment: "")
            self.delegate?.pageRangeSelectView?(self, pageRange: "0")
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
            
        }
        
        alertController.addAction(defaultRange)
        alertController.addAction(customRange)
        alertController.addAction(cancelAction)
        
        parentVC?.present(alertController, animated: true, completion: nil)
    }
    
}

//
//  CAnnotListHeaderInSection.swift
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

class CAnnotListHeaderInSection: UITableViewHeaderFooterView {
    
    var shadowView:UIView?
    var pagenumber:UILabel?
    var annotscount:UILabel?
    var mainView:UIView?
    var mainViewHeight:CGFloat = 0
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = CPDFColorUtils.CViewBackgroundColor()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
    func setPageNumber(number: Int) {
        if pagenumber == nil {
            pagenumber = UILabel()
            pagenumber?.backgroundColor = UIColor.clear
            if #available(iOS 13.0, *) {
                pagenumber?.textColor = UIColor.label
            } else {
                pagenumber?.textColor = UIColor.black
            }
            pagenumber?.font = UIFont.systemFont(ofSize: 13.0)
            if pagenumber != nil {
                contentView.addSubview(pagenumber!)
            }
        }
        pagenumber?.text = String(format: NSLocalizedString("Page %ld", comment: ""), number)
        pagenumber?.sizeToFit()
        
        var rect = pagenumber?.frame ?? CGRect.zero
        rect.origin = CGPoint(x: 16, y: (self.frame.size.height - rect.size.height) / 2.0)
        
        pagenumber?.frame = rect
        
    }
    
    func setAnnotsCount(count: Int) {
        if shadowView == nil {
            shadowView = UIView()
            shadowView?.layer.shadowColor = UIColor.black.cgColor
            shadowView?.layer.shadowOffset = CGSize(width: 0, height: 1.0)
            shadowView?.layer.shadowOpacity = 0.3
            if shadowView != nil {
                mainView?.addSubview(shadowView!)
            }
        }
        if annotscount == nil {
            annotscount = UILabel()
            if #available(iOS 13.0, *) {
                annotscount?.textColor = UIColor.label
            } else {
                annotscount?.textColor = UIColor.black
            }
            annotscount?.font = UIFont.boldSystemFont(ofSize: 13.0)
            annotscount?.textAlignment = .center
            annotscount?.autoresizingMask = .flexibleLeftMargin
            annotscount?.layer.cornerRadius = 2
            annotscount?.layer.masksToBounds = true
            if annotscount != nil {
                contentView.addSubview(annotscount!)
            }
        }
        
        annotscount?.text = String(count)
        annotscount?.sizeToFit()
        var rect = annotscount?.frame ?? CGRect.zero
        rect.size.width = rect.size.width < 8 ? 16 : rect.size.width + 8
        rect.size.height = 16
        rect.origin = CGPoint(x: (mainView?.frame.size.width ?? 0) - rect.size.width - 5, y: (self.frame.size.height - rect.size.height) / 2.0)
        annotscount?.frame = rect
        shadowView?.frame = rect
        
    }
}

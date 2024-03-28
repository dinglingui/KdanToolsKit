//
//  CPDFTipsView.swift
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

public class CPDFTipsView: UIView {

    private var searchLabel = UILabel()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.init(red: 28.0/255.0, green: 28.0/255.0, blue: 30.0/255.0, alpha: 1.9)
        searchLabel.textColor = UIColor.white
        addSubview(searchLabel)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func postAlertWithMessage(message:String) {
        searchLabel.text = message
        searchLabel.sizeToFit()
        searchLabel.font = UIFont.systemFont(ofSize: 14.0)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .left
        paragraphStyle.lineSpacing = 2

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.black
        ]

        let limitSize = CGSize(width: 250, height: 10000)

        let rect = (message as NSString).boundingRect(
            with: limitSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        
        searchLabel.frame = CGRect(x: 0, y: 0, width: 250, height: rect.height)
    }
    
    public func showView(_ subView: UIView) {
        self.frame = CGRect(x: CGFloat(Int((subView.frame.size.width - 250.0))/2) - 10, y: CGFloat(Int((subView.frame.size.height - searchLabel.height))/2) - 10, width: searchLabel.width + 20, height: searchLabel.height + 20)
        self.layer.cornerRadius = 5
        subView.addSubview(self)

        searchLabel.frame = CGRect(x: 10, y: 10, width: searchLabel.width, height: searchLabel.height)
        self.perform(#selector(hidePageView), with: nil, afterDelay: 1.0)


    }
    
     @objc func showTip() {
        if self.isHidden {
            self.alpha = 1.0
            self.isHidden = false
        }
        self.perform(#selector(hidePageView), with: nil, afterDelay: 1.0)

    }
    
    @objc  func hidePageView() {
        if self.isHidden {
            return
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
        }) { (finished) in
            self.isHidden = true
        }
    }

    
}

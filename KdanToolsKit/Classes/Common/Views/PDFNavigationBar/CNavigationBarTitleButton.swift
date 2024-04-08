//
//  CNavigationBarTitleButton.swift
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
import Foundation

public class CNavigationBarTitleButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        
        self.setTitleColor(.black, for: .normal)
        
        self.titleLabel?.textAlignment = .right
        
        self.titleLabel?.numberOfLines = 0
        
        self.adjustsImageWhenDisabled = false
        
        self.imageView?.contentMode = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let height = contentRect.size.height
        let width = height
        let x = self.frame.size.width - width
        let y: CGFloat = 0.0
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    public override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let height = contentRect.size.height
        let width = self.frame.size.width - height
        let x: CGFloat = 0
        let y: CGFloat = 0
        return CGRect(x: x, y: y, width: width, height: height)
    }

    public override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        
        let param: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: self.titleLabel?.font ?? UIFont.systemFont(ofSize: 17.0)]
        let titleWidth = title?.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: self.frame.size.height), options: [.usesLineFragmentOrigin], attributes: param, context: nil).size.width ?? 0.0
        
        var frame = self.frame
        frame.size.width = titleWidth + self.frame.size.height + 10
        self.frame = frame
    }

}

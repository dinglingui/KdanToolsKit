//
//  CPDFEditImageSampleView.swift
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

class CPDFEditImageSampleView: UIView {
    var imageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 90, height: 108))
        self.imageView?.image = UIImage(named: "CPDFEditImageSample", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        self.imageView?.contentMode = .scaleAspectFill
        self.imageView?.isUserInteractionEnabled = true
        if(imageView != nil) {
            self.addSubview(self.imageView!)
        }
        self.backgroundColor = CPDFColorUtils.CAnnotationSampleDrawBackgoundColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.imageView?.frame = self.bounds.insetBy(dx: self.bounds.size.width/7*3, dy: self.bounds.size.height/4)
        
    }
    
}

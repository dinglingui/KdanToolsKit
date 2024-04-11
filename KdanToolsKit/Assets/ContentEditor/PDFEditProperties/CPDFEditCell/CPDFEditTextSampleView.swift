//
//  CPDFEditTextSampleView.swift
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

class CPDFEditTextSampleView: UIView {
    
    var sampleLabel: UILabel?
    
    var textColor: UIColor = .black {
        didSet {
            self.sampleLabel?.textColor = textColor
        }
    }
    
    var textOpacity: CGFloat = 1 {
        didSet {
            self.sampleLabel?.alpha = textOpacity
        }
    }
    
    var textAlignmnet: NSTextAlignment = .center {
        didSet {
            self.sampleLabel?.textAlignment = textAlignmnet
        }
    }
    
    var fontSize: CGFloat = 20 {
        didSet {
            if(fontName != nil) {
                self.sampleLabel?.font = UIFont(name: fontName! as String, size: fontSize)
            } else {
                self.sampleLabel?.font = UIFont.systemFont(ofSize: fontSize)
                
            }
        }
    }
    
    var fontName: String? {
        didSet {
            if(fontName != nil) {
                self.sampleLabel?.font = UIFont(name: fontName! as String, size: self.fontSize)
            } else {
                self.sampleLabel?.font = UIFont.systemFont(ofSize: self.fontSize)
                
            }
            self.sampleLabel?.textColor = self.textColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.sampleLabel = UILabel()
        self.sampleLabel?.text = "Sample"
        self.sampleLabel?.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        self.sampleLabel?.font = UIFont(name: "Helvetica", size: 20)
        let fontD = self.sampleLabel?.font.fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic])
        self.sampleLabel?.font = UIFont(descriptor: fontD ?? UIFontDescriptor(), size: 0)
        self.sampleLabel?.textAlignment = .center
        if sampleLabel != nil {
            self.addSubview(self.sampleLabel!)
        }
        
        self.backgroundColor = CPDFColorUtils.CAnnotationSampleDrawBackgoundColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.sampleLabel?.frame = self.bounds
    }
    
}

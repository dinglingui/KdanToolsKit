//
//  CPDFSlider.swift
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
import ComPDFKit

public class CPDFSlider: UIView {
    
    var valueView:UIImageView?
    
    var label:UILabel?
    
    var isTouchBegan:Bool = false
    
    var pdfView:CPDFView?

    public init(pdfView: CPDFView) {
        super.init(frame: CGRect.zero)
        self.pdfView = pdfView
        
        valueView = UIImageView(frame: CGRect(x: self.frame.size.width-26, y: 0, width: 24, height: 36))
        self.valueView?.autoresizingMask = .flexibleLeftMargin
        self.valueView?.image = UIImage(named: "CPDFSliderImageSlidepage", in: Bundle(for: type(of: self)), compatibleWith: nil)
        
        self.label = UILabel()
        self.label?.textAlignment = .center
        self.label?.textColor = .white
        self.label?.backgroundColor = .black
        self.label?.layer.cornerRadius = 2.0
        self.label?.layer.borderWidth = 1.0
        self.label?.font = UIFont.systemFont(ofSize: 12.0)
        self.label?.isHidden = true
        
        self.addSubview(self.label!)
        self.addSubview(self.valueView!)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func reloadData() {
        var center:CGPoint = self.valueView?.center ?? CGPoint.zero
        let pageIndex:Int = self.pdfView?.currentPageIndex ?? 0
        let height:CGFloat = self.valueView?.frame.height ?? 0
        if self.pdfView?.document != nil {
            let pageHeight = self.frame.height / CGFloat(self.pdfView?.document.pageCount ?? 0)
            
            if center.y >= CGFloat(pageIndex) * pageHeight && center.y <= (CGFloat(pageIndex) + 1) * pageHeight {
                return
            }
            
            center.y = CGFloat(pageIndex) * pageHeight + pageHeight
            center.y = max(height / 2.0, center.y)
            center.y = min(center.y, self.frame.height - height)
            self.valueView?.center = center
        }
    }
    
    func updateLabelFrame() {
        let center:CGPoint = self.valueView?.center ?? CGPoint.zero
        let height = self.valueView?.frame.height
        let pageHeight = (self.frame.height - (height ?? 0)) / CGFloat(self.pdfView?.document.pageCount ?? 0)
        var pageIndex = Int((center.y - (height ?? 0)/2.0) / pageHeight)
        pageIndex = max(0, pageIndex)
        pageIndex = min(pageIndex, Int(self.pdfView?.document.pageCount ?? 0) - 1)
        
        self.label?.text = "\(pageIndex+1)"
        self.label?.sizeToFit()
        self.label?.frame = CGRect(x: 0, y: 0, width: (self.label?.frame.width ?? 0) + 20, height: (self.label?.frame.height ?? 0) + 10)
        self.label?.center = CGPoint(x: -(self.label?.frame.width ?? 0)/2.0 - 10, y: center.y)
    }
    
    // MARK: - touches
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            self.isTouchBegan = ((self.valueView?.frame.contains(location)) != nil)
            if self.isTouchBegan {
                self.label?.isHidden = false
                updateLabelFrame()
            }
        }
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.isTouchBegan {
            return
        }
        if let touch = touches.first {
            let location = touch.location(in: self)
            var center:CGPoint = self.valueView?.center ?? CGPoint.zero
            if location.y < (self.valueView?.frame.height ?? 0)/2.0 {
                center.y = (self.valueView?.frame.height ?? 0)/2.0
            } else if location.y > self.frame.height - (self.valueView?.frame.height ?? 0)/2.0 {
                center.y = self.frame.height - (self.valueView?.frame.height ?? 0)/2.0
            } else {
                center.y = location.y
            }
            self.valueView?.center = center
            updateLabelFrame()
        }
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.isTouchBegan {
            return
        }
        self.label?.isHidden = true
        if let pageIndex = Int(self.label?.text ?? "") {
            self.pdfView?.go(toPageIndex: pageIndex - 1, animated: false)
        }
    }

}

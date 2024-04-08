//
//  CSearchContentView.swift
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

public class CSearchContentView: UIView {
    public var pdflistView: CPDFListView?
    private var replaceButton = UIButton()
    private var replaceBounds:CGRect = CGRect.zero
    private var orgSelection:CPDFSelection?

    public var callback: (() -> Void)?

    init(pdfView: CPDFListView) {
        self.pdflistView = pdfView
        super.init(frame: .zero)
        self.commonInit()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let drawRect = replaceBounds
        if(self.replaceButton.isHidden == true) {
            return
        }
        
        var x = drawRect.origin.x + drawRect.size.width/2 - 40
        if(x < 0) {
            x = 0
        }
        
        var y = drawRect.origin.y - 45
        if(y < 0) {
            y = drawRect.origin.y + 10 + replaceBounds.size.height
            let buttonRect = CGRect(x: x, y: y, width: self.replaceButton.frame.size.width, height: self.replaceButton.frame.size.height)

            let offset = 10.0
            context.beginPath()
            context.move(to: CGPoint(x: buttonRect.midX + offset, y: buttonRect.minY))
            context.addLine(to: CGPoint(x: buttonRect.midX, y: buttonRect.minY - offset))
            context.addLine(to: CGPoint(x: buttonRect.midX - offset, y: buttonRect.minY))
            context.closePath()
            context.setFillColor(UIColor.init(red: 28.0/255.0, green: 28.0/255.0, blue: 28.0/255.0, alpha: 1.0).cgColor)
            context.fillPath()
            
        } else {
            let buttonRect = CGRect(x: x, y: y, width: self.replaceButton.frame.size.width, height: self.replaceButton.frame.size.height)

            let offset = 10.0
            context.beginPath()
            context.move(to: CGPoint(x: buttonRect.midX + offset, y: buttonRect.maxY))
            context.addLine(to: CGPoint(x: buttonRect.midX, y: buttonRect.maxY + offset))
            context.addLine(to: CGPoint(x: buttonRect.midX - offset, y: buttonRect.maxY))
            context.closePath()
            context.setFillColor(UIColor.init(red: 28.0/255.0, green: 28.0/255.0, blue: 28.0/255.0, alpha: 1.0).cgColor)
            context.fillPath()
            
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if(self.pdflistView != nil && self.superview != nil && self.orgSelection != nil) {
            let pageBounds = self.pdflistView!.convert(self.orgSelection!.bounds, from: self.orgSelection!.page)
            let pdfviewBounds = self.superview!.convert(pageBounds, from: self.pdflistView)
            let convertRect:CGRect = self.convert(pdfviewBounds, from: self.superview)

            var x = convertRect.origin.x + convertRect.size.width/2 - 40
            if(x < 0) {
                x = 0
            }
            var y = convertRect.origin.y - 35 - 10

            if(y < 0) {
                y = convertRect.origin.y + convertRect.size.height + 10
            }
            replaceBounds = convertRect
            replaceButton.frame = CGRect(x: x, y: y, width: 80, height: 35)
            setNeedsDisplay()
        }

    }
    
    open func updateSelection(_ selection: CPDFSelection?) {
        self.orgSelection = selection
        if(self.pdflistView != nil && self.superview != nil && self.orgSelection != nil) {
            replaceButton.isHidden = false

            let pageBounds = self.pdflistView!.convert(self.orgSelection!.bounds, from: self.orgSelection!.page)
            let pdfviewBounds = self.superview!.convert(pageBounds, from: self.pdflistView)
            let convertRect:CGRect = self.convert(pdfviewBounds, from: self.superview)

            var x = convertRect.origin.x + convertRect.size.width/2 - 40
            if(x < 0) {
                x = 0
            }
            var y = convertRect.origin.y - 35 - 10

            if(y < 0) {
                y = convertRect.origin.y + 10 + convertRect.size.height
            }
            replaceBounds = convertRect
            replaceButton.frame = CGRect(x: x, y: y, width: 80, height: 35)

        } else {
            replaceButton.isHidden = true
            replaceBounds = CGRect.zero

        }
        setNeedsDisplay()
    }
    
    func commonInit() {
        self.backgroundColor = UIColor.clear
        
        addSubview(replaceButton)
        replaceButton.backgroundColor = UIColor.init(red: 28.0/255.0, green: 28.0/255.0, blue: 28.0/255.0, alpha: 1.0)
        replaceButton.layer.cornerRadius = 5
        replaceButton.frame = CGRect(x: 0, y: 0, width: 80, height: 35)
        replaceButton.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        replaceButton.setTitle(NSLocalizedString("Replace", comment: ""), for: .normal)
        replaceButton.titleLabel?.adjustsFontSizeToFitWidth = true
        replaceButton.setTitleColor(UIColor.white, for: .normal)
        replaceButton.addTarget(self, action: #selector(buttonItemClicked_Replace(_:)), for: .touchUpInside)
    }
    
    // MARK: - Action

    @objc func buttonItemClicked_Replace(_ sender: Any) {
        callback?()
    }

}


//
//  CPDFPageIndicatorView.swift
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

public enum CPDFPageIndicatorViewPosition: Int {
    case CPDFPageIndicatorViewPositionLeftBottom = 0
    case CPDFPageIndicatorViewPositionCenterBottom
}

public class CPDFPageIndicatorView: UIView {
    
    var touchCallBack: (() -> Void)?
    var indicatorBackgroudColor: UIColor?
    var indicatorCornerRadius: CGFloat = 0
    
    var pageNumButton: UIButton?
    
    var atPosition: CPDFPageIndicatorViewPosition = .CPDFPageIndicatorViewPositionCenterBottom
    
    
    init() {
        super.init(frame: CGRect.zero )
        
        pageNumButton = UIButton(type: .custom)
        pageNumButton?.setTitle(" 0/0 ", for: .normal)
        pageNumButton?.setTitleColor(UIColor.white, for: .normal)
        indicatorCornerRadius = 5
        
        backgroundColor = UIColor.black
        isUserInteractionEnabled = true
        pageNumButton?.addTarget(self, action: #selector(buttonItemClick_PageNum(_:)), for: .touchUpInside)
        
        if pageNumButton != nil {
            addSubview(self.pageNumButton!)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePageCount(_ pageCount: Int, currentPageIndex: Int) {
        self.pageNumButton?.setTitle(" \(currentPageIndex)/\(pageCount) ", for: .normal)
        self.pageNumButton?.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        self.pageNumButton?.sizeToFit()
        self.pageNumButton?.frame = CGRect(x: self.pageNumButton?.frame.origin.x ?? 0, y: self.pageNumButton?.frame.origin.y ?? 0, width: (self.pageNumButton?.frame.size.width ?? 0) + 10, height: self.pageNumButton?.frame.size.height ?? 0)
        
        self.pageNumButton?.backgroundColor = self.indicatorBackgroudColor
        self.layer.cornerRadius = self.indicatorCornerRadius
        self.pageNumButton?.layer.cornerRadius = self.indicatorCornerRadius
        
        let offset:CGFloat = self.pageOffset()
        
        var offsetX:CGFloat = offset
        var offsetY:CGFloat = offset
        
        switch self.atPosition {
        case .CPDFPageIndicatorViewPositionLeftBottom:
            offsetY = (self.superview?.frame.size.height ?? 0) - (self.pageNumButton?.frame.size.height ?? 0)
        case .CPDFPageIndicatorViewPositionCenterBottom:
            offsetY = (self.superview?.frame.size.height ?? 0) - (self.pageNumButton?.frame.size.height ?? 0)
            offsetX = ((self.superview?.frame.size.width ?? 0) - (self.pageNumButton?.frame.size.width ?? 0)) / 2
        }
        
        self.frame = CGRect(x: offsetX, y: offsetY - offset, width: self.pageNumButton?.frame.size.width ?? 0, height: self.pageNumButton?.frame.size.height ?? 0)
        
        self.showPageNumIndicator()
        self.perform(#selector(hidePageNumIndicator), with: nil, afterDelay: 3.0)
    }
    
    // Public method
    func show(in subView: UIView, position: CPDFPageIndicatorViewPosition) {
        self.atPosition = position
        subView.addSubview(self)
        self.setNeedsLayout()
    }
    
    
    // MARK: - Action
    @objc func buttonItemClick_PageNum(_ button :UIButton) {
        if self.touchCallBack != nil {
            self.touchCallBack!()
        }
    }
    
    func pageOffset() -> CGFloat {
        return 20.0
    }
    
    @objc  func hidePageNumIndicator() {
        if self.isHidden {
            return
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            
        }) { (finished) in
            self.isHidden = true
        }
    }
    
    @objc func showPageNumIndicator() {
        if self.isHidden {
            self.isHidden = false
        }
    }
}

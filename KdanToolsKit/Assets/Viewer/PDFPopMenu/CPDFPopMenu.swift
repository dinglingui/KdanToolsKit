//
//  CPDFPopMenu.swift
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

public protocol CPDFPopMenuDelegate: AnyObject {
    func menuDidClosed(in menu: CPDFPopMenu, isClosed: Bool)
}

public class CPDFPopMenu: UIView {
    
    var backgroundContainer: UIImageView?
    var coverLayer: UIButton?
    var contentView: UIView?
    var dimCoverLayer: Bool = false
    public weak var delegate: CPDFPopMenuDelegate?
    
    private var lastRect:CGRect = CGRect.zero

    init(contentView: UIView) {
        super.init(frame: .zero)
        self.contentView = contentView
        setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    private func setUp() {
        coverLayer = UIButton(type: .custom)
        self.setDimCoverLayer(true)
        coverLayer?.addTarget(self, action: #selector(coverLayerClicked), for: .touchUpInside)
        if coverLayer != nil {
            addSubview(coverLayer!)
        }
        
        backgroundContainer = UIImageView()
        backgroundContainer?.isUserInteractionEnabled = true
        if backgroundContainer != nil {
            addSubview(backgroundContainer!)
        }
    }
    
    static func popMenu(with contentView: UIView) -> CPDFPopMenu {
        return CPDFPopMenu(contentView: contentView)
    }
    
    // MARK: - Usage

    @objc public func showMenu(in rect: CGRect) {
        self.lastRect = rect
        guard let window = UIApplication.shared.keyWindow else { return }
        frame = window.bounds
        window.addSubview(self)
        
        coverLayer?.frame = window.bounds
        backgroundContainer?.frame = rect
        
        if let contentView = contentView {
            let topMargin: CGFloat = 12
            let leftMargin: CGFloat = 5
            let bottomMargin: CGFloat = 8
            let rightMargin: CGFloat = 5
            
            contentView.frame.origin.x = leftMargin
            contentView.frame.origin.y = topMargin
            contentView.frame.size.width = (backgroundContainer?.frame.width ?? 0) - leftMargin - rightMargin
            contentView.frame.size.height = (backgroundContainer?.frame.height ?? 0) - topMargin - bottomMargin
            
            backgroundContainer?.addSubview(contentView)
        }
        
        delegate?.menuDidClosed(in: self, isClosed: false)
    }

    @objc func coverLayerClicked() {
        hideMenu()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    func hideMenu() {
        removeFromSuperview()
        
        if delegate?.menuDidClosed(in: self, isClosed: true) != nil {
            delegate?.menuDidClosed(in: self, isClosed: true)
        }
    }
    
    // MARK: - Property

    func setDimCoverLayer(_ dimCoverLayer: Bool) {
        if dimCoverLayer {
            coverLayer?.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        } else {
            coverLayer?.backgroundColor = UIColor.clear
        }
    }

}


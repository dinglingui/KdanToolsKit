//
//  CSearchTitleView.swift
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

@objc public protocol CSearchTitleViewDelegate: AnyObject {
        
    @objc optional func searchTitleViewChangeType(_ searchTitleView: CSearchTitleView, onChange searchType: Int)
}

public enum CSearchTitleType: Int {
    case search = 0
    case replace
}

public class CSearchTitleView: UIView {
    
    public var pdfView: CPDFListView?
    
    private var searchItem = UIButton()
    private var searchLineView = UIView()
    private var replaceItem = UIButton()
    private var replaceLineView = UIView()

    weak var delegate: CSearchTitleViewDelegate?

    private var searchTitleType:CSearchTitleType = .search

    init(pdfView: CPDFListView) {
        self.pdfView = pdfView
        super.init(frame: .zero)
        self.commonInit()
        
        if searchTitleType == .replace {
            self.searchLineView.backgroundColor = UIColor.clear
            self.replaceLineView.backgroundColor = UIColor.systemBlue;
        } else {
            self.searchLineView.backgroundColor = UIColor.systemBlue
            self.replaceLineView.backgroundColor = UIColor.clear;
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if(self.pdfView?.isEditing() == true) {
            let offset = 15.0
            searchItem.frame = CGRect(x: 0 , y: 0, width: searchItem.width, height: 38)
            searchLineView.frame = CGRect(x: 0 , y: 38, width: searchItem.width, height: 2)
            searchLineView.centerX = searchItem.centerX
            replaceItem.frame = CGRect(x: searchItem.width + offset , y: 0, width: replaceItem.width, height: 38)
            replaceLineView.frame = CGRect(x: 0 , y: 38, width: replaceItem.width, height: 2)
            replaceLineView.centerX = replaceItem.centerX
        } else {
            searchItem.frame = CGRect(x: 0, y: 0, width: searchItem.width, height: 40)
        }
    }
    
    func commonInit() {
        searchItem.setTitle(NSLocalizedString("Search", comment: ""), for: .normal)
        searchItem.setTitleColor(CPDFColorUtils.CFormFontColor(), for: .normal)
        searchItem.sizeToFit()
        searchLineView.backgroundColor = UIColor.clear
        
        replaceItem.setTitle(NSLocalizedString("Replace", comment: ""), for: .normal)
        replaceItem.setTitleColor(CPDFColorUtils.CFormFontColor(), for: .normal)
        replaceItem.sizeToFit()
        replaceLineView.backgroundColor = UIColor.clear
        searchItem.frame = CGRect(x: 0 , y: 0, width: searchItem.width + 20, height: 38)

        self.frame = CGRect(x: 0, y: 0, width: searchItem.width + 20, height: 40)

        addSubview(searchItem)

        if(self.pdfView?.isEditing() == true) {
            replaceItem.frame = CGRect(x: searchItem.width + 15 , y: 0, width: replaceItem.width + 20, height: 38)

            searchItem.addTarget(self, action: #selector(buttonItemClicked_Search(_:)), for: .touchUpInside)
            replaceItem.addTarget(self, action: #selector(buttonItemClicked_Replace(_:)), for: .touchUpInside)
            addSubview(searchLineView)

            addSubview(replaceItem)
            addSubview(replaceLineView)
            
            self.frame = CGRect(x: 0, y: 0, width: (searchItem.width) + 15.0 + (replaceItem.width), height: 35)
        }
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_Search(_ sender: Any) {
        if(self.searchTitleType != .search) {
            self.searchTitleType = .search
            self.delegate?.searchTitleViewChangeType?(self, onChange: Int(CSearchTitleType.search.rawValue))
            self.searchLineView.backgroundColor = UIColor.systemBlue
            self.replaceLineView.backgroundColor = UIColor.clear;

        }
    }
    
    @objc func buttonItemClicked_Replace(_ sender: Any) {
        if(self.searchTitleType != .replace) {
            self.searchTitleType = .replace

            self.delegate?.searchTitleViewChangeType?(self, onChange: Int(CSearchTitleType.replace.rawValue))
            self.searchLineView.backgroundColor = UIColor.clear
            self.replaceLineView.backgroundColor = UIColor.systemBlue;

        }

    }
}

//
//  CPDFPopMenuView.swift
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

public enum CPDFPopMenuViewType: Int {
    case setting = 0
    case pageEdit
    case info
    case save
    case share
    case addFile
    case watermark
    case security
    case flattened
}

public protocol CPDFPopMenuViewDelegate: AnyObject {
    func menuDidClick(at view: CPDFPopMenuView, clickType viewType: CPDFPopMenuViewType)
}

public class CPDFPopMenuView: UIView,UITableViewDelegate,UITableViewDataSource {
    public weak var delegate: CPDFPopMenuViewDelegate?
    
    private var menuItemTitleArr: [String] = []
    private var menuItemIconArr: [String] = []
    private var tableView: UITableView?
    var menuItemTypes: [NSNumber] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.menuItemTypes = [NSNumber(value: CPDFPopMenuViewType.setting.rawValue),
                              NSNumber(value: CPDFPopMenuViewType.pageEdit.rawValue),
                              NSNumber(value: CPDFPopMenuViewType.info.rawValue),
                              NSNumber(value: CPDFPopMenuViewType.save.rawValue),
                              NSNumber(value: CPDFPopMenuViewType.share.rawValue),
                              NSNumber(value: CPDFPopMenuViewType.addFile.rawValue)]
        
        setUp()
    }
    
    init(_ frame: CGRect, Configuration configuration: CPDFConfiguration) {
        super.init(frame: frame)
        
        for num in configuration.showMoreItems {
            self.menuItemTypes.append(NSNumber(value: num.rawValue))
        }
        
        for num in menuItemTypes {
            switch CPDFPopMenuViewType(rawValue: num.intValue) {
            case .setting:
                menuItemTitleArr.append(NSLocalizedString("View Setting", comment: ""))
                menuItemIconArr.append("CNavigationImageNamePreview")
            case .pageEdit:
                menuItemTitleArr.append(NSLocalizedString("Document Editor", comment: ""))
                menuItemIconArr.append("CNavigationImageNamePageEditTool")
            case .info:     
                menuItemTitleArr.append(NSLocalizedString("Document Info", comment: ""))
                menuItemIconArr.append("CNavigationImageNameInformation")
            case .save:
                menuItemTitleArr.append(NSLocalizedString("Save", comment: ""))
                menuItemIconArr.append("CNavigationImageNameSave")
            case .share:
                menuItemTitleArr.append(NSLocalizedString("Share", comment: ""))
                menuItemIconArr.append("CNavigationImageNameShare")
            case .addFile:
                menuItemTitleArr.append(NSLocalizedString("Open...", comment: ""))
                menuItemIconArr.append("CNavigationImageNameNewFile")
            case .watermark:
                menuItemTitleArr.append(NSLocalizedString("Watermark", comment: ""))
                menuItemIconArr.append("CNavigationImageNameWatermark")
            case .security:
                menuItemTitleArr.append(NSLocalizedString("Security", comment: ""))
                menuItemIconArr.append("CNavigationImageNameSecurity")
            case .flattened:
                menuItemTitleArr.append(NSLocalizedString("Save as Flattened PDF", comment: ""))
                menuItemIconArr.append("CNavigationImageNameFlattened")
            case .none:
                break
            }
        }
        
        tableView = UITableView()
        tableView?.layer.cornerRadius = 5.0
        tableView?.isScrollEnabled = false
        tableView?.separatorStyle = .none
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.autoresizingMask = .flexibleWidth
        if tableView != nil {
            addSubview(tableView!)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    private func setUp() {
        menuItemTitleArr = [
            NSLocalizedString("View Setting", comment: ""),
            NSLocalizedString("Document Editor", comment: ""),
            NSLocalizedString("Document Info", comment: ""),
            NSLocalizedString("Save", comment: ""),
            NSLocalizedString("Share", comment: ""),
            NSLocalizedString("Open...", comment: "")
        ]
        
        menuItemIconArr = [
            "CNavigationImageNamePreview",
            "CNavigationImageNamePageEditTool",
            "CNavigationImageNameInformation",
            "CNavigationImageNameSave",
            "CNavigationImageNameShare",
            "CNavigationImageNameNewFile"
        ]
        
        tableView = UITableView()
        tableView?.layer.cornerRadius = 5.0
        tableView?.isScrollEnabled = false
        tableView?.separatorStyle = .none
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.autoresizingMask = .flexibleWidth
        if tableView != nil {
            addSubview(tableView!)
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        tableView?.frame = bounds
        tableView?.reloadData()
    }
    
    // MARK: - tableview delegate & datasource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItemTitleArr.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "CPDFPopMenuItem"
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? CPDFPopMenuItem {
            cell.selectionStyle = .none
            cell.titleLabel?.text = menuItemTitleArr[indexPath.row]
            cell.iconImage?.image = UIImage(named: menuItemIconArr[indexPath.row], in: Bundle(for: type(of: self)), compatibleWith: nil)

            if indexPath.row == (menuItemTypes.count - 1) {
                cell.hiddenLineView(true)
            } else {
                cell.hiddenLineView(false)
            }

            return cell
        } else {
            let cell = CPDFPopMenuItem.init(style: .default, reuseIdentifier: reuseIdentifier)
            cell.selectionStyle = .none
            cell.titleLabel?.text = menuItemTitleArr[indexPath.row]
            cell.iconImage?.image = UIImage(named: menuItemIconArr[indexPath.row], in: Bundle(for: type(of: self)), compatibleWith: nil)
            
            if indexPath.row == (menuItemTypes.count - 1) {
                cell.hiddenLineView(true)
            } else {
                cell.hiddenLineView(false)
            }
            
            return cell
        }

        
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let num = self.menuItemTypes[indexPath.row]
        delegate?.menuDidClick(at: self, clickType: CPDFPopMenuViewType(rawValue: num.intValue) ?? .setting)
    }

}


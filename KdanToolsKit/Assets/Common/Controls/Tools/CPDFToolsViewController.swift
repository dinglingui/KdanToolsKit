//
//  CPDFToolsViewController.swift
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

public enum CPDFToolFunctionTypeState: Int {
    case viewer = 0
    case edit
    case annotation
    case form
    case pageEdit
    case signature
}

public protocol CPDFToolsViewControllerDelegate: AnyObject {
    func CPDFToolsViewControllerDismiss(_ viewController: CPDFToolsViewController, selectItemAtIndex selectIndex: CPDFToolFunctionTypeState)
}

public class CPDFToolsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    public weak var delegate: CPDFToolsViewControllerDelegate?
    
    var backBtn: UIButton?
    
    var titleLabel: UILabel?
    
    var tableView: UITableView?
    
    var iconArr: [String]?
    
    var titleArr: [String]?
    
    var toolsTypes: [NSNumber]?
    
    var splitView: UIView?
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        titleArr = [NSLocalizedString("Viewer", comment: ""),
                    NSLocalizedString("Content Editor", comment: "")]
        iconArr = ["CNavigationImageNameViewer",
                   "CNavigationImageNameEditTool"]
        self.toolsTypes = [NSNumber(value: CPDFToolFunctionTypeState.viewer.rawValue),
                                      NSNumber(value: CPDFToolFunctionTypeState.edit.rawValue),
                                      NSNumber(value: CPDFToolFunctionTypeState.annotation.rawValue),
                                      NSNumber(value: CPDFToolFunctionTypeState.form.rawValue)]
    }

    public init(customizeWithToolArrays toolsTypes: [NSNumber]) {
        super.init(nibName: nil, bundle: nil)
        titleArr = []
        iconArr = []
        self.toolsTypes = toolsTypes

        for num in toolsTypes {
            switch CPDFToolFunctionTypeState(rawValue: num.intValue) {
            case .viewer:
                titleArr?.append(NSLocalizedString("Viewer", comment: ""))
                iconArr?.append("CNavigationImageNameViewer")
            case .edit:
                titleArr?.append(NSLocalizedString("Content Editor", comment: ""))
                iconArr?.append("CNavigationImageNameEditTool")
            case .annotation:
                titleArr?.append(NSLocalizedString("Annotation", comment: ""))
                iconArr?.append("CNavigationImageNameAnnotationTool")
            case .form:
                titleArr?.append(NSLocalizedString("Form", comment: ""))
                iconArr?.append("CPDFForm")
            case .signature:
                titleArr?.append(NSLocalizedString("Signatures", comment: ""))
                iconArr?.append("CNavigationImageNameDigitalTool")
            default:
                break
            }
        }
    }
    
    public init(Configuration configuration: CPDFConfiguration) {
        super.init(nibName: nil, bundle: nil)
        titleArr = []
        iconArr = []
        toolsTypes = []
        
        for state in configuration.availableViewModes {
            switch state {
            case .viewer:
                titleArr?.append(NSLocalizedString("Viewer", comment: ""))
                iconArr?.append("CNavigationImageNameViewer")
                toolsTypes?.append(NSNumber(value: state.rawValue))
            case .edit:
                titleArr?.append(NSLocalizedString("Content Editor", comment: ""))
                iconArr?.append("CNavigationImageNameEditTool")
                toolsTypes?.append(NSNumber(value: state.rawValue))
            case .annotation:
                titleArr?.append(NSLocalizedString("Annotation", comment: ""))
                iconArr?.append("CNavigationImageNameAnnotationTool")
                toolsTypes?.append(NSNumber(value: state.rawValue))
            case .form:
                titleArr?.append(NSLocalizedString("Form", comment: ""))
                iconArr?.append("CPDFForm")
                toolsTypes?.append(NSNumber(value: state.rawValue))
            case .signature:
                titleArr?.append(NSLocalizedString("Signatures", comment: ""))
                iconArr?.append("CNavigationImageNameDigitalTool")
                toolsTypes?.append(NSNumber(value: state.rawValue))
            default:
                break
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updatePreferredContentSize(with: self.traitCollection)
        
        backBtn = UIButton()
        backBtn?.autoresizingMask = .flexibleLeftMargin
        backBtn?.setImage(UIImage(named: "CPDFAnnotationBaseImageBack", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        backBtn?.addTarget(self, action: #selector(buttonItemClicked_back(_:)), for: .touchUpInside)
        if backBtn != nil {
            view.addSubview(backBtn!)
        }

        titleLabel = UILabel()
        titleLabel?.text = NSLocalizedString("Tools", comment: "")
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.textAlignment = .center
        if titleLabel != nil {
            view.addSubview(titleLabel!)
        }
        
        tableView = UITableView(frame: view.bounds)
        tableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorStyle = .none
        tableView?.backgroundColor = UIColor.white
        view.backgroundColor = UIColor.white

        if tableView != nil {
            view.addSubview(tableView!)
        }
        tableView?.reloadData()

        splitView = UIView()
        splitView?.backgroundColor = CPDFColorUtils.CTableviewCellSplitColor()
        if splitView != nil {
            view.addSubview(splitView!)
        }

        view.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
        tableView?.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
    }
    
    public override func viewWillLayoutSubviews() {
        titleLabel?.frame = CGRect(x: (view.frame.size.width - 120)/2, y: 5, width: 120, height: 50)
        backBtn?.frame = CGRect(x: view.frame.size.width - 60, y: 5, width: 50, height: 50)
        tableView?.frame = CGRect(x: 0, y: 60, width: view.frame.size.width, height: view.frame.size.height - 50)
        splitView?.frame = CGRect(x: 0, y: titleLabel?.frame.maxY ?? 0, width: view.frame.size.width, height: 1)
    }

    public override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSize(with: newCollection)
    }
    
    func updatePreferredContentSize(with traitCollection: UITraitCollection) {
        let hight = 80 + 45 * (iconArr?.count ?? 0)
        preferredContentSize = CGSize(width: view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? CGFloat(hight) : CGFloat(hight))
    }

    // MARK: - UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.iconArr?.count ?? 0
    }
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CPDFDisplayTableViewCell ?? CPDFDisplayTableViewCell(style: .default, reuseIdentifier: "cell")
        cell.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
        cell.titleLabel?.text = titleArr?[indexPath.row]
        cell.iconImageView?.image = UIImage(named: (iconArr?[indexPath.row] ?? "") as String, in: Bundle(for: self.classForCoder), compatibleWith: nil)
        cell.hiddenSplitView = (indexPath.row == (iconArr?.count ?? 0) - 1)
        
        return cell
        
    }
    
    // MARK: - UITableViewDelegate
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true, completion: nil)
        let num = self.toolsTypes?[indexPath.row]
        self.delegate?.CPDFToolsViewControllerDismiss(self, selectItemAtIndex: CPDFToolFunctionTypeState(rawValue: num?.intValue ?? 0) ?? .viewer)
        
    }
    
    // MARK: - Action
    @objc func buttonItemClicked_back(_ sender: UIMenuController) {
        dismiss(animated: true, completion: nil)
    }
    
}

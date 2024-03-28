//
//  CReasonPropertiesViewController.swift
//  PDFViewer-Swift
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import UIKit

@objc protocol CReasonPropertiesViewControllerDelegate: AnyObject {
    @objc optional func reasonPropertiesViewController(_ reasonPropertiesViewController: CReasonPropertiesViewController, properties: String, isReason: Bool)
}

class CReasonPropertiesViewController: UIViewController, CHeaderViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: CReasonPropertiesViewControllerDelegate?
    var resonProperties: String = ""
    var isReason: Bool = false
    
    private var headerView: CHeaderView?
    private var selectLabel: UILabel?
    private var selectSwitch: UISwitch?
    private var splitView: UIView?
    private var tableView: UITableView?
    private var resonSelectStr: String = ""
    
    // MARK: - Accessors
    
    var dataArray: [String] = {
        return [
            NSLocalizedString("I am the owner of the document", comment: ""),
            NSLocalizedString("I am approving the document", comment: ""),
            NSLocalizedString("I have reviewed this document", comment: ""),
            NSLocalizedString("None", comment: "")
        ]
    }()
    
    // MARK: - Viewcontroller Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView = CHeaderView()
        headerView?.titleLabel?.text = NSLocalizedString("Reason", comment: "")
        headerView?.cancelBtn?.isHidden = true
        headerView?.delegate = self
        headerView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        headerView?.layer.borderWidth = 1.0
        headerView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if headerView != nil {
            view.addSubview(headerView!)
        }
        
        selectLabel = UILabel()
        selectLabel?.text = NSLocalizedString("Reasons", comment: "")
        selectLabel?.textColor = .gray
        selectLabel?.font = .systemFont(ofSize: 13)
        if selectLabel != nil {
            view.addSubview(selectLabel!)
        }
        
        selectSwitch = UISwitch()
        selectSwitch?.addTarget(self, action: #selector(selectChange_switch(_:)), for: .valueChanged)
        if selectSwitch != nil {
            view.addSubview(selectSwitch!)
        }
        
        splitView = UIView()
        splitView?.backgroundColor = CPDFColorUtils.CMessageLabelColor()
        if splitView != nil {
            view.addSubview(splitView!)
        }
        
        tableView = UITableView(frame: CGRect(x: 0, y: 130, width: self.view.frame.size.width, height: self.view.frame.size.height - 200), style: .plain)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 44.0
        tableView?.register(CReasonPropertiesCell.self, forCellReuseIdentifier: "reasonPropertiesCell")
        tableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView?.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
        if tableView != nil {
            view.addSubview(tableView!)
        }
        
        view.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        updatePreferredContentSizeWithTraitCollection(traitCollection)
        
        if isReason {
            selectSwitch?.isOn = true
            splitView?.isHidden = false
            tableView?.isHidden = false
        } else {
            splitView?.isHidden = true
            tableView?.isHidden = true
        }
        
        setPageSizeRefresh()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        headerView?.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50)
        selectLabel?.frame = CGRect(x: 25, y: 50, width: 100, height: 50)
        selectSwitch?.frame = CGRect(x: view.frame.size.width - 75, y: 55, width: 50, height: 50)
        splitView?.frame = CGRect(x: 0, y: 100, width: view.frame.size.width, height: 30)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSizeWithTraitCollection(newCollection)
    }
    
    // MARK: - Private Methods
    
    private func updatePreferredContentSizeWithTraitCollection(_ traitCollection: UITraitCollection) {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let mWidth = min(width, height)
        let mHeight = max(width, height)
        
        let currentDevice = UIDevice.current
        if currentDevice.userInterfaceIdiom == .pad {
            // This is an iPad
            preferredContentSize = CGSize(width: view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? mWidth * 0.8 : mHeight * 0.8)
        } else {
            // This is an iPhone or iPod touch
            preferredContentSize = CGSize(width: view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? mWidth * 0.9 : mHeight * 0.9)
        }
    }
    
    private func setPageSizeRefresh() {
        let sizeArray = [
            NSLocalizedString("I am the owner of the document", comment: ""),
            NSLocalizedString("I am approving the document", comment: ""),
            NSLocalizedString("I have reviewed this document", comment: ""),
            NSLocalizedString("None", comment: "")
        ]

        if let index = sizeArray.firstIndex(of: self.resonProperties) {
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView?.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
        }
    }
    
    // MARK: - Action
    
    @objc func selectChange_switch(_ sender: UISwitch) {
        if sender.isOn {
            splitView?.isHidden = false
            tableView?.isHidden = false
        } else {
            splitView?.isHidden = true
            tableView?.isHidden = true
        }
    }
    
    // MARK: - CHeaderViewDelegate
    
    func CHeaderViewBack(_ headerView: CHeaderView) {
        dismiss(animated: true)
        delegate?.reasonPropertiesViewController?(self, properties: resonSelectStr, isReason: selectSwitch?.isOn ?? false)
    }
    
    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reasonPropertiesCell", for: indexPath) as! CReasonPropertiesCell

        if (0...3).contains(indexPath.row) {
            cell.setCellLabel(self.dataArray[indexPath.row])
        }

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CReasonPropertiesCell
        self.resonSelectStr = cell.resonSelectLabel?.text ?? ""
    }
}

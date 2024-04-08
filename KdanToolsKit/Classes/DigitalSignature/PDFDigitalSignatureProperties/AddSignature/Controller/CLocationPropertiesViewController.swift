//
//  CLocationPropertiesViewController.swift
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

@objc protocol CLocationPropertiesViewControllerDelegate: AnyObject {
    @objc optional func locationPropertiesViewController(_ locationPropertiesViewController: CLocationPropertiesViewController, properties: String, isLocation: Bool)
}

class CLocationPropertiesViewController: UIViewController,CHeaderViewDelegate,CInputTextFieldDelegate {
    
    weak var delegate: CLocationPropertiesViewControllerDelegate?
    var locationProperties: String?
    var isLocation: Bool = false
    
    private var headerView: CHeaderView?
    private var selectLabel: UILabel?
    private var selectSwitch: UISwitch?
    private var splitView: UIView?
    private var locationTextField: CInputTextField?
    
    // MARK: - Viewcontroller Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Your Swift code for setting up the view and UI elements goes here
        headerView = CHeaderView()
        headerView?.titleLabel?.text = NSLocalizedString("Location", comment: "")
        headerView?.cancelBtn?.isHidden = true
        headerView?.delegate = self
        headerView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        headerView?.layer.borderWidth = 1.0
        headerView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if headerView != nil {
            view.addSubview(headerView!)
        }
        
        selectLabel = UILabel()
        selectLabel?.text = NSLocalizedString("Location", comment: "")
        selectLabel?.textColor = UIColor.gray
        selectLabel?.font = UIFont.systemFont(ofSize: 13)
        if selectLabel != nil {
            view.addSubview(selectLabel!)
        }
        
        selectSwitch = UISwitch()
        selectSwitch?.addTarget(self, action: #selector(selectChange_switch(_:)), for: .valueChanged)
        if selectLabel != nil {
            view.addSubview(selectSwitch!)
        }
        
        splitView = UIView()
        splitView?.backgroundColor = CPDFColorUtils.CMessageLabelColor()
        if splitView != nil {
            view.addSubview(splitView!)
        }
        
        locationTextField = CInputTextField()
        locationTextField?.delegate = self
        locationTextField?.titleLabel?.text = NSLocalizedString("Location", comment: "")
        if locationProperties == NSLocalizedString("Closes", comment: "") {
            locationTextField?.inputTextField?.text = ""
        } else {
            locationTextField?.inputTextField?.text = locationProperties ?? ""
        }
        if locationTextField != nil {
            view.addSubview(locationTextField!)
        }
        
        view.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        updatePreferredContentSizeWithTraitCollection(traitCollection)
        
        if isLocation {
            selectSwitch?.setOn(true, animated: false)
            splitView?.isHidden = false
            locationTextField?.isHidden = false
        } else {
            splitView?.isHidden = true
            locationTextField?.isHidden = true
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        headerView?.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50)
        selectLabel?.frame = CGRect(x: 25, y: 50, width: 100, height: 50)
        selectSwitch?.frame = CGRect(x: view.frame.size.width - 75, y: 55, width: 50, height: 50)
        splitView?.frame = CGRect(x: 0, y: 100, width: view.frame.size.width, height: 30)
        locationTextField?.frame = CGRect(x: 25, y: splitView?.frame.maxY ?? 0, width: view.frame.size.width - 50, height: 90)
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
    
    // Rest of your Swift code for the view controller
    
    // MARK: - Action
    
    @objc func selectChange_switch(_ sender: UISwitch) {
        if sender.isOn {
            splitView?.isHidden = false
            locationTextField?.isHidden = false
        } else {
            splitView?.isHidden = true
            locationTextField?.isHidden = true
        }
    }
    
    // MARK: - CHeaderViewDelegate
    
    func CHeaderViewBack(_ headerView: CHeaderView) {
        dismiss(animated: true)
        delegate?.locationPropertiesViewController?(self, properties: locationTextField?.inputTextField?.text ?? "", isLocation: selectSwitch?.isOn ?? false)
    }
    
}

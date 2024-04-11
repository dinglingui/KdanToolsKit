//
//  CPDFPageInsertViewController.swift
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

enum CPDFPageInsertType: Int {
    case none
    case before
    case after
}

@objc protocol CPDFPageInsertViewControllerDelegate: AnyObject {
    @objc optional func pageInsertViewControllerSave(_ pageInsertViewController: CPDFPageInsertViewController, pageModel: CBlankPageModel)
    @objc optional func pageInsertViewControllerCancel(_ pageInsertViewController: CPDFPageInsertViewController)
}

class CPDFPageInsertViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CInsertBlankPageCellDelegate {
    weak var delegate: CPDFPageInsertViewControllerDelegate?
    var currentPageIndex: Int = 0
    var currentPageCout: Int = 0
    
    private var cancelBtn: UIButton?
    private var saveButton: UIButton?
    private var headerView: UIView?
    private var titleLabel: UILabel?
    private var tableView: UITableView?
    private var isSelect: Bool = false
    private var pageLoactionBtns: [UIButton] = []
    private var pageModel: CBlankPageModel?
    private var locationTextField: UITextField?
    private var preCell: CInsertBlankPageCell?
    private var pageInsertType: CPDFPageInsertType = .none
    private var pageType: String?
    private var isVertical: Bool = true
    
    // MARK: - Accessors
    
    private lazy var dataArray: [String]  = {
        return [
            NSLocalizedString("Page Size", comment: ""),
            NSLocalizedString("Page Direction", comment: ""),
            NSLocalizedString("Insert To", comment: ""),
            NSLocalizedString("First Page", comment: ""),
            NSLocalizedString("Last Page", comment: ""),
            NSLocalizedString("Insert Before Specifiled Page", comment: ""),
            NSLocalizedString("Please Enter a Page", comment: ""),
            NSLocalizedString("Insert After Specifiled Page", comment: "")
        ]
    } ()
    
    // MARK: - ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        headerView = UIView()
        headerView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        headerView?.layer.borderWidth = 1.0
        headerView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if(headerView != nil) {
            view.addSubview(headerView!)
        }
        titleLabel = UILabel()
        titleLabel?.autoresizingMask = .flexibleRightMargin
        titleLabel?.text = NSLocalizedString("Insert a Blank Page", comment: "")
        titleLabel?.textAlignment = .center
        titleLabel?.font = UIFont.systemFont(ofSize: 20)
        titleLabel?.adjustsFontSizeToFitWidth = true
        if(titleLabel != nil) {
            headerView?.addSubview(titleLabel!)
        }
        
        saveButton = UIButton()
        saveButton?.autoresizingMask = .flexibleRightMargin
        saveButton?.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        saveButton?.setTitleColor(UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0), for: .normal)
        saveButton?.addTarget(self, action: #selector(buttonItemClicked_save(_:)), for: .touchUpInside)
        if(saveButton != nil) {
            headerView?.addSubview(saveButton!)
        }
        
        cancelBtn = UIButton()
        cancelBtn?.autoresizingMask = .flexibleLeftMargin
        cancelBtn?.titleLabel?.adjustsFontSizeToFitWidth = true
        cancelBtn?.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        cancelBtn?.setTitleColor(UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0), for: .normal)
        cancelBtn?.addTarget(self, action: #selector(buttonItemClicked_cancel(_:)), for: .touchUpInside)
        if(cancelBtn != nil) {
            headerView?.addSubview(cancelBtn!)
        }
        
        tableView = UITableView(frame: CGRect(x: 0, y: 50, width: view.frame.size.width, height: view.frame.size.height-100), style: .plain)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 44.0
        tableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView?.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
        if(tableView != nil) {
            view.addSubview(tableView!)
        }
        isSelect = false
        view.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        pageModel = CBlankPageModel()
        pageModel?.pageIndex = 0
        pageModel?.size = CGSize(width: 210, height: 297)
        pageModel?.rotation = 0
        pageLoactionBtns = []
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        pageType = "A4 (210 X 297mm)"
        updatePreferredContentSize(with: traitCollection)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        headerView?.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50)
        titleLabel?.frame = CGRect(x: (view.frame.size.width - 200)/2, y: 0, width: 200, height: 50)
        if #available(iOS 11.0, *) {
            saveButton?.frame = CGRect(x: view.frame.size.width - 60 - view.safeAreaInsets.right, y: 5, width: 50, height: 40)
            cancelBtn?.frame = CGRect(x: view.safeAreaInsets.left + 20, y: 5, width: 50, height: 40)
        } else {
            saveButton?.frame = CGRect(x: view.frame.size.width - 60, y: 5, width: 50, height: 40)
            cancelBtn?.frame = CGRect(x: 20, y: 5, width: 50, height: 40)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        tableView?.reloadData()
        setPageSizeRefresh()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSize(with: newCollection)
    }
    
    // MARK: - Private Methods
    
    func popoverWarning() {
        let OKAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) {
            action in
            // Handle OK action
        }
        let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("The page range is invalid or out of range. Please enter the valid page.", comment: ""), preferredStyle: .alert)
        alert.addAction(OKAction)
        present(alert, animated: true, completion: nil)
    }
    
    func setPageSizeRefresh() {
        let sizeArray = ["A3 (297 X 420mm)", "A4 (210 X 297mm)", "A5 (148 X 210mm)"]
        if isSelect {
            if let index = sizeArray.firstIndex(of: pageType ?? "A4 (210 X 297mm)") {
                switch index {
                case 0:
                    let path = IndexPath(row: 1, section: 0)
                    tableView?.selectRow(at: path, animated: false, scrollPosition: .middle)
                case 1:
                    let path = IndexPath(row: 2, section: 0)
                    tableView?.selectRow(at: path, animated: false, scrollPosition: .middle)
                case 2:
                    let path = IndexPath(row: 3, section: 0)
                    tableView?.selectRow(at: path, animated: false, scrollPosition: .middle)
                default:
                    break
                }
            }
        }
    }
    
    func updatePreferredContentSize(with traitCollection: UITraitCollection) {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let mWidth = min(width, height)
        let mHeight = max(width, height)
        
        let currentDevice = UIDevice.current
        if currentDevice.userInterfaceIdiom == .pad {
            // This is an iPad
            preferredContentSize = CGSize(width: view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? mWidth * 0.7 : mHeight * 0.7)
        } else {
            // This is an iPhone or iPod touch
            preferredContentSize = CGSize(width: view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? mWidth * 0.9 : mHeight * 0.9)
        }
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_save(_ button: UIButton) {
        self.dismiss(animated: true)
        if(pageModel != nil) {
            delegate?.pageInsertViewControllerSave?(self, pageModel: pageModel!)
        }
    }
    
    @objc func buttonItemClicked_cancel(_ button: UIButton) {
        self.dismiss(animated: true)
        delegate?.pageInsertViewControllerCancel?(self)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CInsertBlankPageCell(style: .subtitle, reuseIdentifier: "pageCell")
        cell.delegate = self
        
        if pageLoactionBtns.count > 3 {
            pageLoactionBtns.removeAll()
        }
       
        
        switch indexPath.row {
        case 0:
            cell.setCellStyle(.CInsertBlankPageCellSize, label: self.dataArray[indexPath.row])
            cell.setButtonSelectedStatus(buttonSelectedStatus: self.isSelect)
        case 1:
            if self.isSelect {
                cell.setCellStyle(.CInsertBlankPageCellSizeSelect, label: self.dataArray[indexPath.row])
                cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.size.width, bottom: 0, right: 0)
            } else {
                cell.setCellStyle(.CInsertBlankPageCellDirection, label: self.dataArray[indexPath.row])
                cell.setVertical(status: isVertical)
            }
        case 2:
            if self.isSelect {
                cell.setCellStyle(.CInsertBlankPageCellSizeSelect, label: self.dataArray[indexPath.row])
                cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.size.width, bottom: 0, right: 0)
            } else {
                cell.setCellStyle(.CInsertBlankPageCellLocation, label: self.dataArray[indexPath.row])
            }
        case 3:
            if self.isSelect {
                cell.setCellStyle(.CInsertBlankPageCellSizeSelect, label: self.dataArray[indexPath.row])
            } else {
                cell.setCellStyle(.CInsertBlankPageCellLocationSelect, label: self.dataArray[indexPath.row])
                let locationSelectBtn = cell.locationSelectBtn
                if(locationSelectBtn != nil) {
                    if (self.currentPageIndex == 0) {
                        self.preCell = cell
                        if(locationSelectBtn != nil) {
                            locationSelectBtn!.isSelected = !locationSelectBtn!.isSelected
                        }
                        cell.locationSelectLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
                    }
                    
                    if !self.pageLoactionBtns.contains(locationSelectBtn!) {
                        self.pageLoactionBtns.append(locationSelectBtn!)
                    }
                }
                cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.size.width, bottom: 0, right: 0)
            }
            
        case 4:
            if self.isSelect {
                cell.setCellStyle(.CInsertBlankPageCellDirection, label: self.dataArray[indexPath.row])
                cell.setVertical(status: isVertical)
            } else {
                cell.setCellStyle(.CInsertBlankPageCellLocationSelect, label: self.dataArray[indexPath.row])
                let locationSelectBtn = cell.locationSelectBtn
                if(locationSelectBtn != nil) {
                    if !self.pageLoactionBtns.contains(locationSelectBtn!) {
                        self.pageLoactionBtns.append(locationSelectBtn!)
                    }
                }
                cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.size.width, bottom: 0, right: 0)
            }
        case 5:
            if self.isSelect {
                cell.setCellStyle(.CInsertBlankPageCellLocation, label: self.dataArray[indexPath.row])
            } else {
                cell.setCellStyle(.CInsertBlankPageCellLocationSelect, label: self.dataArray[indexPath.row])
                let locationSelectBtn = cell.locationSelectBtn
                if(locationSelectBtn != nil) {
                    if !self.pageLoactionBtns.contains(locationSelectBtn!) {
                        self.pageLoactionBtns.append(locationSelectBtn!)
                    }
                }
                if (self.currentPageIndex != 0) {
                    self.preCell = cell
                    locationSelectBtn?.isSelected = !locationSelectBtn!.isSelected
                    cell.locationSelectLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
                }
                cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.size.width, bottom: 0, right: 0)
            }
        case 6:
            if self.isSelect {
                cell.setCellStyle(.CInsertBlankPageCellLocationSelect, label: self.dataArray[indexPath.row])
                let locationSelectBtn = cell.locationSelectBtn
                if(locationSelectBtn != nil) {
                    
                    if (self.currentPageIndex == 0) {
                        self.preCell = cell
                        if !self.pageLoactionBtns.contains(locationSelectBtn!) {
                            locationSelectBtn?.isSelected = !locationSelectBtn!.isSelected
                        }
                        cell.locationSelectLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
                    }
                    if !self.pageLoactionBtns.contains(locationSelectBtn!) {
                        self.pageLoactionBtns.append(locationSelectBtn!)
                    }
                }
                cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.size.width, bottom: 0, right: 0)
            } else {
                cell.setCellStyle(.CInsertBlankPageCellLocationTextFiled, label: self.dataArray[indexPath.row])
                if (self.currentPageIndex != 0) {
                    cell.locationTextField?.text = "\(self.currentPageIndex)"
                    self.pageModel?.pageIndex = self.currentPageIndex-1
                }
                self.locationTextField = cell.locationTextField
                cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.size.width, bottom: 0, right: 0)
            }
            
        case 7:
            cell.setCellStyle(.CInsertBlankPageCellLocationSelect, label: self.dataArray[indexPath.row])
            let locationSelectBtn = cell.locationSelectBtn
            if(locationSelectBtn != nil) {
                if !self.pageLoactionBtns.contains(locationSelectBtn!) {
                    self.pageLoactionBtns.append(locationSelectBtn!)
                }
            }
            cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.size.width, bottom: 0, right: 0)
        case 8:
            cell.setCellStyle(.CInsertBlankPageCellLocationSelect, label: self.dataArray[indexPath.row])
            let locationSelectBtn = cell.locationSelectBtn
            if(locationSelectBtn != nil) {
                if !self.pageLoactionBtns.contains(locationSelectBtn!) {
                    self.pageLoactionBtns.append(locationSelectBtn!)
                }
            }
            if (self.currentPageIndex != 0) {
                self.preCell = cell
                if(locationSelectBtn != nil) {
                    locationSelectBtn?.isSelected = !locationSelectBtn!.isSelected
                }
                cell.locationSelectLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
            }
            cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.size.width, bottom: 0, right: 0)
        case 9:
            cell.setCellStyle(.CInsertBlankPageCellLocationTextFiled, label: self.dataArray[indexPath.row])
            if (self.currentPageIndex != 0) {
                cell.locationTextField?.text = "\(self.currentPageIndex)"
                self.pageModel?.pageIndex = self.currentPageIndex-1
            }
            self.locationTextField = cell.locationTextField
            cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.size.width, bottom: 0, right: 0)
        case 10:
            cell.setCellStyle(.CInsertBlankPageCellLocationSelect, label: self.dataArray[indexPath.row])
            let locationSelectBtn = cell.locationSelectBtn
            if(locationSelectBtn != nil) {
                if !self.pageLoactionBtns.contains(locationSelectBtn!) {
                    self.pageLoactionBtns.append(locationSelectBtn!)
                }
            }
            cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.size.width, bottom: 0, right: 0)
        default:
            break
        }
        
        cell.delegate = self
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let path = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: path) as? CInsertBlankPageCell
        switch indexPath.row {
        case 1:
            if self.isSelect {
                self.pageModel?.size = CGSize(width: 297, height: 420)
                cell?.sizeLabel.text = "A3 (297 X 420mm)"
                self.pageType = "A3 (297 X 420mm)"
            }
        case 2:
            if self.isSelect {
                self.pageModel?.size = CGSize(width: 210, height: 297)
                cell?.sizeLabel.text = "A4 (210 X 297mm)"
                self.pageType = "A4 (210 X 297mm)"
            }
        case 3:
            if self.isSelect {
                self.pageModel?.size = CGSize(width: 148, height: 210)
                cell?.sizeLabel.text = "A5 (148 X 210mm)"
                self.pageType = "A5 (148 X 210mm)"
            }
        default:
            break
        }
    }
    
    // MARK: - CInsertBlankPageCellDelegate
    
    func insertBlankPageCell(_ insertBlankPageCell: CInsertBlankPageCell, isSelect: Bool) {
        let szieArray = ["A3 (297 X 420mm)", "A4 (210 X 297mm)", "A5 (148 X 210mm)"]
        let indexPath = self.tableView?.indexPath(for: insertBlankPageCell)
        self.isSelect = !self.isSelect;
        
        if self.isSelect {
            var t = indexPath?.row ?? 0
            var data = Array(self.dataArray)
            for str in szieArray {
                t += 1
                if !self.dataArray.contains(str) {
                    data.insert(str, at: t)
                }
            }
            self.dataArray = data
            
            self.tableView?.reloadData()
            self.setPageSizeRefresh()
        } else {
            var t = indexPath?.row ?? 0
            var data = Array(self.dataArray)
            for i in 0..<szieArray.count {
                t += 1
                let str = szieArray[i]
                if data.contains(str) {
                    data.remove(at: data.firstIndex(of: str) ?? 0)
                }
            }
            self.dataArray = data
            
            self.tableView?.reloadData()
        }
        
        let path = IndexPath(row: 0, section: 0)
        let cell = self.tableView?.cellForRow(at: path) as? CInsertBlankPageCell
        cell?.sizeLabel.text = self.pageType
        
    }
    
    func insertBlankPageCellLocation(_ insertBlankPageCell: CInsertBlankPageCell, button: UIButton) {
        if let preCell = self.preCell {
            let locationSelectBtn = preCell.locationSelectBtn
            let locationSelectLabel = preCell.locationSelectLabel

            if(locationSelectBtn != nil) {
                locationSelectBtn!.isSelected = !locationSelectBtn!.isSelected
            }
            if(locationSelectLabel != nil) {
                locationSelectLabel!.textColor = UIColor.gray
            }
            if preCell.locationSelectBtn != button {
                button.isSelected = !button.isSelected
                insertBlankPageCell.locationSelectLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
                self.preCell = insertBlankPageCell
            } else {
                preCell.locationSelectLabel?.textColor = UIColor.gray
                self.preCell = nil
            }
        } else {
            self.preCell = insertBlankPageCell
            button.isSelected = !button.isSelected
            insertBlankPageCell.locationSelectLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
        }
        
        if let location = self.pageLoactionBtns.firstIndex(of: button) {
            switch location {
            case 0:
                self.pageInsertType = .none
                self.pageModel?.pageIndex = 0
                self.saveButton?.isUserInteractionEnabled = true
                self.saveButton?.setTitleColor(UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0), for: .normal)
            case 1:
                self.pageInsertType = .none
                self.pageModel?.pageIndex = -2
                self.saveButton?.isUserInteractionEnabled = true
                self.saveButton?.setTitleColor(UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0), for: .normal)
            case 2:
                self.pageInsertType = .before
                self.pageModel?.pageIndex = (Int(self.locationTextField?.text  ?? "") ?? 0) - 1
                if self.locationTextField?.text?.isEmpty ?? true {
                    self.saveButton?.isUserInteractionEnabled = false
                    self.saveButton?.setTitleColor(UIColor.gray, for: .normal)
                } else {
                    self.saveButton?.isUserInteractionEnabled = true
                    self.saveButton?.setTitleColor(UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0), for: .normal)
                }
            case 3:
                self.pageInsertType = .after
                self.pageModel?.pageIndex = Int(self.locationTextField?.text ?? "") ?? 0
                if self.locationTextField?.text?.isEmpty ?? true {
                    self.saveButton?.isUserInteractionEnabled = false
                    self.saveButton?.setTitleColor(UIColor.gray, for: .normal)
                } else {
                    self.saveButton?.isUserInteractionEnabled = true
                    self.saveButton?.setTitleColor(UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0), for: .normal)
                }
            default:
                break
            }
        }
        
    }
    
    func insertBlankPageCell(_ insertBlankPageCell: CInsertBlankPageCell, pageIndex: Int) {
        if pageIndex != 0 {
            self.saveButton?.isUserInteractionEnabled = true
            self.saveButton?.setTitleColor(UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0), for: .normal)
        } else {
            self.saveButton?.isUserInteractionEnabled = false
            self.saveButton?.setTitleColor(UIColor.gray, for: .normal)
        }
        if pageIndex > self.currentPageCout {
            popoverWarning()
            self.pageModel?.pageIndex = 0
        } else {
            self.pageModel?.pageIndex = pageIndex-1
            if self.pageInsertType == .before {
                self.pageModel?.pageIndex -= 1
            } else if self.pageInsertType == .after {
                self.pageModel?.pageIndex += 1
            }
        }
        
    }
    
    
    func insertBlankPageCell(_ insertBlankPageCell: CInsertBlankPageCell, rotate: Int) {
        isVertical = !isVertical
        pageModel?.rotation = rotate
    }
    
    func insertBlankPageCellLocationTextFieldBegin(_ insertBlankPageCell: CInsertBlankPageCell) {
        for button in self.pageLoactionBtns {
            if let location = self.pageLoactionBtns.firstIndex(of: button) {
                switch location {
                case 0 ... 1:
                    if button.isSelected {
                        if(self.preCell?.locationSelectBtn != nil) {
                            self.preCell?.locationSelectBtn?.isSelected = !(self.preCell?.locationSelectBtn!.isSelected)!
                            self.preCell?.locationSelectLabel?.textColor = UIColor.gray
                        }
                    }
                case 2:
                    if !button.isSelected && !(self.pageLoactionBtns[3].isSelected) {
                        self.pageInsertType = .before
                        if self.isSelect {
                            if let cell = self.tableView?.cellForRow(at: IndexPath(row: 8, section: 0)) as? CInsertBlankPageCell {
                                cell.locationSelectBtn?.isSelected = !cell.locationSelectBtn!.isSelected
                                cell.locationSelectLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
                                self.preCell = cell
                            }
                        } else {
                            if let cell = self.tableView?.cellForRow(at: IndexPath(row: 5, section: 0)) as? CInsertBlankPageCell {
                                cell.locationSelectBtn?.isSelected = !cell.locationSelectBtn!.isSelected
                                cell.locationSelectLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
                                self.preCell = cell
                            }
                        }
                    }
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - NSNotification
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let frame = value.cgRectValue
                let rect = self.locationTextField?.convert(self.locationTextField?.frame ?? CGRect.zero, to: self.view)
                if (rect?.maxY ?? 0) > self.view.frame.size.height - frame.size.height {
                    var insets = self.tableView?.contentInset
                    insets?.bottom = frame.size.height + (self.locationTextField?.frame.size.height ?? 0)
                    self.tableView?.contentInset = insets ?? UIEdgeInsets.zero
                }
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        var insets = self.tableView?.contentInset
        insets?.bottom = 0
        self.tableView?.contentInset = insets ?? UIEdgeInsets.zero
    }
    
    
}



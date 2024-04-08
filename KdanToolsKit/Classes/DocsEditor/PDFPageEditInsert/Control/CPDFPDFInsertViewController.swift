//
//  CPDFPDFInsertViewController.swift
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

enum CPDFPDFInsertType : Int {
    case none
    case before
    case after
}

@objc protocol CPDFPDFInsertViewControllerDelegate {
    @objc optional func pdfInsertViewControllerSave(_ pageInsertViewController: CPDFPDFInsertViewController, document: CPDFDocument, pageModel: CBlankPageModel)
    @objc optional func pdfInsertViewControllerCancel(_ pageInsertViewController: CPDFPDFInsertViewController)
    
}

class CPDFPDFInsertViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate, CInsertBlankPageCellDelegate, CDocumentPasswordViewControllerDelegate {
    
    weak var delegate: CPDFPDFInsertViewControllerDelegate?
    
    var currentPageIndex: Int = 0
    
    var currentPageCout: Int = 0
    
    var document: CPDFDocument?
    
    private var cancelBtn: UIButton?
    private var saveButton: UIButton?
    private var headerView: UIView?
    private var titleLabel: UILabel?
    private var tableView: UITableView?
    private var isSelect: Bool = false
    private var selectRangeBtn: UIButton?
    private var rangePreCell: CInsertBlankPageCell?
    private var selectLocationBtn: UIButton?
    private var locationPreCell: CInsertBlankPageCell?
    private var pageLoactionBtns: [UIButton] = [UIButton]()
    private var pageRangeBtns: [UIButton] = [UIButton]()
    private var pageModel: CBlankPageModel?
    private var locationTextField: UITextField?
    private var rangeTextField: UITextField?
    private var pdfInsertType: CPDFPDFInsertType?
    
    private var rangSelctInitValue = 0
    
    // MARK: - Accessors
    
    private lazy var dataArray: [String]  = {
        return [
            NSLocalizedString("File Name", comment: ""),
            NSLocalizedString("Page Range", comment: ""),
            NSLocalizedString("All Pages", comment: ""),
            NSLocalizedString("Odd Pages Only", comment: ""),
            NSLocalizedString("Even Pages Only", comment: ""),
            NSLocalizedString("Custom Range", comment: ""),
            NSLocalizedString("e.g. 1,3-5,10", comment: ""),
            NSLocalizedString("Insert To", comment: ""),
            NSLocalizedString("First Page", comment: ""),
            NSLocalizedString("Last Page", comment: ""),
            NSLocalizedString("Insert Before Specifiled Page", comment: ""),
            NSLocalizedString("Please Enter a Page", comment: ""),
            NSLocalizedString("Insert After Specifiled Page", comment: "")
        ]
    } ()
    
    // MARK: - Initializers
    
    init(document: CPDFDocument) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard let document = document else {
            return
        }
        
        headerView = UIView()
        headerView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        headerView?.layer.borderWidth = 1.0
        headerView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if(headerView != nil) {
            view.addSubview(headerView!)
        }
        titleLabel = UILabel()
        titleLabel?.autoresizingMask = .flexibleRightMargin
        titleLabel?.text = NSLocalizedString("Insert From PDF", comment: "")
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
        tableView?.register(CInsertBlankPageCell.self, forCellReuseIdentifier: "pageCell")
        tableView?.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
        if(tableView != nil) {
            view.addSubview(tableView!)
        }
        isSelect = false
        view.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        pageModel = CBlankPageModel()
        pageModel?.pageIndex = 0
        pageModel?.rotation = 0
        var indexSet = IndexSet()
        for i in 0..<document.pageCount {
            indexSet.insert(IndexSet.Element(i))
        }
        pageModel?.indexSet = indexSet
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    func stringByTruncatingMiddle(with font: UIFont, maxLength: CGFloat) -> String {
        guard let filename = self.document?.documentURL.lastPathComponent else {
            return ""
        }
        if filename.size(withAttributes: [.font: font]).width <= maxLength {
            return filename
        }
        let halfLength = filename.count / 4
        let firstHalf = String(filename.prefix(halfLength))
        let secondHalf = String(filename.suffix(halfLength))
        let truncatedStr = "\(firstHalf)...\(secondHalf)"
        
        return truncatedStr
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
    
    func enterPDFAddFile() {
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                let documentTypes = ["com.adobe.pdf"]
                let documentPickerViewController = UIDocumentPickerViewController(documentTypes: documentTypes, in: .open)
                documentPickerViewController.delegate = self
                self.present(documentPickerViewController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_save(_ button: UIButton) {
        self.dismiss(animated: true)
        if(document != nil && pageModel != nil) {
            delegate?.pdfInsertViewControllerSave?(self, document: document!, pageModel: pageModel!)
        }
    }
    
    @objc func buttonItemClicked_cancel(_ button: UIButton) {
        self.dismiss(animated: true)
        delegate?.pdfInsertViewControllerCancel?(self)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = CInsertBlankPageCell(style: .subtitle, reuseIdentifier: "pageCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "pageCell", for: indexPath) as! CInsertBlankPageCell
        cell.delegate = self
        
        switch indexPath.row {
        case 0:
            cell.setCellStyle(.CInsertBlankPageCellSize, label: self.dataArray[indexPath.row])
            let maxLength: CGFloat = 200.0
            let font = UIFont.systemFont(ofSize: 18.0)
            cell.sizeLabel.text = stringByTruncatingMiddle(with: font, maxLength: maxLength)
        case 1:
            cell.setCellStyle(.CInsertBlankPageCellLocation, label: self.dataArray[indexPath.row])
        case 2:
            cell.setCellStyle(.CInsertBlankPageCellRangeSelect, label: self.dataArray[indexPath.row])
            if(cell.rangeSelectBtn != nil) {
                if !self.pageRangeBtns.contains(cell.rangeSelectBtn!) {
                    self.pageRangeBtns.append(cell.rangeSelectBtn!)
                }
                if rangSelctInitValue == 0 {
                    self.rangePreCell = cell
                    cell.rangeSelectBtn?.isSelected = !cell.rangeSelectBtn!.isSelected
                    cell.rangeSelectLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
                    rangSelctInitValue = 1;
                }
                
            }
            cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.size.width, bottom: 0, right: 0)
        case 3...5:
            cell.setCellStyle(.CInsertBlankPageCellRangeSelect, label: self.dataArray[indexPath.row])
            if(cell.rangeSelectBtn != nil) {
                if !self.pageRangeBtns.contains(cell.rangeSelectBtn!) {
                    self.pageRangeBtns.append(cell.rangeSelectBtn!)
                }
            }
            cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.size.width, bottom: 0, right: 0)
        case 6:
            cell.setCellStyle(.CInsertBlankPageCellRangeTextFiled, label: self.dataArray[indexPath.row])
        case 7:
            cell.setCellStyle(.CInsertBlankPageCellLocation, label: self.dataArray[indexPath.row])
        case 8:
            cell.setCellStyle(.CInsertBlankPageCellLocationSelect, label: self.dataArray[indexPath.row])
            if(cell.locationSelectBtn != nil) {
                if !self.pageLoactionBtns.contains(cell.locationSelectBtn!) {
                    self.pageLoactionBtns.append(cell.locationSelectBtn!)
                }
                if self.currentPageIndex == 0 {
                    self.locationPreCell = cell
                    cell.locationSelectBtn?.isSelected = !cell.locationSelectBtn!.isSelected
                    cell.locationSelectLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
                    
                    currentPageIndex = -2
                }
    
            }
            cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.size.width, bottom: 0, right: 0)
        case 9:
            cell.setCellStyle(.CInsertBlankPageCellLocationSelect, label: self.dataArray[indexPath.row])
            if(cell.locationSelectBtn != nil) {
                
                if !self.pageLoactionBtns.contains(cell.locationSelectBtn!) {
                    self.pageLoactionBtns.append(cell.locationSelectBtn!)
                }
            }
            cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.size.width, bottom: 0, right: 0)
        case 10:
            cell.setCellStyle(.CInsertBlankPageCellLocationSelect, label: self.dataArray[indexPath.row])
            if(cell.locationSelectBtn != nil) {
               
                if !self.pageLoactionBtns.contains(cell.locationSelectBtn!) {
                    self.pageLoactionBtns.append(cell.locationSelectBtn!)
                }
                if self.currentPageIndex > 0 {
                    self.locationPreCell = cell
                    cell.locationSelectBtn?.isSelected = !cell.locationSelectBtn!.isSelected
                    cell.locationSelectLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
                }
                
            }
            cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.size.width, bottom: 0, right: 0)
        case 11:
            cell.setCellStyle(.CInsertBlankPageCellLocationTextFiled, label: self.dataArray[indexPath.row])
            if self.currentPageIndex > 0 {
                cell.locationTextField?.text = "\(currentPageIndex)"
                self.pageModel?.pageIndex = currentPageIndex - 1
                
                currentPageIndex = -2
            }
            self.locationTextField = cell.locationTextField
            cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.size.width, bottom: 0, right: 0)
        case 12:
            cell.setCellStyle(.CInsertBlankPageCellLocationSelect, label: self.dataArray[indexPath.row])
            if(cell.locationSelectBtn != nil) {
               
                if !self.pageLoactionBtns.contains(cell.locationSelectBtn!) {
                    self.pageLoactionBtns.append(cell.locationSelectBtn!)
                }
                cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.size.width, bottom: 0, right: 0)
            }
        default:
            break
            
        }
        
        if rangSelctInitValue == 1 {
            self.rangePreCell?.rangeSelectBtn?.isSelected = true
            self.rangePreCell?.rangeSelectLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
        }
        
        if currentPageIndex == -2 {
            locationPreCell?.locationSelectBtn?.isSelected = true
            locationPreCell?.locationSelectLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
        }
        
        return cell
    }
    
    // MARK: - CInsertBlankPageCellDelegate
    
    func insertBlankPageCell(_ insertBlankPageCell: CInsertBlankPageCell, isSelect: Bool) {
        self.enterPDFAddFile()
    }
    
    func insertBlankPageCellRange(_ insertBlankPageCell: CInsertBlankPageCell, button: UIButton) {
        if let rangePreCell = self.rangePreCell {
            if(rangePreCell.rangeSelectBtn != nil) {
                
                rangePreCell.rangeSelectBtn?.isSelected = !rangePreCell.rangeSelectBtn!.isSelected
                rangePreCell.rangeSelectLabel?.textColor = UIColor.gray
                if rangePreCell.rangeSelectBtn != button {
                    button.isSelected = !button.isSelected
                    insertBlankPageCell.rangeSelectLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
                    self.rangePreCell = insertBlankPageCell
                } else {
                    rangePreCell.rangeSelectLabel?.textColor = UIColor.gray
                    self.rangePreCell = nil
                }
            }
        } else {
            self.rangePreCell = insertBlankPageCell
            button.isSelected = !button.isSelected
            insertBlankPageCell.rangeSelectLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
        }
        if let rangePreCell = rangePreCell, let range = tableView?.indexPath(for: rangePreCell) {
            switch range.row {
            case 2:
                var indexSet = IndexSet()
                for i in 0..<(self.document?.pageCount ?? 0) {
                    indexSet.insert(IndexSet.Element(i))
                }
                self.pageModel?.indexSet = indexSet
                self.rangeTextField?.isUserInteractionEnabled = false
            case 3:
                var indexSet = IndexSet()
                for i in stride(from: 0, to: self.document?.pageCount ?? 0, by: 2) {
                    indexSet.insert(IndexSet.Element(i))
                }
                self.pageModel?.indexSet = indexSet
                self.rangeTextField?.isUserInteractionEnabled = false
            case 4:
                var indexSet = IndexSet()
                for i in stride(from: 1, to: self.document?.pageCount ?? 0, by: 2) {
                    indexSet.insert(IndexSet.Element(i))
                }
                self.pageModel?.indexSet = indexSet
                self.rangeTextField?.isUserInteractionEnabled = false
            case 5:
                self.rangeTextField?.isUserInteractionEnabled = true
            default:
                break
            }
        }
        
    }
    
    func insertBlankPageCellLocation(_ insertBlankPageCell: CInsertBlankPageCell, button: UIButton) {
        if let locationPreCell = self.locationPreCell {
            locationPreCell.locationSelectBtn?.isSelected = !(locationPreCell.locationSelectBtn?.isSelected ?? false)
            locationPreCell.locationSelectLabel?.textColor = UIColor.gray
            if locationPreCell.locationSelectBtn != button {
                button.isSelected = !button.isSelected
                insertBlankPageCell.locationSelectLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
                self.locationPreCell = insertBlankPageCell
            } else {
                locationPreCell.locationSelectLabel?.textColor = UIColor.gray
                self.locationPreCell = nil
            }
        } else {
            self.locationPreCell = insertBlankPageCell
            button.isSelected = !button.isSelected
            insertBlankPageCell.locationSelectLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
        }
        if let locationPreCell = locationPreCell, let location = tableView?.indexPath(for: locationPreCell) {
            switch location.row {
            case 8:
                self.pdfInsertType = CPDFPDFInsertType.none
                self.pageModel?.pageIndex = 0
                self.saveButton?.isUserInteractionEnabled = true
                self.saveButton?.setTitleColor(UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0), for: .normal)
            case 9:
                self.pdfInsertType = CPDFPDFInsertType.none
                self.pageModel?.pageIndex = -2
                self.saveButton?.isUserInteractionEnabled = true
                self.saveButton?.setTitleColor(UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0), for: .normal)
            case 10:
                self.pdfInsertType = .before
                self.pageModel?.pageIndex = (Int(self.locationTextField?.text ?? "") ?? 0) - 1
                if self.locationTextField?.text == "" {
                    self.saveButton?.isUserInteractionEnabled = false
                    self.saveButton?.setTitleColor(UIColor.gray, for: .normal)
                } else {
                    self.saveButton?.isUserInteractionEnabled = true
                    self.saveButton?.setTitleColor(UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0), for: .normal)
                }
            case 12:
                self.pdfInsertType = .after
                self.pageModel?.pageIndex = Int(self.locationTextField?.text ?? "") ?? 0
                if self.locationTextField?.text == "" {
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
    
    func insertBlankPageCell(_ insertBlankPageCell: CInsertBlankPageCell, pageRange: String) {
        var indexSet = IndexSet()
        if pageRange.contains(",") {
            let pageIndexsArray = pageRange.components(separatedBy: ",")
            for pageIndexStr in pageIndexsArray {
                if pageIndexStr.contains("-") {
                    let pageIndexs = pageIndexStr.components(separatedBy: "-")
                    if let start = Int(pageIndexs[0]), let end = Int(pageIndexs[1]) {
                        if end > (self.document?.pageCount ?? 0)-1 {
                            popoverWarning()
                        } else {
                            for i in start-1...end-1 {
                                indexSet.insert(i)
                            }
                        }
                    }
                } else {
                    if let pageIndex = Int(pageIndexStr) {
                        if pageIndex > (self.document?.pageCount ?? 0)-1 {
                            popoverWarning()
                        } else {
                            indexSet.insert(pageIndex-1)
                        }
                    }
                }
            }
        } else {
            if pageRange.contains("-") {
                let pageIndexs = pageRange.components(separatedBy: "-")
                if let start = Int(pageIndexs[0]), let end = Int(pageIndexs[1]) {
                    if end > (self.document?.pageCount ?? 0)-1 {
                        popoverWarning()
                    } else {
                        for i in start-1...end-1 {
                            indexSet.insert(i)
                        }
                    }
                }
            } else {
                if let pageIndex = Int(pageRange) {
                    if pageIndex > (self.document?.pageCount ?? 0)-1 {
                        popoverWarning()
                    } else {
                        indexSet.insert(pageIndex-1)
                    }
                }
            }
        }
        self.pageModel?.indexSet = indexSet
    }
    
    func insertBlankPageCell(_ insertBlankPageCell: CInsertBlankPageCell, pageIndex: Int) {
        if pageIndex > 0 {
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
            self.pageModel?.pageIndex = pageIndex - 1
            if self.pdfInsertType == .before {
                self.pageModel?.pageIndex -= 1
            } else if self.pdfInsertType == .after {
                self.pageModel?.pageIndex += 1
            }
        }
        
    }
    
    func insertBlankPageCellLocationTextFieldBegin(_ insertBlankPageCell: CInsertBlankPageCell) {
        for button in self.pageLoactionBtns {
            if let location = self.pageLoactionBtns.firstIndex(of: button) {
                switch location {
                case 0...1:
                    if button.isSelected {
                        self.locationPreCell?.locationSelectBtn?.isSelected = !(self.locationPreCell?.locationSelectBtn?.isSelected ?? false)
                        self.locationPreCell?.locationSelectLabel?.textColor = UIColor.gray
                    }
                case 2:
                    if !button.isSelected && !(self.pageLoactionBtns[3].isSelected) {
                        self.pdfInsertType = .before
                        if let cell = self.tableView?.cellForRow(at: IndexPath(row: 10, section: 0)) as? CInsertBlankPageCell {
                            cell.locationSelectBtn?.isSelected = !(cell.locationSelectBtn?.isSelected ?? false)
                            cell.locationSelectLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
                            self.locationPreCell = cell
                        }
                    }
                default:
                    break
                }
            }
        }
        
    }
    
    func insertBlankPageCellRangeTextFieldBegin(_ insertBlankPageCell: CInsertBlankPageCell) {
        for button in self.pageRangeBtns {
            if let location = self.pageRangeBtns.firstIndex(of: button) {
                switch location {
                case 0...2:
                    if button.isSelected {
                        self.rangePreCell?.rangeSelectBtn?.isSelected = !(self.rangePreCell?.rangeSelectBtn?.isSelected ?? false)
                        self.rangePreCell?.rangeSelectLabel?.textColor = UIColor.gray
                    }
                case 3:
                    if !button.isSelected {
                        
                        if let cell = self.tableView?.cellForRow(at: IndexPath(row: 5, section: 0)) as? CInsertBlankPageCell {
                            cell.rangeSelectBtn?.isSelected = !(cell.rangeSelectBtn?.isSelected ?? false)
                            cell.rangeSelectLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
                            self.rangePreCell = cell
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
    
    // MARK: - UIDocumentPickerDelegate
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let fileUrlAuthozied = urls.first?.startAccessingSecurityScopedResource() ?? false
        if fileUrlAuthozied {
            let fileCoordinator = NSFileCoordinator()
            var error: NSError?
            fileCoordinator.coordinate(readingItemAt: urls.first!, options: [], error: &error) { newURL in
                let documentFolder = NSHomeDirectory() + "/Documents/Files"
                if !FileManager.default.fileExists(atPath: documentFolder) {
                    try? FileManager.default.createDirectory(atPath: documentFolder, withIntermediateDirectories: true, attributes: nil)
                }
                let documentPath = documentFolder+"/"+newURL.lastPathComponent
                if !FileManager.default.fileExists(atPath: documentPath) {
                    try? FileManager.default.copyItem(atPath: newURL.path, toPath: documentPath)
                }
                
                let url = URL(fileURLWithPath: documentPath)
                
                guard let document = CPDFDocument(url: url) else {
                    print("Document is NULL")
                    return
                }
                
                if let error = document.error, error._code != CPDFDocumentPasswordError {
                    let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in }
                    let alert = UIAlertController(title: "", message: NSLocalizedString("Sorry PDF Reader Can't open this pdf file!", comment: ""), preferredStyle: .alert)
                    alert.addAction(okAction)
                    let tRootViewControl = self
                    tRootViewControl.present(alert, animated: true, completion: nil)
                } else {
                    if document.isLocked {
                        let documentPasswordVC = CDocumentPasswordViewController(document: document)
                        documentPasswordVC.delegate = self
                        documentPasswordVC.modalPresentationStyle = .fullScreen
                        self.present(documentPasswordVC, animated: true, completion: nil)
                    } else {
                        self.document = document
                        self.tableView?.reloadData()
                        
                        var indexSet = IndexSet()
                        for i in 0..<(self.document?.pageCount ?? 0) {
                            indexSet.insert(IndexSet.Element(i))
                        }
                        self.pageModel?.indexSet = indexSet
                    }
                }
            }
            urls.first?.stopAccessingSecurityScopedResource()
            
        }
        
    }
    
    // MARK: - CDocumentPasswordViewControllerDelegate
    
    func documentPasswordViewControllerOpen(_ documentPasswordViewController: CDocumentPasswordViewController, document: CPDFDocument) {
        self.document = document
        self.tableView?.reloadData()
        
        var indexSet = IndexSet()
        for i in 0..<(self.document?.pageCount ?? 0) {
            indexSet.insert(IndexSet.Element(i))
        }
        self.pageModel?.indexSet = indexSet
    }
    
    func documentPasswordViewControllerCancel(_ documentPasswordViewController: CDocumentPasswordViewController) {
    
    }
    
}


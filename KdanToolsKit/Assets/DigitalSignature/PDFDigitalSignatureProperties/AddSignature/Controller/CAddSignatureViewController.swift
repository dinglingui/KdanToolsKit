//
//  CAddSignatureViewController.swift
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
import ComPDFKit

let NAME_KEY = NSLocalizedString("Name", comment: "")
let DN_KEY = NSLocalizedString("DN", comment: "")
let REASON_KEY = NSLocalizedString("Reason", comment: "")
let LOCATION_KEY = NSLocalizedString("Location", comment: "")
let DATE_KEY = NSLocalizedString("Date", comment: "")
let VERSION_KEY = NSLocalizedString("ComPDFKit Version", comment: "")

let ISDRAW_KEY = "isDrawKey"
let ISDRAWLOGO_KEY = "isDrawLogo"
let ISCONTENTALGINLEGF_KEY = "isContentAlginLeft"

let SAVEFILEPATH_KEY = "FilePathKey"
let PASSWORD_KEY = "PassWordKey"

@objc protocol CAddSignatureViewControllerDelegate {
    @objc optional func CAddSignatureViewControllerSave(_ addSignatureViewController: CAddSignatureViewController, signatureConfig config: CPDFSignatureConfig)
    @objc optional func CAddSignatureViewControllerCancel(_ addSignatureViewController: CAddSignatureViewController)
}

class CAddSignatureViewController: UIViewController,CHeaderViewDelegate,CAddSignatureCellDelegate,CLocationPropertiesViewControllerDelegate,CReasonPropertiesViewControllerDelegate,UITableViewDelegate,UITableViewDataSource {
    var customType: CSignatureCustomType = .none
    weak var delegate: CAddSignatureViewControllerDelegate?
    var signatureCertificate: CPDFSignatureCertificate?
    
    private var headerView: CHeaderView?
    private var preImageView: UIImageView?
    private var tableView: UITableView?
    private var saveBtn: UIButton?
    private lazy var textArray: [String] = {
        return [NSLocalizedString("Alignment", comment: ""), NSLocalizedString("Location", comment: ""), NSLocalizedString("Reason", comment: "")]
    }()
    
    private lazy var includeArray: [String] = {
        return [NSLocalizedString("Name", comment: ""), NSLocalizedString("Date", comment: ""), NSLocalizedString("Logo", comment: ""), NSLocalizedString("Distinguishable name", comment: ""), NSLocalizedString("ComPDFKit Version", comment: ""), NSLocalizedString("Tab", comment: "")]
    }()
    private var isLocation: Bool = false
    private var isReason: Bool = false
    private var isName: Bool = true
    private var isDate: Bool = true
    private var isLogo: Bool = true
    private var isVersion: Bool = false
    private var isDraw: Bool = true
    private var isDN: Bool = false
    private var isLeftAlignment: Bool = true
    private var locationStr: String = ""
    private var reasonStr: String = ""
    private var signatureConfig: CPDFSignatureConfig?
    private var annotation: CPDFSignatureWidgetAnnotation?
    
    // MARK: - Initializers
    
    init(annotation: CPDFSignatureWidgetAnnotation, signatureConfig: CPDFSignatureConfig) {
        super.init(nibName: nil, bundle: nil)
        // Your initialization code here
        self.annotation = annotation
        self.signatureConfig = signatureConfig
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Viewcontroller Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView = CHeaderView()
        headerView?.titleLabel?.text = NSLocalizedString("Customize the Signature Appearance", comment: "")
        headerView?.cancelBtn?.setImage(nil, for: .normal)
        headerView?.delegate = self
        headerView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        headerView?.layer.borderWidth = 1.0
        headerView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        view.addSubview(headerView!)
        
        saveBtn = UIButton()
        saveBtn?.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        saveBtn?.setTitleColor(UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0), for: .normal)
        saveBtn?.addTarget(self, action: #selector(buttonItemClicked_save(_:)), for: .touchUpInside)
        view.addSubview(saveBtn!)
        
        preImageView = UIImageView()
        view.addSubview(preImageView!)
        
        tableView = UITableView(frame: CGRect(x: 0, y: 210, width: view.frame.size.width, height: view.frame.size.height - 200), style: .plain)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 44.0
        tableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
   
        tableView?.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
        view.addSubview(tableView!)
        
        view.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        updatePreferredContentSizeWithTraitCollection(traitCollection)
        reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        headerView?.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 55)
        preImageView?.frame = CGRect(x: 20, y: (headerView?.frame.maxY ?? 0) + 5, width: view.frame.size.width - 40, height: 150)
        saveBtn?.frame = CGRect(x:  view.frame.size.width - 60, y: 5, width: 50, height: 50)
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
    
    private func reloadData() {
        guard let signatureConfig = signatureConfig, let contents = signatureConfig.contents else {
            return
        }
        
        for item in contents {
            if item.key == DATE_KEY {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                item.value = dateFormatter.string(from: Date())
                break
            }
        }
        annotation?.signAppearanceConfig(signatureConfig)
        let originalImage = annotation?.appearanceImage() ?? UIImage()
        if originalImage.cgImage != nil {
            let rotatedImage = UIImage(cgImage: (originalImage.cgImage!), scale: originalImage.scale, orientation: .down)
            let mirroredImage = UIImage(cgImage: rotatedImage.cgImage!, scale: rotatedImage.scale, orientation: .downMirrored)
            preImageView?.contentMode = .scaleAspectFit
            preImageView?.image = mirroredImage
        } else {
            print("appearanceImage is nil")
        }
    }
    
    private func sortContents(_ contents: [CPDFSignatureConfigItem]) -> [CPDFSignatureConfigItem] {
        var tContents = [CPDFSignatureConfigItem]()
        
        var nameItem: CPDFSignatureConfigItem?
        var dnItem: CPDFSignatureConfigItem?
        var reaItem: CPDFSignatureConfigItem?
        var locaItem: CPDFSignatureConfigItem?
        var dateItem: CPDFSignatureConfigItem?
        var verItem: CPDFSignatureConfigItem?
        
        for item in contents {
            switch item.key {
            case NAME_KEY:
                nameItem = item
            case DN_KEY:
                dnItem = item
            case REASON_KEY:
                reaItem = item
            case LOCATION_KEY:
                locaItem = item
            case DATE_KEY:
                dateItem = item
            case VERSION_KEY:
                verItem = item
            default:
                break
            }
        }
        
        if let nameItem = nameItem {
            tContents.append(nameItem)
        }
        if let dateItem = dateItem {
            tContents.append(dateItem)
        }
        
        if let reaItem = reaItem {
            tContents.append(reaItem)
        }
        
        if let dnItem = dnItem {
            tContents.append(dnItem)
        }
        
        if let verItem = verItem {
            tContents.append(verItem)
        }
        if let locaItem = locaItem {
            tContents.append(locaItem)
        }
        
        return tContents
    }
    
    private func getDNString() -> String {
        var result = ""
        if let cn = self.signatureCertificate?.issuerDict["C"] {
            result += "C= \(cn)"
        }
        
        if let o = self.signatureCertificate?.issuerDict["O"] {
            result += ",O= \(o)"
        }
        
        if let ou = self.signatureCertificate?.issuerDict["OU"] {
            result += ",OU= \(ou)"
        }
        
        if let cn = self.signatureCertificate?.issuerDict["CN"] {
            result += ",CN= \(cn)"
        }
        
        return result
    }
    
    // MARK: - CHeaderViewDelegate
    
    func CHeaderViewBack(_ headerView: CHeaderView) {
        dismiss(animated: true)
        delegate?.CAddSignatureViewControllerCancel?(self)
    }
    
    func CHeaderViewCancel(_ headerView: CHeaderView) {
        dismiss(animated: true)
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_save(_ button: UIButton) {
        dismiss(animated: true)
        delegate?.CAddSignatureViewControllerSave?(self, signatureConfig: signatureConfig ?? CPDFSignatureConfig())
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return textArray.count
        case 1:
            return includeArray.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("Text Properties", comment: "")
        } else if section == 1 {
            return NSLocalizedString("Include Text", comment: "")
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CAddSignatureCell(style: .subtitle, reuseIdentifier: "cell")
        cell.delegate = self
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                cell.setCellStyle(.alignment, label: textArray[indexPath.row])
                cell.setLeftAlignment(isLeftAlignment: isLeftAlignment)
            case 1:
                cell.setCellStyle(.access, label: textArray[indexPath.row])
                cell.accessSelectLabel?.text = locationStr
            case 2:
                cell.setCellStyle(.access, label: textArray[indexPath.row])
                cell.accessSelectLabel?.text = reasonStr
            default:
                break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                cell.setCellStyle(.select, label: includeArray[indexPath.row])
                cell.textSelectBtn?.isSelected = isName
            case 1:
                cell.setCellStyle(.select, label: includeArray[indexPath.row])
                cell.textSelectBtn?.isSelected = isDate
            case 2:
                cell.setCellStyle(.select, label: includeArray[indexPath.row])
                cell.textSelectBtn?.isSelected = isLogo
            case 3:
                cell.setCellStyle(.select, label: includeArray[indexPath.row])
                cell.textSelectBtn?.isSelected = isDN
            case 4:
                cell.setCellStyle(.select, label: includeArray[indexPath.row])
                cell.textSelectBtn?.isSelected = isVersion
            case 5:
                cell.setCellStyle(.select, label: includeArray[indexPath.row])
                cell.textSelectBtn?.isSelected = isDraw
            default:
                break
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell:CAddSignatureCell = tableView.cellForRow(at: indexPath) as? CAddSignatureCell ?? CAddSignatureCell()
        var btn = cell.accessSelectBtn
        if(indexPath.section == 0) {
            btn = nil
        } else {
            btn = cell.textSelectBtn
        }
        if btn != nil {
            self.addSignatureCell(cell, button: btn!)
        }
    }
    
    // MARK: - CAddSignatureCellDelegate
    
    func addSignatureCell(_ addSignatureCell: CAddSignatureCell, button: UIButton) {
        
        addSignatureCell.textSelectBtn?.isSelected = !(addSignatureCell.textSelectBtn?.isSelected ?? false)
        
        let indexPath2 = IndexPath(row: 0, section: 1)
        let cell2 = self.tableView?.cellForRow(at: indexPath2) as? CAddSignatureCell
        let indexPath3 = IndexPath(row: 5, section: 1)
        let cell3 = self.tableView?.cellForRow(at: indexPath3) as? CAddSignatureCell
        if let indexPath = self.tableView?.indexPath(for: addSignatureCell) {
            var contents = self.signatureConfig?.contents ?? []
            
            if contents.count <= 1 && self.customType == .none {
                if let configItem = contents.first,
                   configItem.key == NAME_KEY,
                   self.signatureConfig?.isDrawKey == true {
                    let nameBtn = cell2?.textSelectBtn
                    if nameBtn?.state == .normal {
                        contents.removeAll()
                    }
                    
                    let tapBtn = cell3?.textSelectBtn
                    if tapBtn?.state == .normal {
                        self.signatureConfig?.isDrawKey = false
                    }
                }
            }
            
            var configItem: CPDFSignatureConfigItem?
            
            switch indexPath.row {
            case 0:
                if button.isSelected {
                    configItem = CPDFSignatureConfigItem()
                    configItem?.key = NAME_KEY
                    configItem?.value = NSLocalizedString(self.signatureCertificate?.issuerDict?["CN"] as? String ?? "", comment: "")
                    contents.append(configItem!)
                } else {
                    for item in contents {
                        if item.key == NAME_KEY {
                            configItem = item
                            break
                        }
                    }
                    if let configItem = configItem {
                        contents.removeAll { $0 === configItem }
                    }
                }
                self.isName = button.isSelected
            case 1:
                if button.isSelected {
                    configItem = CPDFSignatureConfigItem()
                    configItem?.key = DATE_KEY
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    configItem?.value = dateFormatter.string(from: Date())
                    contents.append(configItem!)
                } else {
                    for item in contents {
                        if item.key == DATE_KEY {
                            configItem = item
                            break
                        }
                    }
                    if let configItem = configItem {
                        contents.removeAll { $0 === configItem }
                    }
                }
                self.isDate = button.isSelected
            case 2:
                if button.isSelected {
                    self.signatureConfig?.isDrawLogo = true
                } else {
                    self.signatureConfig?.isDrawLogo = false
                }
                self.isLogo = button.isSelected
            case 3:
                if button.isSelected {
                    configItem = CPDFSignatureConfigItem()
                    configItem?.key = DN_KEY
                    let dn = getDNString()
                    configItem?.value = NSLocalizedString(dn, comment: "")
                    contents.append(configItem!)
                } else {
                    for item in contents {
                        if item.key == DN_KEY {
                            configItem = item
                            break
                        }
                    }
                    if let configItem = configItem {
                        contents.removeAll { $0 === configItem }
                    }
                }
                self.isDN = button.isSelected
            case 4:
                if button.isSelected {
                    configItem = CPDFSignatureConfigItem()
                    configItem?.key = VERSION_KEY
                    if let infoDictionary = Bundle.main.infoDictionary,
                       let app_Version = infoDictionary["CFBundleShortVersionString"] as? String {
                        configItem?.value = app_Version
                    }
                    contents.append(configItem!)
                } else {
                    for item in contents {
                        if item.key == VERSION_KEY {
                            configItem = item
                            break
                        }
                    }
                    if let configItem = configItem {
                        contents.removeAll { $0 === configItem }
                    }
                }
                self.isVersion = button.isSelected
            case 5:
                if button.isSelected {
                    self.signatureConfig?.isDrawKey = true
                } else {
                    self.signatureConfig?.isDrawKey = false
                }
                self.isDraw = button.isSelected
            default:
                break
            }
            
            if self.customType == CSignatureCustomType.none && contents.isEmpty {
                configItem = CPDFSignatureConfigItem()
                configItem?.key = NAME_KEY
                configItem?.value = NSLocalizedString(self.signatureCertificate?.issuerDict?["CN"] as? String ?? "", comment: "")
                contents.append(configItem!)
                self.signatureConfig?.isDrawKey = true
            }
            
            self.signatureConfig?.contents = sortContents(contents)
            reloadData()
        }
        
    }
    
    func addSignatureCellAccess(_ addSignatureCell: CAddSignatureCell) {
        if let indexPath = self.tableView?.indexPath(for: addSignatureCell) {
            var presentationController: AAPLCustomPresentationController?
            
            if indexPath.row == 1 {
                let locationPropertiesVC = CLocationPropertiesViewController()
                locationPropertiesVC.delegate = self
                locationPropertiesVC.locationProperties = addSignatureCell.accessSelectLabel?.text
                locationPropertiesVC.isLocation = self.isLocation
                
                presentationController = AAPLCustomPresentationController(presentedViewController: locationPropertiesVC, presenting: self)
                locationPropertiesVC.transitioningDelegate = presentationController
                present(locationPropertiesVC, animated: true, completion: nil)
            } else if indexPath.row == 2 {
                let reasonPropertiesVC = CReasonPropertiesViewController()
                reasonPropertiesVC.delegate = self
                reasonPropertiesVC.resonProperties = addSignatureCell.accessSelectLabel?.text ?? ""
                reasonPropertiesVC.isReason = self.isReason
                
                presentationController = AAPLCustomPresentationController(presentedViewController: reasonPropertiesVC, presenting: self)
                reasonPropertiesVC.transitioningDelegate = presentationController
                present(reasonPropertiesVC, animated: true, completion: nil)
            }
        }
    }
    
    func addSignatureCell(_ addSignatureCell: CAddSignatureCell, alignment isLeft: Bool) {
        signatureConfig?.isContentAlginLeft = isLeft
        isLeftAlignment = !isLeft
        reloadData()
    }
    
    // MARK: - CLocationPropertiesViewControllerDelegate
    
    func locationPropertiesViewController(_ locationPropertiesViewController: CLocationPropertiesViewController, properties: String, isLocation: Bool) {
        let indexPath1 = IndexPath(row: 1, section: 0)
        let cell1 = self.tableView?.cellForRow(at: indexPath1) as? CAddSignatureCell ?? CAddSignatureCell()
        let indexPath2 = IndexPath(row: 0, section: 1)
        let cell2 = self.tableView?.cellForRow(at: indexPath2) as? CAddSignatureCell ?? CAddSignatureCell()
        let indexPath3 = IndexPath(row: 5, section: 1)
        let cell3 = self.tableView?.cellForRow(at: indexPath3) as? CAddSignatureCell ?? CAddSignatureCell()
        
        self.isLocation = isLocation
        cell1.accessSelectLabel?.text = properties
        self.locationStr = properties
        
        var contents = self.signatureConfig?.contents ?? []
        
        if contents.count <= 1 && self.customType == .none {
            if let configItem = contents.first, configItem.key == NAME_KEY, self.signatureConfig?.isDrawKey == true {
                if let nameBtn = cell2.textSelectBtn, nameBtn.state == .normal {
                    contents.removeAll()
                }
                
                if let tapBtn = cell3.textSelectBtn, tapBtn.state == .normal {
                    self.signatureConfig?.isDrawKey = false
                }
            }
        }
        
        var configItem: CPDFSignatureConfigItem?
        
        if isLocation {
            configItem = CPDFSignatureConfigItem()
            configItem?.key = LOCATION_KEY
            if properties.isEmpty {
                configItem?.value = NSLocalizedString("<your signing location here>", comment: "")
            } else {
                configItem?.value = properties
            }
            contents.append(configItem!)
        } else {
            if let index = contents.firstIndex(where: { $0.key == LOCATION_KEY }) {
                configItem = contents[index]
                contents.remove(at: index)
            }
            cell1.accessSelectLabel?.text = NSLocalizedString("Closes", comment: "")
            self.locationStr = ""
        }
        
        if self.customType == .none && contents.isEmpty {
            configItem = CPDFSignatureConfigItem()
            configItem?.key = NAME_KEY
            configItem?.value = NSLocalizedString("<your common name here>", comment: "")
            contents.append(configItem!)
            self.signatureConfig?.isDrawKey = true
        }
        
        self.signatureConfig?.contents = sortContents(contents)
        reloadData()
    }
    
    // MARK: - CReasonPropertiesViewControllerDelegate
    
    func reasonPropertiesViewController(_ reasonPropertiesViewController: CReasonPropertiesViewController, properties: String, isReason: Bool) {
        let indexPath1 = IndexPath(row: 2, section: 0)
        let cell1 = self.tableView?.cellForRow(at: indexPath1) as? CAddSignatureCell ?? CAddSignatureCell()
        let indexPath2 = IndexPath(row: 0, section: 1)
        let cell2 = self.tableView?.cellForRow(at: indexPath2) as? CAddSignatureCell ?? CAddSignatureCell()
        let indexPath3 = IndexPath(row: 5, section: 1)
        let cell3 = self.tableView?.cellForRow(at: indexPath3) as? CAddSignatureCell ?? CAddSignatureCell()
        
        cell1.accessSelectLabel?.text = properties
        self.reasonStr = properties
        self.isReason = isReason
        var contents = self.signatureConfig?.contents ?? []

        if contents.count <= 1 && self.customType == .none {
            if let configItem = contents.first, configItem.key == NAME_KEY, self.signatureConfig?.isDrawKey == true {
                if let nameBtn = cell2.textSelectBtn, nameBtn.state == .normal {
                    contents.removeAll()
                }
                
                if let tapBtn = cell3.textSelectBtn, tapBtn.state == .normal {
                    self.signatureConfig?.isDrawKey = false
                }
            }
        }

        var configItem: CPDFSignatureConfigItem?
        if isReason {
            configItem = CPDFSignatureConfigItem()
            configItem?.key = REASON_KEY
            configItem?.value = properties
            if configItem?.value == "" || configItem?.value == "  \(NSLocalizedString("none", comment: ""))" {
                configItem?.value = NSLocalizedString("<your signing reason here>", comment: "")
            }
            contents.append(configItem!)
        } else {
            if let index = contents.firstIndex(where: { $0.key == REASON_KEY }) {
                configItem = contents[index]
                contents.remove(at: index)
            }
            cell1.accessSelectLabel?.text = NSLocalizedString("Closes", comment: "")
            self.reasonStr = ""
        }

        if self.customType == .none && contents.isEmpty {
            configItem = CPDFSignatureConfigItem()
            configItem?.key = NAME_KEY
            configItem?.value = NSLocalizedString("<your common name here>", comment: "")
            contents.append(configItem!)
            self.signatureConfig?.isDrawKey = true
        }

        self.signatureConfig?.contents = sortContents(contents)
        reloadData()
    }
    
}


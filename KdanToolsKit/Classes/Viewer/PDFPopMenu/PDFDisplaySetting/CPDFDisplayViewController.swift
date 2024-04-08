//
//  CPDFDisplayViewController.swift
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

import Foundation

@objc protocol CPDFDisplayViewDelegate: AnyObject {
    @objc optional func displayViewControllerDismiss(_ displayViewController: CPDFDisplayViewController)
}

enum CDisplayPDFType: UInt {
    case singlePage = 0
    case twoPages
    case bookMode
    case continuousScroll
    case cropMode
    case verticalScrolling
    case horizontalScrolling
    case themesLight
    case themesDark
    case themesSepia
    case themesReseda
}


class CPDFDisplayViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    weak var delegate: CPDFDisplayViewDelegate?
    
    private var tableView: UITableView?
    private var titleLabel: UILabel?
    
    // MARK: - Initializers
    
    init(pdfView: CPDFView) {
        super.init(nibName: nil, bundle: nil)
        self.pdfView = pdfView
        self.updateDisplayView()
    }
    
    var pdfView: CPDFView?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorStyle = .none
        tableView?.tableFooterView = UIView()
        if(tableView != nil) {
            view.addSubview(tableView!)
        }
        tableView?.reloadData()
        
        view.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
        updatePreferredContentSize(with: traitCollection)
    
        titleLabel = UILabel()
        titleLabel?.text = NSLocalizedString("View Setting", comment: "")
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.textAlignment = .center
        if(titleLabel != nil) {
            view.addSubview(titleLabel!)
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSize(with: newCollection)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        titleLabel?.frame = CGRect(x: (view.frame.size.width - 120)/2, y: 5, width: 120, height: 50)
        tableView?.frame = CGRect(x: 0, y: 70, width: view.frame.size.width, height: view.frame.size.height - 50)
    }
    
    func updatePreferredContentSize(with traitCollection: UITraitCollection) {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let mWidth = min(width, height)
        let mHeight = max(width, height)
        let currentDevice = UIDevice.current
        if currentDevice.userInterfaceIdiom == .pad {
            // This is an iPad
            self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? mWidth * 0.7 : mHeight * 0.7)
        } else {
            // This is an iPhone or iPod touch
            self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? mWidth * 0.9 : mHeight * 0.9)
        }
    }
    
    @objc func buttonItemClicked_back(_ button: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - Accessors
    
    private lazy var displayModeArray: [CDisplayPDFType] = {
        let displayModeArray: [CDisplayPDFType] = [
            .verticalScrolling,
            .horizontalScrolling,
            .singlePage,
            .twoPages,
            .bookMode,
            .continuousScroll,
            .cropMode
        ]
        return displayModeArray
    }()
    
    private lazy var themesArray: [CDisplayPDFType] = {
        let themesArray: [CDisplayPDFType] = [
            .themesLight,
            .themesDark,
            .themesSepia,
            .themesReseda
        ]
        return themesArray
    }()
    
    var isSinglePage: Bool {
        get {
            return !(self.pdfView?.displayTwoUp == true)
        }
        set {
            self.pdfView?.displayTwoUp = false
            self.pdfView?.displaysAsBook = false
            self.pdfView?.layoutDocumentView()
        }
    }
    
    var isTwoPage: Bool {
        get {
            return self.pdfView?.displayTwoUp == true && !(self.pdfView?.displaysAsBook == true)
        }
        set {
            self.pdfView?.displayTwoUp = true
            self.pdfView?.displaysAsBook = false
            self.pdfView?.layoutDocumentView()
        }
    }
    
    var isBookMode: Bool {
        get {
            return self.pdfView?.displayTwoUp == true && self.pdfView?.displaysAsBook == true
        }
        set {
            self.pdfView?.displayTwoUp = true
            self.pdfView?.displaysAsBook = true
            self.pdfView?.layoutDocumentView()
        }
    }
    
    // MARK: - Public method
    
    func updateDisplayView() {
        // Implementation
        self.tableView?.reloadData()
    }
    
    // MARK: - Private method
    
    func changePDFViewCropMode(isCropMode: Bool) {
        navigationController?.view.isUserInteractionEnabled = true
        let loadingView = CActivityIndicatorView(style: .whiteLarge)
        loadingView.center = view.center
        loadingView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        if loadingView.superview == nil {
            view.addSubview(loadingView)
        }
        loadingView.startAnimating()
        DispatchQueue.global(qos: .default).async {
            self.pdfView?.displayCrop = isCropMode
            
            DispatchQueue.main.async {
                self.pdfView?.layoutDocumentView()
                
                loadingView.stopAnimating()
                loadingView.removeFromSuperview()
                self.navigationController?.view.isUserInteractionEnabled = false
                
                if let delegate = self.delegate {
                    delegate.displayViewControllerDismiss?(self)
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else if section == 1 {
            return 3
        } else if section == 2 {
            return 2
        } else {
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var zcell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CPDFDisplayTableViewCell
        if zcell == nil {
            zcell = CPDFDisplayTableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        let cell:CPDFDisplayTableViewCell = zcell!

        var model: CPDFDisplayModel?
        
        if indexPath.section == 0 {
            model = CPDFDisplayModel(displayType: self.displayModeArray[indexPath.row])
        } else if indexPath.section == 1 {
            model = CPDFDisplayModel(displayType: self.displayModeArray[indexPath.row + 2])
        } else if indexPath.section == 2 {
            model = CPDFDisplayModel(displayType: self.displayModeArray[indexPath.row + 5])
        } else {
            model = CPDFDisplayModel(displayType: self.themesArray[indexPath.row])
        }
        
        switch model?.tag {
        case .singlePage:
            cell.modeSwitch?.isHidden = true
            cell.checkImageView?.isHidden = true
            if isSinglePage == true {
                cell.checkImageView?.isHidden = false
            }
        case .twoPages:
            cell.modeSwitch?.isHidden = true
            cell.checkImageView?.isHidden = true
            if isTwoPage == true {
                cell.checkImageView?.isHidden = false
            }
        case .bookMode:
            cell.modeSwitch?.isHidden = true
            cell.checkImageView?.isHidden = true
            if isBookMode == true {
                cell.checkImageView?.isHidden = false
            }
        case .continuousScroll:
            cell.modeSwitch?.isHidden = false
            cell.checkImageView?.isHidden = true
            if pdfView?.displaysPageBreaks == true {
                cell.modeSwitch?.setOn(true, animated: false)
            } else {
                cell.modeSwitch?.setOn(false, animated: false)
            }
        case .cropMode:
            cell.checkImageView?.isHidden = true
            cell.modeSwitch?.isHidden = false
            if pdfView?.displayCrop == true {
                cell.modeSwitch?.setOn(true, animated: false)
            } else {
                cell.modeSwitch?.setOn(false, animated: false)
            }
        case .verticalScrolling:
            cell.modeSwitch?.isHidden = true
            cell.checkImageView?.isHidden = false
            if pdfView?.displayDirection == .vertical {
                cell.checkImageView?.isHidden = false
            } else {
                cell.checkImageView?.isHidden = true
            }
        case .horizontalScrolling:
            cell.modeSwitch?.isHidden = true
            cell.checkImageView?.isHidden = false
            if pdfView?.displayDirection == .horizontal {
                cell.checkImageView?.isHidden = false
            } else {
                cell.checkImageView?.isHidden = true
            }
        case .themesLight:
            cell.modeSwitch?.isHidden = true
            cell.checkImageView?.isHidden = true
            if pdfView?.displayMode == .normal {
                cell.checkImageView?.isHidden = false
            }
        case .themesDark:
            cell.modeSwitch?.isHidden = true
            cell.checkImageView?.isHidden = true
            if pdfView?.displayMode == .night {
                cell.checkImageView?.isHidden = false
            }
        case .themesSepia:
            cell.modeSwitch?.isHidden = true
            cell.checkImageView?.isHidden = true
            if pdfView?.displayMode == .soft {
                cell.checkImageView?.isHidden = false
            }
        case .themesReseda:
            cell.modeSwitch?.isHidden = true
            cell.checkImageView?.isHidden = true
            if pdfView?.displayMode == .green {
                cell.checkImageView?.isHidden = false
            }
        default:
            cell.checkImageView?.isHidden = true
            cell.modeSwitch?.isHidden = true
        }
        
        cell.iconImageView?.image = model!.image
        cell.titleLabel?.text = model!.titilName ?? ""
        cell.switchBlock = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            
            if model!.tag == .continuousScroll {
                let isDisplaysPageBreaks = cell.modeSwitch?.isOn
                self.pdfView?.displaysPageBreaks = isDisplaysPageBreaks ?? false
                self.pdfView?.layoutDocumentView()
                
                if let delegate = self.delegate {
                    delegate.displayViewControllerDismiss?(self)
                }
            } else if model!.tag == .cropMode {
                let isCropMode = cell.modeSwitch?.isOn
                self.changePDFViewCropMode(isCropMode: (isCropMode ?? false))
            } else if model!.tag == .verticalScrolling {
                if (cell.modeSwitch?.isOn ?? false) {
                    self.pdfView?.displayDirection = .vertical
                } else {
                    self.pdfView?.displayDirection = .horizontal
                }
                self.pdfView?.layoutDocumentView()
                
                if let delegate = self.delegate {
                    delegate.displayViewControllerDismiss?(self)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("Display Mode", comment: "")
        } else if section == 1 {
            return ""
        } else if section == 2 {
            return ""
        } else {
            return NSLocalizedString("Themes", comment: "")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 || section == 2 {
            return 10
        } else {
            return 30
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var type: CDisplayPDFType = CDisplayPDFType.cropMode
        let index = self.pdfView?.currentPageIndex
        
        if indexPath.section == 0 {
            type = self.displayModeArray[indexPath.row]
        } else if indexPath.section == 1 {
            type = self.displayModeArray[indexPath.row + 2]
        } else if indexPath.section == 2 {
            type = self.displayModeArray[indexPath.row + 5]
        } else {
            type = self.themesArray[indexPath.row]
        }
        
        switch type {
        case .singlePage:
            isSinglePage = true
            
            tableView.reloadData()
            
            self.delegate?.displayViewControllerDismiss?(self)
        case .twoPages:
            isTwoPage = true
            
            tableView.reloadData()
            
            self.delegate?.displayViewControllerDismiss?(self)
        case .bookMode:
            isBookMode = true
            
            tableView.reloadData()
            
            self.delegate?.displayViewControllerDismiss?(self)
        case .themesLight:
            self.pdfView?.displayMode = .normal
            self.pdfView?.layoutDocumentView()
            
            tableView.reloadData()
            
            self.delegate?.displayViewControllerDismiss?(self)
        case .themesDark:
            self.pdfView?.displayMode = .night
            self.pdfView?.layoutDocumentView()
            
            tableView.reloadData()
            
            self.delegate?.displayViewControllerDismiss?(self)
        case .themesSepia:
            self.pdfView?.displayMode = .soft
            self.pdfView?.layoutDocumentView()
            
            self.tableView?.reloadData()
            self.delegate?.displayViewControllerDismiss?(self)
        case .themesReseda:
            self.pdfView?.displayMode = .green
            self.pdfView?.layoutDocumentView()
            
            self.tableView?.reloadData()
            self.delegate?.displayViewControllerDismiss?(self)
        case .horizontalScrolling:
            self.pdfView?.displayDirection = .horizontal
            self.pdfView?.layoutDocumentView()
            
            self.tableView?.reloadData()
        case .verticalScrolling:
            self.pdfView?.displayDirection = .vertical
            self.pdfView?.layoutDocumentView()
            
            self.tableView?.reloadData()
        case .continuousScroll:
            break
        case .cropMode:
            break
        }
        pdfView?.go(toPageIndex: index ?? 0, animated: false)
    }
    
}


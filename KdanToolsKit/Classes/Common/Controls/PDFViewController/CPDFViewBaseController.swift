//
//  CPDFViewBaseController.swift
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

public let SAMPLESFOLDER = NSHomeDirectory().appending("/Documents/Samples")

public let VIEWERSFOLDER = NSHomeDirectory().appending("/Documents/Viewer")

public let ANNOTATIONSFOLDER = NSHomeDirectory().appending("/Documents/Annotations")

public let FORMSFOLDER = NSHomeDirectory().appending("/Documents/Forms")

public let SIGNATURESFOLDER = NSHomeDirectory().appending("/Documents/Signatures")

public let CONTENTEDITORFOLDER = NSHomeDirectory().appending("/Documents/ContentEditor")

public let SECURITYFOLDER = NSHomeDirectory().appending("/Documents/Security")

public let DOCUMENTEDITORFOLDER = NSHomeDirectory().appending("/Documents/DocumentEditor")

public let WATERMARKFOLDER = NSHomeDirectory().appending("/Documents/Watermark")

public let TEMPOARTFOLDER = NSTemporaryDirectory().appending("Samples")

@objc public protocol CPDFViewBaseControllerDelete: AnyObject {
    
    @objc optional func PDFViewBaseControllerDissmiss(_ baseControllerDelete: CPDFViewBaseController)
}

open class CPDFViewBaseController: UIViewController, CPDFListViewDelegate, CPDFViewDelegate, CSearchToolbarDelegate, CPDFBOTAViewControllerDelegate, CPDFSearchResultsDelegate,CPDFDisplayViewDelegate,CPDFPopMenuDelegate,CPDFThumbnailViewControllerDelegate,CPDFPopMenuViewDelegate,CDocumentPasswordViewControllerDelegate, CPDFPageEditViewControllerDelegate,CPDFAddWatermarkViewControllerDelegate,UIDocumentPickerDelegate, CSearchTitleViewDelegate {
    
    public weak var delegate: CPDFViewBaseControllerDelete?
    
    public var filePath:String?
    public var password:String?
    public var pdfListView:CPDFListView?
    public var popMenu:CPDFPopMenu?
    public var navigationTitle:String?
    public var titleButton:CNavigationBarTitleButton?
    var rightView:CNavigationRightView?
    var thumbnailBarItem:UIBarButtonItem?
    var backBarItem:UIBarButtonItem?
    public var searchToolbar:CSearchToolbar?
    public var searchNavView:CSearchTitleView?

    public var configuration:CPDFConfiguration?
    public var signatures: [CPDFSignature]?
    public var documentPickerViewController: UIDocumentPickerViewController?
    private var textField: UITextField?
    private var isEnterPDFSecurity: Bool = false

    public var leftBarButtonItems:[UIBarButtonItem] = []
    public var rightBarButtonItems:[UIBarButtonItem] = []
    public var navTitieView:UIView?
    public var searchOption: CPDFSearchOptions = CPDFSearchOptions(rawValue: 0)

    public var functionTypeState: CPDFToolFunctionTypeState = .viewer
    
    public var popSearchReplaceView:CSearchContentView?

    public var hightSelection:CPDFSelection?

    public init(filePath: String, password: String?) {
        super.init(nibName: nil, bundle: nil)
        self.filePath = filePath
        self.password = password ?? ""
        
        self.configuration = CPDFConfiguration()
        let thumbnail = CNavBarButtonItem(viewLeftBarButtonItem: .thumbnail)
        let search = CNavBarButtonItem(viewRightBarButtonItem: .search)
        let bota = CNavBarButtonItem(viewRightBarButtonItem: .bota)
        let more = CNavBarButtonItem(viewRightBarButtonItem: .more)
        
        self.configuration?.showleftItems = [thumbnail]
        self.configuration?.showRightItems = [search, bota, more]
        configuration?.availableViewModes = [.viewer, .annotation, .edit, .form, .signature]
        configuration?.annotationsTypes = [.note, .highlight, .underline, .strikeout, .squiggly, .freehand, .pencilDrawing, .shapeCircle, .shapeRectangle, .shapeArrow, .shapeLine, .freeText, .signature, .stamp, .image, .sound]
        configuration?.annotationsTools = [.setting, .undo, .redo]
        configuration?.contentEditorTools = [.setting, .undo, .redo]
        configuration?.contentEditorTypes = [.text, .image]
        configuration?.formTypes = [.text, .checkBox, .radioButton, .comboBox, .list, .button, .sign]
        configuration?.formTools = [.undo, .redo]
    }
    
    public init(filePath: String, password: String?, configuration: CPDFConfiguration) {
        super.init(nibName: nil, bundle: nil)
        self.filePath = filePath
        self.password = password ?? ""
        self.configuration = configuration
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
        
        self.initWitPDFListView()
        self.initWitNavigation()
        self.initWitNavigationTitle()
        self.initWithSearchTool()
        self.reloadDocument(withFilePath: self.filePath ?? "", password: self.password) { Bool in
            
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var height:CGFloat = 0
        if self.navigationController!.isNavigationBarHidden != true {
             height = self.navigationController?.navigationBar.frame.maxY ?? 0.0
        } else {
            if #available(iOS 11.0, *) {
                height = self.view.safeAreaInsets.top
            } 
        }
        if(self.searchToolbar?.superview != nil) {
            self.searchToolbar?.frame = CGRect(x: 0, y: height, width: self.view.frame.size.width, height: self.searchToolbar?.frame.height ?? 0)
        }
        if(popSearchReplaceView?.superview != nil) {
            popSearchReplaceView?.frame = CGRect(x: 0, y: self.searchToolbar?.frame.maxY ?? 0, width: self.view.width, height: self.view.height - (self.searchToolbar?.frame.maxY ?? 0))
        }
        
        if(self.hightSelection != nil) {
            let pageIndex = self.pdfListView?.document.index(for: hightSelection!.page)

            self.pdfListView?.go(toPageIndex: Int(pageIndex ?? 0), animated: false)
            self.pdfListView?.setHighlightedSelection(self.hightSelection, animated: true)
            self.pdfListView?.go(to: self.hightSelection!.bounds, on: self.hightSelection!.page, offsetY: self.searchToolbar?.frame.maxY ?? 0, animated: false)
            self.popSearchReplaceView?.setNeedsDisplay()
        }
        
    }
    
    func updatePDFViewDocumentView() {
        if(self.pdfListView == nil) {
            return
        }
        
        let documentView = self.pdfListView!.documentView()
        if CPDFKitConfig.sharedInstance().displayDirection() == .vertical {
            if self.pdfListView?.currentPageIndex != 0 {
                if #available(iOS 11.0, *) {
                    documentView?.contentInsetAdjustmentBehavior = .never
                } else {
                    self.automaticallyAdjustsScrollViewInsets = false
                }
            } else {
                if #available(iOS 11.0, *) {
                    documentView?.contentInsetAdjustmentBehavior = .automatic
                } else {
                    self.automaticallyAdjustsScrollViewInsets = true
                }
            }
        } else {
            if #available(iOS 11.0, *) {
                documentView?.contentInsetAdjustmentBehavior = .never
            } else {
                self.automaticallyAdjustsScrollViewInsets = false
            }
        }
    }
    
    public lazy var loadingView: CActivityIndicatorView = {
        let view = CActivityIndicatorView(style: .gray)
        view.center = self.view.center
        view.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        return view
    }()
    
    func initWitPDFListView() {
        self.pdfListView = CPDFListView(frame: self.view.bounds)
        self.pdfListView?.performDelegate = self
        self.pdfListView?.delegate = self
        self.pdfListView?.parentVC = self
        self.pdfListView?.configuration = self.configuration
    
        self.pdfListView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(self.pdfListView!)
        
        CPDFJSONDataParse.initializeAnnotationAttribute(Configuration: self.configuration ?? CPDFConfiguration())
    }
    
    public func initWitNavigation() {
        let thumbnailItem = UIBarButtonItem(image: UIImage(named: "CPDFThunbnailImageEnter", in: Bundle(for: CPDFViewBaseController.classForCoder()), compatibleWith: nil), style: .plain, target: self, action: #selector(buttonItemClicked_thumbnail(_:)))
        
        let backItem = UIBarButtonItem(image: UIImage(named: "CPDFViewImageBack", in: Bundle(for: CPDFViewBaseController.classForCoder()), compatibleWith: nil), style: .plain, target: self, action: #selector(buttonItemClicked_back(_:)))
        
        self.thumbnailBarItem = thumbnailItem
        self.backBarItem = backItem
        
        var leftItems = [UIBarButtonItem]()
     
        for item in self.configuration?.showleftItems ?? [] {
            if item.leftBarItem == .back {
                leftItems.append(backItem)
            } else if item.leftBarItem == .thumbnail {
                leftItems.append(thumbnailItem)
            }
        }
   
        self.navigationItem.leftBarButtonItems = leftItems
        
        var actions = [CNavigationRightAction]()
        for item in self.configuration?.showRightItems ?? [] {
            if item.rightBarItem == .bota {
                let image = UIImage(named: "CNavigationImageNameBota", in: Bundle(for: CPDFViewBaseController.classForCoder()), compatibleWith: nil)
                let action = CNavigationRightAction(image: image!, tag: .Bota)
                actions.append(action)
            } else if item.rightBarItem == .search {
                let image = UIImage(named: "CNavigationImageNameSearch", in: Bundle(for: CPDFViewBaseController.classForCoder()), compatibleWith: nil)
                let action = CNavigationRightAction(image: image!, tag: .Search)
                actions.append(action)
            } else if item.rightBarItem == .more {
                let image = UIImage(named: "CNavigationImageNameMore", in: Bundle(for: CPDFViewBaseController.classForCoder()), compatibleWith: nil)
                let action = CNavigationRightAction(image: image!, tag: .More)
                actions.append(action)
            }
        }
        self.rightView = CNavigationRightView(rightActions: actions) { [weak self] tag in
            guard let self = self else { return }
            switch tag {
            case .Search:
                self.buttonItemClicked_Search(nil)
            case .Bota:
                self.buttonItemClicked_Bota(nil)
            case .More:
                self.buttonItemClicked_More(nil)
            }
        }
    }    
    
    func initWithSearchTool() {
        if (self.pdfListView != nil) {
            self.searchToolbar = CSearchToolbar(pdfView: self.pdfListView!)
            self.searchToolbar?.parentVC = self
            self.searchToolbar?.delegate = self
        }
    }
    
    public func enterPDFSetting() {
        self.popMenu?.hideMenu()
        if (self.pdfListView != nil) {
            let displayVc = CPDFDisplayViewController(pdfView: self.pdfListView!)
            displayVc.delegate = self
            
            let presentationController = AAPLCustomPresentationController.init(presentedViewController: displayVc, presenting: self)
            displayVc.transitioningDelegate = presentationController  
            self.present(displayVc, animated: true, completion: nil)
        }
    }
    
    public func enterPDFInfo() {
        self.popMenu?.hideMenu()
        if (self.pdfListView != nil) {
            
            let infoVc = CPDFInfoViewController(pdfView: self.pdfListView!)
            let presentationController = AAPLCustomPresentationController(presentedViewController: infoVc, presenting: self)
            infoVc.transitioningDelegate = presentationController  
            self.present(infoVc, animated: true, completion: nil)
        }
    }
    
    public func enterPDFShare() {
        self.popMenu?.hideMenu()
        if (self.pdfListView != nil) {
            if self.pdfListView!.isEditing() && self.pdfListView!.isEdited() {
                DispatchQueue.global(qos: .default).async {
                    self.pdfListView!.commitEditing()
                    
                    let documentFolder = NSHomeDirectory().appending("/Documents/\(self.pdfListView?.document.documentURL.lastPathComponent ?? "")")
                    let url = URL(fileURLWithPath: documentFolder)
                    
                    self.pdfListView!.document.write(to: url)
                    
                    DispatchQueue.main.async {
                        self.shareAction(url: url)
                    }
                }
            } else {
                DispatchQueue.global(qos: .default).async {
                    let documentFolder = NSHomeDirectory().appending("/Documents/\(self.pdfListView!.document.documentURL.lastPathComponent)")
                    let url = URL(fileURLWithPath: documentFolder)
                    
                    self.pdfListView!.document.write(to: url)
                    DispatchQueue.main.async {
                        self.shareAction(url: url)
                    }
                }
            }
        }
    }
    
    public func enterPDFAddFile() {
        self.popMenu?.hideMenu()
        let documentTypes = ["com.adobe.pdf"]
        documentPickerViewController = UIDocumentPickerViewController(documentTypes: documentTypes, in: .open)
        documentPickerViewController?.delegate = self
        self.present(documentPickerViewController!, animated: true, completion: nil)
    }
    
    public func enterPDFSave() {
        self.popMenu?.hideMenu()
        if (self.pdfListView?.isEditing() == true && self.pdfListView?.isEdited() == true) {
            DispatchQueue.global(qos: .default).async {
                self.pdfListView?.commitEditing()
                DispatchQueue.main.async {
                    if self.pdfListView?.document.isModified() == true {
                        self.pdfListView?.document.write(to: self.pdfListView?.document.documentURL)
                    }
                }
            }
            
        } else {
            if self.pdfListView?.document.isModified() == true {
                self.pdfListView?.document.write(to: self.pdfListView?.document.documentURL)
            }
        }
    }
    
    public func enterPDFFlattened() {
        self.popMenu?.hideMenu()
        if (!(FileManager.default.fileExists(atPath: TEMPOARTFOLDER))) {
            try? FileManager.default.createDirectory(atPath: TEMPOARTFOLDER, withIntermediateDirectories: true, attributes: nil)
        }
        
        guard let lastPathComponent = self.pdfListView?.document.documentURL.deletingPathExtension().lastPathComponent else { return  }
        
        let secPath = TEMPOARTFOLDER + "/" + lastPathComponent + NSLocalizedString("_Flattened", comment: "") + ".pdf"
        do {
            try FileManager.default.removeItem(atPath: secPath)
        } catch {
            // Handle the error, e.g., print an error message or perform other actions
        }
        
        let url = NSURL(fileURLWithPath: secPath) as URL
        
        self.pdfListView?.document.writeFlatten(to: url)
        
        shareAction(url: url)
    }
    
    public func enterPDFWatermark() {
        self.popMenu?.hideMenu()
        let addWaterMarkVC = CPDFAddWatermarkViewController.init(fileURL: self.pdfListView?.document.documentURL, document: self.pdfListView?.document)
        addWaterMarkVC.delegate = self
        self.navigationController?.pushViewController(addWaterMarkVC, animated: false)
    }
    
    public func enterPDFSecurity() {
        self.popMenu?.hideMenu()
        let pdfDocument = CPDFDocument(url:self.pdfListView?.document.documentURL)
        if(pdfDocument?.password != nil) {
            pdfDocument?.unlock(withPassword: pdfDocument?.password)
        }
        let filePath = self.pdfListView?.document.documentURL.path ?? ""
        // have open PassWord And have open+ower
        if pdfDocument != nil && pdfDocument?.isLocked == true {
            isEnterPDFSecurity = true
            let documentPasswordVC = CDocumentPasswordViewController(document: pdfDocument!)
            documentPasswordVC.delegate = self
            documentPasswordVC.modalPresentationStyle = .fullScreen
            self.present(documentPasswordVC, animated: true, completion: nil)
        } else {
            if pdfDocument?.permissionsStatus == .user {
                enterPermissionPassword(pdfDocument: pdfDocument!)
            } else {
                enterSecurePDF(filePath: filePath, password: nil)
            }
        }
    }
    
    public func enterSecurePDF(filePath:String,password:String?) {
        let secureVC = CPDFSecureViewController(filePath: filePath, password: password)
        self.navigationController?.pushViewController(secureVC, animated:true)
    }
    
    public func enterPermissionPassword(pdfDocument:CPDFDocument) {
        let alert = UIAlertController(title: NSLocalizedString("Enter Owner's Password to Change the Security", comment: ""), message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            let owerPasswordBtton = UIButton(type: .custom)
            owerPasswordBtton.addTarget(self, action: #selector(self.buttonItemClicked_showOwerPassword(_:)), for: .touchUpInside)
            owerPasswordBtton.setImage(UIImage(named: "CSecureImageInvisible", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
            owerPasswordBtton.setImage(UIImage(named: "CSecureImageVisible", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .selected)
            owerPasswordBtton.frame = CGRect(x:0, y:0, width:25, height:25)
            
            textField.placeholder = NSLocalizedString("Please enter the owner's password", comment: "")
            textField.isSecureTextEntry = true
            textField.returnKeyType = .done
            textField.rightViewMode = .always
            textField.rightView = owerPasswordBtton
            
            self.textField = textField
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        let addAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (action) in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
             let result = pdfDocument.unlock(withPassword: text)
                if result == true {
                    if pdfDocument.permissionsStatus == .owner {
                        self.enterSecurePDF(filePath: pdfDocument.documentURL.path, password: pdfDocument.password)
                    } else {
                        self.enterPermissionPassword(pdfDocument: pdfDocument)
                    }
                } else {
                    self.enterPermissionPassword(pdfDocument: pdfDocument)
                }
            } else {
                self.enterPermissionPassword(pdfDocument: pdfDocument)
            }
        }
          
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    public func enterPDFPageEdit() {
        self.popMenu?.hideMenu()
        if (self.pdfListView?.activeAnnotations?.count ?? 0) > 0 {
            self.pdfListView?.updateActiveAnnotations([])
            self.pdfListView?.setNeedsDisplayForVisiblePages()
        }
        
        if (self.pdfListView?.isEditing() == true && self.pdfListView?.isEdited() == true) {
            DispatchQueue.global(qos: .default).async {
                self.pdfListView?.commitEditing()
                DispatchQueue.main.async {
                    if(self.pdfListView != nil) {
                        let pageEditViewController = CPDFPageEditViewController(pdfView: self.pdfListView!)
                        pageEditViewController.pageEditDelegate = self
                        let navController = CNavigationController(rootViewController: pageEditViewController)
                        
                        navController.modalPresentationStyle = .fullScreen
                        self.navigationController?.present(navController, animated: true, completion: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            pageEditViewController.beginEdit()
                        }
                    }
                }
            }
        } else {
            if(self.pdfListView != nil) {
                let pageEditViewController = CPDFPageEditViewController(pdfView: self.pdfListView!)
                pageEditViewController.pageEditDelegate = self
                let navController = CNavigationController(rootViewController: pageEditViewController)
                
                navController.modalPresentationStyle = .fullScreen
                self.navigationController?.present(navController, animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    pageEditViewController.beginEdit()
                }
            }
        }
    }
    
    open func initWitNavigationTitle() {
        let navTitleButton = CNavigationBarTitleButton()
        self.titleButton = navTitleButton
        self.navigationTitle = NSLocalizedString("View", comment: "")
        if configuration?.availableViewModes.count ?? 0 > 1 {
            navTitleButton.setImage(UIImage(named: "syasarrow", in: Bundle(for: CPDFViewBaseController.classForCoder()), compatibleWith: nil), for: .normal)
        }
        navTitleButton.addTarget(self, action: #selector(titleButtonClickd(_:)), for: .touchUpInside)
        navTitleButton.setTitle(self.navigationTitle as String? ?? "", for: .normal)
        navTitleButton.setTitleColor(CPDFColorUtils.CAnyReverseBackgooundColor(), for: .normal)
        self.titleButton!.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        self.navigationItem.titleView = self.titleButton
    }
    
    open func reloadDocument(withFilePath filePath: String, password: String?, completion: @escaping (Bool) -> Void) {
        navigationController?.view.isUserInteractionEnabled = false
        if loadingView.superview == nil {
            view.addSubview(self.loadingView)
        }
        self.loadingView.startAnimating()
        
        DispatchQueue.global(qos: .default).async {
            let url = URL(fileURLWithPath: filePath)
            let document = CPDFDocument(url: url)
            if document?.isLocked == true {
                document?.unlock(withPassword: password)
            }
            
            DispatchQueue.main.async {
                self.navigationController?.view.isUserInteractionEnabled = true
                self.loadingView.stopAnimating()
                self.loadingView.removeFromSuperview()
                
                if let error = document?.error, error._code != CPDFDocumentPasswordError {
                    let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
                        self.navigationController?.popViewController(animated: true)
                    }
                    let alert = UIAlertController(title: "", message: NSLocalizedString("Sorry PDF Reader Can't open this pdf file!", comment: ""), preferredStyle: .alert)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    completion(false)
                } else {
                    self.pdfListView?.document = document
                    completion(true)
                }
            }
        }
        
    }
    
    func  removeSearchContent() {
        if(popSearchReplaceView?.superview != nil) {
            popSearchReplaceView?.removeFromSuperview()
            popSearchReplaceView = nil
        }
        
        self.hightSelection = nil
    }
    
    func addSearcchContent() {
        if(popSearchReplaceView == nil && self.pdfListView != nil) {
            popSearchReplaceView = CSearchContentView(pdfView: self.pdfListView!)
            popSearchReplaceView?.frame = CGRect(x: 0, y: self.searchToolbar?.frame.maxY ?? 0, width: self.view.width, height: self.view.height - (self.searchToolbar?.frame.maxY ?? 0))
            if(popSearchReplaceView != nil) {
                self.view.addSubview(popSearchReplaceView!)
            }
        }
        
        popSearchReplaceView?.callback = { [weak self] in
            guard let currentSelection = self?.hightSelection else { return }
            let result = self?.pdfListView?.document.replace(with: currentSelection, search: self?.searchToolbar?.searchKeyString ?? "", toReplace: self?.searchToolbar?.replaceTextFied.text) { newSelection in
                self?.pdfListView?.setHighlightedSelection(newSelection, animated: true)
                self?.hightSelection = newSelection
                self?.pdfListView?.setNeedsDisplayFor(currentSelection.page)
                self?.popSearchReplaceView?.updateSelection(nil)

            }

        }
        popSearchReplaceView?.updateSelection(hightSelection)
        
    }
    
    // MARK: - CPDFPageEditViewControllerDelegate
    
    open func pageEditViewControllerDone(_ pageEditViewController: CPDFPageEditViewController) {
        pageEditViewController.dismiss(animated: true) {
            if pageEditViewController.isPageEdit {
                self.reloadDocument(withFilePath: (self.filePath)!, password: self.pdfListView?.document.password) { [weak self] result in
                    self?.pdfListView?.reloadInputViews()
                    self?.selectDocumentRefresh()
                }
                self.pdfListView?.reloadInputViews()
            }
        }
    }
    
    open func pageEditViewController(_ pageEditViewController: CPDFPageEditViewController, pageIndex: Int, isPageEdit: Bool) {
        if isPageEdit {
            reloadDocument(withFilePath: self.filePath!, password: nil) { [weak self] result in
                self?.pdfListView?.reloadInputViews()
                self?.pdfListView?.go(toPageIndex: pageIndex, animated: false)
                self?.selectDocumentRefresh()
            }
        } else {
            self.pdfListView?.go(toPageIndex: pageIndex, animated: false)
        }
    }
    
    // MARK: - CPDFAddWatermarkViewControllerDelegate
    
    open func addWatermarkViewControllerSave(_ addWatermarkViewControllerSave: CPDFAddWatermarkViewController, Text textWaterModel: CWatermarkModel) {
        
    }
    
    open func addWatermarkViewControllerSave(_ addWatermarkViewControllerSave: CPDFAddWatermarkViewController, Image imageWaterModel: CWatermarkModel) {
        
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_showOwerPassword(_ button: UIButton) {
        if button.isSelected == true {
            button.isSelected = false
            textField?.isSecureTextEntry = true
        } else {
            button.isSelected = true
            textField?.isSecureTextEntry = false
            
        }
    }
    
    open func setTitleRefresh() {
        
    }
    
    open func selectDocumentRefresh() {
        
    }
    
    open func shareRefresh() {
        
    }
    
    @objc open func buttonItemClicked_Search(_ button: UIButton?) {
        if(self.navigationController?.navigationBar != nil) {
            if (self.pdfListView != nil) {
                self.searchNavView = CSearchTitleView(pdfView: self.pdfListView!)
                self.searchNavView?.delegate = self
            }
            
            self.searchToolbar?.show(in: self.view)
            self.searchToolbar?.searchTitleType = .search
            self.searchToolbar?.searchOption = searchOption

            self.navigationTitle = ""
            self.navTitieView = self.navigationItem.titleView
            self.leftBarButtonItems = self.navigationItem.leftBarButtonItems!
            self.rightBarButtonItems = self.navigationItem.rightBarButtonItems!
            self.navigationController?.title = NSLocalizedString("Search", comment: "")
            let settingItem = UIBarButtonItem(image: UIImage(named: "CPDFSearchImageSetting", in: Bundle(for: CPDFViewBaseController.classForCoder()), compatibleWith: nil), style: .plain, target: self, action: #selector(buttonItemClicked_searchSetting(_:)))
            
            let searchBackItem = UIBarButtonItem(image: UIImage(named: "CPDFViewImageBack", in: Bundle(for: CPDFViewBaseController.classForCoder()), compatibleWith: nil), style: .plain, target: self, action: #selector(buttonItemClicked_searchBack(_:)))

            self.navigationItem.rightBarButtonItems = [settingItem]
            self.navigationItem.leftBarButtonItems = [searchBackItem]
            self.navigationItem.titleView = self.searchNavView
        }
        
        if(self.pdfListView?.toolModel == .edit) {
            addSearcchContent()
        }
        
        var inset:UIEdgeInsets = self.pdfListView?.documentView().contentInset ?? UIEdgeInsets.zero

        inset.top += searchToolbar?.height ?? 0
        self.pdfListView?.documentView().contentInset = inset        
    }
    
    @objc open func buttonItemClicked_Bota(_ button: UIButton?) {
        if(self.pdfListView != nil) {
            let botaViewController = CPDFBOTAViewController(pdfView: self.pdfListView!)
            botaViewController.delegate = self
            let presentationController = AAPLCustomPresentationController(presentedViewController: botaViewController, presenting: self)
            botaViewController.transitioningDelegate = presentationController  
            self.present(botaViewController, animated: true, completion: nil)
        }
    }
    
    @objc open func buttonItemClicked_More(_ button: UIButton?) {
        if (self.configuration?.showMoreItems.count ?? 0) > 0 {
            let menuView = CPDFPopMenuView.init(CGRect(x: 0, y: 0, width: 200, height: CGFloat((self.configuration?.showMoreItems.count ?? 0) * 45) + 20), Configuration: self.configuration ?? CPDFConfiguration())
            menuView.delegate = self
            self.popMenu = CPDFPopMenu(contentView: menuView)
            self.popMenu?.dimCoverLayer = true
            self.popMenu?.delegate = self
            if #available(iOS 11.0, *) {
                self.popMenu?.showMenu(in: CGRect(x: self.view.frame.size.width - self.view.safeAreaInsets.right - 250, y: (self.navigationController?.navigationBar.frame)!.maxY, width: 250, height: CGFloat((self.configuration?.showMoreItems.count ?? 0) * 45) + 20))
            } else {
                self.popMenu?.showMenu(in: CGRect(x: self.view.frame.size.width - 250, y: (self.navigationController?.navigationBar.frame)!.maxY, width: 250, height: CGFloat((self.configuration?.showMoreItems.count ?? 0) * 45) + 20))
            }
        }
    }
    
    @objc open func buttonItemClicked_thumbnail(_ button: UIButton) {
        if (self.pdfListView?.activeAnnotations?.count ?? 0) > 0 {
            self.pdfListView?.updateActiveAnnotations([])
            self.pdfListView?.setNeedsDisplayForVisiblePages()
        }
        if (self.pdfListView?.isEditing() == true && self.pdfListView?.isEdited() == true) {
            DispatchQueue.global(qos: .default).async {
                self.pdfListView?.commitEditing()
                DispatchQueue.main.async {
                    self.enterThumbnail()
                }
            }
        } else {
            enterThumbnail()
        }
    }
    
    open func enterThumbnail() {
        let thumbnailViewController = CPDFThumbnailViewController(pdfView: self.pdfListView!)
        thumbnailViewController.delegate = self
        let presentationController = AAPLCustomPresentationController(presentedViewController: thumbnailViewController, presenting: self)
        thumbnailViewController.transitioningDelegate = presentationController
        let nav = UINavigationController(rootViewController: thumbnailViewController)
        self.present(nav, animated: true, completion: nil)
    }

    
    @objc func buttonItemClicked_back(_ button: UIButton) {
        
        if (self.pdfListView?.isEditing() == true && self.pdfListView?.isEdited() == true) {
            DispatchQueue.global(qos: .default).async {
                self.pdfListView?.commitEditing()
                DispatchQueue.main.async {
                    if self.pdfListView?.document.isModified() == true {
                        self.pdfListView?.document.write(to: self.pdfListView?.document.documentURL)
                    }
                    self.delegate?.PDFViewBaseControllerDissmiss?(self)
                }
            }
            
        } else {
            if(self.pdfListView?.document != nil) {
                if self.pdfListView?.document.isModified() == true {
                    self.pdfListView?.document.write(to: self.pdfListView?.document.documentURL)
                }
            }
            self.delegate?.PDFViewBaseControllerDissmiss?(self)
        }
    }
    
    @objc open func titleButtonClickd(_ button: UIButton) {
    }
    
    @objc open func buttonItemClicked_searchSetting(_ button: UIButton) {
        var isSensitive = true
        if searchOption.contains(.caseSensitive) {
            // Your code here
            isSensitive = false
        }
        var isWholeWord = false
        if searchOption.contains(.matchWholeWord) {
            // Your code here
            isWholeWord = true
        }
        
        let searchSettingController = CSearchSettingViewController(isSensitive: isSensitive, isWholeWord: isWholeWord)
        let nav = CNavigationController(rootViewController: searchSettingController)
        let presentationController = AAPLCustomPresentationController(presentedViewController: nav, presenting: self)
    
        weak var weakBlockSelf = self

        searchSettingController.callback = { [weak weakBlockSelf] searchOptionz in
            if(weakBlockSelf?.searchOption != searchOptionz) {
                weakBlockSelf?.searchOption = searchOptionz
                weakBlockSelf?.searchToolbar?.searchOption = searchOptionz
                weakBlockSelf?.searchToolbar?.clearDatas(false)
            }
           
        }
        nav.transitioningDelegate = presentationController
        self.present(nav, animated: true, completion: nil)
    }
    
    @objc open func buttonItemClicked_searchBack(_ button: UIButton?) {
        if ((searchNavView?.superview) != nil) {
            searchNavView?.removeFromSuperview()
            self.title = self.navigationTitle as String?
            
            self.navigationItem.leftBarButtonItems = self.leftBarButtonItems
            self.navigationItem.rightBarButtonItems = self.rightBarButtonItems
            self.navigationItem.titleView = self.navTitieView
        }
        
        var inset:UIEdgeInsets = self.pdfListView?.documentView().contentInset ?? UIEdgeInsets.zero
        inset.top = 0
        self.pdfListView?.documentView().contentInset = inset

        
        if(searchToolbar?.superview != nil) {
            searchToolbar?.removeFromSuperview()
        }
        
        removeSearchContent()
        
        self.navigationTitle? = NSLocalizedString("Viewer", comment: "")
        
        self.searchToolbar?.clearDatas(true)
    }
    
    // MARK: - CPDFViewDelegate
    open func pdfViewDocumentDidLoaded(_ pdfView: CPDFView!) {
        if(self.rightView != nil){
            let rightItem = UIBarButtonItem(customView: self.rightView!)
            self.navigationItem.rightBarButtonItems = [rightItem]
        }
        self.updatePDFViewDocumentView()
        
        self.loadingView.startAnimating()
        let signatures = self.pdfListView?.document.signatures() ?? []
        var mSignatures: [CPDFSignature] = []
        
        for sign in signatures {
            if sign.signers.count > 0 {
                mSignatures.append(sign)
            }
        }
        
        self.signatures = mSignatures
        self.navigationController?.view.isUserInteractionEnabled = true
        self.loadingView.stopAnimating()
        self.loadingView.removeFromSuperview()
        
        CPDFJSONDataParse.initializeReaderViewConfig(self.configuration ?? CPDFConfiguration(), PDFView: pdfListView ?? CPDFListView(frame: .zero))
    }
    
    open func pdfViewCurrentPageDidChanged(_ pdfView: CPDFView!) {
        self.updatePDFViewDocumentView()
    }
    
    open func pdfViewPerformURL(_ pdfView: CPDFView!, withContent content: String!) {
        if let url = URL(string: content) {
            UIApplication.shared.open(url)
        } else {
            let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil)
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("The hyperlink is invalid.", comment: ""), preferredStyle: .alert)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    open func pdfViewPerformReset(_ pdfView: CPDFView!) {
        let okAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default) { (action) in
            self.pdfListView?.document.resetForm()
            self.pdfListView?.setNeedsDisplayForVisiblePages()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: nil)
        let alert = UIAlertController(title: nil, message: String(format: NSLocalizedString("Do you really want to reset the form?", comment: "")), preferredStyle: .alert)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    open func pdfViewPerformPrint(_ pdfView: CPDFView!) {
        print("Print")
    }
    
    open func pdfViewEditingSelectStateDidChanged(_ pdfView: CPDFView) {
        
    }
    
    open func pdfViewShouldBeginEditing(_ pdfView: CPDFView, textView: UITextView, for annotation: CPDFFreeTextAnnotation) {
        
    }
    
    open func pdfViewEditingAddTextArea(_ pdfView: CPDFView, add page: CPDFPage, add rect: CGRect) {
        
    }
    
    open func pdfViewEditingAddImageArea(_ pdfView: CPDFView, add page: CPDFPage, add rect: CGRect) {
        
    }
    
    // MARK: - CPDFListViewDelegate
    
    open func PDFListViewPerformTouchEnded(_ pdfListView: CPDFListView) {
        
    }
    
    open func PDFListViewEditNote(_ pdfListView: CPDFListView, forAnnotation annotation: CPDFAnnotation) {
        
    }
    
    open func PDFListViewChangedAnnotationType(_ pdfListView: CPDFListView, forAnnotationMode annotationMode: Int) {
        
    }
    
    open func PDFListViewPerformAddStamp(_ pdfView: CPDFListView, atPoint point: CGPoint, forPage page: CPDFPage) {
        
    }
    
    open func PDFListViewPerformAddImage(_ pdfView: CPDFListView, atPoint point: CGPoint, forPage page: CPDFPage) {
        
    }
    
    open func PDFListViewerTouchEndedIsAudioRecordMedia(_ pdfListView: CPDFListView) -> Bool {
        return false
    }
    
    open func PDFListViewPerformCancelMedia(_ pdfView: CPDFListView, atPoint point: CGPoint, forPage page: CPDFPage) {
        
    }
    
    open func PDFListViewPerformRecordMedia(_ pdfView: CPDFListView, atPoint point: CGPoint, forPage page: CPDFPage) {
        
    }
    
    open func PDFListViewPerformPlay(_ pdfView: CPDFListView, forAnnotation annotation: CPDFSoundAnnotation) {
        
    }
    
    open func PDFListViewPerformSignatureWidget(_ pdfView: CPDFListView, forAnnotation annotation: CPDFSignatureWidgetAnnotation) {
        
    }
    
    open func PDFListViewEditProperties(_ pdfListView: CPDFListView, forAnnotation annotation: CPDFAnnotation) {
        
    }
    
    open func PDFListViewContentEditProperty(_ pdfListView: CPDFListView, point: CGPoint) {
        
    }
    
    // MARK: - CSearchToolbarDelegate
    
    open func searchToolbar(_ searchToolbar: CSearchToolbar, onSearchQueryResults results: [Any]) {
        if results.count < 1 {
            let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil)
            let alert = UIAlertController(title: nil, message: NSLocalizedString("Your search returned no results.", comment: ""), preferredStyle: .alert)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        if self.pdfListView?.document != nil {
            let searchResultController = CPDFSearchResultsViewController(resultArray: results, keyword: searchToolbar.searchKeyString, document: self.pdfListView!.document)
            searchResultController.pdfListView = self.pdfListView
            searchResultController.searchString = searchToolbar.searchKeyString
            searchResultController.delegate = self
            let nav = CNavigationController(rootViewController: searchResultController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
        
    }
    
    open func searchToolbarReplace(_ searchToolbar: CSearchToolbar) {
        buttonItemClicked_searchBack(nil)
        self.pdfListView?.setNeedsDisplayForVisiblePages()
    }
    
    open func searchToolbarTextChange(_ searchToolbar: CSearchToolbar) {
        self.hightSelection = nil
    }
    
    open func searchToolbarChangeSelection(_ searchToolbar: CSearchToolbar, changeSelection selection: CPDFSelection?) {
        if(selection != nil) {
            let offset = searchToolbar.frame.maxY

            let pageIndex = self.pdfListView?.document.index(for: selection!.page)
            
            self.pdfListView?.go(toPageIndex: Int(pageIndex ?? 0), animated: false)
            self.pdfListView?.go(to: selection!.bounds, on: selection!.page, offsetY: offset, animated: false)
        }
        self.pdfListView?.setHighlightedSelection(selection, animated: true)
        
        self.hightSelection = selection
        if self.searchToolbar?.searchTitleType == .replace {
            self.popSearchReplaceView?.updateSelection(selection)
        } else {
            self.popSearchReplaceView?.updateSelection(nil)
        }
    }
    
    // MARK: - CPDFDisplayViewDelegate
    func displayViewControllerDismiss(_ displayViewController: CPDFDisplayViewController) {
        self.navigationController?.dismiss(animated: true,completion: {
            
        })
    }
    
    // MARK: - CPDFBOTAViewControllerDelegate
    open func botaViewControllerDismiss(_ botaViewController: CPDFBOTAViewController) {
        self.navigationController?.dismiss(animated: true,completion: {
            
        })
    }
    
    // MARK: - CPDFSearchResultsDelegate
    func searchResultsView(_ resultVC: CPDFSearchResultsViewController, forSelection selection: CPDFSelection, indexPath: IndexPath) {
        if searchToolbar != nil {
            searchToolbarChangeSelection(searchToolbar!, changeSelection: selection)
        }
    }
    
    func searchResultsViewControllerDismiss(_ searchResultsViewController: CPDFSearchResultsViewController) {
        searchResultsViewController.dismiss(animated: true) {
            
        }
    }
    
    // MARK: - CPDFPopMenuDelegate
    open func menuDidClosed(in menu: CPDFPopMenu, isClosed: Bool) {
        
    }
    
    // MARK: - CPDFThumbnailViewControllerDelegate
    open func thumbnailViewController(_ thumbnailViewController: CPDFThumbnailViewController, pageIndex: Int) {
        thumbnailViewController.dismiss(animated: true) {
            self.pdfListView?.go(toPageIndex: pageIndex, animated: true)
        }
    }
    
    open func thumbnailViewControllerDismiss(_ thumbnailViewController: CPDFThumbnailViewController) {
        thumbnailViewController.dismiss(animated: true,completion: nil)
    }
    
    // MARK: - CPDFPopMenuViewDelegate
    public func menuDidClick(at view: CPDFPopMenuView, clickType viewType: CPDFPopMenuViewType) {
        switch viewType {
        case .setting:
            enterPDFSetting()
        case .pageEdit:
            enterPDFPageEdit()
        case .info:
            enterPDFInfo()
        case .share:
            enterPDFShare()
        case .addFile:
            enterPDFAddFile()
        case .save:
            enterPDFSave()
        case .watermark:
            enterPDFWatermark()
        case .security:
            enterPDFSecurity()
        case .flattened:
            enterPDFFlattened()
        }
    }
    
    func shareAction(url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityVC.definesPresentationContext = true
        if UI_USER_INTERFACE_IDIOM() == .pad {
            
            activityVC.popoverPresentationController?.sourceView = self.rightView
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: (self.rightView?.bounds.origin.x)! + ((self.rightView?.bounds.size.width)!)/3*2 + 10, y: self.rightView!.bounds.maxY, width: 1, height: 1)
        }
        self.present(activityVC, animated: true, completion: nil)
        activityVC.completionWithItemsHandler = { (activityType, completed, returnedItems, activityError) in
            if completed {
                print("Success!")
            } else {
                print("Failed Or Canceled!")
            }
        }
    }
    
    open func searchTitleViewChangeType(_ searchTitleView: CSearchTitleView, onChange searchType: Int) {
        var inset:UIEdgeInsets = self.pdfListView?.documentView().contentInset ?? UIEdgeInsets.zero

        if(self.searchToolbar?.superview != nil) {
            self.searchToolbar?.searchTitleType = CSearchTitleType(rawValue: searchType) ?? .search
        }
        inset.top = searchToolbar?.height ?? 0
        self.pdfListView?.documentView().contentInset = inset
        
        if searchToolbar != nil, hightSelection != nil {
            searchToolbarChangeSelection(searchToolbar!, changeSelection: hightSelection)
        } else if searchToolbar != nil, hightSelection == nil {
            if let text = searchToolbar?.searchBar.text, !text.isEmpty {
                searchToolbar?.searchButton.setTitleColor(CPDFColorUtils.CPageEditToolbarFontColor(), for: .normal)
                searchToolbar?.searchButton.isEnabled = true
            }
        }
    }
    
    // MARK: - UIDocumentPickerDelegate
    open func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let fileUrlAuthozied = urls.first?.startAccessingSecurityScopedResource() ?? false
        if fileUrlAuthozied {
            if self.pdfListView!.isEditing() == true {
                DispatchQueue.global(qos: .default).async {
                    if self.pdfListView!.isEdited() == true {
                        self.pdfListView!.commitEditing()
                    }
                    DispatchQueue.main.async {
                        self.pdfListView!.endOfEditing()
                        DispatchQueue.global(qos: .default).async {
                            if self.pdfListView!.document.isModified() {
                                self.pdfListView!.document.write(to: self.pdfListView!.document.documentURL)
                            }
                            DispatchQueue.main.async {
                                self.openFile(with: urls)
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.global(qos: .default).async {
                    if self.pdfListView!.document.isModified() == true {
                        self.pdfListView!.document.write(to: self.pdfListView!.document.documentURL)
                    }
                    DispatchQueue.main.async {
                        self.openFile(with: urls)
                    }
                }
            }
        }
    }
    
    open func openFile(with urls: [URL]) {
        let fileCoordinator = NSFileCoordinator()
        var error: NSError?
        fileCoordinator.coordinate(readingItemAt: urls.first!, options: [], error: &error) { newURL in
            let documentFolder = NSHomeDirectory().appending("/Documents/Files")
            if !FileManager.default.fileExists(atPath: documentFolder) {
                try? FileManager.default.createDirectory(at: URL(fileURLWithPath: documentFolder), withIntermediateDirectories: true, attributes: nil)
            }
            
            let documentPath = documentFolder + "/\(newURL.lastPathComponent)"
            if !FileManager.default.fileExists(atPath: documentPath) {
                try? FileManager.default.copyItem(atPath: newURL.path, toPath: documentPath)
            }
            
            let url = URL(fileURLWithPath: documentPath)
            let document = CPDFDocument(url: url)
            self.filePath = documentPath
            
            if document?.error != nil && document?.error._code != CPDFDocumentPasswordError {
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (action) in
                }
                let alert = UIAlertController(title: "", message: NSLocalizedString("Sorry PDF Reader Can't open this pdf file!", comment: ""), preferredStyle: .alert)
                alert.addAction(okAction)
                let tRootViewControl = self
                tRootViewControl.present(alert, animated: true, completion: nil)
            } else {
                if document?.isLocked == true {
                    let documentPasswordVC = CDocumentPasswordViewController(document: document!)
                    documentPasswordVC.delegate = self
                    documentPasswordVC.modalPresentationStyle = .fullScreen
                    let tRootViewControl = self
                    tRootViewControl.present(documentPasswordVC, animated: true, completion: nil)
                } else {
                    self.pdfListView?.updateActiveAnnotations([])
                    self.pdfListView?.document = document
                    self.pdfListView?.registerAsObserver()
                    self.selectDocumentRefresh()
                    self.setTitleRefresh()
                }
            }
        }
        urls.first?.stopAccessingSecurityScopedResource()
        
    }
    open func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    }
    
    // MARK: - CDocumentPasswordViewControllerDelegate
    open func documentPasswordViewControllerOpen(_ documentPasswordViewController: CDocumentPasswordViewController, document: CPDFDocument) {
        if(isEnterPDFSecurity) {
            if document.permissionsStatus == .owner {
                enterSecurePDF(filePath: document.documentURL.path, password: document.password)
            } else {
                enterPermissionPassword(pdfDocument: document)
            }
            isEnterPDFSecurity = false
        } else {
            self.pdfListView?.document = document;
            self.selectDocumentRefresh()
            self.setTitleRefresh()
        }
        
    }
    
    open func documentPasswordViewControllerCancel(_ documentPasswordViewController: CDocumentPasswordViewController) {
        isEnterPDFSecurity = false

        if self.pdfListView?.toolModel == .edit {
            self.pdfListView?.beginEditingLoadType([.text, .image])
            self.pdfListView?.setShouAddEdit([])
        }
    }
    
}

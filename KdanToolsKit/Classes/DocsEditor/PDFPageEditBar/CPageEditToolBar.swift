//
//  CPageEditToolBar.swift
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

public enum CPageEditToolBarType: Int {
    case insert = 0
    case replace
    case extract
    case copy
    case rotate
    case delete
}

public protocol CPageEditToolBarDelegate: AnyObject {
    
    func pageEditToolBarBlankPageInsert(_ pageEditToolBar: CPageEditToolBar, pageModel: CBlankPageModel)
    func pageEditToolBarPDFInsert(_ pageEditToolBar: CPageEditToolBar, pageModel: CBlankPageModel, document: CPDFDocument)
    func pageEditToolBarExtract(_ pageEditToolBar: CPageEditToolBar)
    func pageEditToolBarRotate(_ pageEditToolBar: CPageEditToolBar)
    func pageEditToolBarDelete(_ pageEditToolBar: CPageEditToolBar)
    func pageEditToolBarCopy(_ pageEditToolBar: CPageEditToolBar)
    func pageEditToolBarReplace(_ pageEditToolBar: CPageEditToolBar, document: CPDFDocument)
    
}

public class CPageEditToolBar: UIView, UIDocumentPickerDelegate, CPDFPageInsertViewControllerDelegate, CPDFPDFInsertViewControllerDelegate, CDocumentPasswordViewControllerDelegate {
    public weak var delegate: CPageEditToolBarDelegate?
    public var parentVC: UIViewController?
    public var pdfView: CPDFView?
    public var currentPageIndex: Int = 0
    public var isSelect: Bool = false
    public var pageEditBtns: [UIButton]?
    
    private var scrollView: UIScrollView?
    private var selectedIndex: Int = 0
    private var insertDocument: CPDFDocument?
    private var replaceDocument: CPDFDocument?
    private var loadingView: CActivityIndicatorView?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
        let line = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 1))
        line.backgroundColor = UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0)
        line.autoresizingMask = .flexibleWidth
        self.addSubview(line)
        
        self.selectedIndex = -1
        
        self.initSubview()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    }
    
    // MARK: - Public Methods
    
    func reloadData() {
        // Implementation
        if selectedIndex >= 0 && (selectedIndex < pageEditBtns?.count ?? 0) {
            var selectedButton = pageEditBtns?[selectedIndex]
            selectedButton?.backgroundColor = UIColor.clear
        }
        
        selectedIndex = -1
    }
    
    // MARK: - Private Methods
    
    func initSubview() {
        scrollView = UIScrollView(frame: self.bounds)
        scrollView?.showsVerticalScrollIndicator = false
        scrollView?.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView!)
        var offsetX: CGFloat = 20.0
        let buttonOffset: CGFloat = 25
        let buttonSize: CGFloat = 50
        let topOffset = (60 - buttonSize) / 2
        let images = ["CPageEditToolBarImageInsert", "CPageEditToolBarImageRepalce", "CPageEditToolBarImageExtract", "CPageEditToolBarImageCopy", "CPageEditToolBarImageRotate", "CPageEditToolBarImageRemove"]
        let names = [NSLocalizedString("Insert", comment: ""), NSLocalizedString("Replace", comment: ""), NSLocalizedString("Extract", comment: ""), NSLocalizedString("Copy", comment: ""), NSLocalizedString("Rotate", comment: ""), NSLocalizedString("Delete", comment: "")]
        var pageEditBtns = [UIButton]()
        for i in 0..<images.count {
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: offsetX, y: topOffset, width: buttonSize, height: buttonSize)
            button.setImage(UIImage(named: images[i], in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
            button.setTitle(names[i], for: .normal)
            button.setTitleColor(CPDFColorUtils.CPageEditToolbarFontColor(), for: .normal)
            button.layer.cornerRadius = 5.0
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
            button.tag = i
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 18, bottom: 24, right: 10)
            button.titleEdgeInsets = UIEdgeInsets(top: button.imageView?.frame.size.height ?? 0, left: -(button.imageView?.frame.size.width ?? 0) , bottom: -1, right: -11)
            
            button.addTarget(self, action: #selector(buttonItemClicked_switch(_:)), for: .touchUpInside)
            
            scrollView?.addSubview(button)
            pageEditBtns.append(button)
            if i != images.count - 1 {
                offsetX += button.bounds.size.width + buttonOffset
            } else {
                offsetX += button.bounds.size.width + 10
            }
            
        }
        self.pageEditBtns = pageEditBtns
        scrollView?.contentSize = CGSize(width: offsetX, height: scrollView?.bounds.size.height ?? 0)
        
    }
    
    func insertPage() {
        
        let tRootViewControl = parentVC
        
        let insertBlankPageAction = UIAlertAction(title: NSLocalizedString("Blank Page", comment: ""), style: .default) { [weak self] action in
            guard let self = self else { return }

            let pageInsertVC = CPDFPageInsertViewController()
            pageInsertVC.currentPageIndex = self.currentPageIndex
            pageInsertVC.currentPageCout = Int(self.pdfView?.document?.pageCount ?? 0)
            pageInsertVC.delegate = self
            if(tRootViewControl != nil) {
                let presentationController = AAPLCustomPresentationController(presentedViewController: pageInsertVC, presenting: tRootViewControl!)
                pageInsertVC.transitioningDelegate = presentationController
                tRootViewControl?.present(pageInsertVC, animated: true, completion: nil)
            }
        }
        
        let insertPdfPageAction = UIAlertAction(title: NSLocalizedString("From PDF", comment: ""), style: .default) { [weak self] action in
            self?.enterPDFAddFile()
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { [weak self] action in
            self?.reloadData()
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(insertBlankPageAction)
        alertController.addAction(insertPdfPageAction)
        alertController.addAction(cancelAction)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = self.pageEditBtns?.first
            alertController.popoverPresentationController?.sourceRect = self.pageEditBtns?.first?.bounds ?? CGRect.zero
        }
        
        tRootViewControl?.present(alertController, animated: true)
    }
    
    func enterPDFAddFile() {
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                let documentTypes = ["com.adobe.pdf"]
                let documentPickerViewController = UIDocumentPickerViewController(documentTypes: documentTypes, in: .open)
                documentPickerViewController.delegate = self
                guard let tRootViewControl = self.parentVC else { return }
                tRootViewControl.present(documentPickerViewController, animated: true, completion: nil)
            }
        }
    }
    
    func handleDocument() {
        if CPageEditToolBarType(rawValue: selectedIndex) == CPageEditToolBarType.insert {
            if(insertDocument != nil) {
                let pageInsertVC = CPDFPDFInsertViewController(document: insertDocument!)
                pageInsertVC.currentPageIndex = self.currentPageIndex
                pageInsertVC.currentPageCout = Int(self.pdfView?.document?.pageCount ?? 0)
                pageInsertVC.delegate = self
                guard let tRootViewControl = self.parentVC else { return }
                let presentationController = AAPLCustomPresentationController(presentedViewController: pageInsertVC, presenting: tRootViewControl)
                pageInsertVC.transitioningDelegate = presentationController
                tRootViewControl.present(pageInsertVC, animated: true, completion: nil)
            }
        } else if CPageEditToolBarType(rawValue: selectedIndex) == CPageEditToolBarType.replace {
            if(replaceDocument != nil) {
                delegate?.pageEditToolBarReplace(self, document: replaceDocument!)
            }
        }
    }
    
    func popoverWarning() {
        let OKAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) {
            action in
            // Handle OK action
        }
        let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("The page range is invalid or out of range. Please enter the valid page.", comment: ""), preferredStyle: .alert)
        alert.addAction(OKAction)
        guard let tRootViewControl = self.parentVC else { return }
        tRootViewControl.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Action
    
    @objc func buttonItemClicked_switch(_ button: UIButton) {
        if selectedIndex >= 0 && selectedIndex < (pageEditBtns?.count ?? 0) {
            let selectedButton = pageEditBtns![selectedIndex]
            selectedButton.backgroundColor = UIColor.clear
        }
        selectedIndex = button.tag
        switch button.tag {
        case CPageEditToolBarType.insert.rawValue:
            insertPage()
            break
        case CPageEditToolBarType.replace.rawValue:
            if isSelect {
                enterPDFAddFile()
            } else {
                popoverWarning()
            }
            break
        case CPageEditToolBarType.extract.rawValue:
            if isSelect {
                delegate?.pageEditToolBarExtract(self)
            } else {
                popoverWarning()
            }
            break
        case CPageEditToolBarType.rotate.rawValue:
            if isSelect {
                delegate?.pageEditToolBarRotate(self)
            } else {
                popoverWarning()
            }
            break
        case CPageEditToolBarType.copy.rawValue:
            if isSelect {
                delegate?.pageEditToolBarCopy(self)
            } else {
                popoverWarning()
            }
            break
        case CPageEditToolBarType.delete.rawValue:
            if isSelect {
                delegate?.pageEditToolBarDelete(self)
            } else {
                popoverWarning()
            }
            break
        default:
            break
        }
        
    }
    
    // MARK: - CPDFPageInsertViewControllerDelegate
    
    func pageInsertViewControllerSave(_ pageInsertViewController: CPDFPageInsertViewController, pageModel: CBlankPageModel) {
        delegate?.pageEditToolBarBlankPageInsert(self, pageModel: pageModel)
        reloadData()
    }
    
    func pageInsertViewControllerCancel(_ pageInsertViewController: CPDFPageInsertViewController) {
        reloadData()
    }
    
    // MARK: - CPDFPDFInsertViewControllerDelegate
    
    func pdfInsertViewControllerCancel(_ pageInsertViewController: CPDFPDFInsertViewController) {
        reloadData()
    }
    
    func pdfInsertViewControllerSave(_ pageInsertViewController: CPDFPDFInsertViewController, document: CPDFDocument, pageModel: CBlankPageModel) {
        insertDocument = document
        if(insertDocument != nil) {
            delegate?.pageEditToolBarPDFInsert(self, pageModel: pageModel, document: insertDocument!)
        }
    }
    
    // MARK: - UIDocumentPickerDelegate
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
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
                    guard let tRootViewControl = self.parentVC else { return }

                    tRootViewControl.present(alert, animated: true, completion: nil)

                } else {
                    if document.isLocked {
                        let documentPasswordVC = CDocumentPasswordViewController(document: document)
                        documentPasswordVC.delegate = self
                        documentPasswordVC.modalPresentationStyle = .fullScreen
                        guard let tRootViewControl = self.parentVC else { return }
                        tRootViewControl.present(documentPasswordVC, animated: true, completion: nil)
                    } else {
                        if CPageEditToolBarType(rawValue: selectedIndex) == .insert {
                            insertDocument = document
                        } else if CPageEditToolBarType(rawValue: selectedIndex) == .replace {
                            replaceDocument = document
                        }
                        
                        handleDocument()
                    }
                }
            }
            urls.first?.stopAccessingSecurityScopedResource()
        }
        
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        reloadData()
    }
    
    // MARK: - CDocumentPasswordViewControllerDelegate
    
    public func documentPasswordViewControllerCancel(_ documentPasswordViewController: CDocumentPasswordViewController) {
        reloadData()
    }
    
    public func documentPasswordViewControllerOpen(_ documentPasswordViewController: CDocumentPasswordViewController, document: CPDFDocument) {
        if CPageEditToolBarType(rawValue: selectedIndex) == .insert {
            insertDocument = document
        } else if CPageEditToolBarType(rawValue: selectedIndex) == .replace {
            replaceDocument = document
        }
        
        handleDocument()
        reloadData()
    }
    
}

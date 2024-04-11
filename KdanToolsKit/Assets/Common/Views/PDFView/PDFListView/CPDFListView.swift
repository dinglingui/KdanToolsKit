//
//  CPDFListView.swift
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

let CPDFListViewToolModeChangeNotification: NSNotification.Name = NSNotification.Name("CPDFListViewToolModeChangeNotification")

let CPDFListViewAnnotationModeChangeNotification: NSNotification.Name = NSNotification.Name("CPDFListViewAnnotationModeChangeNotification")

let CPDFListViewActiveAnnotationsChangeNotification: NSNotification.Name = NSNotification.Name("CPDFListViewActiveAnnotationsChangeNotification")

let CPDFListViewAnnotationsOperationChangeNotification: NSNotification.Name = NSNotification.Name("CPDFListViewAnnotationsOperationChangeNotification")

var CPDFAnnotationPropertiesObservationContext = "CPDFAnnotationPropertiesObservationContext"

public enum CToolModel: Int {
    case viewer = 0
    case edit
    case annotation
    case form
    case pageEdit
}

public enum CPDFViewAnnotationMode: Int {
    case CPDFViewAnnotationModenone = 0
    case note
    case highlight
    case underline
    case strikeout
    case squiggly
    case circle
    case square
    case arrow
    case line
    case ink
    case pencilDrawing // Available on iOS 13.0 and later
    case freeText
    case signature
    case stamp
    case image
    case link
    case sound
    
    case formModeText = 1000
    case formModeCheckBox
    case formModeRadioButton
    case formModeCombox
    case formModeList
    case formModeButton
    case formModeSign
}

public enum CPDFAnnotationDraggingType {
    case none
    case center
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    case start
    case end
}

@objc public protocol CPDFListViewDelegate: AnyObject {
    @objc optional func PDFListView(_ pdfListView: CPDFListView, customizeMenuItems menuItems: [UIMenuItem], forPage page: CPDFPage, forPagePoint pagePoint: CGPoint) -> [UIMenuItem]
    
    @objc optional func PDFListViewPerformTouchEnded(_ pdfListView: CPDFListView)
    
    @objc optional func PDFListViewChangedToolMode(_ pdfListView: CPDFListView, forToolMode toolMode: Int)
    
    @objc optional func PDFListViewChangedAnnotationType(_ pdfListView: CPDFListView, forAnnotationMode annotationMode: Int)
    
    @objc optional func PDFListViewChangeatioActiveAnnotations(_ pdfListView: CPDFListView, forActiveAnnotations annotations: [CPDFAnnotation])
    
    @objc optional func PDFListViewAnnotationsOperationChange(_ pdfListView: CPDFListView)
    
    @objc optional func PDFListViewEditNote(_ pdfListView: CPDFListView, forAnnotation annotation: CPDFAnnotation)
    
    @objc optional func PDFListViewEditProperties(_ pdfListView: CPDFListView, forAnnotation annotation: CPDFAnnotation)
    
    @objc optional func PDFListViewPerformPlay(_ pdfView: CPDFListView, forAnnotation annotation: CPDFSoundAnnotation)
    
    @objc optional func PDFListViewPerformCancelMedia(_ pdfView: CPDFListView, atPoint point: CGPoint, forPage page: CPDFPage)
    
    @objc optional func PDFListViewPerformRecordMedia(_ pdfView: CPDFListView, atPoint point: CGPoint, forPage page: CPDFPage)
    
    @objc optional func PDFListViewerTouchEndedIsAudioRecordMedia(_ pdfListView: CPDFListView) -> Bool
    
    @objc optional func PDFListViewPerformAddStamp(_ pdfView: CPDFListView, atPoint point: CGPoint, forPage page: CPDFPage)
    
    @objc optional func PDFListViewPerformAddImage(_ pdfView: CPDFListView, atPoint point: CGPoint, forPage page: CPDFPage)
    
    @objc optional func PDFListViewPerformSignatureWidget(_ pdfView: CPDFListView, forAnnotation annotation: CPDFSignatureWidgetAnnotation)
    
    @objc optional func PDFListViewContentEditProperty(_ pdfListView: CPDFListView, point: CGPoint)
}

public class CPDFListView: CPDFView, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    public weak var performDelegate: CPDFListViewDelegate?
    public var pageSliderView:CPDFSlider?
    public var currentToolModel:CToolModel = .viewer
    public var currentAnnotationMode:CPDFViewAnnotationMode = .CPDFViewAnnotationModenone
    public var undoPDFManager:UndoManager?
    public var activeAnnotations:[CPDFAnnotation]?
    public var pageIndicatorView:CPDFPageIndicatorView?
    public var parentVC: UIViewController?
    public var configuration: CPDFConfiguration?
    private var alert:UIAlertController?
    var copyItem: UIMenuItem?
    
    var menuPoint:CGPoint = CGPoint.zero
    
    var menuPage:CPDFPage?
    
    var mediaSelectionRect:CGRect = CGRect.zero
    var mediaSelectionPage:CPDFPage?
    
    var addAnnotationPoint:CGPoint = CGPoint.zero
    var addAnnotationRect:CGRect = CGRect.zero
    var addAnnotation: CPDFAnnotation?
    
    var draggingType:CPDFAnnotationDraggingType = .none
    
    var topLeftRect:CGRect = CGRect.zero
    var bottomLeftRect:CGRect = CGRect.zero
    var topRightRect:CGRect = CGRect.zero
    var bottomRightRect:CGRect = CGRect.zero
    
    var startPointRect:CGRect = CGRect.zero
    var endPointRect:CGRect = CGRect.zero
    var draggingPoint:CGPoint = CGPoint.zero
    var undoMove:Bool = false
    
    var notes:[CPDFAnnotation]?
    var undoGroupOldPropertiesPerNote:NSMapTable<AnyObject, AnyObject>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .lightGray
        CPDFListViewAnnotationConfig.initializeAnnotationConfig()
        
        self.commonInit()
        self.addNotification()
        self.registerAsObserver()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder:coder)
        self.backgroundColor = .lightGray
        CPDFListViewAnnotationConfig.initializeAnnotationConfig()
        
        self.commonInit()
        self.addNotification()
        self.registerAsObserver()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let inset:UIEdgeInsets = self.documentView().contentInset

        if #available(iOS 11.0, *) {
            pageSliderView?.frame = CGRect(x: self.bounds.size.width-22, y: self.safeAreaInsets.top, width: 22, height: self.bounds.size.height - safeAreaInsets.top - inset.bottom)
        } else {
            pageSliderView?.frame = CGRect(x: self.bounds.size.width-22, y: 0, width: 22, height: self.bounds.size.height - inset.bottom)
        }
    }
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    public func canUndo() -> Bool {
        return undoPDFManager?.canUndo == true
    }
    
    public func canRedo() -> Bool {
        return undoPDFManager?.canRedo == true
    }
    
    public func stopObservingNotes(oldNotes: [CPDFAnnotation]) {
        for note in oldNotes {
            let keys: Set<String> = note.keysForValuesToObserveForUndo()
            for key in keys {
                note.removeObserver(self, forKeyPath: key)
            }
        }
    }
    
    public func setAnnotationMode(_ annotationMode: CPDFViewAnnotationMode) {
        if annotationMode == .highlight ||
            annotationMode == .underline ||
            annotationMode == .strikeout ||
            annotationMode == .squiggly {
            textSelectionMode = true
        } else {
            textSelectionMode = false
        }
        
        if annotationMode == .link {
            scrollEnabled = false
            endDrawing()
        } else if annotationMode == .formModeText ||
                    annotationMode == .formModeCheckBox ||
                    annotationMode == .formModeRadioButton ||
                    annotationMode == .formModeCombox ||
                    annotationMode == .formModeList ||
                    annotationMode == .formModeButton ||
                    annotationMode == .formModeSign {
            let currentOffset = self.documentView().contentOffset
            scrollEnabled = false
            endDrawing()
            //Set scrolling to appear offset
            self.documentView().setContentOffset(currentOffset, animated: false)

        } else if annotationMode == .ink ||
                    annotationMode == .pencilDrawing {
            scrollEnabled = false
            beginDrawing()
        } else {
            if self.activeAnnotation != nil {
                scrollEnabled = false
            } else {
                scrollEnabled = true
            }
            endDrawing()
            becomeFirstResponder()
        }
        
        if annotationMode != .CPDFViewAnnotationModenone ||
            currentAnnotationMode != .CPDFViewAnnotationModenone {
            if self.activeAnnotations?.count ?? 0 > 0 {
                let page = activeAnnotation?.page
                self.updateActiveAnnotations([])
                setNeedsDisplayFor(page)
            }
        }
        
        currentAnnotationMode = annotationMode
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: CPDFListViewAnnotationModeChangeNotification, object: self)
            
            self.performDelegate?.PDFListViewChangedAnnotationType?(self, forAnnotationMode: self.annotationMode.rawValue)
        }
    }
    
    public var annotationMode: CPDFViewAnnotationMode {
        return currentAnnotationMode
    }
    
    public func setToolModel(_ toolModel: CToolModel) {
        if currentToolModel == .annotation &&
            currentToolModel != toolModel {
            self.stopRecord()
        }
        
        if currentToolModel != toolModel {
            currentToolModel = toolModel
            
            if self.activeAnnotations?.count ?? 0 > 0 {
                self.updateActiveAnnotations([])
                setNeedsDisplayForVisiblePages()
            }
            self.setAnnotationMode(.CPDFViewAnnotationModenone)
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: CPDFListViewToolModeChangeNotification, object: self)
                
                self.performDelegate?.PDFListViewChangedToolMode?(self, forToolMode: self.currentToolModel.rawValue)
            }
        }
    }
    
    public var toolModel: CToolModel {
        return currentToolModel
    }
    
    public var activeAnnotation: CPDFAnnotation? {
        return activeAnnotations?.first
    }
    
    private func commonInit() {
        pageSliderView = CPDFSlider(pdfView: self)
        if #available(iOS 11.0, *) {
            pageSliderView?.frame = CGRect(x: self.bounds.size.width-22, y: self.safeAreaInsets.top, width: 22, height: self.bounds.size.height - self.safeAreaInsets.top - self.safeAreaInsets.bottom)
        } else {
            pageSliderView?.frame = CGRect(x: self.bounds.size.width-22, y: 64, width: 22, height: self.bounds.size.height-114)
        }
        pageSliderView?.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
        addSubview(pageSliderView!)
        
        backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        
        pageIndicatorView = CPDFPageIndicatorView()
        
        pageIndicatorView?.touchCallBack = { [weak self] in
            guard let weakSelf = self else { return }
            
            let alertController = UIAlertController(title: NSLocalizedString("Enter a Page Number", comment: ""), message: nil, preferredStyle: .alert)
            weakSelf.alert = alertController
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in
                guard let pageTextField = alertController.textFields?.first else { return }
                var pageIndex = (Int(pageTextField.text ?? "") ?? 0) - 1
                
                if pageIndex > weakSelf.document.pageCount {
                    pageIndex = Int(weakSelf.document.pageCount - 1)
                } else if pageIndex < 0 {
                    pageIndex = Int(weakSelf.document.pageCount - 1)
                } else if pageTextField.text?.isEmpty ?? true {
                    pageIndex = Int(weakSelf.currentPageIndex - 1)
                }
                weakSelf.go(toPageIndex: pageIndex, animated: true)
            }))
            
            alertController.addTextField { textField in
                let str = String(format: "\( NSLocalizedString("Page", comment: ""))(1~%lu)", weakSelf.document.pageCount)
                textField.placeholder = NSLocalizedString(str, comment: "")
                textField.keyboardType = .numberPad
                textField.clearButtonMode = .whileEditing
                textField.keyboardType = .numberPad
            }
            
            let tRootViewControl = self?.parentVC
           
            tRootViewControl?.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Action
    @objc private func menuItemClick_CopyAction(_ sender: Any) {
        if self.document.allowsCopying == true {
            if currentSelection.string() != nil {
                UIPasteboard.general.string = self.currentSelection.string()
            }
            
            clearSelection()
        } else {
            enterPermissionPassword(pdfDocument: self.document)
        }
    }
    
    @objc func annotatonCopyActionClick(_ sender: UIMenuController) {
        self.enterPermissionPassword(pdfDocument: self.document)
    }
    
    private var textField: UITextField?
    
    func enterPermissionPassword(pdfDocument:CPDFDocument) {
        let alert = UIAlertController(title: NSLocalizedString("Enter Owner's Password to Change the Security", comment: ""), message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            let owerPasswordBtton = UIButton(type: .custom)
            owerPasswordBtton.addTarget(self, action: #selector(self.buttonItemClicked_showOwerPassword(_:)), for: .touchUpInside)
            owerPasswordBtton.setImage(UIImage(named: "CSecureImageInvisible", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
            owerPasswordBtton.setImage(UIImage(named: "CSecureImageVisible", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .selected)
            owerPasswordBtton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            
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
        self.parentVC?.present(alert, animated: true, completion: nil)
    }
    
    @objc func buttonItemClicked_showOwerPassword(_ button: UIButton) {
        if button.isSelected == true {
            button.isSelected = false
            textField?.isSecureTextEntry = true
        } else {
            button.isSelected = true
            textField?.isSecureTextEntry = false
            
        }
    }
    
    // MARK: - touch
    public override func touchBegan(at point: CGPoint, for page: CPDFPage) {
        if self.toolModel == .annotation {
            annotationTouchBegan(at: point, for: page)
        } else if self.toolModel == .form {
            formTouchBegan(at: point, for: page)
        } else if self.currentToolModel == .edit {
            
        } else {
            
        }
    }
    
    public override func touchMoved(at point: CGPoint, for page: CPDFPage) {
        if self.toolModel == .annotation {
            annotationTouchMoved(at: point, for: page)
        } else if self.toolModel == .form {
            formTouchMoved(at: point, for: page)
        } else if self.currentToolModel == .edit {
            
        } else {
            
        }
    }
    
    public override func touchEnded(at point: CGPoint, for page: CPDFPage) {
        if self.toolModel == .annotation {
            annotationTouchEnded(at: point, for: page)
        } else if self.toolModel == .form {
            formTouchEnded(at: point, for: page)
        } else if self.toolModel == .edit {
            // Handle edit tool model
        } else {
            var annotation = page.annotation(at: point)
            if annotation != nil && annotation?.isHidden() == true {
                annotation = nil
            }
            
            if(annotation != nil) {
                if(annotation is CPDFSignatureWidgetAnnotation) {
                    let signatureWidget:CPDFSignatureWidgetAnnotation = annotation as! CPDFSignatureWidgetAnnotation
                    self.performDelegate?.PDFListViewPerformSignatureWidget?(self, forAnnotation: signatureWidget)
                } else {
                    super.touchEnded(at: point, for: page)
                }
            } else {
                self.performDelegate?.PDFListViewPerformTouchEnded?(self)
            }
        }
    }
    
    public override func touchCancelled(at point: CGPoint, for page: CPDFPage!) {
        if self.toolModel == .annotation {
            annotationTouchCancelled(at: point, for: page)
        } else if self.toolModel == .form {
        } else if self.toolModel == .edit {
            // Handle edit tool model
        } else {
            
        }
    }
    
    public override func longPress(_ annotation: CPDFAnnotation!, at point: CGPoint, for page: CPDFPage!) {
        if toolModel == .viewer {
            
        } else {
            if (annotation != nil && !(self.activeAnnotations?.contains(annotation) ?? false)) {
                self.updateActiveAnnotations([annotation])
                setNeedsDisplayFor(page)
                self.updateScrollEnabled()
            }
        }
    }
    
    public override func longPressGestureShouldBegin(at point: CGPoint, for page: CPDFPage!) -> Bool {
       let annotation = page.annotation(at: point)

        if toolModel == .viewer &&  annotation != nil {
            return false
        } else {
           return true
        }
    }
    
    public override func menuItems(at point: CGPoint, for page: CPDFPage) -> [UIMenuItem] {
        var menuItems = [UIMenuItem]()
        
        if self.toolModel == .annotation {
            if self.document.allowsCopying == true {
                menuItems += annotationMenuItems(at: point, for: page)
            } else {
                let copyItem = UIMenuItem(title: NSLocalizedString("Copy", comment: ""), action: #selector(annotatonCopyActionClick(_:)))
                menuItems += annotationMenuItems(at: point, for: page)
                menuItems.remove(at: 0)
                menuItems.insert(copyItem, at: 0)
            }
        } else if self.toolModel == .form {
            if self.currentSelection != nil {
                let copyItem = UIMenuItem(title: NSLocalizedString("Copy", comment: ""), action: #selector(menuItemClick_CopyAction(_:)))
                menuItems.append(copyItem)
            }
        } else if self.toolModel == .edit {
            // Handle edit tool model
        } else {
            if self.currentSelection != nil {
                let copyItem = UIMenuItem(title: NSLocalizedString("Copy", comment: ""), action: #selector(menuItemClick_CopyAction(_:)))
                menuItems.append(copyItem)
            }
        }
        
        if let customizeMenuItems = self.performDelegate?.PDFListView?(self, customizeMenuItems: menuItems, forPage: page, forPagePoint: bounds.origin) {
            if customizeMenuItems.count > 0 {
                menuItems = customizeMenuItems
            } else {
                menuItems.removeAll()
            }
        }
        
        return menuItems
    }
    
    func addNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(documentChangedNotification(_:)), name: NSNotification.Name.CPDFViewDocumentChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(pageChangedNotification(_:)), name: NSNotification.Name.CPDFViewPageChanged, object: nil)
    }
    
    func showPageNumIndicator() {
        if self.pageIndicatorView?.superview == nil {
            self.pageIndicatorView?.show(in: self, position: .CPDFPageIndicatorViewPositionCenterBottom)
        }
        
        self.pageIndicatorView?.updatePageCount(Int(self.document.pageCount), currentPageIndex: self.currentPageIndex + 1)
        
    }
    
    var annotationUserName: String {
        var annotationUserName: String? = CPDFKitConfig.sharedInstance().annotationAuthor()
        if annotationUserName == nil || annotationUserName?.count ?? 0 <= 0 {
            annotationUserName = UIDevice.current.name
        }
        return annotationUserName ?? ""
    }
    
    public func updateActiveAnnotations(_ activeAnnotations: [CPDFAnnotation]?) {
        if activeAnnotations != nil {
            self.activeAnnotations = activeAnnotations
            NotificationCenter.default.post(name: CPDFListViewActiveAnnotationsChangeNotification, object: self)
            
            self.performDelegate?.PDFListViewChangeatioActiveAnnotations?(self, forActiveAnnotations: self.activeAnnotations ?? [])
            
        } else if activeAnnotations == nil && self.activeAnnotations?.count ?? 0 > 0 {
            for annotation in self.activeAnnotations! {
                if annotation is CPDFLinkAnnotation {
                    let link:CPDFLinkAnnotation = annotation as! CPDFLinkAnnotation
                    let nsstr = link.url()
                    let destination = link.destination()
                    if !(destination != nil || (nsstr != nil && nsstr?.count ?? 0 > 0)) {
                        link.page?.removeAnnotation(link)
                    }
                }
            }
            self.activeAnnotations?.removeAll()
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: CPDFListViewActiveAnnotationsChangeNotification, object: self)
                
                self.performDelegate?.PDFListViewChangeatioActiveAnnotations?(self, forActiveAnnotations: self.activeAnnotations ?? [])
                
            }
        }
    }
    
    public func addAnnotation(_ annotation: CPDFAnnotation?, for page: CPDFPage?) {
        if (annotation == nil || page == nil) {
            return
        }
        
        annotation?.setModificationDate(Date())
        annotation?.setUserName(self.annotationUserName)
        page?.addAnnotation(annotation!)
        
        self.updateActiveAnnotations([annotation!])
        setNeedsDisplayFor(page)
        self.updateScrollEnabled()
        
        self.showMenuForAnnotation(annotation!)
    }
    
    private func addAnnotation(_ annotation: CPDFAnnotation) {
        let page = self.document.page(at: UInt(self.currentPageIndex))
        let center = self.convert(self.center, to: page)
        if center == .zero {
            return
        }
        
        var bounds = annotation.bounds
        bounds.origin.x = center.x - bounds.size.width / 2.0
        bounds.origin.y = center.y - bounds.size.height / 2.0
        bounds.origin.y = min(max(0, bounds.origin.y), (page?.bounds.size.height ?? 0) - bounds.size.height)
        annotation.bounds = bounds
        
        addAnnotation(annotation, for: page ?? CPDFPage())
    }
    
    public func stopRecord() {
        let page = self.mediaSelectionPage
        if page != nil {
            self.mediaSelectionPage = nil
            setNeedsDisplayFor(page)
        }
    }
    
    func stopObserving() {
        if(notes != nil) {
            stopObservingNotes(oldNotes: notes!)
        }
    }
    
    // MARK: - NotificationCenter
    @objc private func documentChangedNotification(_ notification: Notification) {
        guard let pdfView = notification.object as? CPDFView, pdfView.document == self.document else {
            return
        }
        
        showPageNumIndicator()
        pageSliderView?.reloadData()
    }
    
    @objc private func pageChangedNotification(_ notification: Notification) {
        guard let pdfView = notification.object as? CPDFView, pdfView.document == self.document else {
            return
        }
        
        showPageNumIndicator()
        pageSliderView?.reloadData()
    }
    
    // MARK: - Rendering
    public override func draw(_ page: CPDFPage!, to context: CGContext!) {
        if self.toolModel == .annotation {
            annotationDrawPage(page, to: context)
        } else if self.toolModel == .form {
            formDrawPage(page, to: context)
        } else if self.toolModel == .edit {
            // Handle edit tool model
        } else {
            
        }
    }
    
}

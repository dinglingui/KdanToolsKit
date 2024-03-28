//
//  CPDFAnnotationToolBar.swift
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

public enum CPDFAnnotationToolbarType: Int {
    case none = 0
    case note
    case highlight
    case underline
    case strikeout
    case squiggly
    case shapeCircle
    case shapeRectangle
    case shapeArrow
    case shapeLine
    case freehand
    case pencilDrawing
    case freeText
    case signature
    case stamp
    case image
    case link
    case sound
}

public enum CPDFAnnotationPropertieType: Int {
    case setting = 0
    case undo
    case redo
}

@objc public protocol CPDFAnnotationBarDelegate: AnyObject {
    @objc optional func annotationBarClick(_ annotationBar: CPDFAnnotationToolBar, clickAnnotationMode annotationMode: Int, forSelected isSelected: Bool, forButton button: UIButton)
}

public class CPDFAnnotationToolBar: UIView,UINavigationControllerDelegate, UIImagePickerControllerDelegate, CPDFSignatureViewControllerDelegate, CPDFSignatureEditViewControllerDelegate, CPDFNoteViewControllerDelegate, CPDFShapeCircleViewControllerDelegate, CPDFHighlightViewControllerDelegate, CPDFUnderlineViewControllerDelegate, CPDFStrikeoutViewControllerDelegate, CPDFSquigglyViewControllerDelegate, CPDFInkTopToolBarDelegate, CPDFInkViewControllerDelegate, CPDFShapeArrowViewControllerDelegate, CPDFStampViewControllerDelegate,CPDFLinkViewControllerDelegate, CPDFFreeTextViewControllerDelegate,CPDFDrawPencilViewDelegate,AAPLCustomPresentationControllerDelegate {
    public var shapeStyle: NSInteger = 0
    public weak var delegate: CPDFAnnotationBarDelegate?
    public var parentVC: UIViewController?
    public var pdfListView: CPDFListView?
    public var topToolBar: CPDFInkTopToolBar?
    public var drawPencilFuncView: CPDFDrawPencilKitFuncView?
    
    private var scrollView: UIScrollView?
    private var annotationBtns: [UIButton] = []
    private var selectedIndex: Int = 0
    private var propertiesBar: UIView?
    private var propertiesBtn: UIButton?
    private var undoBtn: UIButton?
    private var redoBtn: UIButton?
    private var annotManage: CAnnotationManage?
    private var signatureVC: CPDFSignatureViewController?
    private var menuPoint: CGPoint = CGPoint.zero
    private var menuPage: CPDFPage?
    private var isAddAnnotation: Bool = false
    private var signatureAnnotation: CPDFSignatureWidgetAnnotation?
    private var linkVC: CPDFLinkViewController?
    
    // MARK: - Initializers
    
    public init(annotationManage: CAnnotationManage) {
        // Initialize properties and setup views
        super.init(frame: CGRect.zero)
        
        self.annotManage = annotationManage
        
        self.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
        
        let line = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 1))
        line.backgroundColor = UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0)
        line.autoresizingMask = .flexibleWidth
        self.addSubview(line)
        
        self.selectedIndex = 0
        
        self.pdfListView = annotationManage.pdfListView
        
        self.initSubview()
        
        NotificationCenter.default.addObserver(self, selector: #selector(annotationChangedNotification(_:)), name: NSNotification.Name(CPDFListViewActiveAnnotationsChangeNotification.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(annotationsOperationChangeNotification(_:)), name: NSNotification.Name(CPDFListViewAnnotationsOperationChangeNotification.rawValue), object: nil)
        
        NotificationCenter.default.post(name: NSNotification.Name(CPDFListViewAnnotationsOperationChangeNotification.rawValue), object: annotationManage.pdfListView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        scrollView?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width - (propertiesBar?.frame.size.width ?? 0), height: self.frame.size.height)
        if #available(iOS 11.0, *) {
            topToolBar?.frame = CGRect(x: (pdfListView?.frame.size.width ?? 0) - 30 - (topToolBar?.frame.size.width ?? 0), y: (window?.safeAreaInsets.top ?? 0), width: (topToolBar?.frame.size.width ?? 0), height: 50)
        } else {
            topToolBar?.frame = CGRect(x: (pdfListView?.frame.size.width ?? 0) - 30 - (topToolBar?.frame.size.width ?? 0), y: 64, width: (topToolBar?.frame.size.width ?? 0), height: 50)
        }
        
        if #available(iOS 11.0, *) {
            self.drawPencilFuncView?.frame =  CGRect(x: (self.pdfListView?.frame.size.width ?? 0) - 30 - (self.drawPencilFuncView?.frame.size.width ?? 0), y: self.window?.safeAreaInsets.top ?? 0, width: self.drawPencilFuncView?.frame.size.width ?? 0, height:  self.drawPencilFuncView?.frame.size.height ?? 0)
        } else {
            self.drawPencilFuncView?.frame =  CGRect(x: (self.pdfListView?.frame.size.width ?? 0) - 30 - (self.drawPencilFuncView?.frame.size.width ?? 0), y: 0, width: self.drawPencilFuncView?.frame.size.width ?? 0, height:  self.drawPencilFuncView?.frame.size.height ?? 0)
        }

        
    }
    
    // MARK: - Public Methods
    
    public func reloadData() {
        if pdfListView?.annotationMode == .CPDFViewAnnotationModenone {
            if selectedIndex > 0 {
                for i in 0..<annotationBtns.count {
                    if let button = annotationBtns[i] as? CPDFAnnotationBarButton, button.tag == selectedIndex {
                        button.backgroundColor = UIColor.clear
                        selectedIndex = 0
                        break
                    }
                }
            }
        } else {
            for i in 0..<annotationBtns.count {
                let button = annotationBtns[i]
                if  CPDFViewAnnotationMode(rawValue: button.tag) == pdfListView?.annotationMode {
                    button.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
                    selectedIndex = button.tag
                } else {
                    button.backgroundColor = UIColor.clear
                }
            }
        }
    }
    
    
    public func updatePropertiesButtonState() {
        // Update properties button state
        if self.pdfListView?.annotationMode != .CPDFViewAnnotationModenone {
            let annotation = annotManage?.pdfListView?.activeAnnotations?.first
            if annotation is CPDFStampAnnotation ||
               annotation is CPDFSignatureAnnotation ||
               annotation is CPDFSoundAnnotation ||
               annotation is CPDFLinkAnnotation ||
               .sound == CPDFViewAnnotationMode(rawValue: self.selectedIndex) || .link == CPDFViewAnnotationMode(rawValue: self.selectedIndex) {
              propertiesBtn?.isEnabled = false
            } else {
              propertiesBtn?.isEnabled = true
            }
        } else {
            propertiesBtn?.isEnabled = false
        }
        
    }
    
    public func updateUndoRedoState() {
        // Update undo/redo state
        undoBtn?.isEnabled = false
        redoBtn?.isEnabled = false
        pdfListView?.registerAsObserver()
    }
    
    public func buttonItemClicked_openAnnotation(_ button: UIButton?) {
        let activeAnnotations = pdfListView?.activeAnnotations
        if(activeAnnotations != nil && activeAnnotations?.count ?? 0 > 0) {
            annotManage?.setAnnotStyle(from: activeAnnotations!)
            buttonItemClicked_open(button)
        }
    }
    
    @objc public func buttonItemClicked_openModel(_ button: UIButton) {
        // Handle open model button click
        annotManage?.setAnnotStyle(from: pdfListView?.annotationMode ?? .CPDFViewAnnotationModenone)
        buttonItemClicked_open(button)
    }
    
    public func openSignatureAnnotation(_ signatureAnnotation: CPDFSignatureWidgetAnnotation) {
        // Open signature annotation
        self.signatureAnnotation = signatureAnnotation
        let annotStyle = self.annotManage?.annotStyle
        self.signatureVC = CPDFSignatureViewController(style: annotStyle)
        self.signatureVC?.delegate = self
        if(signatureVC != nil && parentVC != nil) {
            let presentationController = AAPLCustomPresentationController(presentedViewController: signatureVC!, presenting: parentVC!)
            
            self.signatureVC?.transitioningDelegate = presentationController
            parentVC?.present(signatureVC!, animated: true, completion: nil)
        }
    }
    
    public func addStampAnnotation(withPage page: CPDFPage, point: CGPoint) {
        // Add stamp annotation
        self.isAddAnnotation = true
        self.menuPage = page
        self.menuPoint = point
        let stampVC = CPDFStampViewController.init(nibName: nil, bundle: nil)
        guard let parentVC = parentVC else {
            return
        }
        let presentationController = AAPLCustomPresentationController(presentedViewController: stampVC, presenting: parentVC)
        presentationController.tapDelegate = self
        stampVC.delegate = self
        stampVC.transitioningDelegate = presentationController
        parentVC.present(stampVC, animated: true, completion: nil)
    }
    
    public func addImageAnnotation(withPage page: CPDFPage, point: CGPoint) {
        // Add image annotation
        isAddAnnotation = true
        menuPage = page
        menuPoint = point
        createImageAnnotation()
    }
    
    // MARK: - Private Methods
    
    func initSubview() {
        scrollView = UIScrollView(frame: bounds)
        scrollView?.showsVerticalScrollIndicator = false
        scrollView?.showsHorizontalScrollIndicator = false
        if(scrollView != nil) {
            addSubview(scrollView!)
        }
        var offsetX: CGFloat = 10.0
        let buttonOffset: CGFloat = 25
        let buttonSize: CGFloat = 30
        
        let topOffset: CGFloat = (44 - buttonSize)/2
        
        let annotationTypes = self.pdfListView?.configuration?.annotationsTypes ?? []
        
        var images: [String] = []
        var types: [CPDFViewAnnotationMode] = []
        
        for annotationType in annotationTypes {
            switch annotationType {
            case .note:
                images.append("CPDFAnnotationBarImageNote")
                types.append(.note)
            case .highlight:
                images.append("CPDFAnnotationBarImageHighLight")
                types.append(.highlight)
            case .underline:
                images.append("CPDFAnnotationBarImageUnderline")
                types.append(.underline)
            case .strikeout:
                images.append("CPDFAnnotationBarImageStrikeout")
                types.append(.strikeout)
            case .squiggly:
                images.append("CPDFAnnotationBarImageSquiggly")
                types.append(.squiggly)
            case .shapeCircle:
                images.append("CPDFAnnotationBarImageShapeCircle")
                types.append(.circle)
            case .shapeRectangle:
                images.append("CPDFAnnotationBarImageShapeRectangle")
                types.append(.square)
            case .shapeArrow:
                images.append("CPDFAnnotationBarImageShapeArrow")
                types.append(.arrow)
            case .shapeLine:
                images.append("CPDFAnnotationBarImageShapeLine")
                types.append(.line)
            case .freehand:
                images.append("CPDFAnnotationBarImageFreehand")
                types.append(.ink)
            case .pencilDrawing:
                images.append("CPDFAnnotationBarImagePencilDraw")
                types.append(.pencilDrawing)
            case .freeText:
                images.append("CPDFAnnotationBarImageFreeText")
                types.append(.freeText)
            case .signature:
                images.append("CPDFAnnotationBarImageSignature")
                types.append(.signature)
            case .stamp:
                images.append("CPDFAnnotationBarImageStamp")
                types.append(.stamp)
            case .image:
                images.append("CPDFAnnotationBarImageImage")
                types.append(.image)
            case .link:
                images.append("CPDFAnnotationBarImageLink")
                types.append(.link)
            case .sound:
                images.append("CPDFAnnotationBarImageSound")
                types.append(.sound)
            default:
                break
            }
        }
        

        if #available(iOS 13.0, *) {
        } else {
            images.removeAll(where: { $0 == "CPDFAnnotationBarImagePencilDraw" })
            types.removeAll(where: { $0 == .pencilDrawing })
        }
        
        var annotationBtns: [CPDFAnnotationBarButton] = []
        for i in 0..<types.count {
            let annotationMode = types[i]
            let button = CPDFAnnotationBarButton(frame: CGRect.zero)
            button.frame = CGRect(x: offsetX, y: topOffset, width: buttonSize, height: buttonSize)
            button.setImage(UIImage(named: images[i], in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
            button.layer.cornerRadius = 5.0
            button.tag = annotationMode.rawValue
            if annotationMode == .highlight {
                button.lineColor = CAnnotationManage.highlightAnnotationColor()
            } else if annotationMode == .underline {
                button.lineColor = CAnnotationManage.underlineAnnotationColor()
            } else if annotationMode == .strikeout {
                button.lineColor = CAnnotationManage.strikeoutAnnotationColor()
            } else if annotationMode == .squiggly {
                button.lineColor = CAnnotationManage.squigglyAnnotationColor()
            } else if annotationMode == .ink {
                button.lineColor = CAnnotationManage.freehandAnnotationColor()
            }
            button.addTarget(self, action: #selector(buttonItemClicked_Switch(_:)), for: .touchUpInside)
            scrollView?.addSubview(button)
            annotationBtns.append(button)
            if i != types.count - 1 {
                offsetX += (button.bounds.size.width) + buttonOffset
            } else {
                offsetX += (button.bounds.size.width) + 10
            }
        }
        self.annotationBtns = annotationBtns
        
        scrollView?.contentSize = CGSize(width: offsetX, height: scrollView?.bounds.size.height ?? 0)
        
        let annotationsTools = self.pdfListView?.configuration?.annotationsTools ?? []
        
        if annotationsTools.count > 0 {
            
            var offset: CGFloat = 10
            
            let prWidth = buttonSize * CGFloat(annotationsTools.count) + offset
            propertiesBar = UIView(frame: CGRect(x: bounds.size.width - prWidth, y: 0, width: prWidth, height: 44))
            propertiesBar?.autoresizingMask = .flexibleLeftMargin
            if(propertiesBar != nil) {
                addSubview(propertiesBar!)
            }
            
            let lineView = UIView(frame: CGRect(x: offset, y: 12, width: 1, height: 20))
            if #available(iOS 13.0, *) {
                if UITraitCollection.current.userInterfaceStyle == .dark {
                    lineView.backgroundColor = UIColor.white
                } else {
                    lineView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
                }
            } else {
                lineView.backgroundColor = UIColor.black
            }
            propertiesBar?.addSubview(lineView)
            offset += lineView.frame.size.width
            
            for annotationsTool in annotationsTools {
                switch annotationsTool {
                case .setting:
                    propertiesBtn = UIButton(frame: CGRect(x: offset, y: topOffset, width: buttonSize, height: buttonSize))
                    propertiesBtn?.setImage(UIImage(named: "CPDFAnnotationBarImageProperties", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
                    propertiesBtn?.addTarget(self, action: #selector(buttonItemClicked_openModel(_:)), for: .touchUpInside)
                    if propertiesBtn != nil {
                        propertiesBar?.addSubview(propertiesBtn!)
                    }
                    offset += propertiesBtn?.frame.size.width ?? 0
                case .undo:
                    undoBtn = UIButton(frame: CGRect(x: offset, y: topOffset, width: buttonSize, height: buttonSize))
                    undoBtn?.setImage(UIImage(named: "CPDFAnnotationBarImageUndo", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
                    undoBtn?.addTarget(self, action: #selector(buttonItemClicked_undo(_:)), for: .touchUpInside)
                    if undoBtn != nil {
                        propertiesBar?.addSubview(undoBtn!)
                    }
                    offset += undoBtn?.frame.size.width ?? 0
                case .redo:
                    redoBtn = UIButton(frame: CGRect(x: offset, y: topOffset, width: buttonSize, height: buttonSize))
                    redoBtn?.setImage(UIImage(named: "CPDFAnnotationBarImageRedo", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
                    redoBtn?.addTarget(self, action: #selector(buttonItemClicked_redo(_:)), for: .touchUpInside)
                    if redoBtn != nil {
                        propertiesBar?.addSubview(redoBtn!)
                    }
                    offset += redoBtn?.frame.size.width ?? 0
                }
            }
            
            updatePropertiesButtonState()
        }
        
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_Switch(_ button: UIButton) {
        if .sound == CPDFViewAnnotationMode(rawValue: self.selectedIndex) {
            self.pdfListView?.stopRecord()
        }
        self.selectedIndex = button.tag
        var isSelect = true
        if self.pdfListView?.annotationMode != CPDFViewAnnotationMode(rawValue: self.selectedIndex) {
            self.propertiesBtn?.isEnabled = true
            button.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
            if .ink == CPDFViewAnnotationMode(rawValue: self.selectedIndex) {
                CPDFKitConfig.sharedInstance()?.setEnableFreehandPencilKit(false)
            } else if .pencilDrawing == CPDFViewAnnotationMode(rawValue: self.selectedIndex) {
                CPDFKitConfig.sharedInstance()?.setEnableFreehandPencilKit(true)
            }
            self.pdfListView?.setAnnotationMode(CPDFViewAnnotationMode(rawValue: self.selectedIndex) ?? CPDFViewAnnotationMode.CPDFViewAnnotationModenone)
            isSelect = true
        } else {
            self.propertiesBtn?.isEnabled = false
            if .sound == CPDFViewAnnotationMode(rawValue: self.selectedIndex) {
                self.pdfListView?.stopRecord()
            } else if .freeText == CPDFViewAnnotationMode(rawValue: self.selectedIndex) {
                self.pdfListView?.commitEditAnnotationFreeText()
            }
            
            self.pdfListView?.setAnnotationMode(.CPDFViewAnnotationModenone)
            self.selectedIndex = 0
            button.backgroundColor = UIColor.clear
            isSelect = false
        }
        updatePropertiesButtonState()
        createPropertyViewController()
        delegate?.annotationBarClick?(self, clickAnnotationMode: CPDFViewAnnotationMode(rawValue: button.tag)?.rawValue ?? 0, forSelected: isSelect, forButton: button)
    }
    
    public func buttonItemClicked_open(_ button: UIButton?) {
        guard let annotStytle = annotManage?.annotStyle else {
            return
        }
        
        if parentVC == nil {
            return
        }
        
        switch annotStytle.annotMode {
        case .note:
            let noteVC = CPDFNoteViewController(style: annotStytle)
            noteVC.delegate = self
            let presentationController = AAPLCustomPresentationController(presentedViewController: noteVC, presenting: self.parentVC!)
            noteVC.transitioningDelegate = presentationController  
            self.parentVC!.present(noteVC, animated: true, completion: nil)
            
        case .highlight:
            let highlightVC = CPDFHighlightViewController(annotStyle: annotStytle)
            highlightVC.delegate = self
            let presentationController = AAPLCustomPresentationController(presentedViewController: highlightVC, presenting: self.parentVC!)
            highlightVC.transitioningDelegate = presentationController   
            self.parentVC!.present(highlightVC, animated: true, completion: nil)
            
        case .underline:
            let underlineVC = CPDFUnderlineViewController(annotStyle: annotStytle)
            underlineVC.delegate = self
            if self.parentVC != nil {
                let presentationController = AAPLCustomPresentationController(presentedViewController: underlineVC, presenting: self.parentVC!)
                underlineVC.transitioningDelegate = presentationController
                self.parentVC!.present(underlineVC, animated: true, completion: nil)
            }
            
        case .strikeout:
            let strikeoutVC = CPDFStrikeoutViewController(annotStyle: annotStytle)
            strikeoutVC.delegate = self
            if self.parentVC != nil {
                let presentationController = AAPLCustomPresentationController(presentedViewController: strikeoutVC, presenting: self.parentVC!)
                strikeoutVC.transitioningDelegate = presentationController
                self.parentVC!.present(strikeoutVC, animated: true, completion: nil)
            }
            
        case .squiggly:
            let squigglyVC = CPDFSquigglyViewController(annotStyle: annotStytle)
            squigglyVC.delegate = self
            if self.parentVC != nil {
                let presentationController = AAPLCustomPresentationController(presentedViewController: squigglyVC, presenting: self.parentVC!)
                squigglyVC.transitioningDelegate = presentationController
                self.parentVC!.present(squigglyVC, animated: true, completion: nil)
            }
            
        case .ink:
            let inkVC = CPDFInkViewController(annotStyle: annotStytle)
            inkVC.delegate = self
            if self.parentVC != nil {
                let presentationController = AAPLCustomPresentationController(presentedViewController: inkVC, presenting: self.parentVC!)
                inkVC.transitioningDelegate = presentationController
                self.parentVC!.present(inkVC, animated: true, completion: nil)
            }
        case .circle:
            let circleVC = CPDFShapeCircleViewController(annotStyle: annotStytle)
            circleVC.delegate = self
            if self.parentVC != nil {
                let presentationController = AAPLCustomPresentationController(presentedViewController: circleVC, presenting: self.parentVC!)
                circleVC.transitioningDelegate = presentationController
                self.parentVC!.present(circleVC, animated: true, completion: nil)
            }
        case .square:
            let squareVC = CPDFShapeCircleViewController(annotStyle: annotStytle)
            squareVC.delegate = self
            if self.parentVC != nil {
                let presentationController = AAPLCustomPresentationController(presentedViewController: squareVC, presenting: self.parentVC!)
                squareVC.transitioningDelegate = presentationController
                self.parentVC!.present(squareVC, animated: true, completion: nil)
            }
            
        case .arrow:
            let arrowVC = CPDFShapeArrowViewController(annotStyle: annotStytle)
            arrowVC.lineDelegate = self
            if self.parentVC != nil {
                let presentationController = AAPLCustomPresentationController(presentedViewController: arrowVC, presenting: self.parentVC!)
                arrowVC.transitioningDelegate = presentationController
                self.parentVC!.present(arrowVC, animated: true, completion: nil)
            }
        case .line:
            let lineVC = CPDFShapeArrowViewController(annotStyle: annotStytle)
            lineVC.lineDelegate = self
            if self.parentVC != nil {
                let presentationController = AAPLCustomPresentationController(presentedViewController: lineVC, presenting: self.parentVC!)
                lineVC.transitioningDelegate = presentationController
                self.parentVC!.present(lineVC, animated: true, completion: nil)
            }
        case .freeText:
            let freeTextVC = CPDFFreeTextViewController(annotStyle: annotStytle)
            freeTextVC.delegate = self
            let pdfListView = self.annotManage?.pdfListView
            
            if self.parentVC != nil && pdfListView != nil {
                
                let presentationController = AAPLCustomPresentationController(presentedViewController: freeTextVC, presenting: self.parentVC!)
                freeTextVC.pdfListView = pdfListView!
                freeTextVC.transitioningDelegate = presentationController
                self.parentVC!.present(freeTextVC, animated: true, completion: nil)
            }
        case .link:
            self.linkVC = CPDFLinkViewController(annotStyle: annotStytle)
            self.linkVC?.pageCount = Int(self.annotManage?.pdfListView?.document.pageCount ?? 0)
            self.linkVC?.delegate = self
            if self.parentVC != nil && self.linkVC != nil {
                
                let presentationController = AAPLCustomPresentationController(presentedViewController: self.linkVC!, presenting: self.parentVC!)
                presentationController.tapDelegate = self
                self.linkVC!.transitioningDelegate = presentationController
                self.parentVC!.present(self.linkVC!, animated: true, completion: nil)
            }
        default:
            break
        }
        
    }
    
    @objc func buttonItemClicked_undo(_ button: UIButton) {
        if self.annotManage?.pdfListView?.undoPDFManager != nil && ((self.annotManage?.pdfListView?.canUndo()) == true) {
            self.annotManage?.pdfListView?.undoPDFManager?.undo()
        }
    }
    
    @objc func buttonItemClicked_redo(_ button: UIButton) {
        if self.annotManage?.pdfListView?.undoPDFManager != nil && (self.annotManage?.pdfListView?.canRedo()) == true {
            self.annotManage?.pdfListView?.undoPDFManager?.redo()
        }
    }
    
    // MARK: - Private Methods
    
    func createPropertyViewController() {
        if .ink == CPDFViewAnnotationMode(rawValue: self.selectedIndex) {
            self.annotManage?.setAnnotStyle(from: self.pdfListView?.annotationMode ?? .CPDFViewAnnotationModenone)
            self.propertiesBtn?.isEnabled = false
            
            if #available(iOS 11.0, *) {
                self.topToolBar = CPDFInkTopToolBar(frame: CGRect(x: (self.pdfListView?.frame.size.width ?? 0) - 30 - 300, y: self.window?.safeAreaInsets.top ?? 0, width: 300, height: 50))
                self.topToolBar?.delegate = self
                if(self.topToolBar != nil) {
                    self.pdfListView?.addSubview(self.topToolBar!)
                }
            } else {
                self.topToolBar = CPDFInkTopToolBar(frame: CGRect(x: (self.pdfListView?.frame.size.width ?? 0)-30-300, y: 64, width: 300, height: 50))
                self.topToolBar?.delegate = self
                if(self.topToolBar != nil) {
                    self.pdfListView?.addSubview(self.topToolBar!)
                }
            }
        } else if .signature == CPDFViewAnnotationMode(rawValue: self.selectedIndex) {
            self.propertiesBtn?.isEnabled = false
            let annotStytle = self.annotManage?.annotStyle
            self.signatureVC = CPDFSignatureViewController(style: annotStytle)
            if self.parentVC != nil  && self.signatureVC != nil {
                let presentationController = AAPLCustomPresentationController(presentedViewController: self.signatureVC!, presenting: self.parentVC!)
                presentationController.tapDelegate = self
                self.signatureVC?.delegate = self
                self.signatureVC?.transitioningDelegate = presentationController
                parentVC!.present(self.signatureVC!, animated: true, completion: nil)
            }
        } else if .stamp == CPDFViewAnnotationMode(rawValue: self.selectedIndex) {
            self.propertiesBtn?.isEnabled = false
            let stampVC = CPDFStampViewController(nibName: nil, bundle: nil)
            if(parentVC != nil ) {
                let presentationController = AAPLCustomPresentationController(presentedViewController: stampVC, presenting: self.parentVC!)
                presentationController.tapDelegate = self
                stampVC.delegate = self
                stampVC.transitioningDelegate = presentationController
                self.parentVC!.present(stampVC, animated: true, completion: nil)
            }
        } else if .image == CPDFViewAnnotationMode(rawValue: self.selectedIndex) {
            self.propertiesBtn?.isEnabled = false
            self.createImageAnnotation()
        } else if .link == CPDFViewAnnotationMode(rawValue: self.selectedIndex) {
            self.propertiesBtn?.isEnabled = false
        } else if .sound == CPDFViewAnnotationMode(rawValue: self.selectedIndex) {
            
        } else if .pencilDrawing == CPDFViewAnnotationMode(rawValue: self.selectedIndex) {
            self.propertiesBtn?.isEnabled = false
            if #available(iOS 13.0, *) {
                let tWidth: CGFloat = 412.0
                let tHeight: CGFloat = 60.0
                
                self.drawPencilFuncView = CPDFDrawPencilKitFuncView(frame: CGRect(x: (self.pdfListView?.frame.size.width ?? 0) - 30 - tWidth, y: self.window?.safeAreaInsets.top ?? 0, width: tWidth, height: tHeight))
                self.drawPencilFuncView?.delegate = self
                
                if(drawPencilFuncView != nil) {
                    self.pdfListView?.addSubview(self.drawPencilFuncView!)
                }
            }
        }
        
    }
    
    func createImageAnnotation() {
        var tRootViewControl = parentVC
        if let presentedViewController = tRootViewControl?.presentedViewController {
            tRootViewControl = presentedViewController
        }
        let cameraAction = UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .default) { (action) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera
            tRootViewControl?.present(imagePickerController, animated: true, completion: nil)
        }
        let photoAction = UIAlertAction(title: NSLocalizedString("Choose from Album", comment: ""), style: .default) { (action) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.allowsEditing = true
            imagePickerController.modalPresentationStyle = .popover
            if UI_USER_INTERFACE_IDIOM() == .pad {
                imagePickerController.popoverPresentationController?.sourceView = self.annotationBtns[14]
                imagePickerController.popoverPresentationController?.sourceRect = ((self.annotationBtns[14]).bounds)
            }
            tRootViewControl?.present(imagePickerController, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
            self.annotManage?.pdfListView?.setAnnotationMode(.CPDFViewAnnotationModenone)
            self.reloadData()
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if UI_USER_INTERFACE_IDIOM() == .pad {
            alertController.popoverPresentationController?.sourceView = self.annotationBtns[14]
            alertController.popoverPresentationController?.sourceRect = ((self.annotationBtns[14]).bounds)
        }
        
        alertController.addAction(cameraAction)
        alertController.addAction(photoAction)
        alertController.addAction(cancelAction)
        alertController.modalPresentationStyle = .popover
        tRootViewControl?.present(alertController, animated: true, completion: nil)
        
    }
    
    // MARK: - AAPLCustomPresentationControllerDelegate
    
    public func AAPLCustomPresentationControllerTap(_ customPresentationController: AAPLCustomPresentationController) {
        let annotation = annotManage?.pdfListView?.activeAnnotations?.first
        
        if annotation is CPDFLinkAnnotation {
            if linkVC?.isLink == true {
                annotation?.page.removeAnnotation(annotation)
                annotManage?.pdfListView?.setNeedsDisplayFor(annotManage?.pdfListView?.activeAnnotation?.page)
                annotManage?.pdfListView?.updateActiveAnnotations([])
            }
        } else if CPDFViewAnnotationMode(rawValue: self.selectedIndex) == .signature || CPDFViewAnnotationMode(rawValue: self.selectedIndex) == .stamp {
            pdfListView?.setAnnotationMode(.CPDFViewAnnotationModenone)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        var image: UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = originalImage
        }
        let imageOrientation = image?.imageOrientation
        if imageOrientation != .up {
            UIGraphicsBeginImageContext((image?.size)!)
            image?.draw(in: CGRect(x: 0, y: 0, width: (image?.size.width ?? 0), height: (image?.size.height ?? 0)))
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        guard let imageData = image!.pngData() else {
            return
        }
        image = UIImage(data: imageData)
        let colorMasking: [CGFloat] = [222, 255, 222, 255, 222, 255]
        let imageRef = image?.cgImage?.copy(maskingColorComponents: colorMasking)
        if let cgImage = imageRef {
            image = UIImage(cgImage: cgImage)
        }
        let annotation = CPDFStampAnnotation(document: self.annotManage?.pdfListView?.document, image: image)
        if self.isAddAnnotation {
            var bounds = annotation?.bounds ?? .zero
            bounds.origin.x = self.menuPoint.x - bounds.size.width / 2.0
            bounds.origin.y = self.menuPoint.y - bounds.size.height / 2.0
            annotation?.bounds = bounds
            self.pdfListView?.addAnnotation(annotation, for: menuPage)
            self.isAddAnnotation = false
            self.menuPage = nil
            self.menuPoint = CGPoint.zero
            
        } else {
            self.annotManage?.pdfListView?.addAnnotation = annotation
        }
        
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // MARK: - CPDFSignatureViewControllerDelegate
    
    public func signatureViewControllerDismiss(_ signatureViewController: CPDFSignatureViewController) {
        signatureAnnotation = nil
        pdfListView?.setAnnotationMode(.CPDFViewAnnotationModenone)
    }
    
    public func signatureViewController(_ signatureViewController: CPDFSignatureViewController, image: UIImage) {
        if let signatureAnnotation = self.signatureAnnotation {
            signatureAnnotation.sign(with: image)
            self.pdfListView?.setNeedsDisplayFor(signatureAnnotation.page)
            self.signatureAnnotation = nil
        } else {
            let annotation = CPDFSignatureAnnotation(document: self.annotManage?.pdfListView?.document)
            if(annotation != nil) {
                annotation?.setImage(image)
                self.annotManage?.pdfListView?.addAnnotation = annotation
            }
        }
        
    }
    
    // MARK: - CPDFNoteViewControllerDelegate
    
    func noteViewController(_ noteViewController: CPDFNoteViewController, annotStyle: CAnnotStyle) {
        if annotStyle.isSelectAnnot {
            annotManage?.refreshPage(with: annotStyle.annotations)
        }
    }
    
    // MARK: - CPDFShapeCircleViewControllerDelegate
    
    func circleViewController(_ circleViewController: CPDFShapeCircleViewController, annotStyle: CAnnotStyle) {
        if annotStyle.isSelectAnnot {
            annotManage?.refreshPage(with: annotStyle.annotations)
        }
    }
    
    // MARK: - CPDFHighlightViewControllerDelegate
    
    func highlightViewController(_ highlightViewController: CPDFHighlightViewController, annotStyle: CAnnotStyle) {
        if annotStyle.isSelectAnnot {
            annotManage?.refreshPage(with: annotStyle.annotations)
        } else {
            for button in annotationBtns {
                if CPDFViewAnnotationMode(rawValue: button.tag) == .highlight {
                    (button as? CPDFAnnotationBarButton)?.lineColor = CAnnotationManage.highlightAnnotationColor()
                    button.setNeedsDisplay()
                    break
                }
            }
        }
    }
    
    // MARK: - CPDFUnderlineViewControllerDelegate
    
    func underlineViewController(_ underlineViewController: CPDFUnderlineViewController, annotStyle: CAnnotStyle) {
        if annotStyle.isSelectAnnot == true {
            annotManage?.refreshPage(with: annotStyle.annotations)
        } else {
            for button in annotationBtns {
                if CPDFViewAnnotationMode(rawValue: button.tag) == .underline {
                    (button as? CPDFAnnotationBarButton)?.lineColor = CAnnotationManage.underlineAnnotationColor()
                    button.setNeedsDisplay()
                    break
                }
            }
        }
    }
    
    // MARK: - CPDFStrikeoutViewControllerDelegate
    
    func strikeoutViewController(_ strikeoutViewController: CPDFStrikeoutViewController, annotStyle: CAnnotStyle) {
        if annotStyle.isSelectAnnot {
            annotManage?.refreshPage(with: annotStyle.annotations)
        } else {
            for button in annotationBtns {
                if CPDFViewAnnotationMode(rawValue: button.tag) == .strikeout {
                    (button as? CPDFAnnotationBarButton)?.lineColor = CAnnotationManage.strikeoutAnnotationColor()
                    button.setNeedsDisplay()
                    break
                }
            }
        }
    }
    
    // MARK: - CPDFSquigglyViewControllerDelegate
    
    func squigglyViewController(_ squigglyViewController: CPDFSquigglyViewController, annotStyle: CAnnotStyle) {
        if annotStyle.isSelectAnnot {
            annotManage?.refreshPage(with: annotStyle.annotations)
        } else {
            for button in annotationBtns {
                if CPDFViewAnnotationMode(rawValue: button.tag) == .squiggly {
                    (button as? CPDFAnnotationBarButton)?.lineColor = CAnnotationManage.squigglyAnnotationColor()
                    button.setNeedsDisplay()
                    break
                }
            }
        }
    }
    
    // MARK: - CPDFAnnotationBarDelegate
    
    public func inkTopToolBar(_ inkTopToolBar: CPDFInkTopToolBar, tag: Int, isSelect: Bool) {
        var inkButton: CPDFAnnotationBarButton? = nil
        for button in self.annotationBtns {
            if CPDFViewAnnotationMode(rawValue: button.tag) == .ink {
                inkButton = button as? CPDFAnnotationBarButton
                break
            }
        }
        switch CPDFInkTopToolBarSelect(rawValue: tag) {
        case .setting:
            self.pdfListView?.commitDrawing()
            let annotStyle = self.annotManage?.annotStyle
            if(annotStyle != nil && parentVC != nil) {
                let inkVC = CPDFInkViewController(annotStyle: annotStyle!)
                inkVC.delegate = self
                let presentationController = AAPLCustomPresentationController(presentedViewController: inkVC, presenting: self.parentVC!)
                inkVC.transitioningDelegate = presentationController
                self.parentVC?.present(inkVC, animated: true, completion: nil)
            }
        case .erase:
            self.annotManage?.pdfListView?.setDrawErasing(isSelect)
        case .undo:
            self.annotManage?.pdfListView?.drawUndo()
            if self.topToolBar?.buttonArray[1].isSelected == true {
                self.topToolBar?.buttonArray[1].backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
            }
        case .redo:
            self.annotManage?.pdfListView?.drawRedo()
            if self.topToolBar?.buttonArray[1].isSelected == true {
                self.topToolBar?.buttonArray[1].backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
            }
        case .clear:
            if(inkButton != nil) {
                self.delegate?.annotationBarClick?(self, clickAnnotationMode: CPDFViewAnnotationMode.ink.rawValue, forSelected: false, forButton: inkButton!)
            }
            self.annotManage?.pdfListView?.setAnnotationMode(.CPDFViewAnnotationModenone)
            self.reloadData()
        case .save:
            if(inkButton != nil) {
                self.delegate?.annotationBarClick?(self, clickAnnotationMode: CPDFViewAnnotationMode.ink.rawValue, forSelected: false, forButton: inkButton!)
            }
            self.annotManage?.pdfListView?.commitDrawing()
            self.annotManage?.pdfListView?.setAnnotationMode(.CPDFViewAnnotationModenone)
            self.reloadData()
        default:
            break
        }
        
    }
    
    // MARK: - CPDFInkViewControllerDelegate
    
    func inkViewController(_ inkViewController: CPDFInkViewController, annotStyle: CAnnotStyle) {
        if annotStyle.isSelectAnnot {
            annotManage?.refreshPage(with: annotStyle.annotations)
        } else {
            for button in annotationBtns {
                if CPDFViewAnnotationMode(rawValue: button.tag) == .ink {
                    (button as? CPDFAnnotationBarButton)?.lineColor = CAnnotationManage.freehandAnnotationColor()
                    button.setNeedsDisplay()
                    break
                }
            }
        }
    }
    
    func inkViewControllerDimiss(_ inkViewController: CPDFInkViewController) {
        if ((topToolBar?.isDescendant(of: pdfListView ?? UIView())) == true) {
            self.topToolBar?.buttonArray[0].backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
            if self.topToolBar?.buttonArray[1].isSelected == true {
                self.topToolBar?.buttonArray[1].backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
            }
        }
    }
    
    // MARK: - CPDFShapeArrowViewControllerDelegate
    
    func arrowViewController(_ arrowViewController: CPDFShapeArrowViewController, annotStyle: CAnnotStyle) {
        if annotStyle.isSelectAnnot {
            annotManage?.refreshPage(with: annotStyle.annotations)
        }
    }
    
    // MARK: - CPDFFreeTextViewControllerDelegate
    
    func freeTextViewController(_ freeTextViewController: CPDFFreeTextViewController, annotStyle: CAnnotStyle) {
        if annotStyle.isSelectAnnot {
            annotManage?.refreshPage(with: annotStyle.annotations)
        }
    }
    
    // MARK: - CPDFLinkViewControllerDelegate
    
    func linkViewController(_ linkViewController: CPDFLinkViewController, linkType: Int, linkString: String) {
        let linkAnnotation = linkViewController.annotStyle?.annotations[0] as? CPDFLinkAnnotation
        if linkType == CPDFLinkType.link.rawValue || linkType == CPDFLinkType.email.rawValue {
            linkAnnotation?.setURL(linkString)
        } else if linkType == CPDFLinkType.page.rawValue {
            linkAnnotation?.setDestination(CPDFDestination(document: self.pdfListView?.document, pageIndex: (Int(linkString) ?? 0) - 1, at: .zero, zoom: 1))
        }
        self.pdfListView?.updateActiveAnnotations([])
        self.pdfListView?.setNeedsDisplayFor(linkAnnotation?.page)
    }
    
    func linkViewControllerDismiss(_ linkViewController: CPDFLinkViewController, isLink: Bool) {
        if !isLink {
            let annotation = annotManage?.pdfListView?.activeAnnotations?.first
            if(annotation != nil) {
                annotation!.page.removeAnnotation(annotation!)
                pdfListView?.setNeedsDisplayFor(annotManage?.pdfListView?.activeAnnotation?.page)
                self.pdfListView?.updateActiveAnnotations([])
            }
        }
    }
    
    // MARK: - CPDFDrawPencilViewDelegate
    
    public func drawPencilFuncView(_ view: CPDFDrawPencilKitFuncView, eraserBtn btn: UIButton) {
        if btn.isSelected {
            pdfListView?.scrollEnabled = true
        } else {
            pdfListView?.scrollEnabled = false
        }
    }
    
    public func drawPencilFuncView(_ view: CPDFDrawPencilKitFuncView, saveBtn btn: UIButton) {
        pdfListView?.commitDrawing()
        pdfListView?.commitEditing()
        
        pdfListView?.setAnnotationMode(.CPDFViewAnnotationModenone)
        drawPencilFuncView?.removeFromSuperview()
        drawPencilFuncView = nil
    }
    
    public func drawPencilFuncView(_ view: CPDFDrawPencilKitFuncView, cancelBtn btn: UIButton) {
        pdfListView?.setAnnotationMode(.CPDFViewAnnotationModenone)
        drawPencilFuncView?.removeFromSuperview()
        drawPencilFuncView = nil
        drawPencilFuncView?.delegate = nil
    }
    
    // MARK: - NSNotification
    
    @objc func annotationsOperationChangeNotification(_ notification: Notification) {
        if let pdfListView = notification.object as? CPDFListView, pdfListView == annotManage?.pdfListView {
            self.undoBtn?.isEnabled = pdfListView.canUndo()
            self.redoBtn?.isEnabled = pdfListView.canRedo()
        }
    }
    
    @objc func annotationChangedNotification(_ notification: Notification) {
        updatePropertiesButtonState()
    }
    
    // MARK: - CPDFStampViewControllerDelegate
    
    func stampViewController(_ stampViewController: CPDFStampViewController, selectedIndex: Int, stamp: [String : Any]) {
        if self.isAddAnnotation {
            if selectedIndex == -1 {
            } else {
                if stamp.count > 0 {
                    if let stampImagePath = stamp[PDFAnnotationStampKeyImagePath] as? String {
                        let image = UIImage(contentsOfFile: stampImagePath)
                        let annotation = CPDFStampAnnotation(document: annotManage?.pdfListView?.document, image: image)
                        if(annotation != nil) {
                            var bounds = annotation!.bounds
                            bounds.origin.x = self.menuPoint.x - bounds.size.width/2.0
                            bounds.origin.y = self.menuPoint.y - bounds.size.height/2.0
                            annotation!.bounds = bounds
                            annotManage?.pdfListView?.addAnnotation(annotation, for: menuPage)
                        }
                    } else {
                        let stampText = stamp[PDFAnnotationStampKeyText] as? String
                        let stampShowDate = stamp[PDFAnnotationStampKeyShowDate] as? Bool ?? false
                        let stampShowTime = stamp[PDFAnnotationStampKeyShowTime] as? Bool ?? false
                        let stampStyle = CPDFStampStyle(rawValue: stamp[PDFAnnotationStampKeyStyle] as? Int ?? 0) ?? .white
                        let stampShape = CPDFStampShape(rawValue: stamp[PDFAnnotationStampKeyShape] as? Int ?? 0) ?? .rectangle
                        var detailText: String?
                        let timeZone = NSTimeZone.system
                        let outputFormatter = DateFormatter()
                        outputFormatter.timeZone = timeZone
                        if stampShowDate && !stampShowTime {
                            outputFormatter.dateFormat = "yyyy/MM/dd"
                            detailText = outputFormatter.string(from: Date())
                        } else if stampShowTime && !stampShowDate {
                            outputFormatter.dateFormat = "HH:mm:ss"
                            detailText = outputFormatter.string(from: Date())
                        } else if stampShowDate && stampShowTime {
                            outputFormatter.dateFormat = "yyyy/MM/dd HH:mm"
                            detailText = outputFormatter.string(from: Date())
                        }
                        
                        let annotation = CPDFStampAnnotation(document: self.annotManage?.pdfListView?.document, text: stampText, detailText: detailText, style: stampStyle, shape: stampShape)
                        if(annotation != nil) {
                            var bounds = annotation!.bounds
                            bounds.origin.x = self.menuPoint.x - bounds.size.width/2.0
                            bounds.origin.y = self.menuPoint.y - bounds.size.height/2.0
                            annotation!.bounds = bounds
                            self.annotManage?.pdfListView?.addAnnotation(annotation, for: menuPage)
                        }
                    }
                } else {
                    let annotation = CPDFStampAnnotation(document: self.annotManage?.pdfListView?.document, type: selectedIndex + 1)
                    if(annotation != nil) {
                        
                        var bounds = annotation!.bounds
                        bounds.origin.x = self.menuPoint.x - bounds.size.width/2.0
                        bounds.origin.y = self.menuPoint.y - bounds.size.height/2.0
                        annotation!.bounds = bounds
                        self.annotManage?.pdfListView?.addAnnotation(annotation, for: menuPage)
                    }
                }
            }
            self.isAddAnnotation = false
            self.menuPage = nil
            self.menuPoint = CGPoint.zero
            
        } else {
            if selectedIndex == -1 {
                self.annotManage?.pdfListView?.setAnnotationMode(.CPDFViewAnnotationModenone)
                self.reloadData()
            } else {
                if stamp.count > 0 {
                    if let stampImagePath = stamp[PDFAnnotationStampKeyImagePath] as? String {
                        let image = UIImage(contentsOfFile: stampImagePath)
                        let annotation = CPDFStampAnnotation(document: annotManage?.pdfListView?.document, image: image)
                        self.annotManage?.pdfListView?.addAnnotation = annotation
                    } else {
                        let stampText = stamp[PDFAnnotationStampKeyText] as? String
                        let stampShowDate = stamp[PDFAnnotationStampKeyShowDate] as? Bool ?? false
                        let stampShowTime = stamp[PDFAnnotationStampKeyShowTime] as? Bool ?? false
                        let stampStyle = CPDFStampStyle(rawValue: stamp[PDFAnnotationStampKeyStyle] as? Int ?? 0) ?? .white
                        let stampShape = CPDFStampShape(rawValue: stamp[PDFAnnotationStampKeyShape] as? Int ?? 0) ?? .rectangle
                        var detailText: String?
                        let timeZone = NSTimeZone.system
                        let outputFormatter = DateFormatter()
                        outputFormatter.timeZone = timeZone
                        if stampShowDate && !stampShowTime {
                            outputFormatter.dateFormat = "yyyy/MM/dd"
                            detailText = outputFormatter.string(from: Date())
                        } else if stampShowTime && !stampShowDate {
                            outputFormatter.dateFormat = "HH:mm:ss"
                            detailText = outputFormatter.string(from: Date())
                        } else if stampShowDate && stampShowTime {
                            outputFormatter.dateFormat = "yyyy/MM/dd HH:mm"
                            detailText = outputFormatter.string(from: Date())
                        }
                        
                        let annotation = CPDFStampAnnotation(document:annotManage?.pdfListView?.document, text: stampText, detailText: detailText, style: stampStyle, shape: stampShape)
                        annotManage?.pdfListView?.addAnnotation = annotation
                    }
                } else {
                    let annotation = CPDFStampAnnotation(document: annotManage?.pdfListView?.document, type: selectedIndex + 1)
                    annotManage?.pdfListView?.addAnnotation = annotation
                }
            }
            
        }
        
    }
    
    func stampViewControllerDismiss(_ stampViewController: CPDFStampViewController) {
        pdfListView?.setAnnotationMode(.CPDFViewAnnotationModenone)
    }
    
}

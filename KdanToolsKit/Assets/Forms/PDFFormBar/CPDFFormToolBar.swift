//
//  CPDFFormToolBar.swift
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

public enum CPDFFormToolbarSelectedIndex: Int {
    case none = 0
    case text
    case checkBox
    case radioButton
    case comboBox
    case list
    case button
    case sign
}

public enum CPDFFormPropertieType: Int {
    case undo = 0
    case redo
}

@objc public protocol CPDFFormBarDelegate: AnyObject {
    @objc optional func formBarClick(_ pdfFormBar: CPDFFormToolBar, forSelected isSelected: Bool, forButton button: UIButton);
}

public class CPDFFormToolBar: UIView {
    
    public weak var delegate: CPDFFormBarDelegate?
    
    public var pdfListView: CPDFListView?
    
    public var parentVC: UIViewController?
    var scrollView: UIScrollView?
    var formBtns:[UIButton] = []
    
    var propertiesBar: UIView?
    var propertiesBtn: UIButton?
    var undoBtn: UIButton?
    var redoBtn: UIButton?
    var annotManage: CAnnotationManage?
    
    var selectedIndex: Int = 0
    
    
    public init(annotationManage: CAnnotationManage?) {
        super.init(frame: CGRect.zero)
        self.annotManage = annotationManage
        self.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
        
        let line = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 1))
        line.backgroundColor = UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0)
        line.autoresizingMask = .flexibleWidth
        self.addSubview(line)
        
        self.pdfListView = annotationManage?.pdfListView
        
        self.selectedIndex = 0
        self.initSubview()
        
        NotificationCenter.default.addObserver(self, selector: #selector(annotationChangedNotification(_:)), name: CPDFListViewActiveAnnotationsChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(annotationsOperationChangeNotification(_:)), name: CPDFListViewAnnotationsOperationChangeNotification, object: nil)
        
        NotificationCenter.default.post(name: CPDFListViewAnnotationsOperationChangeNotification, object: annotationManage?.pdfListView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        scrollView?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width - (self.propertiesBar?.frame.size.width ?? 0), height: self.frame.size.height)
    }
    
    // MARK: - NSNotification
    @objc func annotationsOperationChangeNotification(_ notification: Notification) {
        guard let pdfListView = notification.object as? CPDFListView else { return }
        if pdfListView == annotManage?.pdfListView {
            undoBtn?.isEnabled = pdfListView.canUndo()
            redoBtn?.isEnabled = pdfListView.canRedo()
        }
    }
    
    @objc func annotationChangedNotification(_ notification: Notification) {
        let activeAnnotation = pdfListView?.activeAnnotations?.first
        if activeAnnotation != nil {
            
            annotManage?.setAnnotStyle(from: self.pdfListView?.activeAnnotations ?? [])
        } else {
            annotManage?.setAnnotStyle(from: pdfListView?.annotationMode ?? .CPDFViewAnnotationModenone)
        }
        updatePropertiesButtonState()
    }
    
    public func reloadData() {
        if pdfListView?.annotationMode == .none {
            if selectedIndex > 0 && selectedIndex <= formBtns.count {
                for (_, button) in formBtns.enumerated() {
                    if button.tag == selectedIndex {
                        button.backgroundColor = UIColor.clear
                        selectedIndex = 0
                        break
                    }
                }
            }
        } else {
            for (button) in formBtns {
                if button.tag == pdfListView?.annotationMode.rawValue {
                    button.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
                    selectedIndex = button.tag
                } else {
                    button.backgroundColor = UIColor.clear
                }
            }
        }
        pdfListView?.reloadInputViews()
        
    }
    
    func initSubview() {
        scrollView = UIScrollView(frame: bounds)
        scrollView?.showsVerticalScrollIndicator = false
        scrollView?.showsHorizontalScrollIndicator = false
        addSubview(scrollView!)
        var offsetX: CGFloat = 10.0
        let buttonOffset: CGFloat = 25
        let buttonSize: CGFloat = 30
        
        let topOffset = (44 - buttonSize) / 2
        
        let formTypes = self.pdfListView?.configuration?.formTypes ?? []
        
        var images: [String] = []
        var types: [CPDFViewAnnotationMode] = []
        
        for formType in formTypes {
            switch formType {
            case .text:
                images.append("CPDFFormTextField")
                types.append(.formModeText)
            case .checkBox:
                images.append("CPDFFormCheckbox")
                types.append(.formModeCheckBox)
            case .radioButton:
                images.append("CPDFFormRadiobutton")
                types.append(.formModeRadioButton)
            case .comboBox:
                images.append("CPDFFormPullDownMenu")
                types.append(.formModeCombox)
            case .list:
                images.append("CPDFFormListbox")
                types.append(.formModeList)
            case .button:
                images.append("CPDFFormButton")
                types.append(.formModeButton)
            case .sign:
                images.append("CPDFFormSign")
                types.append(.formModeSign)
            default:
                break
            }
        }
        
        var annotationBtns: [UIButton] = []
        for i in 0..<types.count {
            let annotationMode = types[i]
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: offsetX, y: topOffset, width: buttonSize, height: buttonSize)
            button.setImage(UIImage(named: images[i], in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
            button.layer.cornerRadius = 5.0
            button.tag = annotationMode.rawValue
            button.addTarget(self, action: #selector(buttonItemClicked_Switch(_:)), for: .touchUpInside)
            scrollView?.addSubview(button)
            annotationBtns.append(button)
            if i != types.count - 1 {
                offsetX += button.bounds.size.width + buttonOffset
            } else {
                offsetX += button.bounds.size.width + 10
            }
        }
        formBtns = annotationBtns
        
        scrollView?.contentSize = CGSize(width: offsetX, height: scrollView?.bounds.size.height ?? 0)
        
        let formTools = self.pdfListView?.configuration?.formTools ?? []
        
        if formTools.count > 0 {
            
            var offset: CGFloat = 10
            
            let prWidth = buttonSize * 2 + offset
            propertiesBar = UIView(frame: CGRect(x: bounds.size.width - prWidth, y: 0, width: prWidth, height: 44))
            propertiesBar?.autoresizingMask = .flexibleLeftMargin
            addSubview(propertiesBar!)
            
            let lineView = UIView(frame: CGRect(x: offset - 5, y: 12, width: 1, height: 20))
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
            
            for formTool in formTools {
                switch formTool {
                case .undo:
                    undoBtn = UIButton(frame: CGRect(x: offset, y: topOffset, width: buttonSize, height: buttonSize))
                    undoBtn?.setImage(UIImage(named: "CPDFAnnotationBarImageUndo", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
                    undoBtn?.addTarget(self, action: #selector(buttonItemClicked_undo(_:)), for: .touchUpInside)
                    if undoBtn != nil {
                        propertiesBar?.addSubview(undoBtn!)
                    }
                    offset += undoBtn?.frame.size.width ?? 0
                case .redo:
                    redoBtn = UIButton(frame: CGRect(x: offset, y: topOffset, width: buttonSize, height: buttonSize))
                    redoBtn?.setImage(UIImage(named: "CPDFAnnotationBarImageRedo", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
                    redoBtn?.addTarget(self, action: #selector(buttonItemClicked_redo(_:)), for: .touchUpInside)
                    if redoBtn != nil {
                        propertiesBar?.addSubview(redoBtn!)
                    }
                    offset += undoBtn?.frame.size.width ?? 0
                }
            }
            
            updatePropertiesButtonState()
        }
        
    }
    
    public func updatePropertiesButtonState() {
        if pdfListView?.annotationMode != .none || annotManage?.pdfListView?.activeAnnotations?.count ?? 0 > 0 {
            let annotation = annotManage?.pdfListView?.activeAnnotations?.first
            if annotation != nil && annotation is CPDFSignatureWidgetAnnotation {
                propertiesBtn?.isEnabled = false
            } else {
                propertiesBtn?.isEnabled = true
            }
        } else {
            propertiesBtn?.isEnabled = false
        }
        propertiesBtn?.isEnabled = false
    }
    
    public func updateStatus() {
        self.selectedIndex = 0
        self.pdfListView?.setAnnotationMode(CPDFViewAnnotationMode(rawValue: self.selectedIndex) ?? .CPDFViewAnnotationModenone)
        self.annotManage?.setAnnotStyle(from: (CPDFViewAnnotationMode(rawValue: self.selectedIndex) ?? .CPDFViewAnnotationModenone))
        self.reloadData()
    }
    
    public func initUndoRedo() {
        self.undoBtn?.isEnabled = false
        self.redoBtn?.isEnabled = false
        self.pdfListView?.registerAsObserver()
    }
    
    // MARK: - Action
    @objc func buttonItemClicked_Switch(_ button: UIButton) {
        self.selectedIndex = button.tag
        if self.pdfListView?.annotationMode.rawValue != self.selectedIndex {
            self.propertiesBtn?.isEnabled = true
            button.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
            self.pdfListView?.setAnnotationMode(CPDFViewAnnotationMode(rawValue: self.selectedIndex) ?? .CPDFViewAnnotationModenone)
            self.annotManage?.setAnnotStyle(from: (CPDFViewAnnotationMode(rawValue: self.selectedIndex) ?? .CPDFViewAnnotationModenone))
        } else {
            self.propertiesBtn?.isEnabled = false
            self.pdfListView?.setAnnotationMode(.CPDFViewAnnotationModenone)
            self.selectedIndex = 0
            button.backgroundColor = UIColor.clear
        }
        self.updatePropertiesButtonState()
        self.reloadData()
    }
    
    @objc public func buttonItemClicked_open(_ button: UIButton?) {
        let annotStyle = self.annotManage?.annotStyle
        if (self.annotManage != nil) {
            var presentationController: AAPLCustomPresentationController
            switch annotStyle?.annotMode {
            case .formModeText:
                let textVC = CPDFFormTextViewController(annotManage: self.annotManage!)
                presentationController = AAPLCustomPresentationController(presentedViewController: textVC, presenting: self.parentVC ?? UIViewController())
                textVC.transitioningDelegate = presentationController  
                self.parentVC?.present(textVC, animated: true, completion: nil)
            case .formModeCheckBox:
                let checkBoxVC = CPDFFormCheckBoxViewController(annotManage: self.annotManage!)
                presentationController = AAPLCustomPresentationController(presentedViewController: checkBoxVC, presenting: self.parentVC ?? UIViewController())
                checkBoxVC.transitioningDelegate = presentationController  
                self.parentVC?.present(checkBoxVC, animated: true, completion: nil)
            case .formModeRadioButton:
                let radioButtonVC = CPDFFormRadioButtonViewController(annotManage: self.annotManage!)
                presentationController = AAPLCustomPresentationController(presentedViewController: radioButtonVC, presenting: self.parentVC ?? UIViewController())
                radioButtonVC.transitioningDelegate = presentationController  
                self.parentVC?.present(radioButtonVC, animated: true, completion: nil)
            case .formModeList:
                let listVC = CPDFFormListViewController(annotManage: self.annotManage!)
                presentationController = AAPLCustomPresentationController(presentedViewController: listVC, presenting: self.parentVC ?? UIViewController())
                listVC.transitioningDelegate = presentationController  
                self.parentVC?.present(listVC, animated: true, completion: nil)
            case .formModeCombox:
                let comboVC = CPDFFormComboxViewController(annotManage: self.annotManage!)
                presentationController = AAPLCustomPresentationController(presentedViewController: comboVC, presenting: self.parentVC ?? UIViewController())
                comboVC.transitioningDelegate = presentationController  
                self.parentVC?.present(comboVC, animated: true, completion: nil)
            case .formModeButton:
                let buttonVC = CPDFFormButtonViewController(annotManage: self.annotManage!)
                presentationController = AAPLCustomPresentationController(presentedViewController: buttonVC, presenting: self.parentVC ?? UIViewController())
                buttonVC.transitioningDelegate = presentationController  
                self.parentVC?.present(buttonVC, animated: true, completion: nil)
            case .formModeSign:
                let signatureVC = CPDFSignatureViewController(style: nil)
                presentationController = AAPLCustomPresentationController(presentedViewController: signatureVC, presenting: self.parentVC ?? UIViewController())
                signatureVC.transitioningDelegate = presentationController  
                self.parentVC?.present(signatureVC, animated: true, completion: nil)
            default:
                break
            }
        }
    }
    
    public func buttonItemClicked_openOption(_ annotation: CPDFWidgetAnnotation) {
        let annotStyle = self.annotManage?.annotStyle
        var presentationController: AAPLCustomPresentationController?
        if annotation is CPDFButtonWidgetAnnotation {
            let linkVC = CPDFFormLinkViewController(annotStyle: annotStyle!)
            linkVC.pageCount = Int(self.annotManage?.pdfListView?.document.pageCount ?? 0)
            presentationController = AAPLCustomPresentationController(presentedViewController: linkVC, presenting: self.parentVC ?? UIViewController())
            linkVC.transitioningDelegate = presentationController  
            self.parentVC?.present(linkVC, animated: true, completion: nil)
        } else {
            let listVC = CPDFFormListOptionVC(pdfView: self.pdfListView ?? CPDFListView(), annotation: annotation)
            presentationController = AAPLCustomPresentationController(presentedViewController: listVC, presenting: self.parentVC ?? UIViewController())
            listVC.transitioningDelegate = presentationController  
            self.parentVC?.present(listVC, animated: true, completion: nil)
        }
    }
    
    @objc func buttonItemClicked_undo(_ button: UIButton) {
        if self.annotManage?.pdfListView?.undoPDFManager != nil && ((self.annotManage?.pdfListView?.canUndo()) == true) {
            self.annotManage?.pdfListView?.undoPDFManager?.undo()
        }
    }
    
    @objc func buttonItemClicked_redo(_ button: UIButton) {
        if self.annotManage?.pdfListView?.undoPDFManager != nil && ((self.annotManage?.pdfListView?.canRedo()) == true) {
            self.annotManage?.pdfListView?.undoPDFManager?.redo()
        }
    }
    
}

//
//  CPDFEditToolBar.swift
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

public enum CPDFEditMode: UInt {
    case text
    case image
    case all
}

public enum CPDFEditToolMode: UInt {
    case setting
    case undo
    case redo
}

@objc public protocol CPDFEditToolBarDelegate: AnyObject {
    @objc optional func editClick(in toolBar: CPDFEditToolBar, editMode mode: Int)
    @objc optional func propertyEditDidClick(in toolBar: CPDFEditToolBar)
    @objc optional func redoDidClick(in toolBar: CPDFEditToolBar)
    @objc optional func undoDidClick(in toolBar: CPDFEditToolBar)
}

public class CPDFEditToolBar: UIView {
    
    public weak var delegate: CPDFEditToolBarDelegate?
    
    public var pdfView: CPDFListView?
    
    public var contentEditorTypes: [CPDFEditMode] = []
    
    public var undoButton: UIButton?
    public var redoButton: UIButton?
    public var propertyButton: UIButton?
    
    public var textEditButton: UIButton?
    public var imageEditButton: UIButton?
    
    public var leftView: UIView?
    public var rightView: UIView?
    public var splitView: UIView?
    
    public var editToolBarSelectType: CPDFEditMode = .all
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(pdfView: CPDFListView) {
        super.init(frame: CGRect.zero)
        self.pdfView = pdfView
        
        self.setUp()
        NotificationCenter.default.addObserver(self, selector: #selector(pageChangedNotification(_:)), name: NSNotification.Name.CPDFViewPageChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(pageEditingDidChanged(_:)), name: NSNotification.Name.CPDFPageEditingDidChanged, object: nil)

    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        
        rightView?.frame = CGRect(x: self.bounds.size.width - (rightView?.frame.size.width ?? 0), y: 0, width: (rightView?.frame.size.width ?? 0), height: 44)
        leftView?.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width - (rightView?.frame.size.width ?? 0), height: 44)
        
        if contentEditorTypes.count > 0 {
            let with = ((leftView?.bounds.width ?? 0) - (30 * CGFloat(contentEditorTypes.count))) / CGFloat(contentEditorTypes.count + 1)
            var x: CGFloat = with
            for contentEditorType in contentEditorTypes {
                switch contentEditorType {
                case .text:
                    textEditButton?.frame = CGRect(x:x, y: textEditButton?.frame.origin.y ?? 0, width: textEditButton?.frame.size.width ?? 0, height: textEditButton?.frame.size.height ?? 0)
                    x = x + (textEditButton?.frame.size.width ?? 0) + with
                    
                case .image:
                    imageEditButton?.frame = CGRect(x: x, y: imageEditButton?.frame.origin.y ?? 0, width: imageEditButton?.frame.size.width ?? 0, height: imageEditButton?.frame.size.height ?? 0)
                    x = x + (imageEditButton?.frame.size.width ?? 0) + with
                case .all:
                    break
                }
            }
        }
    }
    
    func removeViews() {
        if((self.leftView) != nil) {
            self.leftView?.removeFromSuperview()
        }
        
        if((self.rightView) != nil) {
            self.rightView?.removeFromSuperview()
        }
        
        if((self.splitView) != nil) {
            self.splitView?.removeFromSuperview()
        }
    }
    
    func setUp() {
        contentEditorTypes = self.pdfView?.configuration?.contentEditorTypes ?? []
        let contentEditorTools = self.pdfView?.configuration?.contentEditorTools ?? []
        
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 110, height: 44))
        if contentEditorTypes.count > 0 {
            for contentEditorType in contentEditorTypes {
                switch contentEditorType {
                case .text:
                    textEditButton = UIButton(frame: CGRect(x: 10, y: 7, width: 30, height: 30))
                    textEditButton?.addTarget(self, action: #selector(textEditAction(_:)), for: .touchUpInside)
                    textEditButton?.setImage(UIImage(named: "CPDFEditAddText", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
                    if(textEditButton != nil) {
                        leftView?.addSubview(textEditButton!)
                    }
                case .image:
                    imageEditButton = UIButton(frame: CGRect(x: 10, y: 7, width: 30, height: 30))
                    imageEditButton?.addTarget(self, action: #selector(imageEditAction(_:)), for: .touchUpInside)
                    imageEditButton?.setImage(UIImage(named: "CPDFEditAddImage", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
                    if(imageEditButton != nil) {
                        leftView?.addSubview(imageEditButton!)
                    }
                    
                default:
                    break
                }
            }
        }
        
        if(leftView != nil) {
            self.addSubview(leftView!)
        }

        if contentEditorTools.count > 0 {
            
            var offset: CGFloat = 10
            let buttonSize: CGFloat = 30
            
            let prWidth = buttonSize * CGFloat(contentEditorTools.count) + offset
            rightView = UIView(frame: CGRect(x: self.bounds.size.width - prWidth, y: 0, width: prWidth, height: 44))
            if(rightView != nil) {
                self.addSubview(rightView!)
            }
            
            let lineView = UIView(frame: CGRect(x: 10, y: 12, width: 1, height: 20))
            if #available(iOS 13.0, *) {
                if UITraitCollection.current.userInterfaceStyle == .dark {
                    lineView.backgroundColor = UIColor.white
                } else {
                    lineView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
                }
            } else {
                lineView.backgroundColor = UIColor.black
            }
            rightView?.addSubview(lineView)
            offset += lineView.frame.size.width
            
            for contentEditorTool in contentEditorTools {
                switch contentEditorTool {
                case .setting:
                    propertyButton = UIButton(frame: CGRect(x: offset, y: 7, width: 30, height: 30))
                    propertyButton?.setImage(UIImage(named: "CPDFAnnotationBarImageProperties", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
                    propertyButton?.addTarget(self, action: #selector(propertyAction(_:)), for: .touchUpInside)
                    if(propertyButton != nil) {
                        rightView?.addSubview(propertyButton!)
                    }
                    offset += propertyButton?.frame.size.width ?? 0
                case .undo:
                    undoButton = UIButton(frame: CGRect(x: offset, y: 7, width: 30, height: 30))
                    undoButton?.addTarget(self, action: #selector(undoAction(_:)), for: .touchUpInside)
                    undoButton?.setImage(UIImage(named: "CPDFAnnotationBarImageUndo", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
                    if(undoButton != nil) {
                        rightView?.addSubview(undoButton!)
                    }
                    offset += undoButton?.frame.size.width ?? 0
                case .redo:
                    redoButton = UIButton(frame: CGRect(x: offset, y: 7, width: 30, height: 30))
                    redoButton?.addTarget(self, action: #selector(redoAction(_:)), for: .touchUpInside)
                    redoButton?.setImage(UIImage(named: "CPDFAnnotationBarImageRedo", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
                    if(redoButton != nil) {
                        rightView?.addSubview(redoButton!)
                    }
                    offset += redoButton?.frame.size.width ?? 0
                }
            }
            
        }

        self.backgroundColor = UIColor(red: 0.98, green: 0.99, blue: 1.0, alpha: 1.0)
        self.updateButtonState()
        self.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
        editToolBarSelectType = .all
    }
    
    @objc func textEditAction(_ sender: UIButton) {
        self.textEditButton?.isSelected = !(self.textEditButton?.isSelected ?? false)
        if self.textEditButton?.isSelected == true {
            self.imageEditButton?.isSelected = false
            self.imageEditButton?.backgroundColor = UIColor.clear
        }
        
        if sender.isSelected == false && self.imageEditButton?.isSelected == false {
            self.pdfView?.changeEditingLoadType([.text, .image])
            self.pdfView?.setShouAddEdit([])
            
            self.delegate?.editClick?(in: self, editMode:2)
            
            self.editToolBarSelectType = .all
        } else {
            self.pdfView?.changeEditingLoadType(.text)
            self.pdfView?.setShouAddEdit(.text)
                    
            self.delegate?.editClick?(in: self, editMode: 0)

            self.editToolBarSelectType = .text
        }
        
        updateButtonState()
        if sender.isSelected {
            self.textEditButton?.backgroundColor = UIColor(red: 221/255, green: 233/255, blue: 255/255, alpha: 1)
        } else {
            self.textEditButton?.backgroundColor = UIColor.clear
        }
    }
    
    @objc func imageEditAction(_ sender: UIButton) {
        self.imageEditButton?.isSelected = !(self.imageEditButton?.isSelected ?? false)

        if self.imageEditButton?.isSelected == true {
            self.textEditButton?.isSelected = false
            self.textEditButton?.backgroundColor = UIColor.clear
        }
        
        if sender.isSelected == false && self.textEditButton?.isSelected == false {
            self.pdfView?.changeEditingLoadType([.text, .image])
            self.pdfView?.setShouAddEdit([])
            
            self.delegate?.editClick?(in: self, editMode: 2)
            
            self.editToolBarSelectType = .all
        } else {
            self.pdfView?.changeEditingLoadType(.image)
            self.pdfView?.setShouAddEdit(.image)
                    
            self.delegate?.editClick?(in: self, editMode: 1)
            
            self.editToolBarSelectType = .image
        }
        
        updateButtonState()
        
        if sender.isSelected {
            self.imageEditButton?.backgroundColor = UIColor(red: 221/255, green: 233/255, blue: 255/255, alpha: 1)
        } else {
            self.imageEditButton?.backgroundColor = UIColor.clear
        }
    }

    @objc func redoAction(_ sender: UIButton) {
        self.delegate?.redoDidClick?(in: self)
    }
    
    @objc func undoAction(_ sender: UIButton) {
        self.delegate?.undoDidClick?(in: self)
    }
    
    @objc func propertyAction(_ sender: UIButton) {
        self.delegate?.propertyEditDidClick?(in: self)
    }
    
    public func updateButtonState() {
        if self.pdfView?.editingLoadType == .text {
            // Text
            self.textEditButton?.isSelected = true
            self.imageEditButton?.isSelected = false
        } else if self.pdfView?.editingLoadType == .image {
            self.textEditButton?.isSelected = false
            self.imageEditButton?.isSelected = true
        } else {
            self.textEditButton?.isSelected = false
            self.imageEditButton?.isSelected = false
        }
        if self.textEditButton?.isSelected == true {
            self.textEditButton?.backgroundColor = UIColor(red: 221/255, green: 233/255, blue: 255/255, alpha: 1)
        } else {
            self.textEditButton?.backgroundColor = UIColor.clear
        }
        
        if self.imageEditButton?.isSelected == true {
            self.imageEditButton?.backgroundColor = UIColor(red: 221/255, green: 233/255, blue: 255/255, alpha: 1)
        } else {
            self.imageEditButton?.backgroundColor = UIColor.clear
        }
        let stayy = self.pdfView?.editStatus()
    
        if self.pdfView?.shouAddEditAreaType() == .text {
            self.propertyButton?.isEnabled = true
        } else if stayy == .empty {
            self.propertyButton?.isEnabled = false
        } else {
            self.propertyButton?.isEnabled = true
        }
        
        if ((self.pdfView?.canEditTextRedo()) == true) {
            self.redoButton?.isEnabled = true
        } else {
            self.redoButton?.isEnabled = false
        }
        
        if ((self.pdfView?.canEditTextUndo()) == true) {
            self.undoButton?.isEnabled = true
        } else {
            self.undoButton?.isEnabled = false
        }
        
    }
    
    @objc func pageChangedNotification(_ notification: Notification) {
        guard let pdfview = notification.object as? CPDFView else {
            return
        }
        if pdfview.document == self.pdfView?.document {
            updateButtonState()
        }
    }
    
    @objc func pageEditingDidChanged(_ notification: Notification) {
        guard let page = notification.object as? CPDFPage else {
            return
        }
        if page.document == self.pdfView?.document {
            updateButtonState()
        }
    }
    
}

//
//  CPDFNoteOpenViewController.swift
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

@objc public protocol CPDFNoteOpenViewControllerDelegate: AnyObject {
    @objc optional func getNoteOpenViewController(_ noteOpenVC: CPDFNoteOpenViewController, content: String, isDelete: Bool)
}

public class CPDFNoteOpenViewController: UIViewController {
    public weak var delegate: CPDFNoteOpenViewControllerDelegate?
    
    public var annotation: CPDFAnnotation?
    
    private var noteTextView: UITextView?
    private var textViewContent: String?
    private var contentView: UIView?
    
    // MARK: - Initializers
    
    public init(annotation: CPDFAnnotation) {
        self.annotation = annotation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController Methods
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = CPDFColorUtils.CNoteOpenBackgooundColor()
        noteTextView = UITextView(frame: CGRect(x: 10, y: 10, width: self.view.bounds.size.width, height: self.view.bounds.size.height - 60))
        noteTextView?.delegate = self
        noteTextView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        noteTextView?.backgroundColor = UIColor.clear
        noteTextView?.font = UIFont.systemFont(ofSize: 14)
        noteTextView?.textAlignment = .left
        noteTextView?.textColor = UIColor.black
        if noteTextView != nil {
            self.view.addSubview(noteTextView!)
        }
        noteTextView?.text = self.textViewContent
        let deleteButton = UIButton(type: .custom)
        deleteButton.setImage(UIImage(named: "CPDFNoteContentImageNameDelete", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        deleteButton.sizeToFit()
        var frame = deleteButton.frame
        frame.origin.x = 10
        frame.origin.y = self.view.bounds.size.height - deleteButton.bounds.size.height - 10
        deleteButton.frame = frame
        deleteButton.autoresizingMask = .flexibleTopMargin
        deleteButton.addTarget(self, action: #selector(buttonItemClicked_Delete(_:)), for: .touchUpInside)
        self.view.addSubview(deleteButton)
        let saveButton = UIButton(type: .custom)
        saveButton.setImage(UIImage(named: "CPDFNoteContentImageNameSave", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        saveButton.sizeToFit()
        frame = saveButton.frame
        frame.origin.x = self.view.bounds.size.width - saveButton.bounds.size.width - 10
        frame.origin.y = self.view.bounds.size.height - saveButton.bounds.size.height - 10
        saveButton.frame = frame
        saveButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        saveButton.addTarget(self, action: #selector(buttonItemClicked_Save(_:)), for: .touchUpInside)
        self.view.addSubview(saveButton)
        self.noteTextView?.text = self.annotation?.contents ?? ""
        
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        noteTextView?.becomeFirstResponder()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if ((noteTextView?.isFirstResponder) != nil) {
            noteTextView?.resignFirstResponder()
        }
    }
    
    public func showViewController(_ viewController: UIViewController, inRect rect: CGRect) {
        // Implementation for showing view controller in rect
        preferredContentSize = CGSize(width: 280, height: 305)
        modalPresentationStyle = .popover
        
        let popVC = popoverPresentationController
        popVC?.delegate = self
        popVC?.sourceRect = rect
        popVC?.sourceView = viewController.view
        popVC?.canOverlapSourceViewRect = true
        popVC?.popoverBackgroundViewClass = UIPopBackgroundView.classForCoder() as? UIPopoverBackgroundViewMethods.Type
        
        popVC?.permittedArrowDirections = .unknown

        viewController.present(self, animated: true)
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_Delete(_ button: UIButton) {
        dismiss(animated: true)
        delegate?.getNoteOpenViewController?(self, content: noteTextView?.text ?? "", isDelete: true)
    }
    
    @objc func buttonItemClicked_Save(_ button: UIButton) {
        dismiss(animated: true)
        delegate?.getNoteOpenViewController?(self, content: noteTextView?.text ?? "", isDelete: false)
    }
    
}

extension CPDFNoteOpenViewController: UIPopoverPresentationControllerDelegate, UITextViewDelegate {
    // Implement the methods for UIPopoverPresentationControllerDelegate and UITextViewDelegate here
    
    // MARK: - UIPopoverPresentationControllerDelegate
    
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        delegate?.getNoteOpenViewController?(self, content: noteTextView?.text ?? "", isDelete: false)
    }
    
}


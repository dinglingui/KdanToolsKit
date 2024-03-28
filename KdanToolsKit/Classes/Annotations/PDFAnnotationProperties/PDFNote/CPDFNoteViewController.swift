//
//  CPDFNoteViewController.swift
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

@objc protocol CPDFNoteViewControllerDelegate: AnyObject {
    @objc optional func noteViewController(_ noteViewController: CPDFNoteViewController, annotStyle: CAnnotStyle)
}

class CPDFNoteViewController: UIViewController, UIColorPickerViewControllerDelegate, CPDFColorSelectViewDelegate, CPDFColorPickerViewDelegate {
    var annoStyle: CAnnotStyle?
    
    fileprivate var sampleView: CPDFSampleView?
    fileprivate var colorView: CPDFColorSelectView?
    fileprivate var colorPicker: CPDFColorPickerView?
    fileprivate var scrcollView: UIScrollView?
    fileprivate var backBtn: UIButton?
    fileprivate var titleLabel: UILabel?
    fileprivate var sampleBackgoundView: UIView?
    fileprivate var headerView: UIView?
    
    weak var delegate: CPDFNoteViewControllerDelegate?
    
    // MARK: - Initializers
    
    init(style: CAnnotStyle) {
        self.annoStyle = style
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Common initialization code
        self.headerView = UIView()
        self.headerView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        self.headerView?.layer.borderWidth = 1.0
        self.headerView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if headerView != nil {
            self.view.addSubview(self.headerView!)
        }
        
        self.titleLabel = UILabel()
        self.titleLabel?.autoresizingMask = .flexibleRightMargin
        self.titleLabel?.textAlignment = .center
        self.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        self.titleLabel?.text = NSLocalizedString("Note", comment: "")
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        if titleLabel != nil {
            self.headerView?.addSubview(self.titleLabel!)
        }
        
        self.scrcollView = UIScrollView()
        self.scrcollView?.isScrollEnabled = true
        if scrcollView != nil {
            self.view.addSubview(self.scrcollView!)
        }
        
        self.backBtn = UIButton()
        self.backBtn?.autoresizingMask = .flexibleLeftMargin
        self.backBtn?.setImage(UIImage(named: "CPDFAnnotationBaseImageBack", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        self.backBtn?.addTarget(self, action: #selector(buttonItemClicked_back(_:)), for: .touchUpInside)
        if backBtn != nil {
            self.headerView?.addSubview(self.backBtn!)
        }
        
        self.sampleBackgoundView = UIView()
        self.sampleBackgoundView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        self.sampleBackgoundView?.layer.borderWidth = 1.0
        self.sampleBackgoundView?.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
        if sampleBackgoundView != nil {
            self.headerView?.addSubview(self.sampleBackgoundView!)
        }
        
        self.sampleView = CPDFSampleView()
        self.sampleView?.backgroundColor = UIColor.white
        self.sampleView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        self.sampleView?.layer.borderWidth = 1.0
        self.sampleView?.autoresizingMask = .flexibleRightMargin
        if sampleView != nil {
            self.sampleBackgoundView?.addSubview(self.sampleView!)
        }
        
        self.colorView = CPDFColorSelectView()
        self.colorView?.delegate = self
        self.colorView?.autoresizingMask = .flexibleWidth
        if colorView != nil {
            self.scrcollView?.addSubview(self.colorView!)
        }
        
        self.view.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        self.updatePreferredContentSizeWithTraitCollection(traitCollection: traitCollection)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        titleLabel?.frame = CGRect(x: (view.frame.size.width - 120) / 2, y: 5, width: 120, height: 50)
        scrcollView?.frame = CGRect(x: 0, y: 170, width: view.frame.size.width, height: 210)
        headerView?.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 170)
        scrcollView?.contentSize = CGSize(width: view.frame.size.width, height: 330)
        sampleBackgoundView?.frame = CGRect(x: 0, y: 50, width: view.bounds.size.width, height: 120)
        sampleView?.frame = CGRect(x: (view.frame.size.width - 300) / 2, y: 15, width: 300, height: (sampleBackgoundView?.bounds.size.height ?? 0) - 30)
        
        if #available(iOS 11.0, *) {
            colorPicker?.frame = CGRect(x: view.safeAreaInsets.left, y: 0, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: view.frame.size.height)
            colorView?.frame = CGRect(x: view.safeAreaInsets.left, y: 0, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 90)
            backBtn?.frame = CGRect(x: view.frame.size.width - 60 - view.safeAreaInsets.right, y: 5, width: 50, height: 50)
        } else {
            colorView?.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 90)
            backBtn?.frame = CGRect(x: view.frame.size.width - 60, y: 5, width: 50, height: 50)
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSizeWithTraitCollection(traitCollection: newCollection)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sampleView?.color = annoStyle?.color
        sampleView?.selecIndex = .note
        sampleView?.opcity = annoStyle?.opacity ?? 1.0
        sampleView?.setNeedsDisplay()
        colorView?.selectedColor = annoStyle?.color
    }
    
    // MARK: - Protect Methods
    
    func updatePreferredContentSizeWithTraitCollection(traitCollection: UITraitCollection) {
        if self.colorPicker?.superview != nil {
            let currentDevice = UIDevice.current
            if currentDevice.userInterfaceIdiom == .pad {
                // This is an iPad
                self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: 320)
            } else {
                // This is an iPhone or iPod touch
                self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: 320)
            }
        } else {
            self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? 320 : 320)
        }
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_back(_ button: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - CPDFColorSelectViewDelegate
    
    func selectColorView(_ select: CPDFColorSelectView) {
        if #available(iOS 14.0, *) {
            let picker = UIColorPickerViewController()
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        } else {
            self.colorPicker = CPDFColorPickerView(frame: view.frame)
            self.colorPicker?.delegate = self
            self.colorView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.colorPicker?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
            if colorPicker != nil {
                self.view.addSubview(self.colorPicker!)
            }
            
            updatePreferredContentSizeWithTraitCollection(traitCollection: traitCollection)
        }
        
    }
    
    func selectColorView(_ select: CPDFColorSelectView, color: UIColor) {
        sampleView?.color = color
        annoStyle?.setColor(color)
        sampleView?.setNeedsDisplay()
        if annoStyle != nil {
            delegate?.noteViewController?(self, annotStyle: annoStyle!)
        }
    }
    
    // MARK: - CPDFColorPickerViewDelegate
    
    func pickerView(_ colorPickerView: CPDFColorPickerView, color: UIColor) {
        sampleView?.color = color
        annoStyle?.setColor(color)
        sampleView?.setNeedsDisplay()
        if annoStyle != nil {
            delegate?.noteViewController?(self, annotStyle: annoStyle!)
        }
    }
    
    // MARK: - UIColorPickerViewControllerDelegate
    
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        sampleView?.color = viewController.selectedColor
        annoStyle?.setColor(sampleView?.color)
        sampleView?.setNeedsDisplay()
        if annoStyle != nil {
            delegate?.noteViewController?(self, annotStyle: annoStyle!)
        }
    }
}


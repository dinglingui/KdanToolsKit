//
//  CPDFFormCheckBoxViewController.swift
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

class CPDFFormCheckBoxViewController: CPDFFormBaseViewController, CPDFFormTextFiledViewDelegate, CPDFColorSelectViewDelegate, CPDFFormSwitchViewDelegate, CPDFFormArrowStyleViewDelegate,CPDFColorPickerViewDelegate,CPDFArrowStyleTableViewDelegate,UIColorPickerViewControllerDelegate {
    var annotManage: CAnnotationManage?
    var formTextFiledView: CPDFFormTextFieldView?
    var borderColorView: CPDFColorSelectView?
    var backGroundColorView: CPDFColorSelectView?
    var colorSelectView: CPDFColorSelectView?
    var selectDefaultSwitchView: CPDFFormSwitchView?
    var hideFormSwitchView: CPDFFormSwitchView?
    var arrowStyleView: CPDFFormArrowStyleView?
    var colorPicker: CPDFColorPickerView?
    var currentSelectColorView: CPDFColorSelectView?
    var arrowStyleTableView: CPDFArrowStyleTableView?
    
    var buttonWidget: CPDFButtonWidgetAnnotation? {
        didSet {
            self.formTextFiledView?.contentField?.text = buttonWidget?.fieldName()
            self.hideFormSwitchView?.switcher?.isOn = buttonWidget?.isHidden() == true
            if buttonWidget?.state() == 1 {
                self.selectDefaultSwitchView?.switcher?.isOn = true
            }
            if buttonWidget?.state() == 0 {
                self.selectDefaultSwitchView?.switcher?.isOn = false
            }
            if buttonWidget?.fontColor == nil {
                self.colorSelectView?.selectedColor = UIColor.black
                buttonWidget?.fontColor = UIColor.black
                self.refreshUI()
            } else {
                self.colorSelectView?.selectedColor = buttonWidget?.fontColor
            }
            if buttonWidget?.borderColor == nil {
                borderColorView?.selectedColor = .black
                buttonWidget?.borderColor = borderColorView?.selectedColor
                self.refreshUI()
            } else {
                self.borderColorView?.selectedColor = buttonWidget?.borderColor
            }
            if self.backGroundColorView?.selectedColor == nil {
                self.refreshUI()
            } else {
                self.backGroundColorView?.selectedColor = buttonWidget?.backgroundColor
            }
            let widgetCheckStyle:CPDFWidgetButtonStyle = buttonWidget?.widgetCheckStyle() ?? .none
            switch widgetCheckStyle {
            case .check:
                self.arrowStyleView?.arrowImageView?.image = UIImage(named: "CPDFFormCheck", in: Bundle(for: self.classForCoder), compatibleWith: nil)
            case .circle:
                self.arrowStyleView?.arrowImageView?.image = UIImage(named: "CPDFFormCircle", in: Bundle(for: self.classForCoder), compatibleWith: nil)
            case .cross:
                self.arrowStyleView?.arrowImageView?.image = UIImage(named: "CPDFFormCross", in: Bundle(for: self.classForCoder), compatibleWith: nil)
            case .diamond:
                self.arrowStyleView?.arrowImageView?.image = UIImage(named: "CPDFFormDiamond", in: Bundle(for: self.classForCoder), compatibleWith: nil)
            case .square:
                self.arrowStyleView?.arrowImageView?.image = UIImage(named: "CPDFFormSquare", in: Bundle(for: self.classForCoder), compatibleWith: nil)
            case .star:
                self.arrowStyleView?.arrowImageView?.image = UIImage(named: "CPDFFormStar", in: Bundle(for: self.classForCoder), compatibleWith: nil)
            default:
                break
            }
        }
    }
    
    init(annotManage: CAnnotationManage) {
        self.annotManage = annotManage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formTextFiledView = CPDFFormTextFieldView(frame: CGRect.zero)
        if(formTextFiledView != nil) {
            scrcollView?.addSubview(formTextFiledView!)
        }
        formTextFiledView?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        formTextFiledView?.titleLabel?.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        formTextFiledView?.titleLabel?.text = NSLocalizedString("Name", comment: "")
        formTextFiledView?.delegate = self
        borderColorView = CPDFColorSelectView.init(frame: CGRect.zero)
        borderColorView?.delegate = self
        borderColorView?.colorLabel?.text = NSLocalizedString("Stroke Color", comment: "")
        borderColorView?.colorLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        borderColorView?.colorLabel?.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        borderColorView?.colorPickerView?.showsHorizontalScrollIndicator = false
        backGroundColorView = CPDFColorSelectView(frame: CGRect.zero)
        backGroundColorView?.colorLabel?.text = NSLocalizedString("Background Color", comment: "")
        backGroundColorView?.delegate = self
        backGroundColorView?.colorLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        backGroundColorView?.colorLabel?.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        backGroundColorView?.colorPickerView?.showsHorizontalScrollIndicator = false
        colorSelectView = CPDFColorSelectView(frame: CGRect.zero)
        if(colorSelectView != nil) {
            scrcollView?.addSubview(colorSelectView!)
        }
        if(borderColorView != nil) {
            scrcollView?.addSubview(borderColorView!)
        }
        if(backGroundColorView != nil) {
            scrcollView?.addSubview(backGroundColorView!)
        }
        colorSelectView?.colorLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        colorSelectView?.colorLabel?.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        colorSelectView?.colorLabel?.text = NSLocalizedString("Checkmark Color", comment: "")
        colorSelectView?.delegate = self
        colorSelectView?.colorPickerView?.showsHorizontalScrollIndicator = false
        selectDefaultSwitchView = CPDFFormSwitchView(frame: CGRect.zero)
        if(selectDefaultSwitchView != nil) {
            scrcollView?.addSubview(selectDefaultSwitchView!)
        }
        selectDefaultSwitchView?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        selectDefaultSwitchView?.titleLabel?.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        selectDefaultSwitchView?.titleLabel?.text = NSLocalizedString("Button is checked by default", comment: "")
        selectDefaultSwitchView?.delegate = self
        arrowStyleView = CPDFFormArrowStyleView(frame: CGRect.zero)
        if(arrowStyleView != nil) {
            scrcollView?.addSubview(arrowStyleView!)
        }
        
        arrowStyleView?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        arrowStyleView?.titleLabel?.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        arrowStyleView?.titleLabel?.text = NSLocalizedString("Button Style", comment: "")
        arrowStyleView?.delegate = self
        
        buttonWidget = annotManage?.annotStyle?.annotations.first as? CPDFButtonWidgetAnnotation
        
        
        // Do any additional setup after loading the view.
    }
    
    override func commomInitTitle() {
        self.titleLabel?.text = NSLocalizedString("Check Box", comment: "")
    }
    
    override func updatePreferredContentSize(with traitCollection: UITraitCollection) {
        if colorPicker?.superview != nil {
            let currentDevice = UIDevice.current
            if currentDevice.userInterfaceIdiom == .pad {
                // This is an iPad
                preferredContentSize = CGSize(width: view.bounds.size.width, height: 520)
            } else {
                // This is an iPhone or iPod touch
                preferredContentSize = CGSize(width: view.bounds.size.width, height: 320)
            }
        } else {
            preferredContentSize = CGSize(width: view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? 350 : 600)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.scrcollView?.frame = CGRect(x: 0, y: 60, width: self.view.frame.size.width, height: self.view.frame.size.height-60)
        self.scrcollView?.contentSize = CGSize(width: self.view.frame.size.width, height: 500)
        self.scrcollView?.showsVerticalScrollIndicator = false
        if #available(iOS 11.0, *) {
            self.formTextFiledView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: 8, width: self.view.frame.size.width - self.view.safeAreaInsets.left, height: 65)
            self.borderColorView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: (self.formTextFiledView?.frame.maxY ?? 0)+8, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 74)
            self.backGroundColorView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: (self.borderColorView?.frame.maxY ?? 0) + 8, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 74)
            self.colorSelectView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: (self.backGroundColorView?.frame.maxY ?? 0) + 8, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 74)
            self.arrowStyleView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: (self.colorSelectView?.frame.maxY ?? 0) + 8, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 44)
            self.selectDefaultSwitchView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: (self.arrowStyleView?.frame.maxY ?? 0) + 8, width: self.view.frame.size.width - self.view.safeAreaInsets.left, height: 44)
        } else {
            self.formTextFiledView?.frame = CGRect(x: 0, y: 8, width: self.view.bounds.size.width, height: 60)
            self.borderColorView?.frame = CGRect(x: 0, y: (self.formTextFiledView?.frame.maxY ?? 0) + 8, width: self.view.frame.size.width, height: 74)
            self.backGroundColorView?.frame = CGRect(x: 0, y: (self.borderColorView?.frame.maxY ?? 0) + 8, width: self.view.frame.size.width, height: 74)
            self.colorSelectView?.frame = CGRect(x: 0, y: (self.backGroundColorView?.frame.maxY ?? 0) + 8, width: self.view.frame.size.width, height: 74)
            self.arrowStyleView?.frame = CGRect(x: 0, y: (self.colorSelectView?.frame.maxY ?? 0) + 8, width: self.view.frame.size.width, height: 44)
            self.selectDefaultSwitchView?.frame = CGRect(x: 0, y: (self.arrowStyleView?.frame.maxY ?? 0) + 8, width: self.view.frame.size.width, height: 44)
        }
        
    }
    
    func refreshUI() {
        self.buttonWidget?.updateAppearanceStream()
        let page = self.buttonWidget?.page
        if page != nil {
            self.annotManage?.pdfListView?.setNeedsDisplayFor(page)
        }
    }
    
    // MARK: - Action
    @objc override func buttonItemClicked_back(_ button: UIButton) {
        self.dismiss(animated:true)
    }
    
    
    // MARK: - CPDFFormTextFiledViewDelegate
    func setCPDFFormTextFieldView(_ view: CPDFFormTextFieldView, text: String) {
        self.buttonWidget?.setFieldName(text)
        self.refreshUI()
    }
    
    // MARK: - CPDFColorSelectViewDelegate
    func selectColorView(_ select: CPDFColorSelectView, color: UIColor) {
        self.currentSelectColorView = select
        if self.borderColorView == select {
            self.buttonWidget?.borderColor = color
        } else if self.backGroundColorView == select {
            self.buttonWidget?.backgroundColor = color
        } else if self.colorSelectView == select {
            self.buttonWidget?.fontColor = color
        }
        self.refreshUI()
    }
    
    func selectColorView(_ select: CPDFColorSelectView) {
        self.currentSelectColorView = select
        if #available(iOS 14.0, *) {
            let picker = UIColorPickerViewController()
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        } else{
            let currentDevice = UIDevice.current
            if currentDevice.userInterfaceIdiom == .pad {
                // This is an iPad
                colorPicker = CPDFColorPickerView(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: 520))
            } else {
                // This is an iPhone or iPod touch
                colorPicker = CPDFColorPickerView(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: 320))
            }
            self.colorPicker?.delegate = self
            self.colorPicker?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
            if(colorPicker != nil) {
                view.addSubview(self.colorPicker!)
            }
            updatePreferredContentSize(with: self.traitCollection)
        }
        self.refreshUI()
    }
    
    // MARK: - CPDFColorPickerViewDelegate
    func pickerView(_ colorPickerView: CPDFColorPickerView, color: UIColor) {
        if self.currentSelectColorView == self.borderColorView {
            self.buttonWidget?.borderColor = color
        } else if self.currentSelectColorView == self.backGroundColorView {
            self.buttonWidget?.backgroundColor = color
        } else if self.currentSelectColorView == self.colorSelectView {
            self.buttonWidget?.fontColor = color
        }
        self.updatePreferredContentSize(with: self.traitCollection)
        self.refreshUI()
    }
    
    // MARK: - UIColorPickerViewControllerDelegate
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        if self.currentSelectColorView == self.borderColorView {
            self.buttonWidget?.borderColor = viewController.selectedColor
        } else if self.currentSelectColorView == self.backGroundColorView {
            self.buttonWidget?.backgroundColor = viewController.selectedColor
        } else if self.currentSelectColorView == self.colorSelectView {
            self.buttonWidget?.fontColor = viewController.selectedColor
        }
        
        self.refreshUI()
    }
    
    
    // MARK: - CPDFFormSwitchViewDelegate
    func switchAction(in view: CPDFFormSwitchView, switcher: UISwitch) {
        if view == self.selectDefaultSwitchView {
            if switcher.isOn {
                buttonWidget?.setState(1)
            } else {
                buttonWidget?.setState(0)
            }
        } else if view == self.hideFormSwitchView {
            if switcher.isOn {
                let annotation = self.annotManage?.annotStyle?.annotations.first
                if(annotation != nil) {
                    if (self.annotManage?.pdfListView?.activeAnnotations?.contains(annotation!) == true) {
                        self.annotManage?.pdfListView?.updateActiveAnnotations([])
                    }
                }
            }
            self.buttonWidget?.setHidden(switcher.isOn)
        }
        
        self.refreshUI()
    }
    
    // MARK: - CPDFFormArrowStyleViewDelegate
    func CPDFFormArrowStyleViewClicked(_ view: CPDFFormArrowStyleView) {
        self.arrowStyleTableView = CPDFArrowStyleTableView(frame: self.view.bounds)

        self.arrowStyleTableView?.delegate = self
        self.arrowStyleTableView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        self.arrowStyleTableView?.style = self.buttonWidget?.widgetCheckStyle() ?? .none
        if(arrowStyleTableView != nil) {
            self.view.addSubview(self.arrowStyleTableView!)
        }
    }
    
    // MARK: - CPDFArrowStyleTableViewDelegate
    func setCPDFArrowStyleTableView(_ arrowStyleTableView: CPDFArrowStyleTableView, style widgetButtonStyle: CPDFWidgetButtonStyle) {
        self.buttonWidget?.setWidgetCheck(widgetButtonStyle)
        
        switch widgetButtonStyle {
        case .check:
            self.arrowStyleView?.arrowImageView?.image = UIImage(named: "CPDFFormCheck", in: Bundle(for: type(of: self)), compatibleWith: nil)
        case .circle:
            self.arrowStyleView?.arrowImageView?.image = UIImage(named: "CPDFFormCircle", in: Bundle(for: type(of: self)), compatibleWith: nil)
        case .cross:
            self.arrowStyleView?.arrowImageView?.image = UIImage(named: "CPDFFormCross", in: Bundle(for: type(of: self)), compatibleWith: nil)
        case .diamond:
            self.arrowStyleView?.arrowImageView?.image = UIImage(named: "CPDFFormDiamond", in: Bundle(for: type(of: self)), compatibleWith: nil)
        case .square:
            self.arrowStyleView?.arrowImageView?.image = UIImage(named: "CPDFFormSquare", in: Bundle(for: type(of: self)), compatibleWith: nil)
        case .star:
            self.arrowStyleView?.arrowImageView?.image = UIImage(named: "CPDFFormStar", in: Bundle(for: type(of: self)), compatibleWith: nil)
        default: break
        }
        
        self.refreshUI()
    }
}

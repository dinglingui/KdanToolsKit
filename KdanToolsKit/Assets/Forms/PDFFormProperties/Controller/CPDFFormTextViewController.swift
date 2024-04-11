//
//  CPDFFormTextViewController.swift
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

class CPDFFormTextViewController: CPDFFormBaseViewController, CPDFColorSelectViewDelegate, CPDFThicknessSliderViewDelegate, CPDFFormTextFiledViewDelegate, CPDFFormSwitchViewDelegate, CPDFFontSettingViewDelegate, CPDFFontAlignViewDelegate, CPDFFormInputTextViewDelegate, UIColorPickerViewControllerDelegate, CPDFColorPickerViewDelegate, CPDFFontStyleTableViewDelegate {
    
    var annotManage: CAnnotationManage?
    
    var splitView: UIView?
    var borderColorView: CPDFColorSelectView?
    var backGroundColorView: CPDFColorSelectView?
    var textColorView: CPDFColorSelectView?
    var sizeThickNessView: CPDFThicknessSliderView?
    var textFiledView: CPDFFormTextFieldView?
    var hideFormView: CPDFFormSwitchView?
    var multiLineView: CPDFFormSwitchView?
    var fontSettingView: CPDFFontSettingSubView?
    var fontAlignView: CPDFFontAlignView?
    var inputTextView: CPDFFormInputTextView?
    var colorPicker: CPDFColorPickerView?
    var currentSelectColorView: CPDFColorSelectView?
    
    var fontStyleTableView: CPDFFontStyleTableView?
    
    var baseName: String?
    private var baseStyleName:String = ""
    var fontSize: CGFloat = 0.0
    
    var textWidget:CPDFTextWidgetAnnotation? {
        didSet {
            // field Name
            self.textFiledView?.contentField?.text = textWidget?.fieldName()
            // string value
            self.inputTextView?.contentField?.text = textWidget?.stringValue
            // alignment
            self.fontAlignView?.alignment = textWidget?.alignment ?? .left
            // border color
            if textWidget?.borderColor == nil {
                self.borderColorView?.selectedColor = nil
            } else {
                self.borderColorView?.selectedColor = textWidget?.borderColor
            }
            
            if textWidget?.backgroundColor == nil {
                self.backGroundColorView?.selectedColor = nil
                refreshUI()
            } else {
                self.backGroundColorView?.selectedColor = textWidget?.backgroundColor
            }
            
            if textWidget?.fontColor == nil {
                self.textColorView?.selectedColor = UIColor.black
                textWidget?.fontColor = self.textColorView?.selectedColor
            } else {
                self.textColorView?.selectedColor = textWidget?.fontColor
            }
            
            
            if(self.textWidget?.fontSize == 0) {
                self.fontSize = 14
                self.sizeThickNessView?.defaultValue = 0.14
                refreshUI()
            }  else {
                self.fontSize = self.textWidget?.fontSize ?? 14
                self.sizeThickNessView?.defaultValue = (self.fontSize) / 100.0
            }
            let pdfFont = textWidget?.cFont
            
            baseName = pdfFont?.familyName ?? "Helvetica"
            baseStyleName = pdfFont?.styleName ?? ""
            if(baseStyleName.count == 0) {
                let datasArray:[String] = CPDFFont.fontNames(forFamilyName: baseName ?? "Helvetica")
                baseStyleName = datasArray.first ?? ""
            }
            self.fontSettingView?.fontNameSelectLabel?.text = baseName
            self.fontSettingView?.fontStyleNameSelectLabel?.text = baseStyleName

            self.hideFormView?.switcher?.isOn = textWidget?.isHidden() == true
            self.multiLineView?.switcher?.isOn = textWidget?.isMultiline == true
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
        self.borderColorView = CPDFColorSelectView.init(frame: CGRect.zero)
        self.borderColorView?.delegate = self
        self.borderColorView?.colorLabel?.text = NSLocalizedString("Stroke Color", comment: "")
        self.borderColorView?.colorLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        self.borderColorView?.colorLabel?.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        self.borderColorView?.colorPickerView?.showsHorizontalScrollIndicator = false
        
        self.backGroundColorView = CPDFColorSelectView.init(frame: CGRect.zero)
        self.backGroundColorView?.colorLabel?.text = NSLocalizedString("Background Color", comment: "")
        self.backGroundColorView?.delegate = self
        self.backGroundColorView?.colorLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        self.backGroundColorView?.colorLabel?.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        self.backGroundColorView?.colorPickerView?.showsHorizontalScrollIndicator = false
        
        self.textColorView = CPDFColorSelectView.init(frame: CGRect.zero)
        self.textColorView?.colorLabel?.text = NSLocalizedString("Font Color", comment: "")
        self.textColorView?.colorLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        self.textColorView?.delegate = self
        self.textColorView?.colorLabel?.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        self.textColorView?.colorPickerView?.showsHorizontalScrollIndicator = false
        if(borderColorView != nil) {
            scrcollView?.addSubview(borderColorView!)
        }
        
        if(backGroundColorView != nil) {
            scrcollView?.addSubview(backGroundColorView!)
        }
        
        if(textColorView != nil) {
            scrcollView?.addSubview(textColorView!)
        }
        
        self.sizeThickNessView = CPDFThicknessSliderView(frame: CGRect.zero)
        self.sizeThickNessView?.titleLabel?.text = NSLocalizedString("Font Size", comment: "")
        self.sizeThickNessView?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        self.sizeThickNessView?.delegate = self
        self.sizeThickNessView?.thick = 10
        self.sizeThickNessView?.titleLabel?.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        if(sizeThickNessView != nil) {
            scrcollView?.addSubview(sizeThickNessView!)
        }
        
        self.textFiledView = CPDFFormTextFieldView(frame: CGRect.zero)
        self.textFiledView?.delegate = self
        if(textFiledView != nil) {
            scrcollView?.addSubview(textFiledView!)
        }
        
        self.multiLineView = CPDFFormSwitchView(frame: CGRect.zero)
        self.multiLineView?.delegate = self
        self.multiLineView?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        self.multiLineView?.titleLabel?.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        self.multiLineView?.titleLabel?.text = NSLocalizedString("Multi-line", comment: "")
        if(multiLineView != nil) {
            scrcollView?.addSubview(multiLineView!)
        }
        
        self.fontSettingView = CPDFFontSettingSubView(frame: CGRect.zero)
        self.fontSettingView?.fontNameLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        self.fontSettingView?.delegate = self
        self.fontSettingView?.fontNameLabel?.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        self.fontSettingView?.fontNameLabel?.text = NSLocalizedString("Font", comment: "")
        if(fontSettingView != nil) {
            scrcollView?.addSubview(fontSettingView!)
        }
        
        self.fontAlignView = CPDFFontAlignView(frame: CGRect.zero)
        self.fontAlignView?.delegate = self
        if(fontAlignView != nil) {
            scrcollView?.addSubview(fontAlignView!)
        }
        
        self.inputTextView = CPDFFormInputTextView(frame: CGRect.zero)
        self.inputTextView?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        self.inputTextView?.titleLabel?.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        self.inputTextView?.titleLabel?.text = NSLocalizedString("Default Value", comment: "")
        self.inputTextView?.delegate = self
        if(inputTextView != nil) {
            scrcollView?.addSubview(inputTextView!)
        }
        
        self.baseName = "Helvetica"
        self.fontSettingView?.fontNameSelectLabel?.text = self.baseName
        let datasArray:[String] = CPDFFont.fontNames(forFamilyName: baseName ?? "Helvetica")
        baseStyleName = datasArray.first ?? ""

        self.fontSettingView?.fontStyleNameSelectLabel?.text = baseStyleName
        self.textWidget = self.annotManage?.annotStyle?.annotations.first as? CPDFTextWidgetAnnotation
    }
    
   
    override func commomInitTitle() {
        self.titleLabel?.text = NSLocalizedString("Text Field", comment: "")
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
            preferredContentSize = CGSize(width: view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? 310 : 620)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrcollView?.frame = CGRect(x: 0, y: 60, width: view.frame.size.width, height: view.frame.size.height - 60)
        scrcollView?.contentSize = CGSize(width: view.frame.size.width, height: 680)
        scrcollView?.showsVerticalScrollIndicator = false
        
        if #available(iOS 11.0, *) {
            textFiledView?.frame = CGRect(x: view.safeAreaInsets.left, y: 8, width: view.frame.size.width - view.safeAreaInsets.left, height: 65)
            borderColorView?.frame = CGRect(x: view.safeAreaInsets.left, y: (textFiledView?.frame.maxY ?? 0) + 8, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 74)
            backGroundColorView?.frame = CGRect(x: view.safeAreaInsets.left, y: (borderColorView?.frame.maxY ?? 0) + 8, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 74)
            textColorView?.frame = CGRect(x: view.safeAreaInsets.left, y: (backGroundColorView?.frame.maxY ?? 0) + 8, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 74)
            fontSettingView?.frame = CGRect(x: view.safeAreaInsets.left, y: (textColorView?.frame.maxY ?? 0) + 16, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 30)
            fontAlignView?.frame = CGRect(x: view.safeAreaInsets.left, y: (fontSettingView?.frame.maxY ?? 0) + 8, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 48)
            sizeThickNessView?.frame = CGRect(x: view.safeAreaInsets.left, y: (fontAlignView?.frame.maxY ?? 0) + 8, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 82)
            inputTextView?.frame = CGRect(x: view.safeAreaInsets.left, y: (sizeThickNessView?.frame.maxY ?? 0) + 8, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 120)
            multiLineView?.frame = CGRect(x: view.safeAreaInsets.left, y: (inputTextView?.frame.maxY ?? 0) + 8, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 44)
        } else {
            textFiledView?.frame = CGRect(x: 0, y: 8, width: view.bounds.size.width, height: 60)
            borderColorView?.frame = CGRect(x: 0, y: (textFiledView?.frame.maxY ?? 0) + 8, width: view.frame.size.width, height: 74)
            backGroundColorView?.frame = CGRect(x: 0, y: (borderColorView?.frame.maxY ?? 0) + 8, width: view.frame.size.width, height: 74)
            textColorView?.frame = CGRect(x: 0, y: (backGroundColorView?.frame.maxY ?? 0) + 8, width: view.frame.size.width, height: 74)
            fontSettingView?.frame = CGRect(x: 0, y: (textColorView?.frame.maxY ?? 0) + 8, width: view.frame.size.width, height: 30)
            fontAlignView?.frame = CGRect(x: 0, y: (fontSettingView?.frame.maxY ?? 0) + 8, width: view.frame.size.width, height: 48)
            sizeThickNessView?.frame = CGRect(x: 0, y: (fontAlignView?.frame.maxY ?? 0) + 8, width: view.frame.size.width, height: ((view.frame.size.height) / 9) * 2)
            inputTextView?.frame = CGRect(x: 0, y: (sizeThickNessView?.frame.maxY ?? 0) + 8, width: view.frame.size.width, height: 120)
            multiLineView?.frame = CGRect(x: 0, y: (inputTextView?.frame.maxY ?? 0) + 8, width: view.frame.size.width, height: 44)
        }
    }
    
    func refreshUI() {
        self.textWidget?.updateAppearanceStream()
        let page = textWidget?.page
        if page != nil {
            annotManage?.pdfListView?.setNeedsDisplayFor(page)
        }
    }
    
    // MARK: - Action
    @objc override func buttonItemClicked_back(_ button: UIButton) {
        self.dismiss(animated:true)
    }
    
    // MARK: - CPDFFormTextFiledViewDelegate
    func setCPDFFormTextFieldView(_ view: CPDFFormTextFieldView, text: String) {
        self.textWidget?.setFieldName(text)
        self.refreshUI()
    }
    
    func SetCPDFFormInputTextView(_ view: CPDFFormInputTextView, text: String) {
        self.textWidget?.stringValue = text
        self.refreshUI()
    }
    
    // MARK: - CPDFColorSelectViewDelegate
    func selectColorView(_ select: CPDFColorSelectView, color: UIColor) {
        self.currentSelectColorView = select
        
        if self.borderColorView == select {
            self.textWidget?.borderColor = color
        } else if self.backGroundColorView == select {
            self.textWidget?.backgroundColor = color
        } else if self.textColorView == select {
            self.textWidget?.fontColor = color
        }
        self.refreshUI()
    }
    
    func selectColorView(_ select: CPDFColorSelectView) {
        self.currentSelectColorView = select
        if #available(iOS 14.0, *) {
            let picker = UIColorPickerViewController()
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        } else {
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
        refreshUI()
    }
    
    // MARK: - CPDFColorPickerViewDelegate
    func pickerView(_ colorPickerView: CPDFColorPickerView, color: UIColor) {
        if self.currentSelectColorView == self.borderColorView {
            self.textWidget?.borderColor = color
        } else if self.currentSelectColorView == self.backGroundColorView {
            self.textWidget?.backgroundColor = color
        } else if self.currentSelectColorView == self.textColorView {
            self.textWidget?.fontColor = color
        }
        
        self.updatePreferredContentSize(with: self.traitCollection)
        self.refreshUI()
    }
    
    // MARK: - UIColorPickerViewControllerDelegate
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        if self.currentSelectColorView == self.borderColorView {
            self.textWidget?.borderColor = viewController.selectedColor
        } else if self.currentSelectColorView == self.backGroundColorView {
            self.textWidget?.backgroundColor = viewController.selectedColor
        } else if self.currentSelectColorView == self.textColorView {
            self.textWidget?.fontColor = viewController.selectedColor
        }
        
        self.refreshUI()
    }
    
    // MARK: - CPDFFormSwitchViewDelegate
    func switchAction(in view: CPDFFormSwitchView, switcher: UISwitch) {
        if view == self.hideFormView {
            if switcher.isOn {
                let annotation = self.annotManage?.annotStyle?.annotations.first
                if(annotation != nil) {
                    if (self.annotManage?.pdfListView?.activeAnnotations?.contains(annotation!) == true) {
                        self.annotManage?.pdfListView?.updateActiveAnnotations([])
                    }
                }
            }
            
            self.textWidget?.setHidden(switcher.isOn)
        } else if view == self.multiLineView {
            self.textWidget?.isMultiline = switcher.isOn
        }
        
        self.refreshUI()
        
    }
    
    // MARK: - CPDFThicknessSliderViewDelegate
    func thicknessSliderView(_ opacitySliderView: CPDFThicknessSliderView, thickness: CGFloat) {
        self.fontSize = thickness * 10
        self.textWidget?.fontSize = fontSize
        self.refreshUI()
    }
    
    // MARK: - CPDFFontAlignViewDelegate
    func setCPDFFontAlignView(view: CPDFFontAlignView, algnment: NSTextAlignment) {
        self.textWidget?.alignment = algnment
        self.refreshUI()
    }
    
    // MARK: - CPDFFontSettingViewDelegate
    func setCPDFFontSettingViewFontSelect(view: CPDFFontSettingSubView,isFontStyle:Bool) {
        fontStyleTableView = CPDFFontStyleTableView(frame: self.view.bounds, familyNames: view.fontNameSelectLabel?.text ?? "Helvetica", styleName: baseStyleName,isFontStyle: isFontStyle)
        self.fontStyleTableView?.delegate = self
        self.fontStyleTableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.fontStyleTableView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if(fontStyleTableView != nil) {
            self.view.addSubview(self.fontStyleTableView!)
        }

    }
    
    // MARK: - CPDFFontStyleTableViewDelegate
    func fontStyleTableView(_ fontStyleTableView: CPDFFontStyleTableView, fontName: String, isFontStyle: Bool) {
        var familyName = baseName
        if(isFontStyle) {
            baseStyleName = fontName
        } else {
            baseName = fontName;
            familyName = fontName
            
            let datasArray:[String] = CPDFFont.fontNames(forFamilyName: familyName ?? "Helvetica")
            baseStyleName = datasArray.first ?? ""
        }
        
        let pdfFont = CPDFFont.init(familyName: baseName ?? "Helvetica", fontStyle: baseStyleName)
        textWidget?.cFont = pdfFont
        
        self.fontSettingView?.fontNameSelectLabel?.text = familyName
        self.fontSettingView?.fontStyleNameSelectLabel?.text = baseStyleName
        self.refreshUI()
    }
    
}

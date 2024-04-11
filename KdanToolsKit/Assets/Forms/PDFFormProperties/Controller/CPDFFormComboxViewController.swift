//
//  CPDFFormComboxViewController.swift
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

class CPDFFormComboxViewController: CPDFFormBaseViewController, CPDFColorSelectViewDelegate, CPDFThicknessSliderViewDelegate, CPDFFormTextFiledViewDelegate, CPDFFontSettingViewDelegate, UIColorPickerViewControllerDelegate, CPDFColorPickerViewDelegate, CPDFFontStyleTableViewDelegate {
    var annotManage: CAnnotationManage?
    
    var borderColorView: CPDFColorSelectView?
    var backGroundColorView: CPDFColorSelectView?
    var textColorView: CPDFColorSelectView?
    var sizeThickNessView: CPDFThicknessSliderView?
    var textFiledView: CPDFFormTextFieldView?
    var hideFormView: CPDFFormSwitchView?
    var fontSettingView: CPDFFontSettingSubView?
    var colorPicker: CPDFColorPickerView?
    var currentSelectColorView: CPDFColorSelectView?
    var fontStyleTableView: CPDFFontStyleTableView?
    var baseName: String?
    private var baseStyleName:String = ""
    var fontSize: CGFloat = 0.0
    
    var comboxChoiceWidget: CPDFChoiceWidgetAnnotation? {
        didSet {
            // field Name
            textFiledView?.contentField?.text = comboxChoiceWidget?.fieldName()
            // border color
            if comboxChoiceWidget?.borderColor == nil {
                refreshUI()
            } else {
                borderColorView?.selectedColor = comboxChoiceWidget?.borderColor
            }
            // background color
            if comboxChoiceWidget?.backgroundColor == nil {
                refreshUI()
            } else {
                backGroundColorView?.selectedColor = comboxChoiceWidget?.backgroundColor
            }
            // text color
            if comboxChoiceWidget?.fontColor == nil {
                textColorView?.selectedColor = UIColor.black
                comboxChoiceWidget?.fontColor = textColorView?.selectedColor
                refreshUI()
            } else {
                textColorView?.selectedColor = comboxChoiceWidget?.fontColor
            }
            // text content
            if comboxChoiceWidget?.fontSize ==  0 {
                fontSize = 14
                sizeThickNessView?.defaultValue = 0.14
            } else {
                fontSize = comboxChoiceWidget?.fontSize ?? 14
                sizeThickNessView?.defaultValue = CGFloat(fontSize / 100.0)
            }
            
            let pdfFont = comboxChoiceWidget?.cFont
            
            baseName = pdfFont?.familyName ?? "Helvetica"
            baseStyleName = pdfFont?.styleName ?? ""
            if(baseStyleName.count == 0) {
                let datasArray:[String] = CPDFFont.fontNames(forFamilyName: baseName ?? "Helvetica")
                baseStyleName = datasArray.first ?? ""
            }
            self.fontSettingView?.fontNameSelectLabel?.text = baseName
            self.fontSettingView?.fontStyleNameSelectLabel?.text = baseStyleName

            // hide form
            hideFormView?.switcher?.isOn = comboxChoiceWidget?.isHidden() == true
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
        // Do any additional setup after loading the view.
        borderColorView = CPDFColorSelectView.init(frame: CGRect.zero)
        borderColorView?.delegate = self
        borderColorView?.colorLabel?.text = NSLocalizedString("Stroke Color", comment: "")
        borderColorView?.colorLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        borderColorView?.colorLabel?.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        borderColorView?.colorPickerView?.showsHorizontalScrollIndicator = false
        
        backGroundColorView = CPDFColorSelectView(frame: CGRect.zero)
        backGroundColorView?.colorLabel?.text = NSLocalizedString("Background Color", comment: "")
        backGroundColorView?.colorLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        backGroundColorView?.colorLabel?.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        backGroundColorView?.colorPickerView?.showsHorizontalScrollIndicator = false
        backGroundColorView?.delegate = self
        
        textColorView = CPDFColorSelectView(frame: CGRect.zero)
        textColorView?.colorLabel?.text = NSLocalizedString("Font Color", comment: "")
        textColorView?.colorLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        textColorView?.colorLabel?.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        textColorView?.colorPickerView?.showsHorizontalScrollIndicator = false
        textColorView?.delegate = self
        
        if(borderColorView !== nil) {
            scrcollView?.addSubview(borderColorView!)
        }
        if(backGroundColorView !== nil) {
            scrcollView?.addSubview(backGroundColorView!)
        }
        
        if(textColorView !== nil) {
            scrcollView?.addSubview(textColorView!)
        }
        
        sizeThickNessView = CPDFThicknessSliderView(frame: CGRect.zero)
        sizeThickNessView?.titleLabel?.text = NSLocalizedString("Font Size", comment: "")
        sizeThickNessView?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        sizeThickNessView?.titleLabel?.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        if(sizeThickNessView !== nil) {
            scrcollView?.addSubview(sizeThickNessView!)
        }
        sizeThickNessView?.thick = 10.0
        sizeThickNessView?.delegate = self
        
        textFiledView = CPDFFormTextFieldView(frame: CGRect.zero)
        textFiledView?.delegate = self
        if(textFiledView !== nil) {
            scrcollView?.addSubview(textFiledView!)
        }
        
        fontSettingView = CPDFFontSettingSubView(frame: CGRect.zero)
        fontSettingView?.fontNameLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        fontSettingView?.fontNameLabel?.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        fontSettingView?.fontNameLabel?.text = NSLocalizedString("Font", comment: "")
        fontSettingView?.delegate = self
        if(fontSettingView !== nil) {
            scrcollView?.addSubview(fontSettingView!)
        }
        
        baseName = "Helvetica"
        fontSettingView?.fontNameSelectLabel?.text = baseName
        let datasArray:[String] = CPDFFont.fontNames(forFamilyName: baseName ?? "Helvetica")
        baseStyleName = datasArray.first ?? ""

        self.fontSettingView?.fontStyleNameSelectLabel?.text = baseStyleName

        comboxChoiceWidget = annotManage?.annotStyle?.annotations.first as? CPDFChoiceWidgetAnnotation
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
    
    override func commomInitTitle() {
        self.titleLabel?.text = NSLocalizedString("Combo Button", comment: "")
    }
    
    func refreshUI() {
        comboxChoiceWidget?.updateAppearanceStream()
        let page = comboxChoiceWidget?.page
        if page != nil {
            self.annotManage?.pdfListView?.setNeedsDisplayFor(page)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrcollView?.frame = CGRect(x: 0, y: 60, width: view.frame.size.width, height: view.frame.size.height - 60)
        scrcollView?.contentSize = CGSize(width: view.frame.size.width, height: 550)
        scrcollView?.showsVerticalScrollIndicator = false
        
        if #available(iOS 11.0, *) {
            textFiledView?.frame = CGRect(x: view.safeAreaInsets.left, y: 8, width: view.frame.size.width - view.safeAreaInsets.left, height: 65)
            self.borderColorView?.frame = CGRect(x: view.safeAreaInsets.left, y: (textFiledView?.frame.maxY ?? 0) + 8, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 74)
            self.backGroundColorView?.frame = CGRect(x: view.safeAreaInsets.left, y: (borderColorView?.frame.maxY ?? 0) + 8, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 74)
            self.textColorView?.frame = CGRect(x: view.safeAreaInsets.left, y: (backGroundColorView?.frame.maxY ?? 0) + 8, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 74)
            self.fontSettingView?.frame = CGRect(x: view.safeAreaInsets.left, y: (textColorView?.frame.maxY ?? 0) + 16, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 30)
            self.sizeThickNessView?.frame = CGRect(x: view.safeAreaInsets.left, y: (fontSettingView?.frame.maxY ?? 0) + 8, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 82)
        } else {
            self.textFiledView?.frame = CGRect(x: 0, y: 8, width: view.bounds.size.width, height: 60)
            self.borderColorView?.frame = CGRect(x: 0, y: (textFiledView?.frame.maxY ?? 0) + 8, width: view.frame.size.width, height: 74)
            self.backGroundColorView?.frame = CGRect(x: 0, y: (borderColorView?.frame.maxY ?? 0) + 8, width: view.frame.size.width, height: 74)
            self.textColorView?.frame = CGRect(x: 0, y: (backGroundColorView?.frame.maxY ?? 0) + 8, width: view.frame.size.width, height: 74)
            self.fontSettingView?.frame = CGRect(x: 0, y: (textColorView?.frame.maxY ?? 0) + 16, width: view.frame.size.width, height: 30)
            self.sizeThickNessView?.frame = CGRect(x: 0, y: (fontSettingView?.frame.maxY ?? 0) + 8, width: view.frame.size.width, height: 82)
        }
        self.textFiledView?.contentField?.text = comboxChoiceWidget?.fieldName()
    }
    
    // MARK: - Action
    @objc override func buttonItemClicked_back(_ button: UIButton) {
        self.dismiss(animated:true)
    }
    
    // MARK: - CPDFFormTextFiledViewDelegate
    func setCPDFFormTextFieldView(_ view: CPDFFormTextFieldView, text: String) {
        self.comboxChoiceWidget?.setFieldName(text)
        self.refreshUI()
    }
    
    // MARK: - CPDFColorSelectViewDelegate
    func selectColorView(_ select: CPDFColorSelectView, color: UIColor) {
        self.currentSelectColorView = select
        
        if self.borderColorView == select {
            self.comboxChoiceWidget?.borderColor = color
        } else if self.backGroundColorView == select {
            self.comboxChoiceWidget?.backgroundColor = color
        } else if self.textColorView == select {
            self.comboxChoiceWidget?.fontColor = color
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
            self.comboxChoiceWidget?.borderColor = color
        } else if self.currentSelectColorView == self.backGroundColorView {
            self.comboxChoiceWidget?.backgroundColor = color
        } else if self.currentSelectColorView == self.textColorView {
            self.comboxChoiceWidget?.fontColor = color
        }
        
        self.updatePreferredContentSize(with: self.traitCollection)
        self.refreshUI()
    }
    
    // MARK: - UIColorPickerViewControllerDelegate
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        if self.currentSelectColorView == self.borderColorView {
            self.comboxChoiceWidget?.borderColor = viewController.selectedColor
        } else if self.currentSelectColorView == self.backGroundColorView {
            self.comboxChoiceWidget?.backgroundColor = viewController.selectedColor
        } else if self.currentSelectColorView == self.textColorView {
            self.comboxChoiceWidget?.fontColor = viewController.selectedColor
        }
        
        self.refreshUI()
    }
    
    // MARK: - CPDFThicknessSliderViewDelegate
    func thicknessSliderView(_ opacitySliderView: CPDFThicknessSliderView, thickness: CGFloat) {
        self.fontSize = thickness * 10
        self.comboxChoiceWidget?.fontSize = self.fontSize
        self.refreshUI()
    }
    
    // MARK: - CPDFFontSettingViewDelegate
    func setCPDFFontSettingViewFontSelect(view: CPDFFontSettingSubView,isFontStyle:Bool) {
        fontStyleTableView = CPDFFontStyleTableView(frame: self.view.bounds, familyNames: view.fontNameSelectLabel?.text ?? "Helvetica",styleName: baseStyleName, isFontStyle: isFontStyle)
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
        comboxChoiceWidget?.cFont = pdfFont
        self.fontSettingView?.fontNameSelectLabel?.text = familyName
        self.fontSettingView?.fontStyleNameSelectLabel?.text = baseStyleName
        self.refreshUI()
    }
    
    
}

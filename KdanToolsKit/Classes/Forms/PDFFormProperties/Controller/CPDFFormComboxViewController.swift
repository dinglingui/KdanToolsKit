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
    var isBold: Bool = false
    var isItalic: Bool = false
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
            analyzeFont(comboxChoiceWidget?.font.fontName)
            if comboxChoiceWidget?.font.pointSize ==  0 {
                fontSize = 14
                sizeThickNessView?.defaultValue = 0.14
                refreshUI()
            } else {
                sizeThickNessView?.defaultValue = CGFloat((comboxChoiceWidget?.font.pointSize ?? 14) / 100.0)
                fontSize = comboxChoiceWidget?.font?.pointSize ?? 14
            }
            
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
        
        comboxChoiceWidget = annotManage?.annotStyle?.annotations.first as? CPDFChoiceWidgetAnnotation
    }
    
    func analyzeFont(_ fontName: String?) {
        if fontName == nil {
            fontSettingView?.isBold = false
            fontSettingView?.isItalic = false
            return
        }
        if fontName?.range(of: "Bold") != nil {
            // isBold
            fontSettingView?.isBold = true
            isBold = true
        } else {
            // is not bold
            fontSettingView?.isBold = false
            isBold = false
        }
        
        if fontName?.range(of: "Italic") != nil || fontName?.range(of: "Oblique") != nil {
            // is Italic
            fontSettingView?.isItalic = true
            isItalic = true
        } else {
            // is Not Italic
            fontSettingView?.isItalic = false
            isItalic = false
        }
        
        if fontName?.range(of: "Helvetica") != nil {
            baseName = "Helvetica"
            fontSettingView?.fontNameSelectLabel?.text = baseName
            return
        }
        
        if fontName?.range(of: "Courier") != nil {
            baseName = "Courier"
            fontSettingView?.fontNameSelectLabel?.text = baseName
            return
        }
        
        if fontName?.range(of: "Times") != nil {
            baseName = "Times-Roman"
            fontSettingView?.fontNameSelectLabel?.text = baseName
        }
        
    }
    
    func constructionFontname(_ baseName: String, isBold: Bool, isItalic: Bool) -> String {
        var result: String
        if baseName.range(of: "Times") != nil {
            if isBold || isItalic {
                if isBold && isItalic {
                    return "Times-BoldItalic"
                }
                if isBold {
                    return "Times-Bold"
                }
                if isItalic {
                    return "Times-Italic"
                }
            } else {
                return "Times-Roman"
            }
        }
        
        if isBold || isItalic {
            result = "\(baseName)-"
            
            if isBold {
                result = "\(result)Bold"
            }
            if isItalic {
                result = "\(result)Oblique"
            }
        } else {
            return baseName
        }
        
        return result
        
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
        let fontName = constructionFontname(self.baseName ?? "", isBold: self.isBold, isItalic: self.isItalic)
        comboxChoiceWidget?.font = UIFont(name: fontName, size: self.fontSize)
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
            self.fontSettingView?.frame = CGRect(x: view.safeAreaInsets.left, y: (textColorView?.frame.maxY ?? 0) + 8, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 30)
            self.sizeThickNessView?.frame = CGRect(x: view.safeAreaInsets.left, y: (fontSettingView?.frame.maxY ?? 0), width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 82)
        } else {
            self.textFiledView?.frame = CGRect(x: 0, y: 8, width: view.bounds.size.width, height: 60)
            self.borderColorView?.frame = CGRect(x: 0, y: (textFiledView?.frame.maxY ?? 0) + 8, width: view.frame.size.width, height: 74)
            self.backGroundColorView?.frame = CGRect(x: 0, y: (borderColorView?.frame.maxY ?? 0) + 8, width: view.frame.size.width, height: 74)
            self.textColorView?.frame = CGRect(x: 0, y: (backGroundColorView?.frame.maxY ?? 0) + 8, width: view.frame.size.width, height: 74)
            self.fontSettingView?.frame = CGRect(x: 0, y: (textColorView?.frame.maxY ?? 0) + 8, width: view.frame.size.width, height: 30)
            self.sizeThickNessView?.frame = CGRect(x: 0, y: fontSettingView?.frame.maxY ?? 0, width: view.frame.size.width, height: 82)
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
        self.refreshUI()
    }
    
    // MARK: - CPDFFontSettingViewDelegate
    func setCPDFFontSettingViewFontSelect(view: CPDFFontSettingSubView) {
        self.fontStyleTableView = CPDFFontStyleTableView(frame: self.view.bounds)
        self.fontStyleTableView?.delegate = self
        self.fontStyleTableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.fontStyleTableView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if(fontStyleTableView != nil) {
            self.view.addSubview(self.fontStyleTableView!)
        }
    }
    
    func setCPDFFontSettingView(view: CPDFFontSettingSubView, text: String) {
        
    }
    
    func setCPDFFontSettingView(view: CPDFFontSettingSubView, isItalic: Bool) {
        self.isItalic = isItalic
        self.refreshUI()
    }
    
    func setCPDFFontSettingView(view: CPDFFontSettingSubView, isBold: Bool) {
        self.isBold = isBold
        self.refreshUI()
    }
    
    // MARK: - CPDFFontStyleTableViewDelegate
    func fontStyleTableView(_ fontStyleTableView: CPDFFontStyleTableView, fontName: String) {
        self.baseName = fontName
        self.fontSettingView?.fontNameSelectLabel?.text = fontName
        self.refreshUI()
    }
    
    
}

//
//  CPDFFormButtonViewController.swift
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

class CPDFFormButtonViewController: CPDFFormBaseViewController, CPDFColorSelectViewDelegate, CPDFThicknessSliderViewDelegate, CPDFFormTextFiledViewDelegate, CPDFFontSettingViewDelegate,CPDFColorPickerViewDelegate,UIColorPickerViewControllerDelegate, CPDFFontStyleTableViewDelegate {
    var annotManage: CAnnotationManage?
    
    var borderColorView: CPDFColorSelectView?
    var backGroundColorView: CPDFColorSelectView?
    var textColorView: CPDFColorSelectView?
    var sizeThickNessView: CPDFThicknessSliderView?
    var textFiledView: CPDFFormTextFieldView?
    var buttonTextFiledView: CPDFFormTextFieldView?
    var hideFormView: CPDFFormSwitchView?
    var fontSettingView: CPDFFontSettingSubView?
    var currentSelectColorView: CPDFColorSelectView?
    var fontStyleTableView: CPDFFontStyleTableView?
    
    var colorPicker: CPDFColorPickerView?
    
    var baseName: String?
    var isBold: Bool = false
    var isItalic: Bool = false
    var fontSize: CGFloat = 0.0
    
    var buttonWidget: CPDFButtonWidgetAnnotation? {
        didSet {
            self.textFiledView?.contentField?.text = buttonWidget?.fieldName()
            self.buttonTextFiledView?.contentField?.text = buttonWidget?.caption()
            if buttonWidget?.borderColor == nil {
                refreshUI()
            } else {
                self.borderColorView?.selectedColor = buttonWidget?.borderColor
            }
            if self.buttonWidget?.fontColor == nil {
                self.textColorView?.selectedColor = UIColor.black
                buttonWidget?.fontColor = UIColor.black
                refreshUI()
            } else {
                self.textColorView?.selectedColor = self.buttonWidget?.fontColor
            }
            if buttonWidget?.backgroundColor == nil {
                buttonWidget?.backgroundColor = UIColor(red: 233.0/255.0, green: 233.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                refreshUI()
            } else {
                self.backGroundColorView?.selectedColor = buttonWidget?.backgroundColor
            }
            //Text content
            analyzeFont(buttonWidget?.font.fontName)
            if self.buttonWidget?.font.pointSize == 0 {
                fontSize = 14
                self.sizeThickNessView?.defaultValue = 0.14
                refreshUI()
            } else {
                self.sizeThickNessView?.defaultValue = (buttonWidget?.font.pointSize ?? 0) / 100
                self.fontSize = buttonWidget?.font.pointSize ?? 0
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
        
        // Do any additional setup after loading the view.
        self.borderColorView = CPDFColorSelectView(frame: CGRect.zero)
        self.borderColorView?.delegate = self
        self.borderColorView?.colorLabel?.text = NSLocalizedString("Stroke Color", comment: "")
        self.borderColorView?.colorLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        self.borderColorView?.colorLabel?.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        self.borderColorView?.colorPickerView?.showsHorizontalScrollIndicator = false
        if(borderColorView != nil) {
            self.scrcollView?.addSubview(self.borderColorView!)
        }
        
        self.backGroundColorView = CPDFColorSelectView(frame: CGRect.zero)
        self.backGroundColorView?.colorLabel?.text = NSLocalizedString("Background Color", comment: "")
        self.backGroundColorView?.colorLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        self.backGroundColorView?.colorLabel?.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        self.backGroundColorView?.colorPickerView?.showsHorizontalScrollIndicator = false
        self.backGroundColorView?.delegate = self
        if(backGroundColorView != nil) {
            self.scrcollView?.addSubview(self.backGroundColorView!)
        }
        
        self.textColorView = CPDFColorSelectView(frame: CGRect.zero)
        self.textColorView?.colorLabel?.text = NSLocalizedString("Font Color", comment: "")
        self.textColorView?.colorLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        self.textColorView?.delegate = self
        self.textColorView?.colorLabel?.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        self.textColorView?.colorPickerView?.showsHorizontalScrollIndicator = false
        if(textColorView != nil) {
            self.scrcollView?.addSubview(self.textColorView!)
        }
        
        self.sizeThickNessView = CPDFThicknessSliderView(frame: CGRect.zero)
        self.sizeThickNessView?.titleLabel?.text = NSLocalizedString("Font Size", comment: "")
        self.sizeThickNessView?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        self.sizeThickNessView?.titleLabel?.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        if(sizeThickNessView != nil) {
            self.scrcollView?.addSubview(self.sizeThickNessView!)
        }
        
        self.sizeThickNessView?.thick = 10
        self.sizeThickNessView?.delegate = self
        self.textFiledView = CPDFFormTextFieldView(frame: CGRect.zero)
        self.textFiledView?.delegate = self
        if(textFiledView != nil) {
            self.scrcollView?.addSubview(self.textFiledView!)
        }
        
        self.buttonTextFiledView = CPDFFormTextFieldView(frame: CGRect.zero)
        self.buttonTextFiledView?.titleLabel?.text = NSLocalizedString("Push Button", comment: "")
        self.buttonTextFiledView?.delegate = self
        if(buttonTextFiledView != nil) {
            self.scrcollView?.addSubview(self.buttonTextFiledView!)
        }
        
        self.fontSettingView = CPDFFontSettingSubView.init(frame: CGRect.zero)
        self.fontSettingView?.fontNameLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        self.fontSettingView?.fontNameLabel?.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        self.fontSettingView?.fontNameLabel?.text = NSLocalizedString("Font", comment: "")
        self.fontSettingView?.delegate = self
        if(fontSettingView != nil) {
            self.scrcollView?.addSubview(self.fontSettingView!)
        }
        self.fontSize = 14
        self.baseName = "Helvetica"
        self.fontSettingView?.fontNameSelectLabel?.text = self.baseName
        
        self.buttonWidget = self.annotManage?.annotStyle?.annotations.first as? CPDFButtonWidgetAnnotation
    }
    
    
    func analyzeFont(_ fontName: String?) {
        if fontName == nil {
            fontSettingView?.isBold = false
            fontSettingView?.isItalic = false
            return
        }
        
        if fontName?.range(of: "Bold") != nil {
            fontSettingView?.isBold = true
            isBold = true
        } else {
            fontSettingView?.isBold = false
            isBold = false
        }
        
        if fontName?.range(of: "Italic") != nil || fontName?.range(of: "Oblique") != nil {
            fontSettingView?.isItalic = true
            isItalic = true
        } else {
            fontSettingView?.isItalic = false
            isItalic = false
        }
        
        if fontName?.range(of: "Helvetica") != nil {
            baseName = "Helvetica"
            fontSettingView?.fontNameSelectLabel?.text = baseName
        } else if fontName?.range(of: "Courier") != nil {
            baseName = "Courier"
            fontSettingView?.fontNameSelectLabel?.text = baseName
        } else if fontName?.range(of: "Times") != nil {
            baseName = "Times-Roman"
            fontSettingView?.fontNameSelectLabel?.text = baseName
        }
    }
    
    func constructionFontname(baseName: String, isBold: Bool, isItalic: Bool) -> String {
        var result = ""
        
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
    
    
    override func commomInitTitle() {
        self.titleLabel?.text = NSLocalizedString("Push Button tititle", comment: "")
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
        
        self.scrcollView?.frame = CGRect(x: 0, y: 60, width: self.view.frame.size.width, height: self.view.frame.size.height - 60)
       self.scrcollView?.contentSize = CGSize(width: self.view.frame.size.width, height: 610)
       self.scrcollView?.showsVerticalScrollIndicator = false
       if #available(iOS 11.0, *) {
       self.textFiledView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: 8, width: self.view.frame.size.width - self.view.safeAreaInsets.left, height: 65)
           self.buttonTextFiledView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: (self.textFiledView?.frame.maxY ?? 0) + 8, width: self.view.frame.size.width - self.view.safeAreaInsets.left, height: 65)
           self.borderColorView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: (self.buttonTextFiledView?.frame.maxY ?? 0) + 8, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 74)
           self.backGroundColorView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: (self.borderColorView?.frame.maxY ?? 0) + 8, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 74)
           self.textColorView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: (self.backGroundColorView?.frame.maxY ?? 0) + 8, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 74)
           self.fontSettingView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: (self.textColorView?.frame.maxY ?? 0) + 8, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 30)
           self.sizeThickNessView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: self.fontSettingView?.frame.maxY ?? 0, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 82)
       } else {
       self.textFiledView?.frame = CGRect(x: 0, y: 8, width: self.view.bounds.size.width, height: 60)
           self.buttonTextFiledView?.frame = CGRect(x: 0, y: (self.textFiledView?.frame.maxY ?? 0) + 8, width: self.view.frame.size.width, height: 60)
           self.borderColorView?.frame = CGRect(x: 0, y: (self.buttonTextFiledView?.frame.maxY ?? 0) + 8, width: self.view.frame.size.width, height: 74)
           self.backGroundColorView?.frame = CGRect(x: 0, y: (self.borderColorView?.frame.maxY ?? 0) + 8, width: self.view.frame.size.width, height: 74)
           self.textColorView?.frame = CGRect(x: 0, y: (self.backGroundColorView?.frame.maxY ?? 0) + 8, width: self.view.frame.size.width, height: 74)
           self.fontSettingView?.frame = CGRect(x: 0, y: (self.textColorView?.frame.maxY ?? 0) + 8, width: self.view.frame.size.width, height: 30)
           self.sizeThickNessView?.frame = CGRect(x: 0, y: self.fontSettingView?.frame.maxY ?? 0, width: self.view.frame.size.width, height: 82)
       }

    }
    
    func refreshUI() {
        let fontName = constructionFontname(baseName: baseName ?? "", isBold: isBold, isItalic: isItalic)
        buttonWidget?.font = UIFont(name: fontName, size: fontSize)
        buttonWidget?.updateAppearanceStream()
        let page = buttonWidget?.page
        if page != nil {
            annotManage?.pdfListView?.setNeedsDisplayFor(page)
        }
    }
    
    // MARK: - CPDFFormTextFiledViewDelegate
    func setCPDFFormTextFieldView(_ view: CPDFFormTextFieldView, text: String) {
        if(view == self.textFiledView) {
            self.buttonWidget?.setFieldName(text)
        } else if view == self.buttonTextFiledView {
            self.buttonWidget?.setCaption(text)
        }
        self.refreshUI()
    }
    
    // MARK: - CPDFColorSelectViewDelegate
    func selectColorView(_ select: CPDFColorSelectView, color: UIColor) {
        self.currentSelectColorView = select
        if self.borderColorView == select {
            self.buttonWidget?.borderColor = color
        } else if self.backGroundColorView == select {
            self.buttonWidget?.backgroundColor = color
        } else if self.textColorView == select {
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
        } else if self.currentSelectColorView == self.textColorView {
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
        } else if self.currentSelectColorView == self.textColorView {
            self.buttonWidget?.fontColor = viewController.selectedColor
        }
        
        self.refreshUI()
    }
    
    
    // MARK: - CPDFFormSwitchViewDelegate
    func switchAction(in view: CPDFFormSwitchView, switcher: UISwitch) {
        if switcher.isOn {
            let annotation = self.annotManage?.annotStyle?.annotations.first
            if(annotation != nil) {
                if (self.annotManage?.pdfListView?.activeAnnotations?.contains(annotation!) == true) {
                    self.annotManage?.pdfListView?.updateActiveAnnotations([])
                }
            }
        }
        self.buttonWidget?.setHidden(switcher.isOn)
        
        self.refreshUI()
    }
    
    // MARK: - CPDFThicknessSliderViewDelegate
    func thicknessSliderView(_ opacitySliderView: CPDFThicknessSliderView, thickness: CGFloat) {
        self.fontSize = thickness * 10
        self.refreshUI()
    }
    
    // MARK: - CPDFFontSettingViewDelegate
    func CPDFFontSettingView(view: CPDFFontSettingSubView, text: String) {
        
    }
    
    func setCPDFFontSettingView(view: CPDFFontSettingSubView, isBold: Bool) {
        self.isBold = isBold
        self.refreshUI()
    }
    
    func setCPDFFontSettingView(view: CPDFFontSettingSubView, isItalic: Bool) {
        self.isItalic = isItalic
        self.refreshUI()
    }
    
    // MARK: - CPDFFontSettingViewDelegate
    func setCPDFFontSettingViewFontSelect(view: CPDFFontSettingSubView) {
        self.fontStyleTableView = CPDFFontStyleTableView(frame: self.view.bounds)
        self.fontStyleTableView?.delegate = self
        self.fontStyleTableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.fontStyleTableView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if(self.fontStyleTableView != nil) {
            self.view.addSubview(self.fontStyleTableView!)
        }
        self.refreshUI()
    }
    
    // MARK: - CPDFFontStyleTableViewDelegate
    func fontStyleTableView(_ fontStyleTableView: CPDFFontStyleTableView, fontName: String) {
        self.baseName = fontName
        self.fontSettingView?.fontNameSelectLabel?.text = fontName
        self.refreshUI()
    }
}

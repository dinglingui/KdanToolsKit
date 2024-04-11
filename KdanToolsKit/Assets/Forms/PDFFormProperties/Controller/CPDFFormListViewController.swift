//
//  CPDFFormListViewController.swift
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

class CPDFFormListViewController: CPDFFormBaseViewController, CPDFColorSelectViewDelegate, CPDFThicknessSliderViewDelegate, CPDFFormTextFiledViewDelegate, CPDFFontSettingViewDelegate, UIColorPickerViewControllerDelegate, CPDFColorPickerViewDelegate, CPDFFontStyleTableViewDelegate {
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
    var listChoiceWidget: CPDFChoiceWidgetAnnotation? {
        didSet {
            // field Name
            self.textFiledView?.contentField?.text = listChoiceWidget?.fieldName()
            // border color
            if listChoiceWidget?.borderColor == nil {
                self.refreshUI()
            } else {
                self.borderColorView?.selectedColor = listChoiceWidget?.borderColor
            }
            // background color
            if listChoiceWidget?.backgroundColor == nil {
                self.refreshUI()
            } else {
                self.backGroundColorView?.selectedColor = listChoiceWidget?.backgroundColor
            }
            // Text color
            if listChoiceWidget?.fontColor == nil {
                self.textColorView?.selectedColor = .black
                listChoiceWidget?.fontColor = self.textColorView?.selectedColor
                self.refreshUI()
            } else {
                self.textColorView?.selectedColor = listChoiceWidget?.fontColor
            }
            // Text content
            if(self.listChoiceWidget?.fontSize == 0) {
                self.sizeThickNessView?.defaultValue = 0.14
            } else {
                if self.listChoiceWidget?.fontSize == 0 {
                    self.sizeThickNessView?.defaultValue = 0.14
                    self.fontSize = 14
                   
                } else {
                    self.fontSize = self.listChoiceWidget?.fontSize ?? 14
                    self.sizeThickNessView?.defaultValue = self.fontSize / 100
                }
                let pdfFont = listChoiceWidget?.cFont
                
                baseName = pdfFont?.familyName ?? "Helvetica"
                baseStyleName = pdfFont?.styleName ?? ""
                if(baseStyleName.count == 0) {
                    let datasArray:[String] = CPDFFont.fontNames(forFamilyName: baseName ?? "Helvetica")
                    baseStyleName = datasArray.first ?? ""
                }
                self.fontSettingView?.fontNameSelectLabel?.text = baseName
                self.fontSettingView?.fontStyleNameSelectLabel?.text = baseStyleName
            }
            // hide form
            self.hideFormView?.switcher?.isOn = listChoiceWidget?.isHidden() == true
            
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
        self.backGroundColorView?.colorLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        self.backGroundColorView?.colorLabel?.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        self.backGroundColorView?.colorPickerView?.showsHorizontalScrollIndicator = false
        self.backGroundColorView?.delegate = self
        
        self.textColorView = CPDFColorSelectView.init(frame: CGRect.zero)
        self.textColorView?.colorLabel?.text = NSLocalizedString("Font Color", comment: "")
        self.textColorView?.colorLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        self.textColorView?.colorLabel?.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        self.textColorView?.colorPickerView?.showsHorizontalScrollIndicator = false
        self.textColorView?.delegate = self
        
        if(borderColorView != nil) {
            self.scrcollView?.addSubview(self.borderColorView!)
        }
        if(backGroundColorView != nil) {
            self.scrcollView?.addSubview(self.backGroundColorView!)
        }
        if(textColorView != nil) {
            self.scrcollView?.addSubview(self.textColorView!)
        }
        
        self.sizeThickNessView = CPDFThicknessSliderView.init(frame: CGRect.zero)
        self.sizeThickNessView?.titleLabel?.text = NSLocalizedString("Font Size", comment: "")
        self.sizeThickNessView?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        self.sizeThickNessView?.titleLabel?.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        if(sizeThickNessView != nil) {
            self.scrcollView?.addSubview(self.sizeThickNessView!)
        }
        self.sizeThickNessView?.delegate = self
        self.sizeThickNessView?.thick = 10.0
        
        self.textFiledView = CPDFFormTextFieldView.init(frame: CGRect.zero)
        self.textFiledView?.delegate = self
        if(textFiledView != nil) {
            self.scrcollView?.addSubview(self.textFiledView!)
        }
        
        self.fontSettingView = CPDFFontSettingSubView(frame: CGRect.zero)
        self.fontSettingView?.fontNameLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        self.fontSettingView?.fontNameLabel?.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        self.fontSettingView?.fontNameLabel?.text = NSLocalizedString("Font", comment: "")
        self.fontSettingView?.delegate = self
        
        if(self.fontSettingView != nil) {
            self.scrcollView?.addSubview(self.fontSettingView!)
        }
        self.fontSize = 14
        
        self.baseName = "Helvetica"
        self.fontSettingView?.fontNameSelectLabel?.text = self.baseName
        let datasArray:[String] = CPDFFont.fontNames(forFamilyName: baseName ?? "Helvetica")
        baseStyleName = datasArray.first ?? ""

        self.fontSettingView?.fontStyleNameSelectLabel?.text = baseStyleName

        self.listChoiceWidget = self.annotManage?.annotStyle?.annotations.first as? CPDFChoiceWidgetAnnotation
    }
  
    func refreshUI() {
        listChoiceWidget?.updateAppearanceStream()
        let page = listChoiceWidget?.page
        if page != nil {
            self.annotManage?.pdfListView?.setNeedsDisplayFor(page)
        }
    }
    
    override func commomInitTitle() {
        self.titleLabel?.text = NSLocalizedString("List Box", comment: "")
    }
    
    override func updatePreferredContentSize(with traitCollection: UITraitCollection) {
        if self.colorPicker?.superview != nil {
            let currentDevice = UIDevice.current
            if currentDevice.userInterfaceIdiom == .pad {
                // This is an iPad
                self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: 520)
            } else {
                // This is an iPhone or iPod touch
                self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: 320)
            }
        } else {
            self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? 350 : 600)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.scrcollView?.frame = CGRect(x: 0, y: 60, width: self.view.frame.size.width, height: self.view.frame.size.height-60)
        self.scrcollView?.contentSize = CGSize(width: self.view.frame.size.width, height: 550)
        self.scrcollView?.showsVerticalScrollIndicator = false
        if #available(iOS 11.0, *) {
            self.textFiledView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: 8, width: self.view.frame.size.width - self.view.safeAreaInsets.left, height: 65)
            self.borderColorView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: (self.textFiledView?.frame.maxY ?? 0)+8, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 74)
            self.backGroundColorView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: (self.borderColorView?.frame.maxY ?? 0)+8, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 74)
            self.textColorView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: (self.backGroundColorView?.frame.maxY ?? 0)+8, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 74)
            self.fontSettingView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: (self.textColorView?.frame.maxY ?? 0)+16, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 30)
            self.sizeThickNessView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: (self.fontSettingView?.frame.maxY ?? 0)+8, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 82)
        } else {
            self.textFiledView?.frame = CGRect(x: 0, y: 8, width: self.view.bounds.size.width, height: 60)
            self.borderColorView?.frame = CGRect(x: 0, y: (self.textFiledView?.frame.maxY ?? 0)+8, width: self.view.frame.size.width, height: 74)
            self.backGroundColorView?.frame = CGRect(x: 0, y: (self.borderColorView?.frame.maxY ?? 0)+8, width: self.view.frame.size.width, height: 74)
            self.textColorView?.frame = CGRect(x: 0, y: (self.backGroundColorView?.frame.maxY ?? 0)+8, width: self.view.frame.size.width, height: 74)
            self.fontSettingView?.frame = CGRect(x: 0, y: (self.textColorView?.frame.maxY ?? 0)+16, width: self.view.frame.size.width, height: 30)
            self.sizeThickNessView?.frame = CGRect(x: 0, y: (self.fontSettingView?.frame.maxY ?? 0)+8, width: self.view.frame.size.width, height: 82)
        }
        
    }
    
    
    
    // MARK: - Action
    @objc override func buttonItemClicked_back(_ button: UIButton) {
        self.dismiss(animated:true)
    }
    
    // MARK: - CPDFFormTextFiledViewDelegate
    func setCPDFFormTextFieldView(_ view: CPDFFormTextFieldView, text: String) {
        self.listChoiceWidget?.setFieldName(text)
        self.refreshUI()
    }
    
    // MARK: - CPDFColorSelectViewDelegate
    func selectColorView(_ select: CPDFColorSelectView, color: UIColor) {
        self.currentSelectColorView = select
        if self.borderColorView == select {
            self.listChoiceWidget?.borderColor = color
        } else if self.backGroundColorView == select {
            self.listChoiceWidget?.backgroundColor = color
        } else if self.textColorView == select {
            self.listChoiceWidget?.fontColor = color
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
            self.listChoiceWidget?.borderColor = color
        } else if self.currentSelectColorView == self.backGroundColorView {
            self.listChoiceWidget?.backgroundColor = color
        } else if self.currentSelectColorView == self.textColorView {
            self.listChoiceWidget?.fontColor = color
        }
        self.updatePreferredContentSize(with: self.traitCollection)
        self.refreshUI()
    }
    
    // MARK: - UIColorPickerViewControllerDelegate
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        if self.currentSelectColorView == self.borderColorView {
            self.listChoiceWidget?.borderColor = viewController.selectedColor
        } else if self.currentSelectColorView == self.backGroundColorView {
            self.listChoiceWidget?.backgroundColor = viewController.selectedColor
        } else if self.currentSelectColorView == self.textColorView {
            self.listChoiceWidget?.fontColor = viewController.selectedColor
        }
        
        self.refreshUI()
    }

    // MARK: - CPDFThicknessSliderViewDelegate
    func thicknessSliderView(_ opacitySliderView: CPDFThicknessSliderView, thickness: CGFloat) {
        self.fontSize = thickness * 10
        self.listChoiceWidget?.fontSize = self.fontSize
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
        self.refreshUI()
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
        listChoiceWidget?.cFont = pdfFont
        
        self.fontSettingView?.fontNameSelectLabel?.text = familyName
        self.fontSettingView?.fontStyleNameSelectLabel?.text = baseStyleName
        self.refreshUI()
    }
    
}

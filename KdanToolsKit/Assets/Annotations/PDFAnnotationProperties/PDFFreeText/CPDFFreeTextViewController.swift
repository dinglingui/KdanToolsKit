//
//  CPDFFreeTextViewController.swift
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

@objc protocol CPDFFreeTextViewControllerDelegate: AnyObject {
    @objc optional func freeTextViewController(_ freeTextViewController: CPDFFreeTextViewController, annotStyle: CAnnotStyle)
}

class CPDFFreeTextViewController: CPDFAnnotationBaseViewController, CPDFThicknessSliderViewDelegate, CPDFFontStyleTableViewDelegate {
    weak var delegate: CPDFFreeTextViewControllerDelegate?
    
    var pdfListView: CPDFListView?
        
    private var alignmentLabel: UILabel?
    
    private var leftBtn: UIButton?
    
    private var centerBtn: UIButton?
    
    private var rightBtn: UIButton?
    
    private var fontsizeSliderView: CPDFThicknessSliderView?
        
    private var baseName:String = "Helvetica"
    
    private var baseStyleName:String = ""
    
    private var fontStyleTableView: CPDFFontStyleTableView?
    
    private var dropMenuView: UIView?
    
    private var splitView: UIView?
    
    private var fontSelectBtn: UIButton?
    
    private var dropDownIcon: UIImageView?
    
    private var fontNameLabel: UILabel?
    
    private var fontNameSelectLabel: UILabel?
    
    private var dropStyleMenuView: UIView?
    
    private var splitStyleView: UIView?
    
    private var fontStyleSelectBtn: UIButton?
     
    private var dropStyleDownIcon: UIImageView?
    
    private var fontStyleNameLabel: UILabel?
    
    private var fontStyleNameSelectLabel: UILabel?
    
    // MARK: - Initializers
    
    override init(annotStyle: CAnnotStyle) {
        super.init(annotStyle: annotStyle)
        self.annotStyle = annotStyle
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fontNameLabel = UILabel()
        self.fontNameLabel?.text = NSLocalizedString("Font", comment: "")
        self.fontNameLabel?.font = UIFont.systemFont(ofSize: 12)
        self.fontNameLabel?.textColor = UIColor.gray
        if fontNameLabel != nil {
            self.scrcollView?.addSubview(self.fontNameLabel!)
        }
        
        self.dropMenuView = UIView()
        if dropMenuView != nil {
            self.scrcollView?.addSubview(self.dropMenuView!)
        }
        
        self.splitView = UIView()
        self.splitView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        if splitView != nil {
            self.dropMenuView?.addSubview(self.splitView!)
        }
        
        self.dropDownIcon = UIImageView()
        self.dropDownIcon?.image = UIImage(named: "CPDFEditArrow", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        if dropDownIcon != nil {
            self.dropMenuView?.addSubview(self.dropDownIcon!)
        }
        
        self.fontNameSelectLabel = UILabel()
        self.fontNameSelectLabel?.font = UIFont.systemFont(ofSize: 12)
        if fontNameSelectLabel != nil {
            self.dropMenuView?.addSubview(self.fontNameSelectLabel!)
        }
        
        self.fontSelectBtn = UIButton(type: .custom)
        self.fontSelectBtn?.backgroundColor = UIColor.clear
        self.fontSelectBtn?.addTarget(self, action: #selector(buttonItemClicked_FontStyle), for: .touchUpInside)
        if fontSelectBtn != nil {
            self.dropMenuView?.addSubview(self.fontSelectBtn!)
        }
        
        self.dropStyleMenuView = UIView()
        if dropStyleMenuView != nil {
            self.scrcollView?.addSubview(self.dropStyleMenuView!)
        }
        
        self.splitStyleView = UIView()
        self.splitStyleView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        if splitView != nil {
            self.dropStyleMenuView?.addSubview(self.splitStyleView!)
        }
        
        self.dropStyleDownIcon = UIImageView()
        self.dropStyleDownIcon?.image = UIImage(named: "CPDFEditArrow", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        if dropStyleDownIcon != nil {
            self.dropStyleMenuView?.addSubview(self.dropStyleDownIcon!)
        }
        
        self.fontStyleNameSelectLabel = UILabel()
        self.fontStyleNameSelectLabel?.font = UIFont.systemFont(ofSize: 12)
        if fontStyleNameSelectLabel != nil {
            self.dropStyleMenuView?.addSubview(self.fontStyleNameSelectLabel!)
        }
        
        self.fontStyleSelectBtn = UIButton(type: .custom)
        self.fontStyleSelectBtn?.backgroundColor = UIColor.clear
        self.fontStyleSelectBtn?.addTarget(self, action: #selector(buttonItemClicked_StyleName), for: .touchUpInside)
        if fontStyleSelectBtn != nil {
            self.dropStyleMenuView?.addSubview(self.fontStyleSelectBtn!)
        }
        
        self.alignmentLabel = UILabel()
        self.alignmentLabel?.text = NSLocalizedString("Alignment", comment: "")
        self.alignmentLabel?.textColor = UIColor.gray
        self.alignmentLabel?.font = UIFont.systemFont(ofSize: 12.0)
        if alignmentLabel != nil {
            self.scrcollView?.addSubview(self.alignmentLabel!)
        }
        
        self.leftBtn = UIButton()
        self.leftBtn?.setImage(UIImage(named: "CPDFFreeTextImageLeft", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        self.leftBtn?.addTarget(self, action: #selector(buttonItemClicked_Left), for: .touchUpInside)
        if leftBtn != nil {
            self.scrcollView?.addSubview(self.leftBtn!)
        }
        
        self.centerBtn = UIButton()
        self.centerBtn?.setImage(UIImage(named: "CPDFFreeTextImageCenter", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        self.centerBtn?.addTarget(self, action: #selector(buttonItemClicked_Center), for: .touchUpInside)
        self.scrcollView?.addSubview(self.centerBtn!)
        
        self.rightBtn = UIButton()
        self.rightBtn?.setImage(UIImage(named: "CPDFFreeTextImageRight", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        self.rightBtn?.addTarget(self, action: #selector(buttonItemClicked_Right), for: .touchUpInside)
        if rightBtn != nil {
            self.scrcollView?.addSubview(self.rightBtn!)
        }
        
        self.fontsizeSliderView = CPDFThicknessSliderView()
        self.fontsizeSliderView?.thicknessSlider?.value = 20
        self.fontsizeSliderView?.thicknessSlider?.minimumValue = 1
        self.fontsizeSliderView?.thicknessSlider?.maximumValue = 100
        self.fontsizeSliderView?.titleLabel?.text = NSLocalizedString("Font Size", comment: "")
        self.fontsizeSliderView?.startLabel?.text = "1"
        self.fontsizeSliderView?.delegate = self
        self.fontsizeSliderView?.autoresizingMask = .flexibleWidth
        if fontsizeSliderView != nil {
            self.scrcollView?.addSubview(self.fontsizeSliderView!)
        }
                
        self.view.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.scrcollView?.frame = CGRect(x: 0, y: 170, width: self.view.frame.size.width, height: self.view.frame.size.height-170)
        self.scrcollView?.contentSize = CGSize(width: self.view.frame.size.width, height: 470)
        
        if #available(iOS 11.0, *) {
            self.backBtn?.frame = CGRect(x: self.view.frame.size.width - 60 - self.view.safeAreaInsets.right, y: 5, width: 50, height: 50)
            self.fontNameLabel?.frame = CGRect(x: self.view.safeAreaInsets.left+20, y: 195, width: 30, height: 30)
            
            self.dropMenuView?.frame = CGRect(x: self.view.safeAreaInsets.left+60, y: 195, width: (self.view.frame.size.width - 60 - self.view.safeAreaInsets.right-self.view.safeAreaInsets.left - 10)/5 * 3, height: 30)
            self.dropDownIcon?.frame = CGRect(x: (self.dropMenuView?.bounds.size.width ?? 0) - 24 - 5, y: 3, width: 24, height: 24)
            self.fontNameSelectLabel?.frame = CGRect(x: 10, y: 0, width: (self.dropMenuView?.bounds.size.width ?? 0) - 40, height: 29)
            self.fontSelectBtn?.frame = self.dropMenuView?.bounds ?? CGRect.zero
            self.splitView?.frame = CGRect(x: 0, y: 29, width: self.dropMenuView?.bounds.size.width ?? 0, height: 1)

            self.dropStyleMenuView?.frame = CGRect(x: (self.dropMenuView?.frame.maxX ?? 0) + 10, y: self.dropMenuView?.frame.minY ?? 0, width:(self.view.frame.size.width - 60 - self.view.safeAreaInsets.right-self.view.safeAreaInsets.left - 10)/5 * 2, height: self.dropMenuView?.frame.size.height ?? 0)
            self.dropStyleDownIcon?.frame = CGRect(x: (self.dropStyleMenuView?.bounds.size.width ?? 0) - 24 - 5, y: 3, width: 24, height: 24)
            self.fontStyleNameSelectLabel?.frame = CGRect(x: 10, y: 0, width: (self.dropStyleMenuView?.bounds.size.width ?? 0) - 40, height: 29)
            self.fontStyleSelectBtn?.frame = self.dropStyleMenuView?.bounds ?? CGRect.zero
            self.splitStyleView?.frame = CGRect(x: 0, y: 29, width: (self.dropStyleMenuView?.bounds.size.width ?? 0) - 24 - 5, height: 1)

            self.alignmentLabel?.frame = CGRect(x: self.view.safeAreaInsets.left+20, y: 225, width: 120, height: 45)
            self.leftBtn?.frame = CGRect(x: self.view.frame.size.width - 130 - self.view.safeAreaInsets.right, y: 240, width: 30, height: 30)
            self.centerBtn?.frame = CGRect(x: self.view.frame.size.width - 90 - self.view.safeAreaInsets.right, y: 240, width: 30, height: 30)
            self.rightBtn?.frame = CGRect(x: self.view.frame.size.width - 50, y: 240, width: 30, height: 30)
            self.fontsizeSliderView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: 280, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 90)
            
        } else {
            self.backBtn?.frame = CGRect(x: self.view.frame.size.width - 60, y: 5, width: 50, height: 50)
            self.alignmentLabel?.frame = CGRect(x: 20, y: 225, width: 120, height: 45)
            self.leftBtn?.frame = CGRect(x: self.view.frame.size.width - 110, y: 240, width: 30, height: 30)
            self.centerBtn?.frame = CGRect(x: self.view.frame.size.width - 80, y: 240, width: 30, height: 30)
            self.rightBtn?.frame = CGRect(x: self.view.frame.size.width - 50, y: 240, width: 30, height: 30)
            self.fontsizeSliderView?.frame = CGRect(x: 0, y: 280, width: self.view.frame.size.width, height: 90)
            self.fontNameLabel?.frame = CGRect(x: 20, y: 195, width: 30, height: 30)
            
            self.dropMenuView?.frame = CGRect(x: 60, y: 195, width: (self.view.frame.size.width - 60 - 10)/5 * 3, height: 30)
            self.dropDownIcon?.frame = CGRect(x: (self.dropMenuView?.bounds.size.width ?? 0) - 24 - 5, y: 3, width: 24, height: 24)
            self.fontNameSelectLabel?.frame = CGRect(x: 10, y: 0, width: (self.dropMenuView?.bounds.size.width ?? 0)-40, height: 29)
            self.fontSelectBtn?.frame = self.dropMenuView?.bounds ?? CGRect.zero
            self.splitView?.frame = CGRect(x: 0, y: 29, width: (self.dropStyleMenuView?.bounds.size.width ?? 0) - 24 - 5, height: 1)
            
            self.dropStyleMenuView?.frame = CGRect(x: 60, y: 195, width: (self.view.frame.size.width - 60 - 10)/5 * 2, height: 30)
            self.dropStyleDownIcon?.frame = CGRect(x: (self.dropStyleMenuView?.bounds.size.width ?? 0) - 24 - 5, y: 3, width: 24, height: 24)
            self.fontStyleNameSelectLabel?.frame = CGRect(x: 10, y: 0, width: (self.dropStyleMenuView?.bounds.size.width ?? 0)-40, height: 29)
            self.fontStyleSelectBtn?.frame = self.dropStyleMenuView?.bounds ?? CGRect.zero
            self.splitStyleView?.frame = CGRect(x: 0, y: 29, width: self.dropStyleMenuView?.bounds.size.width ?? 0, height: 1)
            
        }
        
    }
    
    // MARK: - Protect Mehtods
    
    override func commomInitTitle() {
        self.titleLabel?.text = NSLocalizedString("FreeText", comment: "")
        self.colorView?.colorLabel?.text = NSLocalizedString("Font Color", comment: "")
        self.colorView?.selectedColor = self.annotStyle?.fontColor ?? UIColor.clear
        self.sampleView?.selecIndex = .freeText
        self.sampleView?.color = UIColor.blue
        
    }
    
    override func updatePreferredContentSizeWithTraitCollection(traitCollection: UITraitCollection) {
        self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? 350 : 600)
    }
    
    override func commomInitFromAnnotStyle() {
        self.opacitySliderView?.opacitySlider?.value = Float(self.annotStyle?.opacity ?? 0)
        self.opacitySliderView?.startLabel?.text = "\(Int(((self.opacitySliderView?.opacitySlider?.value ?? 0)/1)*100))%"
        self.fontsizeSliderView?.thicknessSlider?.value = Float(self.annotStyle?.fontSize ?? 0)
        self.fontsizeSliderView?.startLabel?.text = "\(Int(self.annotStyle?.fontSize ?? 0))"
        let cFont = self.annotStyle?.newCFont
        let familyName = cFont?.familyName ?? "Helvetica"
        var styleName = cFont?.styleName
        if(styleName?.count == 0) {
            let datasArray:[String] = CPDFFont.fontNames(forFamilyName: familyName)
            styleName = datasArray.first ?? ""
        }

        self.fontNameSelectLabel?.text = familyName
        self.fontStyleNameSelectLabel?.text = styleName
        baseName = familyName
        baseStyleName = styleName ?? ""

        self.analyzeAlignment(self.annotStyle?.alignment ?? .left)
        self.sampleView?.color = self.annotStyle?.fontColor ?? UIColor.clear
        self.sampleView?.opcity = self.annotStyle?.opacity ?? 0
        self.sampleView?.thickness = self.annotStyle?.fontSize ?? 0
        self.sampleView?.familyName = baseName
        self.sampleView?.styleName = baseStyleName

        self.sampleView?.textAlignment = self.annotStyle?.alignment ?? .left
        self.sampleView?.setNeedsDisplay()
    }
    
    // MARK: - Private Mehtods
    
    func analyzeAlignment(_ alignment: NSTextAlignment) {
        switch alignment {
        case .left:
            self.leftBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
        case .center:
            self.centerBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
        case .right:
            self.rightBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
        default:
            break
        }
    }
        
    // MARK: - Action
    
    @objc func buttonItemClicked_FontStyle(sender: AnyObject) {
        fontStyleTableView = CPDFFontStyleTableView(frame: self.view.bounds, familyNames: baseName,styleName: baseStyleName, isFontStyle: false)
        fontStyleTableView?.delegate = self
        fontStyleTableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        fontStyleTableView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if(fontStyleTableView != nil) {
            self.view.addSubview(fontStyleTableView!)
        }
    }
    
    @objc func buttonItemClicked_StyleName(sender: AnyObject) {
        fontStyleTableView = CPDFFontStyleTableView(frame: self.view.bounds, familyNames: baseName,styleName: baseStyleName, isFontStyle: true)
        fontStyleTableView?.delegate = self
        fontStyleTableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        fontStyleTableView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if(fontStyleTableView != nil) {
            self.view.addSubview(fontStyleTableView!)
        }

    }
    
    @objc func buttonItemClicked_Left(sender: AnyObject) {
        leftBtn?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        centerBtn?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        rightBtn?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        leftBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
        annotStyle?.setAlignment(NSTextAlignment.left)
        sampleView?.textAlignment = NSTextAlignment.left
        if annotStyle != nil {
            delegate?.freeTextViewController?(self, annotStyle: annotStyle!)
        }
        sampleView?.setNeedsDisplay()
        
    }
    
    @objc func buttonItemClicked_Center(sender: AnyObject) {
        leftBtn?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        centerBtn?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        rightBtn?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        centerBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
        annotStyle?.setAlignment(NSTextAlignment.center)
        sampleView?.textAlignment = NSTextAlignment.center
        if annotStyle != nil {
            delegate?.freeTextViewController?(self, annotStyle: annotStyle!)
        }
        sampleView?.setNeedsDisplay()
        
    }
    
    @objc func buttonItemClicked_Right(sender: AnyObject) {
        leftBtn?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        centerBtn?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        rightBtn?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        rightBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
        annotStyle?.setAlignment(NSTextAlignment.right)
        sampleView?.textAlignment = NSTextAlignment.right
        if annotStyle != nil {
            delegate?.freeTextViewController?(self, annotStyle: annotStyle!)
        }
        sampleView?.setNeedsDisplay()
        
    }
    
    // MARK: - CPDFOpacitySliderViewDelegate
    
    override func opacitySliderView(_ opacitySliderView: CPDFOpacitySliderView, opacity: CGFloat) {
        sampleView?.opcity = opacity
        annotStyle?.setOpacity(opacity)
        annotStyle?.setInteriorOpacity(opacity)
        if annotStyle != nil {
            delegate?.freeTextViewController?(self, annotStyle: annotStyle!)
        }
        sampleView?.setNeedsDisplay()
    }
    
    // MARK: - CPDFThicknessSliderViewDelegate
    
    func thicknessSliderView(_ opacitySliderView: CPDFThicknessSliderView, thickness: CGFloat) {
        sampleView?.thickness = thickness
        annotStyle?.setFontSize(thickness)
        if annotStyle != nil {
            delegate?.freeTextViewController?(self, annotStyle: annotStyle!)
        }
        
        sampleView?.setNeedsDisplay()
    }
    
    // MARK: - CPDFFontStyleTableViewDelegate
    
    func fontStyleTableView(_ fontStyleTableView: CPDFFontStyleTableView, fontName: String, isFontStyle: Bool) {
        var styleName = baseStyleName
        var familyName = baseName
        if(isFontStyle) {
            styleName = fontName
        } else {
            baseName = fontName;
            familyName = fontName
            
            let datasArray:[String] = CPDFFont.fontNames(forFamilyName: familyName ?? "Helvetica")
            
            styleName = datasArray.first ?? ""
        }
        let pdfFont = CPDFFont.init(familyName: familyName ?? "Helvetica", fontStyle: styleName)
        self.sampleView?.familyName = pdfFont.familyName
        self.sampleView?.styleName = pdfFont.styleName ?? ""
        self.annotStyle?.setNewCFont(pdfFont)
        self.fontNameSelectLabel?.text = pdfFont.familyName
        self.fontStyleNameSelectLabel?.text = pdfFont.styleName
        self.sampleView?.setNeedsDisplay()
        
        if annotStyle != nil {
            delegate?.freeTextViewController?(self, annotStyle: annotStyle!)
        }
    }
    
    // MARK: - CPDFColorSelectViewDelegate
    
    override func selectColorView(_ select: CPDFColorSelectView) {
        if select == self.colorView {
            if #available(iOS 14.0, *) {
                let picker = UIColorPickerViewController()
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)

            } else {
                let currentDevice = UIDevice.current
                self.colorPicker? = CPDFColorPickerView(frame: self.view.frame)
                self.colorPicker?.delegate = self
                self.colorPicker?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.colorPicker?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
                if colorPicker != nil {
                    self.view.addSubview(self.colorPicker!)
                }
                
                self.updatePreferredContentSizeWithTraitCollection(traitCollection: self.traitCollection)
            }
        }

    }
    
    override func selectColorView(_ select: CPDFColorSelectView, color: UIColor) {
        sampleView?.color = color
        annotStyle?.setFontColor(color)
        sampleView?.setNeedsDisplay()
        if annotStyle != nil {
            delegate?.freeTextViewController?(self, annotStyle: self.annotStyle!)
        }
    }
    
    // MARK: - CPDFColorPickerViewDelegate
    
    override func pickerView(_ colorPickerView: CPDFColorPickerView, color: UIColor) {
        self.sampleView?.color = color
        annotStyle?.setFontColor(color)
        sampleView?.setNeedsDisplay()
        if annotStyle != nil {
            delegate?.freeTextViewController?(self, annotStyle: self.annotStyle!)
        }
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        self.opacitySliderView?.opacitySlider?.value = Float(alpha)
        self.opacitySliderView?.startLabel?.text = "\(Int(((self.opacitySliderView?.opacitySlider?.value ?? 0)/1)*100))%"
        self.updatePreferredContentSizeWithTraitCollection(traitCollection: traitCollection)
    }
    
    // MARK: - UIColorPickerViewControllerDelegate
    
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        self.sampleView?.color = color;
        annotStyle?.setFontColor(color)
        sampleView?.setNeedsDisplay()
        if annotStyle != nil {
            delegate?.freeTextViewController?(self, annotStyle: self.annotStyle!)
        }
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        viewController.selectedColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        self.opacitySliderView?.opacitySlider?.value = Float(alpha)
        self.opacitySliderView?.startLabel?.text = "\(Int(((self.opacitySliderView?.opacitySlider?.value ?? 0) / 1) * 100))%"
        updatePreferredContentSizeWithTraitCollection(traitCollection: traitCollection)
    }
    
}


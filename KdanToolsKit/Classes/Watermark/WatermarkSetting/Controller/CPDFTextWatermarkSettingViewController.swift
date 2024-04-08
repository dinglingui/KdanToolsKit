//
//  CPDFTextWatermarkSettingViewController.swift
//  PDFViewer-Swift
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import UIKit

@objc protocol CPDFTextWatermarkSettingViewControllerDelegate: AnyObject {
    @objc optional func textWatermarkSettingViewControllerSetting(_ textWatermarkSettingViewController: CPDFTextWatermarkSettingViewController, Color color: UIColor)
    @objc optional func textWatermarkSettingViewControllerSetting(_ textWatermarkSettingViewController: CPDFTextWatermarkSettingViewController, Opacity opacity: CGFloat)
    @objc optional func textWatermarkSettingViewControllerSetting(_ textWatermarkSettingViewController: CPDFTextWatermarkSettingViewController, IsFront isFront: Bool)
    @objc optional func textWatermarkSettingViewControllerSetting(_ textWatermarkSettingViewController: CPDFTextWatermarkSettingViewController, IsTile isTile: Bool)
    @objc optional func textWatermarkSettingViewControllerSetting(_ textWatermarkSettingViewController: CPDFTextWatermarkSettingViewController, FontName fontName: String)
    @objc optional func textWatermarkSettingViewControllerSetting(_ textWatermarkSettingViewController: CPDFTextWatermarkSettingViewController, FontSize fontSize: CGFloat)
    @objc optional func textWatermarkSettingViewControllerSetting(_ imageWatermarkSettingViewController: CPDFTextWatermarkSettingViewController, PageRange pageRange: String)
}

class CPDFTextWatermarkSettingViewController: UIViewController, UIColorPickerViewControllerDelegate, CPDFColorSelectViewDelegate, CPDFColorPickerViewDelegate, CPDFOpacitySliderViewDelegate, CPDFThicknessSliderViewDelegate, CPDFFontStyleTableViewDelegate, CLocationSelectViewDelegate, CPageRangeSelectViewDelegate,CTileSelectViewDelegate {
    
    weak var delegate: CPDFTextWatermarkSettingViewControllerDelegate?
    
    private var backBtn: UIButton?
    
    private var titleLabel: UILabel?
    
    private var headerView: UIView?
    
    private var colorView: CPDFColorSelectView?
    
    private var opacitySliderView: CPDFOpacitySliderView?
    
    private var colorPicker: CPDFColorPickerView?
    
    private var boldBtn: UIButton?
    
    private var italicBtn: UIButton?
    
    private var fontsizeSliderView: CPDFThicknessSliderView?
    
    private var isBold: Bool = false
    
    private var isItalic: Bool = false
    
    private var baseName:String?
    
    private var fontStyleTableView: CPDFFontStyleTableView?
    
    private var dropMenuView: UIView?
    
    private var splitView: UIView?
    
    private var fontSelectBtn: UIButton?
    
    private var dropDownIcon: UIImageView?
    
    private var fontNameLabel: UILabel?
    
    private var fontNameSelectLabel: UILabel?
    
    private var locationSelectView: CLocationSelectView?
    
    private var tileSelectView: CTileSelectView?
    
    private var waterModel: CWatermarkModel?
    
    private var pageRangeSelectView: CPageRangeSelectView?
    
    var scrcollView: UIScrollView?
    
    // MARK: - Init
    
    init(waterModel: CWatermarkModel?) {
        super.init(nibName: nil, bundle: nil)
        
        self.waterModel = waterModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Common initialization code
        headerView = UIView()
        headerView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        headerView?.layer.borderWidth = 1.0
        headerView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if(headerView != nil) {
            view.addSubview(headerView!)
        }
        
        titleLabel = UILabel()
        titleLabel?.autoresizingMask = .flexibleRightMargin
        titleLabel?.text = NSLocalizedString("Watermark Settings", comment: "")
        titleLabel?.textAlignment = .center
        titleLabel?.font = UIFont.systemFont(ofSize: 20)
        titleLabel?.adjustsFontSizeToFitWidth = true
        if(self.titleLabel != nil) {
            headerView?.addSubview(titleLabel!)
        }
        
        backBtn = UIButton()
        backBtn?.autoresizingMask = .flexibleLeftMargin
        backBtn?.setImage(UIImage(named: "CPDFAnnotationBaseImageBack", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        backBtn?.addTarget(self, action: #selector(buttonItemClicked_back(_:)), for: .touchUpInside)
        if(backBtn != nil) {
            headerView?.addSubview(backBtn!)
        }
        
        scrcollView = UIScrollView()
        scrcollView?.isScrollEnabled = true
        if(scrcollView != nil) {
            view.addSubview(scrcollView!)
        }
        
        colorView = CPDFColorSelectView.init(frame: CGRect.zero)
        colorView?.delegate = self
        colorView?.autoresizingMask = .flexibleWidth
        if (colorView != nil) {
            scrcollView?.addSubview(colorView!)
        }
        
        opacitySliderView = CPDFOpacitySliderView(frame: CGRect.zero)
        opacitySliderView?.delegate = self
        opacitySliderView?.autoresizingMask = .flexibleWidth
        if (opacitySliderView != nil) {
            scrcollView?.addSubview(opacitySliderView!)
        }
        
        createFreeTextProperty()
        
        pageRangeSelectView = CPageRangeSelectView(frame: .zero)
        pageRangeSelectView?.parentVC = self
        pageRangeSelectView?.delegate = self
        pageRangeSelectView?.autoresizingMask = .flexibleWidth
        if pageRangeSelectView != nil {
            scrcollView?.addSubview(pageRangeSelectView!)
        }
        
        locationSelectView = CLocationSelectView(frame: .zero)
        locationSelectView?.delegate = self
        if locationSelectView != nil {
            scrcollView?.addSubview(locationSelectView!)
        }
        
        tileSelectView = CTileSelectView(frame: .zero)
        tileSelectView?.delegate = self
        if tileSelectView != nil {
            scrcollView?.addSubview(tileSelectView!)
        }
        
        commomInitWaterProperty()
        
        updatePreferredContentSizeWithTraitCollection(traitCollection: traitCollection)
        view.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSizeWithTraitCollection(traitCollection: newCollection)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        titleLabel?.frame = CGRect(x: (view.frame.size.width - 120) / 2, y: 5, width: 120, height: 50)
        headerView?.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50)
        scrcollView?.frame = CGRect(x: 0, y: 50, width: view.frame.size.width, height: view.bounds.size.height-50)
        scrcollView?.contentSize = CGSize(width: view.frame.size.width, height: 550)
        if #available(iOS 11.0, *) {
            backBtn?.frame = CGRect(x: view.frame.size.width - 60 - view.safeAreaInsets.right, y: 5, width: 50, height: 50)
            colorView?.frame = CGRect(x: view.safeAreaInsets.left, y: 0, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 90)
            opacitySliderView?.frame = CGRect(x: view.safeAreaInsets.left, y: colorView?.frame.maxY ?? 0, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 90)
            fontNameLabel?.frame = CGRect(x: view.safeAreaInsets.left+20, y: opacitySliderView?.frame.maxY ?? 0, width: 40, height: 30)
            dropMenuView?.frame = CGRect(x: view.safeAreaInsets.left+60, y: opacitySliderView?.frame.maxY ?? 0, width: view.frame.size.width - 150 - view.safeAreaInsets.right-view.safeAreaInsets.left, height: 30)
            dropDownIcon?.frame = CGRect(x: (dropMenuView?.bounds.size.width ?? 0) - 24 - 5, y: 3, width: 24, height: 24)
            fontNameSelectLabel?.frame = CGRect(x: 10, y: 0, width: (dropMenuView?.bounds.size.width ?? 0) - 40, height: 29)
            fontSelectBtn?.frame = dropMenuView?.bounds ?? CGRect.zero
            splitView?.frame = CGRect(x: 0, y: 29, width: dropMenuView?.bounds.size.width ?? 0, height: 1)
            boldBtn?.frame = CGRect(x: view.frame.size.width - 80 - view.safeAreaInsets.right, y: opacitySliderView?.frame.maxY ?? 0, width: 30, height: 30)
            italicBtn?.frame = CGRect(x: view.frame.size.width - 50 - view.safeAreaInsets.right, y: opacitySliderView?.frame.maxY ?? 0, width: 30, height: 30)
            locationSelectView?.frame = CGRect(x: view.safeAreaInsets.left, y: (fontNameLabel?.frame.maxY ?? 0)+5, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 30)
            fontsizeSliderView?.frame = CGRect(x: view.safeAreaInsets.left, y: locationSelectView?.frame.maxY ?? 0, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 90)
            pageRangeSelectView?.frame = CGRect(x: view.safeAreaInsets.left, y: (fontsizeSliderView?.frame.maxY ?? 0)+5, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 30)
            tileSelectView?.frame = CGRect(x: view.safeAreaInsets.left, y: (pageRangeSelectView?.frame.maxY ?? 0)+5, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 45)
            
        } else {
            colorView?.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 90)
            backBtn?.frame = CGRect(x: view.frame.size.width - 60, y: 5, width: 50, height: 50)
            opacitySliderView?.frame = CGRect(x: 0, y: colorView?.frame.maxY ?? 0, width: view.frame.size.width, height: 90)
            fontNameLabel?.frame = CGRect(x: 20, y: opacitySliderView?.frame.maxY ?? 0, width: 30, height: 30)
            dropMenuView?.frame = CGRect(x: 60, y: opacitySliderView?.frame.maxY ?? 0, width: view.frame.size.width - 150, height: 30)
            dropDownIcon?.frame = CGRect(x: (dropMenuView?.bounds.size.width ?? 0) - 24 - 5, y: 3, width: 24, height: 24)
            fontNameSelectLabel?.frame = CGRect(x: 10, y: 0, width: (dropMenuView?.bounds.size.width ?? 0) - 40, height: 29)
            fontSelectBtn?.frame = dropMenuView?.bounds ?? CGRect.zero
            splitView?.frame = CGRect(x: 0, y: 29, width: dropMenuView?.bounds.size.width ?? 0, height: 1)
            boldBtn?.frame = CGRect(x: view.frame.size.width - 80, y: opacitySliderView?.frame.maxY ?? 0, width: 30, height: 30)
            italicBtn?.frame = CGRect(x: view.frame.size.width - 50, y: opacitySliderView?.frame.maxY ?? 0, width: 30, height: 30)
            locationSelectView?.frame = CGRect(x: 0, y: (fontNameLabel?.frame.maxY ?? 0)+5, width: view.frame.size.width, height: 30)
            fontsizeSliderView?.frame = CGRect(x: 0, y: locationSelectView?.frame.maxY ?? 0, width: view.frame.size.width, height: 90)
            pageRangeSelectView?.frame = CGRect(x: 0, y: (fontsizeSliderView?.frame.maxY ?? 0)+5, width: view.frame.size.width, height: 30)
            tileSelectView?.frame = CGRect(x: 0, y: (pageRangeSelectView?.frame.maxY ?? 0)+5, width: view.frame.size.width , height: 45)
        }
    }
    
    // MARK: - Protect Methods
    
    func updatePreferredContentSizeWithTraitCollection(traitCollection: UITraitCollection) {
        if self.colorPicker?.superview != nil {
            let currentDevice = UIDevice.current
            if currentDevice.userInterfaceIdiom == .pad {
                // This is an iPad
                self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: 550)
            } else {
                // This is an iPhone or iPod touch
                self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: 350)
            }
        } else {
            self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? 380 : 480)
        }
    }
    
    func commomInitWaterProperty() {
        fontsizeSliderView?.thicknessSlider?.maximumValue = 30.0
        fontsizeSliderView?.thicknessSlider?.minimumValue = 12.0
        colorView?.selectedColor = waterModel?.textColor
        opacitySliderView?.opacitySlider?.value = Float(waterModel?.watermarkOpacity ?? 0)
        opacitySliderView?.startLabel?.text = "\(Int(((opacitySliderView?.opacitySlider?.value ?? 0)/1)*100))%"
        fontsizeSliderView?.thicknessSlider?.value = Float(waterModel?.watermarkScale ?? 0)
        fontsizeSliderView?.startLabel?.text = "\(Int(fontsizeSliderView?.thicknessSlider?.value ?? 0))pt"
        fontNameSelectLabel?.text = waterModel?.fontName
        analyzeFont(waterModel?.fontName ?? "")
        tileSelectView?.tileSwitch?.isOn = waterModel?.isTile ?? false
        locationSelectView?.setLocation(waterModel?.isFront ?? true)
    }
    
    func analyzeFont(_ fontName: String) {
        if fontName.range(of: "Bold") != nil {
            self.isBold = true
            
            self.boldBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
           
        } else {
            self.isBold = false
            
            self.boldBtn?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
            
        }
        if fontName.range(of: "Italic") != nil || fontName.range(of: "Oblique") != nil {
            self.isItalic = true
           
            self.italicBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
            
        } else {
            self.isItalic = false
          
            self.italicBtn?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
           
        }
        
        if fontName.range(of: "Helvetica") != nil {
            self.baseName = "Helvetica"
          
            return
        }
        
        if fontName.range(of: "Courier") != nil {
            self.baseName = "Courier"
            
            return
        }
        
        if fontName.range(of: "Times") != nil {
            self.baseName = "Times-Roman"
            
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
    
    func createFreeTextProperty() {
        fontNameLabel = UILabel()
        fontNameLabel?.text = NSLocalizedString("Font", comment: "")
        fontNameLabel?.font = UIFont.systemFont(ofSize: 14)
        fontNameLabel?.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        if fontNameLabel != nil {
            scrcollView?.addSubview(fontNameLabel!)
        }
        
        dropMenuView = UIView()
        if dropMenuView != nil {
            scrcollView?.addSubview(self.dropMenuView!)
        }
        
        splitView = UIView()
        splitView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        if splitView != nil {
            dropMenuView?.addSubview(splitView!)
        }
        
        dropDownIcon = UIImageView()
        dropDownIcon?.image = UIImage(named: "CPDFEditArrow", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        if dropDownIcon != nil {
            dropMenuView?.addSubview(self.dropDownIcon!)
        }
        
        fontNameSelectLabel = UILabel()
        fontNameSelectLabel?.font = UIFont.systemFont(ofSize: 14)
        fontNameSelectLabel?.textColor = UIColor.black
        if fontNameSelectLabel != nil {
            dropMenuView?.addSubview(fontNameSelectLabel!)
        }
        
        fontSelectBtn = UIButton(type: .custom)
        fontSelectBtn?.backgroundColor = UIColor.clear
        fontSelectBtn?.addTarget(self, action: #selector(buttonItemClicked_FontStyle), for: .touchUpInside)
        if fontSelectBtn != nil {
            dropMenuView?.addSubview(self.fontSelectBtn!)
        }
        
        boldBtn = UIButton()
        boldBtn?.setImage(UIImage(named: "CPDFFreeTextImageBold", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        boldBtn?.setImage(UIImage(named: "CPDFFreeTextImageBoldHighLinght", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .selected)
        boldBtn?.addTarget(self, action: #selector(buttonItemClicked_Bold), for: .touchUpInside)
        if boldBtn != nil {
            scrcollView?.addSubview(self.boldBtn!)
        }
        
        italicBtn = UIButton()
        italicBtn?.setImage(UIImage(named: "CPDFFreeTextImageUnderline", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        italicBtn?.setImage(UIImage(named: "CPDFFreeTextImageItailcHighLight", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .selected)
        italicBtn?.addTarget(self, action: #selector(buttonItemClicked_Italic), for: .touchUpInside)
        if italicBtn != nil {
            scrcollView?.addSubview(self.italicBtn!)
        }
        
        fontsizeSliderView = CPDFThicknessSliderView()
        fontsizeSliderView?.thicknessSlider?.value = 20
        fontsizeSliderView?.thicknessSlider?.minimumValue = 1
        fontsizeSliderView?.thicknessSlider?.maximumValue = 100
        fontsizeSliderView?.titleLabel?.text = NSLocalizedString("Font Size", comment: "")
        fontsizeSliderView?.startLabel?.text = "1"
        fontsizeSliderView?.delegate = self
        fontsizeSliderView?.autoresizingMask = .flexibleWidth
        if fontsizeSliderView != nil {
            scrcollView?.addSubview(fontsizeSliderView!)
        }
        
        baseName = "Helvetica"
    }
    
    
    // MARK: - Action
    
    @objc func buttonItemClicked_back(_ button: UIButton) {
        dismiss(animated: true)
    }
    
    @objc func buttonItemClicked_Bold(_ sender: UIButton) {
        isBold = !isBold
        if self.isBold {
            self.boldBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
        } else {
            self.boldBtn?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        }
        
        waterModel?.fontName = constructionFontname(self.baseName ?? "", isBold: self.isBold, isItalic: self.isItalic)
        delegate?.textWatermarkSettingViewControllerSetting?(self, FontName: (waterModel?.fontName)!)
    }
    
    @objc func buttonItemClicked_Italic(_ sender: UIButton) {
        self.isItalic = !self.isItalic
        if self.isItalic {
            self.italicBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
        } else {
            self.italicBtn?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        }
        waterModel?.fontName = constructionFontname(self.baseName ?? "", isBold: self.isBold, isItalic: self.isItalic)
        delegate?.textWatermarkSettingViewControllerSetting?(self, FontName: (waterModel?.fontName)!)
    }
    
    @objc func buttonItemClicked_FontStyle(sender: AnyObject) {
        fontStyleTableView = CPDFFontStyleTableView(frame: self.view.bounds)
        fontStyleTableView?.delegate = self
        fontStyleTableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        fontStyleTableView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if(fontStyleTableView != nil) {
            self.view.addSubview(fontStyleTableView!)
        }
    }
    
    // MARK: - CLocationSelectViewDelegate
    
    func locationSelectView(_ locationSelectView: CLocationSelectView, isFront: Bool) {
        delegate?.textWatermarkSettingViewControllerSetting?(self, IsFront: isFront)
    }
    
    // MARK: - CTileSelectViewDelegate
    
    func tileSelectView(_ tileSelectView: CTileSelectView, isTile: Bool) {
        delegate?.textWatermarkSettingViewControllerSetting?(self, IsTile: isTile)
    }
    
    // MARK: - CPDFThicknessSliderViewDelegate
    
    func thicknessSliderView(_ opacitySliderView: CPDFThicknessSliderView, thickness: CGFloat) {
        delegate?.textWatermarkSettingViewControllerSetting?(self, FontSize: thickness)
    }
    
    // MARK: - CPDFFontStyleTableViewDelegate
    
    func fontStyleTableView(_ fontStyleTableView: CPDFFontStyleTableView, fontName: String) {
        
        baseName = fontName
        
        fontNameSelectLabel?.text = fontName;
        
        waterModel?.fontName = constructionFontname(self.baseName ?? "", isBold: self.isBold, isItalic: self.isItalic)
        
        delegate?.textWatermarkSettingViewControllerSetting?(self, FontName: (waterModel?.fontName)!)
    }
    
    // MARK: - CPDFColorSelectViewDelegate
    
    func selectColorView(_ select: CPDFColorSelectView) {
        if #available(iOS 14.0, *) {
            let picker = UIColorPickerViewController()
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        } else {
            let currentDevice = UIDevice.current
            if currentDevice.userInterfaceIdiom == .pad {
                // This is an iPad
                self.colorPicker = CPDFColorPickerView(frame: CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.size.width, height: 520))
            } else {
                // This is an iPhone or iPod touch
                self.colorPicker = CPDFColorPickerView(frame: CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.size.width, height: 320))
            }
            self.colorPicker?.delegate = self
            self.colorView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.colorPicker?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
            if(self.colorPicker != nil) {
                self.view.addSubview(self.colorPicker!)
            }
            
            updatePreferredContentSizeWithTraitCollection(traitCollection: traitCollection)
        }
    }
    
    func selectColorView(_ select: CPDFColorSelectView, color: UIColor) {
        delegate?.textWatermarkSettingViewControllerSetting?(self, Color: color)
    }
    
    // MARK: - CPDFOpacitySliderViewDelegate
    
    func opacitySliderView(_ opacitySliderView: CPDFOpacitySliderView, opacity: CGFloat) {
        delegate?.textWatermarkSettingViewControllerSetting?(self, Opacity: opacity)
    }
    
    // MARK: - CPageRangeSelectViewDelegate
    
    func pageRangeSelectView(_ pageRangeSelectView: CPageRangeSelectView, pageRange: String) {
        delegate?.textWatermarkSettingViewControllerSetting?(self, PageRange: pageRange)
    }
    
    // MARK: - CPDFColorPickerViewDelegate
    
    func pickerView(_ colorPickerView: CPDFColorPickerView, color: UIColor) {

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        self.opacitySliderView?.opacitySlider?.value = Float(alpha)
        self.opacitySliderView?.startLabel?.text = "\(Int(((self.opacitySliderView?.opacitySlider?.value ?? 0)/1)*100))%"
        self.updatePreferredContentSizeWithTraitCollection(traitCollection: traitCollection)
        
        delegate?.textWatermarkSettingViewControllerSetting?(self, Color: color)
    }
    
    // MARK: - UIColorPickerViewControllerDelegate
    
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        viewController.selectedColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
       
        self.opacitySliderView?.opacitySlider?.value = Float(alpha)
        self.opacitySliderView?.startLabel?.text = "\(Int(((self.opacitySliderView?.opacitySlider?.value ?? 0) / 1) * 100))%"
        updatePreferredContentSizeWithTraitCollection(traitCollection: traitCollection)
        
        delegate?.textWatermarkSettingViewControllerSetting?(self, Color: viewController.selectedColor)
    }
    
}

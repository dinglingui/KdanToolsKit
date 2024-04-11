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
import ComPDFKit

@objc protocol CPDFTextWatermarkSettingViewControllerDelegate: AnyObject {
    @objc optional func textWatermarkSettingViewControllerSetting(_ textWatermarkSettingViewController: CPDFTextWatermarkSettingViewController, Color color: UIColor)
    @objc optional func textWatermarkSettingViewControllerSetting(_ textWatermarkSettingViewController: CPDFTextWatermarkSettingViewController, Opacity opacity: CGFloat)
    @objc optional func textWatermarkSettingViewControllerSetting(_ textWatermarkSettingViewController: CPDFTextWatermarkSettingViewController, IsFront isFront: Bool)
    @objc optional func textWatermarkSettingViewControllerSetting(_ textWatermarkSettingViewController: CPDFTextWatermarkSettingViewController, IsTile isTile: Bool)
    @objc optional func textWatermarkSettingViewControllerSetting(_ textWatermarkSettingViewController: CPDFTextWatermarkSettingViewController, FamilyName fontName: String,FontStyleName styleName: String)
    @objc optional func textWatermarkSettingViewControllerSetting(_ textWatermarkSettingViewController: CPDFTextWatermarkSettingViewController, FontSize fontSize: CGFloat)
    @objc optional func textWatermarkSettingViewControllerSetting(_ imageWatermarkSettingViewController: CPDFTextWatermarkSettingViewController, PageRange pageRange: String)
}

class CPDFTextWatermarkSettingViewController: UIViewController, UIColorPickerViewControllerDelegate, CPDFColorSelectViewDelegate, CPDFColorPickerViewDelegate, CPDFOpacitySliderViewDelegate, CPDFThicknessSliderViewDelegate, CPDFFontStyleTableViewDelegate, CLocationSelectViewDelegate, CPageRangeSelectViewDelegate,CTileSelectViewDelegate,CPDFFontSettingViewDelegate {
    
    weak var delegate: CPDFTextWatermarkSettingViewControllerDelegate?
    
    private var backBtn: UIButton?
    
    private var titleLabel: UILabel?
    
    private var headerView: UIView?
    
    private var colorView: CPDFColorSelectView?
    
    private var opacitySliderView: CPDFOpacitySliderView?
    
    private var colorPicker: CPDFColorPickerView?
        
    private var fontsizeSliderView: CPDFThicknessSliderView?
    
    private var baseName:String?
    private var baseStyleName:String = ""
    
    private var fontStyleTableView: CPDFFontStyleTableView?
    
    var fontSettingView: CPDFFontSettingSubView?
    
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
            
            fontSettingView?.frame = CGRect(x: view.safeAreaInsets.left, y: opacitySliderView?.frame.maxY ?? 0, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 30)

            locationSelectView?.frame = CGRect(x: view.safeAreaInsets.left, y: (fontSettingView?.frame.maxY ?? 0)+5, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 30)
            fontsizeSliderView?.frame = CGRect(x: view.safeAreaInsets.left, y: locationSelectView?.frame.maxY ?? 0, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 90)
            pageRangeSelectView?.frame = CGRect(x: view.safeAreaInsets.left, y: (fontsizeSliderView?.frame.maxY ?? 0)+5, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 30)
            tileSelectView?.frame = CGRect(x: view.safeAreaInsets.left, y: (pageRangeSelectView?.frame.maxY ?? 0)+5, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 45)
            
        } else {
            colorView?.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 90)
            backBtn?.frame = CGRect(x: view.frame.size.width - 60, y: 5, width: 50, height: 50)
            opacitySliderView?.frame = CGRect(x: 0, y: colorView?.frame.maxY ?? 0, width: view.frame.size.width, height: 90)
            fontSettingView?.frame = CGRect(x: 20, y: opacitySliderView?.frame.maxY ?? 0, width: view.frame.size.width - 40, height: 30)

            locationSelectView?.frame = CGRect(x: 0, y: (fontSettingView?.frame.maxY ?? 0)+5, width: view.frame.size.width, height: 30)
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
        fontSettingView?.fontNameSelectLabel?.text = waterModel?.fontName
        fontSettingView?.fontStyleNameSelectLabel?.text = waterModel?.fontStyleName
        tileSelectView?.tileSwitch?.isOn = waterModel?.isTile ?? false
        locationSelectView?.setLocation(waterModel?.isFront ?? true)
    }
    
    func createFreeTextProperty() {
        self.fontSettingView = CPDFFontSettingSubView(frame: CGRect.zero)
        self.fontSettingView?.fontNameLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
        self.fontSettingView?.fontNameLabel?.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
        self.fontSettingView?.fontNameLabel?.text = NSLocalizedString("Font", comment: "")
        self.fontSettingView?.delegate = self
        
        if(self.fontSettingView != nil) {
            self.scrcollView?.addSubview(self.fontSettingView!)
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
    
    // MARK: - CPDFFontSettingViewDelegate
    func setCPDFFontSettingViewFontSelect(view: CPDFFontSettingSubView,isFontStyle:Bool) {
        fontStyleTableView = CPDFFontStyleTableView(frame: self.view.bounds, familyNames: view.fontNameSelectLabel?.text ?? "Helvetica", styleName: baseStyleName,isFontStyle: isFontStyle)
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
    
    func fontStyleTableView(_ fontStyleTableView: CPDFFontStyleTableView, fontName: String, isFontStyle: Bool) {
        if(isFontStyle) {
            baseStyleName = fontName
        } else {
            baseName = fontName;
            
            let datasArray:[String] = CPDFFont.fontNames(forFamilyName: baseName ?? "Helvetica")
            baseStyleName = datasArray.first ?? ""
        }

        fontSettingView?.fontNameSelectLabel?.text = baseName
        fontSettingView?.fontStyleNameSelectLabel?.text = baseStyleName
        
        waterModel?.fontName = baseName
        waterModel?.fontStyleName = baseStyleName

        delegate?.textWatermarkSettingViewControllerSetting?(self, FamilyName: baseName ?? "Helvetica", FontStyleName: baseStyleName)
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

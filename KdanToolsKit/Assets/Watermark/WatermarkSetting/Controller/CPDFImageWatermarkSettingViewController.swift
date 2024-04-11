//
//  CPDFImageWatermarkSettingViewController.swift
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

@objc protocol CPDFImageWatermarkSettingViewControllerDelegate: AnyObject {
    @objc optional func imageWatermarkSettingViewControllerSetting(_ imageWatermarkSettingViewController: CPDFImageWatermarkSettingViewController, Image image:UIImage)
    @objc optional func imageWatermarkSettingViewControllerSetting(_ imageWatermarkSettingViewController: CPDFImageWatermarkSettingViewController, Opacity opacity: CGFloat)
    @objc optional func imageWatermarkSettingViewControllerSetting(_ imageWatermarkSettingViewController: CPDFImageWatermarkSettingViewController, IsFront isFront: Bool)
    @objc optional func imageWatermarkSettingViewControllerSetting(_ imageWatermarkSettingViewController: CPDFImageWatermarkSettingViewController, IsTile isTile: Bool)
    @objc optional func imageWatermarkSettingViewControllerSetting(_ imageWatermarkSettingViewController: CPDFImageWatermarkSettingViewController, PageRange pageRange: String)
}

class CPDFImageWatermarkSettingViewController: UIViewController, CPDFOpacitySliderViewDelegate, CImageSelectViewDelegate, CPageRangeSelectViewDelegate, CLocationSelectViewDelegate, CTileSelectViewDelegate {
    
    weak var delegate: CPDFImageWatermarkSettingViewControllerDelegate?

    private var backBtn: UIButton?
    
    private var titleLabel: UILabel?
    
    private var headerView: UIView?
    
    private var imageSelectView: CImageSelectView?
    
    private var opacitySliderView: CPDFOpacitySliderView?
    
    private var locationSelectView: CLocationSelectView?
    
    private var pageRangeSelectView: CPageRangeSelectView?
    
    private var tileSelectView: CTileSelectView?
    
    private var scrcollView: UIScrollView?
    
    private var waterModel: CWatermarkModel?
    
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
        
        imageSelectView = CImageSelectView(frame: .zero)
        imageSelectView?.delegate = self
        imageSelectView?.parentVC = self
        imageSelectView?.autoresizingMask = .flexibleWidth
        if imageSelectView != nil {
            scrcollView?.addSubview(imageSelectView!)
        }
        
        opacitySliderView = CPDFOpacitySliderView(frame: CGRect.zero)
        opacitySliderView?.delegate = self
        opacitySliderView?.autoresizingMask = .flexibleWidth
        if (opacitySliderView != nil) {
            scrcollView?.addSubview(opacitySliderView!)
        }
        
        locationSelectView = CLocationSelectView(frame: .zero)
        locationSelectView?.delegate = self
        if locationSelectView != nil {
            scrcollView?.addSubview(locationSelectView!)
        }
        
        pageRangeSelectView = CPageRangeSelectView(frame: .zero)
        pageRangeSelectView?.parentVC = self
        pageRangeSelectView?.delegate = self
        pageRangeSelectView?.autoresizingMask = .flexibleWidth
        if pageRangeSelectView != nil {
            scrcollView?.addSubview(pageRangeSelectView!)
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        titleLabel?.frame = CGRect(x: (view.frame.size.width - 120) / 2, y: 5, width: 120, height: 50)
        headerView?.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50)
        scrcollView?.frame = CGRect(x: 0, y: 50, width: view.frame.size.width, height: view.bounds.size.height-50)
        scrcollView?.contentSize = CGSize(width: view.frame.size.width, height: 400)
        if #available(iOS 11.0, *) {
            backBtn?.frame = CGRect(x: view.frame.size.width - 60 - view.safeAreaInsets.right, y: 5, width: 50, height: 50)
            imageSelectView?.frame = CGRect(x: view.safeAreaInsets.left, y: 5, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 30)
            opacitySliderView?.frame = CGRect(x: view.safeAreaInsets.left, y: imageSelectView?.frame.maxY ?? 0, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 90)
            locationSelectView?.frame = CGRect(x: view.safeAreaInsets.left, y: opacitySliderView?.frame.maxY ?? 0, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 30)
            pageRangeSelectView?.frame = CGRect(x: view.safeAreaInsets.left, y: (locationSelectView?.frame.maxY ?? 0)+5, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 30)
            tileSelectView?.frame = CGRect(x: view.safeAreaInsets.left, y: (pageRangeSelectView?.frame.maxY ?? 0) + 5, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 45)
        } else {
            backBtn?.frame = CGRect(x: view.frame.size.width - 60, y: 5, width: 50, height: 50)
            imageSelectView?.frame = CGRect(x: 0, y: 5, width: view.frame.size.width, height: 50)
            opacitySliderView?.frame = CGRect(x: 0, y: imageSelectView?.frame.maxY ?? 0, width: view.frame.size.width, height: 90)
            locationSelectView?.frame = CGRect(x: 0, y: opacitySliderView?.frame.maxY ?? 0, width: view.frame.size.width, height: 30)
            pageRangeSelectView?.frame = CGRect(x: 0, y: (locationSelectView?.frame.maxY ?? 0)+5, width: view.frame.size.width, height: 30)
            tileSelectView?.frame = CGRect(x: 0, y: (pageRangeSelectView?.frame.maxY ?? 0) + 5, width: view.frame.size.width , height: 45)
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSizeWithTraitCollection(traitCollection: newCollection)
    }
    
    // MARK: - Protect Methods
    
    func updatePreferredContentSizeWithTraitCollection(traitCollection: UITraitCollection) {
        self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? 350 : 350)
    }
    
    func commomInitWaterProperty() {
        opacitySliderView?.opacitySlider?.value = Float(waterModel?.watermarkOpacity ?? 0)
        opacitySliderView?.startLabel?.text = "\(Int(((opacitySliderView?.opacitySlider?.value ?? 0)/1)*100))%"
        tileSelectView?.tileSwitch?.isOn = waterModel?.isTile ?? false
        locationSelectView?.setLocation(waterModel?.isFront ?? true)
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_back(_ button: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - CPDFOpacitySliderViewDelegate
    
    func opacitySliderView(_ opacitySliderView: CPDFOpacitySliderView, opacity: CGFloat) {
        delegate?.imageWatermarkSettingViewControllerSetting?(self, Opacity: opacity)
    }
    
    // MARK: - CImageSelectViewDelegate
    
    func imageSelectView(_ imageSelectView: CImageSelectView, image: UIImage) {
        delegate?.imageWatermarkSettingViewControllerSetting?(self, Image: image)
    }
    
    // MARK: - CPageRangeSelectViewDelegate
    
    func pageRangeSelectView(_ pageRangeSelectView: CPageRangeSelectView, pageRange: String) {
        delegate?.imageWatermarkSettingViewControllerSetting?(self, PageRange: pageRange)
    }
    
    // MARK: - CLocationSelectViewDelegate
    
    func locationSelectView(_ locationSelectView: CLocationSelectView, isFront: Bool) {
        delegate?.imageWatermarkSettingViewControllerSetting?(self, IsFront: isFront)
    }
    
    // MARK: - CTileSelectViewDelegate
    
    func tileSelectView(_ tileSelectView: CTileSelectView, isTile: Bool) {
        delegate?.imageWatermarkSettingViewControllerSetting?(self, IsTile: isTile)
    }
    
}

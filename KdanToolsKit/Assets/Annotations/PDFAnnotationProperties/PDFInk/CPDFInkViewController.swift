//
//  CPDFInkViewController.swift
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

@objc protocol CPDFInkViewControllerDelegate: AnyObject {
    @objc optional func inkViewController(_ inkViewController: CPDFInkViewController, annotStyle: CAnnotStyle)
    @objc optional func inkViewControllerDimiss(_ inkViewController: CPDFInkViewController)
}

class CPDFInkViewController: CPDFAnnotationBaseViewController, CPDFThicknessSliderViewDelegate {
    weak var delegate: CPDFInkViewControllerDelegate?
    private var thicknessView: CPDFThicknessSliderView?
    
    // MARK: - ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        thicknessView = CPDFThicknessSliderView(frame: CGRect.zero)
        thicknessView?.delegate = self
        thicknessView?.thicknessSlider?.value = 4.0
        thicknessView?.autoresizingMask = .flexibleWidth
        if(thicknessView != nil) {
            scrcollView?.addSubview(thicknessView!)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrcollView?.frame = CGRect(x: 0, y: 170, width: self.view.frame.size.width, height: 310)
        scrcollView?.contentSize = CGSize(width: self.view.frame.size.width, height: 400)
        if #available(iOS 11.0, *) {
            self.thicknessView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: 180, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 90)
        } else {
            self.colorView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 90)
            self.thicknessView?.frame = CGRect(x: 0, y: 180, width: self.view.frame.size.width, height: 90)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        delegate?.inkViewControllerDimiss?(self)
    }
    
    // MARK: - Private Methods
    
    override func commomInitTitle() {
        self.titleLabel?.text = NSLocalizedString("Ink", comment: "")
        self.thicknessView?.titleLabel?.text = NSLocalizedString("Line Width", comment: "")
        sampleView?.selecIndex = .freehand
        self.sampleView?.thickness = 4.0
        self.colorView?.selectedColor = self.annotStyle?.color
    }

    override func commomInitFromAnnotStyle() {
        self.sampleView?.color = self.annotStyle?.color ?? UIColor.clear
        self.sampleView?.opcity = self.annotStyle?.opacity ?? 0
        self.sampleView?.thickness = self.annotStyle?.lineWidth ?? 0
        
        self.opacitySliderView?.opacitySlider?.value = Float(self.annotStyle?.opacity ?? 0)
        self.opacitySliderView?.startLabel?.text = "\(Int(((self.opacitySliderView?.opacitySlider?.value ?? 0)/1)*100))%"
        self.thicknessView?.thicknessSlider?.value = Float(self.annotStyle?.lineWidth ?? 0 )
        self.thicknessView?.startLabel?.text = "\(Int((self.thicknessView?.thicknessSlider?.value ?? 0))) pt"
        self.sampleView?.setNeedsDisplay()
    }

    override func updatePreferredContentSizeWithTraitCollection(traitCollection: UITraitCollection) {
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
            self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? 350 : 520)
        }
    }
    
    // MARK: - Action
    
    @objc override func buttonItemClicked_back(_ button: UIButton) {
        dismiss(animated: true)
        
        delegate?.inkViewControllerDimiss?(self)
    }
    
    // MARK: - CPDFThicknessSliderViewDelegate
    
    func thicknessSliderView(_ opacitySliderView: CPDFThicknessSliderView, thickness: CGFloat) {
        sampleView?.thickness = thickness
        annotStyle?.setLineWidth(thickness)
        if(annotStyle != nil) {
            delegate?.inkViewController?(self, annotStyle: annotStyle!)
        }
        sampleView?.setNeedsDisplay()
    }
    
    // MARK: - CPDFColorSelectViewDelegate
    
    override func selectColorView(_ select: CPDFColorSelectView, color: UIColor) {
        sampleView?.color = color
        annotStyle?.setColor(color)
        sampleView?.setNeedsDisplay()
        if(annotStyle != nil) {
            delegate?.inkViewController?(self, annotStyle: annotStyle!)
        }
    }
    
    // MARK: - CPDFColorPickerViewDelegate
    
    override func pickerView(_ colorPickerView: CPDFColorPickerView, color: UIColor) {
        sampleView?.color = color
        annotStyle?.setColor(color)
        if(annotStyle != nil) {
            delegate?.inkViewController?(self, annotStyle: annotStyle!)
        }
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        self.opacitySliderView?.opacitySlider?.value = Float(alpha)
        self.opacitySliderView?.startLabel?.text = "\(Int(((self.opacitySliderView?.opacitySlider?.value ?? 0) / 1) * 100))%"
        updatePreferredContentSizeWithTraitCollection(traitCollection: traitCollection)
    }
    
    // MARK: - CPDFOpacitySliderViewDelegate
    
    override func opacitySliderView(_ opacitySliderView: CPDFOpacitySliderView, opacity: CGFloat) {
        sampleView?.opcity = opacity
        annotStyle?.setOpacity(opacity)
        if(annotStyle != nil) {
            delegate?.inkViewController?(self, annotStyle: annotStyle!)
        }
        sampleView?.setNeedsDisplay()
    }
    
    // MARK: - UIColorPickerViewControllerDelegate
    
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        sampleView?.color = viewController.selectedColor
        annotStyle?.setColor(viewController.selectedColor)
        if(annotStyle != nil) {
            delegate?.inkViewController?(self, annotStyle: annotStyle!)
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


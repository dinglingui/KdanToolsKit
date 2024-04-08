//
//  CPDFHighlightViewController.swift
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

@objc protocol CPDFHighlightViewControllerDelegate: AnyObject {
    @objc optional func highlightViewController(_ highlightViewController: CPDFHighlightViewController, annotStyle: CAnnotStyle)
}

class CPDFHighlightViewController: CPDFAnnotationBaseViewController {
    weak var delegate: CPDFHighlightViewControllerDelegate?
    
    // MARK: - ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func commomInitTitle() {
        titleLabel?.text = NSLocalizedString("Highlight", comment: "")
        sampleView?.selecIndex = .highlight
        colorView?.selectedColor = annotStyle?.color
    }
    
    // MARK: - CPDFColorSelectViewDelegate
    
    override func selectColorView(_ select: CPDFColorSelectView, color: UIColor) {
        sampleView?.color = color
        annotStyle?.setColor(color)
        if annotStyle != nil {
            delegate?.highlightViewController?(self, annotStyle: annotStyle!)
        }
        
        sampleView?.setNeedsDisplay()
    }
    
    
    // MARK: - CPDFColorPickerViewDelegate
    
    override func pickerView(_ colorPickerView: CPDFColorPickerView, color: UIColor) {
        sampleView?.color = color
        annotStyle?.setColor(color)
        
        delegate?.highlightViewController?(self, annotStyle: annotStyle!)
        
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
        if annotStyle != nil {
            delegate?.highlightViewController?(self, annotStyle: annotStyle!)
        }
        sampleView?.setNeedsDisplay()
    }
    
    // MARK: - UIColorPickerViewControllerDelegate
    
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        sampleView?.color = viewController.selectedColor
        annotStyle?.setColor(viewController.selectedColor)
        if annotStyle != nil {
            delegate?.highlightViewController?(self, annotStyle: annotStyle!)
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


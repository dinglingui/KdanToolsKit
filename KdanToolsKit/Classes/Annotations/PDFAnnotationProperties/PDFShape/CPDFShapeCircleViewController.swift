//
//  CPDFShapeCircleViewController.swift
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

import Foundation

@objc protocol CPDFShapeCircleViewControllerDelegate: AnyObject {
    @objc optional func circleViewController(_ circleViewController: CPDFShapeCircleViewController, annotStyle: CAnnotStyle)
}

class CPDFShapeCircleViewController: CPDFAnnotationBaseViewController, CPDFThicknessSliderViewDelegate {
    weak var delegate: CPDFShapeCircleViewControllerDelegate?
    var fillColorSelectView: CPDFColorSelectView?
    var thicknessView: CPDFThicknessSliderView?
    var dottedView: CPDFThicknessSliderView?
    var fillColorPicker: CPDFColorPickerView?
    var index: Int = 0
    var titles = ""
    
    var isFill: Bool = false

    private var dashPattern: [NSNumber]  = [NSNumber]()
    
    // MARK: - Initializers
    
    override init(annotStyle: CAnnotStyle) {
        super.init(annotStyle: annotStyle)
//        self.annotStyle = annotStyle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.thicknessView = CPDFThicknessSliderView(frame: CGRect.zero)
        self.thicknessView?.delegate = self
        self.thicknessView?.autoresizingMask = [.flexibleWidth]
        if thicknessView != nil {
            self.scrcollView?.addSubview(self.thicknessView!)
        }
        
        self.dottedView = CPDFThicknessSliderView(frame: CGRect.zero)
        self.dottedView?.delegate = self
        self.dottedView?.thicknessSlider?.minimumValue = 0.0
        self.dottedView?.thicknessSlider?.maximumValue = 10.0
        self.dottedView?.autoresizingMask = [.flexibleWidth]
        if dottedView != nil {
            self.scrcollView?.addSubview(self.dottedView!)
        }
        
        self.fillColorSelectView = CPDFColorSelectView(frame: CGRect.zero)
        self.fillColorSelectView?.delegate = self
        self.fillColorSelectView?.autoresizingMask = [.flexibleWidth]
        if fillColorSelectView != nil {
            self.scrcollView?.addSubview(self.fillColorSelectView!)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.scrcollView?.frame = CGRect(x: 0, y: 170, width: self.view.frame.size.width, height: self.view.frame.size.height - 170)
        self.scrcollView?.contentSize = CGSize(width: self.view.frame.size.width, height: 550)
        
        if #available(iOS 11.0, *) {
            self.colorView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: 0, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 90)
            self.fillColorSelectView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: 90, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 90)
            self.opacitySliderView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: 180, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 90)
            self.thicknessView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: 270, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 90)
            self.dottedView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: 360, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 90)
            self.backBtn?.frame = CGRect(x: self.view.frame.size.width - 60 - self.view.safeAreaInsets.right, y: 5, width: 50, height: 50)
        } else {
            self.colorView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 90)
            self.opacitySliderView?.frame = CGRect(x: 0, y: 180, width: self.view.frame.size.width, height: 90)
            self.fillColorSelectView?.frame = CGRect(x: 0, y: 90, width: self.view.frame.size.width, height: 90)
            self.thicknessView?.frame = CGRect(x: 0, y: 270, width: self.view.frame.size.width, height: 90)
            self.dottedView?.frame = CGRect(x: 0, y: 360, width: self.view.frame.size.width, height: 90)
            self.backBtn?.frame = CGRect(x: self.view.frame.size.width - 60, y: 5, width: 50, height: 50)
        }
    }
    
    // MARK: - Protect Mehthods
    
    override func commomInitTitle() {
        self.sampleView?.color = self.annotStyle?.color
        self.sampleView?.interiorColor = UIColor.white
        self.sampleView?.thickness = 4.0
        self.sampleView?.selecIndex = CPDFSamplesSelectedIndex(rawValue: self.annotStyle?.annotMode.rawValue ?? 0)!
        switch self.annotStyle?.annotMode {
        case .circle:
            self.titleLabel?.text = NSLocalizedString("Circle", comment: "")
        case .square:
            self.titleLabel?.text = NSLocalizedString("Square", comment: "")
        case .arrow:
            self.titleLabel?.text = NSLocalizedString("Arrow", comment: "")
        case .line:
            self.titleLabel?.text = NSLocalizedString("Line", comment: "")
        default:
            break
        }
        
        self.fillColorSelectView?.colorLabel?.text = NSLocalizedString("Fill Color", comment: "")
        self.thicknessView?.titleLabel?.text = NSLocalizedString("Line Width", comment: "")
        self.colorView?.colorLabel?.text = NSLocalizedString("Stroke Color", comment: "")
        self.dottedView?.titleLabel?.text = NSLocalizedString("Line and Border Style", comment: "")
        self.colorView?.selectedColor = self.annotStyle?.color
        self.fillColorSelectView?.selectedColor = self.annotStyle?.interiorColor
    }
    
    override func commomInitFromAnnotStyle() {
        self.opacitySliderView?.opacitySlider?.value = Float(self.annotStyle?.opacity ?? 1)
        self.opacitySliderView?.startLabel?.text = "\(Int(((self.opacitySliderView?.opacitySlider?.value ?? 0)/1)*100))%"
        self.thicknessView?.thicknessSlider?.value = Float(self.annotStyle?.lineWidth ?? 1)
        self.thicknessView?.startLabel?.text = "\(Int(self.thicknessView?.thicknessSlider?.value ?? 0)) pt"
        self.dashPattern = self.annotStyle?.dashPattern ?? []
        self.dottedView?.thicknessSlider?.value = Float(truncating: self.dashPattern.first ?? 0)
        self.dottedView?.startLabel?.text = "\(Int(self.dottedView?.thicknessSlider?.value ?? 0)) pt"
        
        self.sampleView?.color = self.annotStyle?.color
        self.sampleView?.opcity = self.annotStyle?.opacity ?? 1
        self.sampleView?.thickness = self.annotStyle?.lineWidth ?? 1
        self.sampleView?.dotted = CGFloat(self.dottedView?.thicknessSlider?.value ?? 0)
        self.sampleView?.interiorColor = self.annotStyle?.interiorColor
        self.sampleView?.setNeedsDisplay()
    }
    
    override func updatePreferredContentSizeWithTraitCollection(traitCollection: UITraitCollection) {
        if self.colorPicker?.superview != nil || self.fillColorPicker?.superview != nil {
            let currentDevice = UIDevice.current
            if currentDevice.userInterfaceIdiom == .pad {
                // This is an iPad
                self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: 520)
            } else {
                // This is an iPhone or iPod touch
                self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: 320)
            }
        } else {
            self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? 350 : 660)
        }
    }
    
    func updateBorderColor(_ color: UIColor?) {
        if let color = color {
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            sampleView?.color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)

            annotStyle?.setColor(sampleView?.color)
            annotStyle?.setOpacity(sampleView?.opcity ?? 0)
            annotStyle?.setInteriorOpacity(sampleView?.opcity ?? 0)
        } else {
            sampleView?.color = color
            sampleView?.opcity = 0

            annotStyle?.setColor(color)
        }
        sampleView?.setNeedsDisplay()
        
        if annotStyle != nil {
            delegate?.circleViewController?(self, annotStyle: annotStyle!)
        }
        opacitySliderView?.opacitySlider?.value = Float(annotStyle?.opacity ?? 1)
        opacitySliderView?.startLabel?.text = "\(Int(((opacitySliderView?.opacitySlider?.value ?? 0) / 1) * 100))%"
    }

    func updateFillColor(_ color: UIColor?) {
        if let color = color {
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            sampleView?.interiorColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)

            annotStyle?.setInteriorColor(sampleView?.interiorColor)
            annotStyle?.setOpacity(sampleView?.opcity ?? 0)
            annotStyle?.setInteriorOpacity(sampleView?.opcity ?? 0)
        } else {
            sampleView?.interiorColor = color
            sampleView?.opcity = 0

            annotStyle?.setColor(color)
        }
        sampleView?.setNeedsDisplay()
        
        if annotStyle != nil {
            delegate?.circleViewController?(self, annotStyle: annotStyle!)
        }
        opacitySliderView?.opacitySlider?.value = Float(annotStyle?.opacity ?? 1)
        opacitySliderView?.startLabel?.text = "\(Int(((opacitySliderView?.opacitySlider?.value ?? 0) / 1) * 100))%"
    }
    
    // MARK: - CPDFColorPickerViewDelegate
    
    override func pickerView(_ colorPickerView: CPDFColorPickerView, color: UIColor) {
        if colorPickerView == colorPicker {
            updateBorderColor(color)
        } else if colorPicker == fillColorPicker {
            updateFillColor(color)
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
        annotStyle?.setInteriorOpacity(opacity)
        if annotStyle != nil {
            delegate?.circleViewController?(self, annotStyle: annotStyle!)
        }
        sampleView?.setNeedsDisplay()
    }
    
    // MARK: - CPDFThicknessSliderViewDelegate
    
    func thicknessSliderView(_ opacitySliderView: CPDFThicknessSliderView, thickness: CGFloat) {
        if opacitySliderView == thicknessView {
            sampleView?.thickness = thickness
            annotStyle?.setLineWidth(thickness)
            if annotStyle != nil {
                delegate?.circleViewController?(self, annotStyle: annotStyle!)
            }
            
            sampleView?.setNeedsDisplay()
        } else if opacitySliderView == dottedView {
            sampleView?.dotted = thickness
            annotStyle?.setStyle(.dashed)
            annotStyle?.setDashPattern([NSNumber(value: thickness)])
            if annotStyle != nil {
                delegate?.circleViewController?(self, annotStyle: annotStyle!)
            }
            
            sampleView?.setNeedsDisplay()
        }
    }
    
    // MARK: - CPDFColorSelectViewDelegate
    
    override func selectColorView(_ select: CPDFColorSelectView) {
        if select == self.colorView {
            if #available(iOS 14.0, *) {
                let picker = UIColorPickerViewController()
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
                
                isFill = false
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
                self.colorPicker?.backgroundColor = UIColor.white
                if colorPicker != nil {
                    self.view.addSubview(self.colorPicker!)
                }
                
                self.updatePreferredContentSizeWithTraitCollection(traitCollection: self.traitCollection)
            }
        } else if select == self.fillColorSelectView {
            if #available(iOS 14.0, *) {
                let fillPicker = UIColorPickerViewController()
                fillPicker.delegate = self
                self.present(fillPicker, animated: true, completion: nil)
                
                isFill = true
            } else {
                let currentDevice = UIDevice.current
                if currentDevice.userInterfaceIdiom == .pad {
                    // This is an iPad
                    self.fillColorPicker = CPDFColorPickerView(frame: CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.size.width, height: 520))
                } else {
                    // This is an iPhone or iPod touch
                    self.fillColorPicker = CPDFColorPickerView(frame: CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.size.width, height: 320))
                }
                self.fillColorPicker?.delegate = self
                self.fillColorPicker?.backgroundColor = UIColor.white
                if fillColorPicker != nil {
                    self.view.addSubview(self.fillColorPicker!)
                }
                
                self.updatePreferredContentSizeWithTraitCollection(traitCollection: self.traitCollection)
            }
        }

    }
    
    override func selectColorView(_ select: CPDFColorSelectView, color: UIColor) {
        if select == colorView {
            updateBorderColor(color)
        } else if select == fillColorSelectView {
            updateFillColor(color)
        }
    }
    

    // MARK: - UIColorPickerViewControllerDelegate
    
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        
        if isFill {
            updateFillColor(color)
        } else {
            updateBorderColor(color)
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



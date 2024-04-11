//
//  CPDFShapeArrowViewController.swift
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

@objc protocol CPDFShapeArrowViewControllerDelegate: AnyObject {
    @objc optional func arrowViewController(_ arrowViewController: CPDFShapeArrowViewController, annotStyle: CAnnotStyle)
}

class CPDFShapeArrowViewController: CPDFShapeCircleViewController, CPDFArrowStyleViewDelegate, CShapeSelectViewDelegate {
    
    weak var lineDelegate: CPDFShapeArrowViewControllerDelegate?
    
    private var arrowLabel: UILabel?
    private var arrowBtn: UIButton?
    private var trialLabel: UILabel?
    private var trialBtn: UIButton?
    private var startArrowStyleView: CPDFArrowStyleView?
    private var endArrowStyleView: CPDFArrowStyleView?
    private var startDrawView: CPDFDrawArrowView?
    private var endDrawView: CPDFDrawArrowView?
    private var dashPattern: [NSNumber] = []
    private var shapeSelectView: CShapeSelectView?
    
    // MARK: - Initializers
    
    override init(annotStyle: CAnnotStyle) {
        super.init(annotStyle: annotStyle)
        self.annotStyle = annotStyle
    }
    
    // MARK: - ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.arrowLabel = UILabel()
        self.arrowLabel?.text = NSLocalizedString("Start", comment: "")
        self.arrowLabel?.textColor = UIColor.gray
        self.arrowLabel?.font = UIFont.systemFont(ofSize: 12.0)
        if self.arrowLabel != nil {
            self.scrcollView?.addSubview(self.arrowLabel!)
        }
        self.arrowBtn = UIButton()
        self.arrowBtn?.setImage(UIImage(named: "CPDFShapeArrowImageStart", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        self.arrowBtn?.layer.borderWidth = 1.0
        self.arrowBtn?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        self.arrowBtn?.autoresizingMask = .flexibleLeftMargin
        self.arrowBtn?.addTarget(self, action: #selector(buttonItemClicked_start(_:)), for: .touchUpInside)
        if self.arrowBtn != nil {
            self.scrcollView?.addSubview(self.arrowBtn!)
        }
        
        self.startDrawView = CPDFDrawArrowView(frame: CGRect.zero)
        self.startDrawView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if self.startDrawView != nil {
            self.arrowBtn?.addSubview(self.startDrawView!)
        }
        
        self.trialLabel = UILabel()
        self.trialLabel?.text = NSLocalizedString("End", comment: "")
        self.trialLabel?.textColor = UIColor.gray
        self.trialLabel?.font = UIFont.systemFont(ofSize: 12.0)
        self.trialLabel?.autoresizingMask = .flexibleRightMargin
        if self.trialLabel != nil {
            self.scrcollView?.addSubview(self.trialLabel!)
        }
        
        self.trialBtn = UIButton()
        self.trialBtn?.setImage(UIImage(named: "CPDFShapeArrowImageEnd", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        self.trialBtn?.layer.borderWidth = 1.0
        self.trialBtn?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        self.trialBtn?.addTarget(self, action: #selector(buttonItemClicked_trial(_:)), for: .touchUpInside)
        self.trialBtn?.autoresizingMask = .flexibleLeftMargin
        if self.trialLabel != nil {
            self.scrcollView?.addSubview(self.trialBtn!)
        }
        
        self.endDrawView = CPDFDrawArrowView(frame: CGRect.zero)
        self.endDrawView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
            if self.endDrawView != nil {
                self.trialBtn?.addSubview(self.endDrawView!)
            }
        
        self.fillColorSelectView?.isHidden = true
        
        self.view.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.scrcollView?.frame = CGRect(x: 0, y: 170, width: self.view.frame.size.width, height: self.view.frame.size.height-170)
        self.scrcollView?.contentSize = CGSize(width: self.view.frame.size.width, height: 500)
        if #available(iOS 11.0, *) {
            var offsetY: CGFloat = 0
            self.colorView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: 0, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 90)
            offsetY += self.colorView?.frame.size.height ?? 0
            self.opacitySliderView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: offsetY, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 90)
            offsetY += self.opacitySliderView?.frame.size.height ?? 0
            
            self.thicknessView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: offsetY, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 90)
            offsetY += self.thicknessView?.frame.size.height ?? 0
            
            self.dottedView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: offsetY, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 90)
            offsetY += (self.dottedView?.frame.size.height ?? 0)
            
            self.arrowLabel?.frame = CGRect(x: self.view.safeAreaInsets.left+20, y: offsetY, width: 100, height: 45)
            self.arrowBtn?.frame = CGRect(x: self.view.frame.size.width - 100 - self.view.safeAreaInsets.right, y: offsetY + 7.5, width: 80, height: 30)
            offsetY += self.arrowLabel?.frame.size.height ?? 0
            self.startDrawView?.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
            
            self.trialLabel?.frame = CGRect(x: self.view.safeAreaInsets.left+20, y: offsetY, width: 100, height: 45)
            self.trialBtn?.frame = CGRect(x: self.view.frame.size.width - 100 - self.view.safeAreaInsets.right, y: offsetY + 7.5, width: 80, height: 30)
            self.endDrawView?.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        } else {
            var offsetY: CGFloat = 0
            self.colorView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 90)
            offsetY += self.colorView?.frame.size.height ?? 0
            self.opacitySliderView?.frame = CGRect(x: 0, y: offsetY, width: self.view.frame.size.width - 0, height: 90)
            offsetY += self.opacitySliderView?.frame.size.height ?? 0
            
            self.thicknessView?.frame = CGRect(x: 0, y: offsetY, width: self.view.frame.size.width, height: 90)
            offsetY += self.thicknessView?.frame.size.height ?? 0
            
            self.dottedView?.frame = CGRect(x: 0, y: offsetY, width: self.view.frame.size.width, height: 90)
            offsetY += self.dottedView?.frame.size.height ?? 0
            
            self.arrowLabel?.frame = CGRect(x: 20, y: offsetY, width: 100, height: 45)
            self.arrowBtn?.frame = CGRect(x: self.view.frame.size.width - 100, y: offsetY + 7.5, width: 80, height: 30)
            offsetY += self.arrowLabel?.frame.size.height ?? 0
            self.startDrawView?.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
            
            self.trialLabel?.frame = CGRect(x: 20, y: offsetY, width: 100, height: 45)
            self.trialBtn?.frame = CGRect(x: self.view.frame.size.width - 100, y: offsetY + 7.5, width: 80, height: 30)
            self.endDrawView?.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        }
        
    }
    
    // MARK: - Protect Mehthods
    
    override func commomInitFromAnnotStyle() {
        self.opacitySliderView?.opacitySlider?.value = Float(self.annotStyle?.opacity ?? 0)
        self.opacitySliderView?.startLabel?.text = "\(Int(((self.opacitySliderView?.opacitySlider?.value ?? 0)/1)*100))%"
        self.thicknessView?.thicknessSlider?.value = Float(self.annotStyle?.lineWidth ?? 0)
        self.thicknessView?.startLabel?.text = "\(Int(self.thicknessView?.thicknessSlider?.value ?? 0)) pt"
        self.dashPattern = self.annotStyle?.dashPattern ?? []
        self.dottedView?.thicknessSlider?.value = Float(truncating: self.dashPattern.first ?? 0)
        self.dottedView?.startLabel?.text = "\(Int(self.dottedView?.thicknessSlider?.value ?? 0)) pt"
        self.startDrawView?.selectIndex = self.annotStyle?.startLineStyle.rawValue ?? 0
        self.endDrawView?.selectIndex = self.annotStyle?.endLineStyle.rawValue ?? 1
        startDrawView?.setNeedsDisplay()
        endDrawView?.setNeedsDisplay()
        
        self.sampleView?.color = self.annotStyle?.color
        self.sampleView?.opcity = self.annotStyle?.opacity ?? 1
        self.sampleView?.thickness = self.annotStyle?.lineWidth ?? 1
        self.sampleView?.dotted = CGFloat(self.dottedView?.thicknessSlider?.value ?? 0)
        self.sampleView?.interiorColor = self.annotStyle?.interiorColor
        self.sampleView?.startArrowStyleIndex = CPDFArrowStyle(rawValue: self.annotStyle?.startLineStyle.rawValue ?? 0)!
        self.sampleView?.endArrowStyleIndex = CPDFArrowStyle(rawValue: self.annotStyle?.endLineStyle.rawValue ?? 0)!
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
    
    // MARK: - Action
    
    @objc func buttonItemClicked_start(_ sender: Any) {
        self.startArrowStyleView = CPDFArrowStyleView(title: NSLocalizedString("Arrow Style", comment: ""))
        self.startArrowStyleView?.frame = self.view.frame
        self.startArrowStyleView?.delegate = self
        self.startArrowStyleView?.selectIndex = self.startDrawView?.selectIndex ?? 0
        self.startArrowStyleView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if (self.startArrowStyleView != nil) {
            self.view.addSubview(self.startArrowStyleView!)
        }
        self.updatePreferredContentSizeWithTraitCollection(traitCollection: self.traitCollection)
    }
    
    @objc func buttonItemClicked_trial(_ sender: Any) {
        self.endArrowStyleView = CPDFArrowStyleView(title: NSLocalizedString("Arrowtail style", comment: ""))
        self.endArrowStyleView?.frame = self.view.frame
        self.endArrowStyleView?.delegate = self
        self.endArrowStyleView?.selectIndex = self.endDrawView?.selectIndex ?? 0
        self.endArrowStyleView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if (self.endArrowStyleView != nil) {
            self.view.addSubview(self.endArrowStyleView!)
        }
        self.updatePreferredContentSizeWithTraitCollection(traitCollection: self.traitCollection)
    }
    
    // MARK: - CPDFArrowStyleViewDelegate
    
    func arrowStyleView(_ arrowStyleView: CPDFArrowStyleView, selectIndex: Int) {
        if arrowStyleView == self.startArrowStyleView {
            self.sampleView?.startArrowStyleIndex = CPDFArrowStyle(rawValue: selectIndex) ?? .none
            self.annotStyle?.setStartLineStyle(CPDFLineStyle(rawValue: selectIndex) ?? .none)
            if annotStyle != nil {
                lineDelegate?.arrowViewController?(self, annotStyle: self.annotStyle!)
            }
            self.sampleView?.setNeedsDisplay()
            self.startDrawView?.selectIndex = selectIndex
            self.startDrawView?.setNeedsDisplay()
            
        } else if arrowStyleView == self.endArrowStyleView {
            self.sampleView?.endArrowStyleIndex = CPDFArrowStyle(rawValue: selectIndex) ?? .none
            self.annotStyle?.setEndLineStyle(CPDFLineStyle(rawValue: selectIndex) ?? .none)
            if annotStyle != nil {
                lineDelegate?.arrowViewController?(self, annotStyle: self.annotStyle!)
            }
            self.sampleView?.setNeedsDisplay()
            self.endDrawView?.selectIndex = selectIndex
            self.endDrawView?.setNeedsDisplay()
            
        }
    }
    
    func arrowStyleRemoveView(_ arrowStyleView: CPDFArrowStyleView) {
        self.updatePreferredContentSizeWithTraitCollection(traitCollection: self.traitCollection)
    }
    
    // MARK: - CPDFOpacitySliderViewDelegate
    
    override func opacitySliderView(_ opacitySliderView: CPDFOpacitySliderView, opacity: CGFloat) {
        sampleView?.opcity = opacity
        annotStyle?.setOpacity(opacity)
        if annotStyle != nil {
            lineDelegate?.arrowViewController?(self, annotStyle: self.annotStyle!)
        }
        sampleView?.setNeedsDisplay()
    }
    
    // MARK: - CPDFThicknessSliderViewDelegate
    
    override func thicknessSliderView(_ opacitySliderView: CPDFThicknessSliderView, thickness: CGFloat) {
        if opacitySliderView == thicknessView {
            sampleView?.thickness = thickness
            annotStyle?.setLineWidth(thickness)
            if annotStyle != nil {
                lineDelegate?.arrowViewController?(self, annotStyle: self.annotStyle!)
            }
            
            sampleView?.setNeedsDisplay()
        } else if opacitySliderView == dottedView {
            sampleView?.dotted = thickness
            annotStyle?.setStyle(.dashed)
            annotStyle?.setDashPattern([NSNumber(value: thickness)])
            if annotStyle != nil {
                lineDelegate?.arrowViewController?(self, annotStyle: self.annotStyle!)
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
                if(self.colorPicker != nil) {
                    self.view.addSubview(self.colorPicker!)
                }
                
                self.updatePreferredContentSizeWithTraitCollection(traitCollection: self.traitCollection)
            }
        }

    }
    
    override func selectColorView(_ select: CPDFColorSelectView, color: UIColor) {
        if select == colorView {
            sampleView?.color = color
            annotStyle?.setColor(color)
            sampleView?.setNeedsDisplay()
            if annotStyle != nil {
                lineDelegate?.arrowViewController?(self, annotStyle: self.annotStyle!)
            }
        } else if select == fillColorSelectView {
            sampleView?.interiorColor = color
            annotStyle?.setInteriorColor(color)
            sampleView?.setNeedsDisplay()
            if annotStyle != nil {
                lineDelegate?.arrowViewController?(self, annotStyle: self.annotStyle!)
            }
        }
    }
    
    
    // MARK: - CPDFColorPickerViewDelegate
    
    override func pickerView(_ colorPickerView: CPDFColorPickerView, color: UIColor) {
        if colorPickerView == colorPicker {
            sampleView?.color = color
            annotStyle?.setColor(color)
            sampleView?.setNeedsDisplay()
            if annotStyle != nil {
                lineDelegate?.arrowViewController?(self, annotStyle: self.annotStyle!)
            }
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
    
    // MARK: - UIColorPickerViewControllerDelegate
    
    @available(iOS 14.0, *)
    override func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        
        sampleView?.color = color
        annotStyle?.setColor(color)
        sampleView?.setNeedsDisplay()
        if annotStyle != nil {
            lineDelegate?.arrowViewController?(self, annotStyle: self.annotStyle!)
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


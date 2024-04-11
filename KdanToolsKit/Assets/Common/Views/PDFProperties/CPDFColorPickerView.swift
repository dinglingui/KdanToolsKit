//
//  CPDFColorPickerView.swift
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

@objc protocol CPDFColorPickerViewDelegate: AnyObject {
   @objc optional func pickerView(_ colorPickerView: CPDFColorPickerView, color: UIColor)
}

class CPDFColorPickerView: UIView {
    weak var delegate: CPDFColorPickerViewDelegate?

    var color:UIColor?
    var selectedLabel:UILabel?
    var selectBtn:UIButton?
    var titleLabel:UILabel?
    var backBtn:UIButton?
    var colorSlider:UISlider?
    var colorLabel:UILabel?
    var hue:CGFloat = 0
    var saturation:CGFloat = 0
    var brightness:CGFloat = 0
    var gradientLayer:CAGradientLayer?
    var gradientLayers:CAGradientLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel = UILabel(frame: CGRect(x: (self.frame.size.width - 120)/2, y: 0, width: 120, height: 50))
        titleLabel?.text = NSLocalizedString("Custom Color", comment: "")
        titleLabel?.adjustsFontSizeToFitWidth = true
        self.addSubview(titleLabel!)

        backBtn = UIButton(frame: CGRect(x: 10, y: 0, width: 50, height: 50))
        backBtn?.autoresizingMask = [.flexibleLeftMargin]
        backBtn?.setImage(UIImage(named: "CPFFormBack", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        backBtn?.addTarget(self, action: #selector(buttonItemClicked_back(_:)), for: .touchUpInside)
        self.addSubview(backBtn!)

        selectedLabel = UILabel(frame: CGRect(x: 15, y: 50, width: self.bounds.size.width - 30, height: (self.bounds.size.height - 40)/6 * 3))
        selectedLabel?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        selectedLabel?.isUserInteractionEnabled = true
        
        gradientLayers = CAGradientLayer()
        gradientLayers?.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayers?.endPoint = CGPoint(x: 1.0, y: 0.5)
        selectedLabel?.layer.addSublayer(gradientLayers!)
        self.addSubview(selectedLabel!)

        selectBtn = UIButton(frame: CGRect(x: 15, y: (self.bounds.size.height - 40)/6, width: 30, height: 30))
        selectBtn?.backgroundColor = UIColor.clear
        selectBtn?.layer.cornerRadius = 15
        selectBtn?.layer.borderColor = UIColor.white.cgColor
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        selectBtn?.addGestureRecognizer(panGesture)
        selectBtn?.layer.borderWidth = 1.0
        self.addSubview(selectBtn!)

        colorSlider = UISlider(frame: CGRect(x: 15, y: (self.bounds.size.height - 40)/6 * 4, width: self.bounds.size.width - 30, height: (self.bounds.size.height - 40)/6))
        colorSlider?.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin]
        colorSlider?.minimumValue = 0
        colorSlider?.maximumValue = 1
        colorSlider?.value = 1
        colorSlider?.addTarget(self, action: #selector(sliderValueChanged_Color(_:)), for: .valueChanged)
        gradientLayer? = CAGradientLayer()
        gradientLayer?.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer?.endPoint = CGPoint(x: 1.0, y: 0.5)
        colorSlider?.layer.addSublayer(gradientLayer!)
        self.addSubview(colorSlider!)

        colorLabel = UILabel(frame: CGRect(x: 15, y: (self.bounds.size.height - 40)/6 * 5, width: self.bounds.size.width - 30, height: (self.bounds.size.height - 40)/6))
        colorLabel?.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin]
        self.addSubview(colorLabel!)

        hue = 0
        saturation = 1
        brightness = 1

        reloadData()

        self.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var rect = self.colorSlider?.trackRect(forBounds: self.colorSlider?.bounds ?? CGRect.zero)
        rect?.origin.y -= 5
        rect?.size.height += 10
        self.gradientLayer?.frame = rect ?? CGRect.zero

        gradientLayers?.frame = self.selectedLabel?.bounds ?? CGRect.zero
    }
    
    func reloadData() {
        var colors = [CGColor]()
        let hueStep: CGFloat = 1.0 / 8.0
        let saturationStep: CGFloat = 1.0 / 4.0
        for i in 0..<8 {
            var rowColors = [CGColor]()
            for j in 0..<4 {
                let color = UIColor(hue: CGFloat(i) * hueStep, saturation: 1.0 - CGFloat(j) * saturationStep, brightness: self.brightness, alpha: 1.0)
                rowColors.append(color.cgColor)
            }
            colors.append(contentsOf: rowColors)
        }
        gradientLayers?.colors = colors
        
        let colorArray: [CGColor] = [
            UIColor(hue: self.hue, saturation: self.saturation, brightness: 0, alpha: 1).cgColor,
            UIColor(hue: self.hue, saturation: self.saturation, brightness: 1, alpha: 1).cgColor
        ]
        gradientLayer?.colors = colorArray
        
        colorLabel?.backgroundColor = UIColor(hue: self.hue, saturation: self.saturation, brightness: self.brightness, alpha: 1)
    }
    
    // MARK: - UIPanGestureRecognizer
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let point = gestureRecognizer.translation(in: self.selectedLabel)
        let newX = (self.selectBtn?.center.x ?? 0) + point.x
        let newY = (self.selectBtn?.center.y ?? 0) + point.y
        if ((self.selectedLabel?.frame.contains(CGPoint(x: newX, y: newY))) == true) {
            self.selectBtn?.center = CGPoint(x: newX, y: newY)
        }
        gestureRecognizer.setTranslation(CGPoint.zero, in: self.selectedLabel)
        
        if let button = gestureRecognizer.view as? UIButton {
            let newFrame = button.frame.offsetBy(dx: point.x, dy: point.y)
            self.hue = 0.125 * ((newFrame.origin.x - 15) / (self.selectedLabel?.bounds.size.width ?? 0 / 8))
            self.saturation = 1 - 0.5 * ((newFrame.origin.y - (self.bounds.size.height - 40) / 6) / (self.selectedLabel?.bounds.size.height ?? 0 / 4))
        }
        reloadData()
    }

    // MARK: - Action
    @objc func sliderValueChanged_Color(_ sender: UISlider) {
        self.brightness = CGFloat(sender.value)
        self.reloadData()
    }
    
    @objc func buttonItemClicked_back(_ sender: UIButton) {
        self.removeFromSuperview()
        self.delegate?.pickerView?(self, color: self.colorLabel?.backgroundColor ?? UIColor.white)
    }

}

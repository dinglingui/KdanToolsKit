//
//  CStampColorSelectView.swift
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

@objc protocol CStampColorSelectViewDelegate: AnyObject {
    @objc optional func stampColorSelectView(_ stampColorSelectView: CStampColorSelectView, tag: Int)
}

class CStampColorSelectView: UIView {
    var colorLabel: UILabel?
    var selectedColor: UIColor?
    weak var delegate: CStampColorSelectViewDelegate?
    
    private var colorPickerView: UIView?
    private var colorArray: [UIView] = []
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.colorLabel = UILabel()
        self.colorLabel?.text = NSLocalizedString("Color", comment: "")
        self.colorLabel?.textColor = UIColor.gray
        self.colorLabel?.font = UIFont.systemFont(ofSize: 12.0)
        if colorLabel != nil {
            self.addSubview(self.colorLabel!)
        }
        self.colorPickerView = UIView()
        self.colorPickerView?.autoresizingMask = .flexibleWidth
        if colorPickerView != nil {
            self.addSubview(self.colorPickerView!)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.colorLabel?.frame = CGRect(x: 20, y: 0, width: 50, height: self.bounds.size.height-15)
        self.colorPickerView?.frame = CGRect(x: 70, y: 0, width: self.bounds.size.width-70, height: self.bounds.size.height)
        self.pickerBarInit()
    }
    
    func pickerBarInit() {
        let colors: [UIColor] = [
            UIColor.black,
            UIColor(red: 0.57, green: 0.06, blue: 0.02, alpha: 1.0),
            UIColor(red: 0.25, green: 0.42, blue: 0.13, alpha: 1.0),
            UIColor(red: 0.09, green: 0.15, blue: 0.39, alpha: 1.0)
        ]
        var array: [UIView] = []
        for i in 0..<colors.count {
            let view = UIButton()
            view.tag = i

            let colorPickerViewBounds = self.colorPickerView?.bounds ?? CGRect.zero
            let heightMinus20 = colorPickerViewBounds.size.height - 20
            let iPlus1 = CGFloat(i) + 1

            let xNumerator = (colorPickerViewBounds.size.width - (heightMinus20 * 4))/5 * iPlus1
            let xDenominator = heightMinus20 * CGFloat(i)
            let x = xNumerator + xDenominator

            let y: CGFloat = 5
            let width = colorPickerViewBounds.size.height - 20
            let heightz = colorPickerViewBounds.size.height - 20

            view.frame = CGRect(x: x, y: y, width: width, height: heightz)
            let heigth = self.colorPickerView?.bounds.size.height ?? 0


            view.layer.cornerRadius = (heigth - 20)/2
            view.layer.masksToBounds = true
            view.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin]
            view.layer.borderColor = UIColor.white.cgColor
            view.layer.borderWidth = 1.0
            if let selectedColor = self.selectedColor {
                var red1: CGFloat = 0, green1: CGFloat = 0, blue1: CGFloat = 0, alpha1: CGFloat = 0
                selectedColor.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
                
                var red2: CGFloat = 0, green2: CGFloat = 0, blue2: CGFloat = 0, alpha2: CGFloat = 0
                colors[i].getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
                
                if abs(red1 - red2) < CGFloat.ulpOfOne &&
                    abs(green1 - green2) < CGFloat.ulpOfOne &&
                    abs(blue1 - blue2) < CGFloat.ulpOfOne {
                    view.layer.borderColor = UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0).cgColor
                } else {
                    view.layer.borderColor = UIColor.white.cgColor
                }
            } else {
                view.layer.borderColor = UIColor.white.cgColor
            }
            
            view.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
            array.append(view)
            self.colorPickerView?.addSubview(view)
            
            let button = UIButton()
            button.frame = view.frame.insetBy(dx: 3, dy: 3)
            button.layer.cornerRadius = (heigth - 26)/2
            button.layer.masksToBounds = true
            button.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin]
            self.colorPickerView?.addSubview(button)
            button.backgroundColor = colors[i]
            button.tag = i
            button.addTarget(self, action: #selector(buttonItemClicked_select(_:)), for: .touchUpInside)
        }
        self.colorArray = array
        
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_select(_ button: UIButton) {
        for i in 0..<self.colorArray.count {
            self.colorArray[i].layer.borderColor = UIColor.white.cgColor
        }
        self.colorArray[button.tag].layer.borderColor = UIColor.blue.cgColor
        
        delegate?.stampColorSelectView?(self, tag: button.tag)
        
    }
    
    func setSelectedColor(_ selectedColor: UIColor) {
        self.selectedColor = selectedColor
    }
}


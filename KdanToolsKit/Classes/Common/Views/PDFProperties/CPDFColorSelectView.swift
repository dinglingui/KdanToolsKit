//
//  CPDFColorSelectView.swift
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

@objc protocol CPDFColorSelectViewDelegate: AnyObject {
    @objc optional func selectColorView(_ select: CPDFColorSelectView)
    
    @objc optional func selectColorView(_ select: CPDFColorSelectView, color: UIColor)
}

class CPDFColorSelectView: UIView {
    
    weak var delegate: CPDFColorSelectViewDelegate?
    var selectedColor:UIColor?
    var colorLabel:UILabel?
    var colorPickerView:UIScrollView?

    var colorArray:[UIView]?
    var buttonArray:[UIButton]?


    override init(frame: CGRect) {
        super.init(frame: frame)
        
        colorLabel = UILabel()
           colorLabel?.text = NSLocalizedString("Color", comment: "")
           colorLabel?.textColor = UIColor.gray
           colorLabel?.font = UIFont.systemFont(ofSize: 12.0)
           addSubview(colorLabel!)
           
           colorArray = [UIView]()
           buttonArray = [UIButton]()
           colorPickerView = UIScrollView()
           colorPickerView?.showsHorizontalScrollIndicator = false
           colorPickerView?.autoresizingMask = .flexibleWidth
           
           addSubview(colorPickerView!)
           backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pickerBarInit() {
        if self.colorPickerView == nil {
            return
        }
        
        for view in colorPickerView!.subviews {
            view.removeFromSuperview()
        }
        
        let colors: [UIColor] = [
            UIColor(red: 233.0/255.0, green: 27.0/255.0, blue: 0.0, alpha: 1.0),
            UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
            UIColor(red: 0.0/255.0, green: 188.0/255.0, blue: 162.0/255.0, alpha: 1.0),
            UIColor(red: 61.0/255.0, green: 136.0/255.0, blue: 71.0/255.0, alpha: 1.0),
            UIColor(red: 91.0/255.0, green: 122.0/255.0, blue: 162.0/255.0, alpha: 1.0),
            UIColor(red: 92.0/255.0, green: 187.0/255.0, blue: 247.0/255.0, alpha: 1.0),
            UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0),
            UIColor.clear
        ]
        
        var array = [UIView]()
        
        for i in 0..<colors.count {
            let view = UIView()
            view.tag = i
            view.frame = CGRect(x: (bounds.size.width + 100 - 16 - ((colorPickerView!.bounds.size.height - 16)*8))/9 * CGFloat(i+1) + (colorPickerView!.bounds.size.height - 16) * CGFloat(i), y: 5, width: colorPickerView!.bounds.size.height - 16, height: colorPickerView!.bounds.size.height - 16)
            view.layer.cornerRadius = (colorPickerView!.bounds.size.height - 16)/2
            view.layer.borderWidth = 1.0
            
            if self.selectedColor != nil {
                var red1: CGFloat = 0, green1: CGFloat = 0, blue1: CGFloat = 0, alpha1: CGFloat = 0
                selectedColor!.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
                
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
            colorPickerView!.addSubview(view)
            
            let button = UIButton()
            colorPickerView!.addSubview(button)
            button.frame = view.frame.insetBy(dx: 3, dy: 3)
            button.layer.cornerRadius = (colorPickerView!.bounds.size.height - 22)/2
            button.layer.masksToBounds = true
            button.layer.borderWidth = 0.5
            button.layer.borderColor = UIColor.gray.cgColor
            button.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin]
            button.backgroundColor = colors[i]
            button.tag = i
            button.addTarget(self, action: #selector(buttonItemClicked_select(_:)), for: .touchUpInside)
            if i == 7 {
                button.setBackgroundImage(UIImage(named: "CPDFColorSelectViewImageColor", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
            }
        }
        
        colorArray = array
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        colorLabel?.frame = CGRect(x: 20, y: 0, width: bounds.size.width, height: bounds.size.height/3)
        colorPickerView?.frame = CGRect(x: 20, y: bounds.size.height/3, width: bounds.size.width-40, height: 60)
        colorPickerView?.contentSize = CGSize(width: bounds.size.width+100, height: 60)
        pickerBarInit()
    }
    
    // MARK: - Action
    @objc func buttonItemClicked_select(_ button: UIButton) {
        for view in colorArray ?? [] {
            view.layer.borderColor = UIColor.white.cgColor
        }
        
        colorArray?[button.tag].layer.borderColor = UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0).cgColor
        
        switch button.tag {
        case 0...6:
            self.delegate?.selectColorView?(self, color: button.backgroundColor ?? UIColor.white)
        case 7:
            self.delegate?.selectColorView?(self)
        default:
            break
        }
    }

}

//
//  CPDFOpacitySliderView.swift
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

@objc protocol CPDFOpacitySliderViewDelegate: AnyObject {
    @objc optional func opacitySliderView(_ opacitySliderView: CPDFOpacitySliderView, opacity: CGFloat)
}

class CPDFOpacitySliderView: UIView {
    
    weak var delegate: CPDFOpacitySliderViewDelegate?
    
    var titleLabel:UILabel?
    var opacitySlider:UISlider?
    var startLabel:UILabel?
    var leftMargin:CGFloat = 0
    var rightMargin:CGFloat = 0
    var rightTitleMargin:CGFloat = 0
    var sliderCount:Int = 0
    
    var bgColor: UIColor? {
        didSet {
            backgroundColor = bgColor
        }
    }
    
    var defaultValue: CGFloat = 0 {
        didSet {
            opacitySlider?.value = Float(defaultValue)
            startLabel?.text = "\(Int((defaultValue/1)*100))%"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel = UILabel()
        titleLabel?.autoresizingMask = .flexibleRightMargin
        titleLabel?.text = NSLocalizedString("Opacity", comment: "")
        titleLabel?.textColor = .gray
        titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        addSubview(titleLabel!)
        
        opacitySlider = UISlider()
        opacitySlider?.autoresizingMask = .flexibleWidth
        opacitySlider?.value = 1
        opacitySlider?.maximumValue = 1
        opacitySlider?.minimumValue = 0
        opacitySlider?.addTarget(self, action: #selector(buttonItemClicked_changes(_:)), for: .valueChanged)
        addSubview(opacitySlider!)
        
        startLabel = UILabel()
        startLabel?.layer.borderWidth = 1.0
        startLabel?.textAlignment = .center
        startLabel?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        startLabel?.autoresizingMask = .flexibleRightMargin
        startLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
        addSubview(startLabel!)
        
        sliderCount = 10
        leftMargin = 0
        rightMargin = 0
        rightTitleMargin = 0
        
        backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel?.frame = CGRect(x: 20 - rightTitleMargin, y: 0, width: frame.size.width, height: frame.size.height/2)
        opacitySlider?.frame = CGRect(x: 20 - leftMargin, y: frame.size.height/2, width: frame.size.width - 130 + leftMargin + rightMargin, height: frame.size.height/2)
        startLabel?.frame = CGRect(x: frame.size.width - 100 + rightMargin, y: frame.size.height/2 + 7.5, width: 80, height: frame.size.height/2 - 15)
    }
    
    // MARK: - Action
    @objc func buttonItemClicked_changes(_ button: UISlider) {
        sliderCount -= 1
        
        if sliderCount == 3 {
            startLabel?.text = "\(Int((button.value/1)*100))%"
            self.delegate?.opacitySliderView?(self, opacity: CGFloat(button.value))
            sliderCount = 10
        }
    }
    
}

//
//  CPDFThicknessSliderView.swift
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

@objc protocol CPDFThicknessSliderViewDelegate: AnyObject {
    @objc optional func thicknessSliderView(_ opacitySliderView: CPDFThicknessSliderView, thickness: CGFloat)

}

class CPDFThicknessSliderView: UIView {

    weak var delegate: CPDFThicknessSliderViewDelegate?
        
    var titleLabel:UILabel?
    var thicknessSlider:UISlider?
    var startLabel:UILabel?
    var endLabel:UILabel?
    var thick:Float = 0
    var leftMargin:CGFloat = 0
    var rightMargin:CGFloat = 0
    var leftTitleMargin:CGFloat = 0
    var sliderCount:Int = 0
    
    var defaultValue: CGFloat = 0 {
        didSet {
            thicknessSlider?.value = Float(defaultValue * 10)
            startLabel?.text = "\(Int(defaultValue * 100)) pt"
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.titleLabel = UILabel()
        self.titleLabel?.text = NSLocalizedString("Thickeness", comment:"")
        self.titleLabel?.autoresizingMask = .flexibleRightMargin
        self.titleLabel?.textColor = UIColor.gray
        self.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        self.addSubview(self.titleLabel!)
        self.thicknessSlider = UISlider()
        self.thicknessSlider?.autoresizingMask = .flexibleWidth
        self.thicknessSlider?.maximumValue = 10.0
        self.thicknessSlider?.minimumValue = 0.1
        self.thicknessSlider?.addTarget(self, action: #selector(buttonItemClicked_changes(_:)), for: .valueChanged)
        self.addSubview(self.thicknessSlider!)
        
        self.startLabel = UILabel()
        self.startLabel?.text = NSLocalizedString("10pt", comment:"")
        self.startLabel?.layer.borderWidth = 1.0
        self.startLabel?.textAlignment = .center
        self.startLabel?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        self.startLabel?.autoresizingMask = .flexibleRightMargin
        self.startLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
        self.addSubview(self.startLabel!)
        
        self.thick = 1
        self.sliderCount = 10
        self.leftTitleMargin = 0
        self.rightMargin = 0
        self.leftMargin = 0
        self.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleLabel?.frame = CGRect(x: 20 - self.leftTitleMargin, y: 0, width: self.frame.size.width, height: self.frame.size.height/2)
        self.thicknessSlider?.frame = CGRect(x: 20 - self.leftMargin, y: self.frame.size.height/2, width: self.frame.size.width - 130 + self.leftMargin + self.rightMargin, height: self.frame.size.height/2)
        self.startLabel?.frame = CGRect(x: self.frame.size.width - 100 + self.rightMargin, y: self.frame.size.height/2 + 7.5, width: 80, height: self.frame.size.height/2 - 15)
        
    }
    
    // MARK: - Action
    @objc func buttonItemClicked_changes(_ button: UISlider) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(updateNewAppearanceStream), object: button)
        perform(#selector(updateNewAppearanceStream), with: button, afterDelay: 0.2)
        
    }
    
    @objc func updateNewAppearanceStream(_ button: UISlider) {
        self.startLabel?.text = String(format: "%.0f pt", button.value * self.thick)
        self.delegate?.thicknessSliderView?(self, thickness: CGFloat(button.value))
    }

}

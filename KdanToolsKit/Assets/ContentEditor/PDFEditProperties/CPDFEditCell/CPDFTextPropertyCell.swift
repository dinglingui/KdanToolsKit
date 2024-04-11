//
//  CPDFTextPropertyCell.swift
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

enum CPDFTextActionType: UInt {
    case colorSelect
    case fontNameSelect
    case fontStyleSelect

}

enum CPDFTextAlignment: UInt {
    case left
    case center
    case right
    case justified
    case natural
}

class CPDFTextPropertyCell: UITableViewCell, CPDFColorSelectViewDelegate, CPDFOpacitySliderViewDelegate, CPDFThicknessSliderViewDelegate {
    
    var actionBlock: ((CPDFTextActionType) -> Void)?
    var colorBlock: ((UIColor) -> Void)?
    var opacityBlock: ((CGFloat) -> Void)?
    var alignmentBlock: ((CPDFTextAlignment) -> Void)?
    var fontSizeBlock: ((CGFloat) -> Void)?
    var pdfView: CPDFView?
    
    var colorAreaView: UIView?
    var sliderArea: UIView?
    
    var colorView: CPDFColorSelectView?
    var opacityView: CPDFOpacitySliderView?
    var colorPickerView: CPDFColorPickerView?
    var thickSliderView: CPDFThicknessSliderView?
    
    var fontView: UIView?
    var alignmentView: UIView?
    var alignmnetCoverView: UIView?
    var dropMenuView: UIView?
    var splitView: UIView?
    var splitStyleView: UIView?

    var menu: CPDFDropDownMenu?
    
    var dropDownIcon: UIImageView?
    var dropStyleDownIcon: UIImageView?

    var fontNameLabel: UILabel?
    var alignmentLabel: UILabel?
    var fontNameSelectLabel: UILabel?
    var fontStyleSelectLabel: UILabel?

    var leftAlignBtn: UIButton?
    var centerAlignBtn: UIButton?
    var rightAlignBtn: UIButton?
    
    var fontSelectBtn: UIButton?
    var fontStyleSelectBtn: UIButton?

    var lastSelectAlignBtn: UIButton?
    var currentSelectCFont: CPDFFont = CPDFFont.init(familyName: "Helvetica", fontStyle: "") {
        didSet {
            fontNameSelectLabel?.text = currentSelectCFont.familyName
            if(currentSelectCFont.styleName?.count == 0) {
                let styles = CPDFFont.fontNames(forFamilyName: currentSelectCFont.familyName)
                fontStyleSelectLabel?.text = styles.first
            } else {
                fontStyleSelectLabel?.text = currentSelectCFont.styleName ?? ""
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.colorView = CPDFColorSelectView.init(frame: CGRect.zero)
        self.colorView?.autoresizingMask = .flexibleWidth
        self.colorView?.colorLabel?.text = NSLocalizedString("Font Color", comment: "")
        self.colorView?.delegate = self
        if(colorView != nil) {
            self.contentView.addSubview(self.colorView!)
        }
        
        self.opacityView = CPDFOpacitySliderView(frame: CGRect.zero)
        self.opacityView?.autoresizingMask = .flexibleWidth
        self.opacityView?.titleLabel?.text = NSLocalizedString("Opacity", comment: "")
        self.opacityView?.startLabel?.text = "0"
        self.opacityView?.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.opacityView?.titleLabel?.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        self.opacityView?.delegate = self
        self.opacityView?.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
        if(opacityView != nil) {
            self.contentView.addSubview(self.opacityView!)
        }
        
        self.fontView = UIView()
        self.fontView?.autoresizingMask = .flexibleWidth
        if(fontView != nil) {
            self.contentView.addSubview(self.fontView!)
        }
        
        self.fontNameLabel = UILabel()
        self.fontNameLabel?.text = NSLocalizedString("Font", comment: "")
        self.fontNameLabel?.font = UIFont.systemFont(ofSize: 14)
        self.fontNameLabel?.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        if(fontNameLabel != nil) {
            self.fontView?.addSubview(self.fontNameLabel!)
        }
        
        self.alignmentView = UIView()
        self.alignmentView?.autoresizingMask = .flexibleWidth
        if(alignmentView != nil) {
            self.contentView.addSubview(self.alignmentView!)
        }
        
        self.alignmentLabel = UILabel()
        self.alignmentLabel?.text = NSLocalizedString("Alignment", comment: "")
        self.alignmentLabel?.font = UIFont.systemFont(ofSize: 14)
        self.alignmentLabel?.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        if(alignmentLabel != nil) {
            self.alignmentView?.addSubview(self.alignmentLabel!)
        }
        
        self.alignmnetCoverView = UIView()
        self.alignmnetCoverView?.layer.borderColor = UIColor(red: 0.886, green: 0.89, blue: 0.902, alpha: 1).cgColor
        self.alignmnetCoverView?.layer.borderWidth = 1
        if(alignmnetCoverView != nil) {
            self.alignmentView?.addSubview(self.alignmnetCoverView!)
        }
        
        self.leftAlignBtn = UIButton(type: .custom)
        self.leftAlignBtn?.setImage(UIImage(named: "CPDFEditAlignmentLeft", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        self.leftAlignBtn?.addTarget(self, action: #selector(fontAlignmentAction(_:)), for: .touchUpInside)
        
        self.rightAlignBtn = UIButton(type: .custom)
        self.rightAlignBtn?.setImage(UIImage(named: "CPDFEditAlignmentRight", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        self.rightAlignBtn?.addTarget(self, action: #selector(fontAlignmentAction(_:)), for: .touchUpInside)
        
        self.centerAlignBtn = UIButton(type: .custom)
        self.centerAlignBtn?.setImage(UIImage(named: "CPDFEditAligmentCenter", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        self.centerAlignBtn?.addTarget(self, action: #selector(fontAlignmentAction(_:)), for: .touchUpInside)
        if(leftAlignBtn != nil) {
            self.alignmnetCoverView?.addSubview(self.leftAlignBtn!)
        }
        if(centerAlignBtn != nil) {
            self.alignmnetCoverView!.addSubview(self.centerAlignBtn!)
        }
        
        if(rightAlignBtn != nil) {
            self.alignmnetCoverView!.addSubview(self.rightAlignBtn!)
        }
        
        self.thickSliderView = CPDFThicknessSliderView(frame: CGRect(x: 10, y: (self.fontView?.frame.maxY ?? 0) + 10, width: self.frame.size.width-20, height: 90))
        self.thickSliderView?.titleLabel?.text = NSLocalizedString("Font Size", comment: "")
        self.thickSliderView?.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.thickSliderView?.titleLabel?.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        self.thickSliderView?.thick = 10
        self.thickSliderView?.delegate = self
        if(thickSliderView != nil) {
            self.contentView.addSubview(self.thickSliderView!)
        }
        
        self.backgroundColor = UIColor(red: 250/255, green: 252/255, blue: 255/255, alpha: 1)
        
        self.dropMenuView = UIView()
        if(dropMenuView != nil) {
            self.fontView?.addSubview(self.dropMenuView!)
        }
        
        self.splitView = UIView()
        self.splitView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        if(splitView != nil) {
            self.dropMenuView?.addSubview(self.splitView!)
        }
        
        splitStyleView = UIView()
        splitStyleView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        if(splitStyleView != nil) {
            dropMenuView?.addSubview(splitStyleView!)
        }
        
        self.dropDownIcon = UIImageView()
        self.dropDownIcon?.image = UIImage(named: "CPDFEditArrow", in: Bundle(for: type(of: self)), compatibleWith: nil)
        if(dropDownIcon != nil) {
            self.dropMenuView?.addSubview(self.dropDownIcon!)
        }
        
        dropStyleDownIcon = UIImageView()
        dropStyleDownIcon?.image = UIImage(named: "CPDFEditArrow", in: Bundle(for: type(of: self)), compatibleWith: nil)
        if(dropStyleDownIcon != nil) {
            self.dropMenuView?.addSubview(dropStyleDownIcon!)
        }
        
        self.fontNameSelectLabel = UILabel()
        self.fontNameSelectLabel?.adjustsFontSizeToFitWidth = true
        self.fontNameSelectLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
        if(fontNameSelectLabel != nil) {
            self.dropMenuView?.addSubview(self.fontNameSelectLabel!)
        }
        
        self.fontStyleSelectLabel = UILabel()
        self.fontStyleSelectLabel?.adjustsFontSizeToFitWidth = true
        self.fontStyleSelectLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
        if(fontStyleSelectLabel != nil) {
            self.dropMenuView?.addSubview(self.fontStyleSelectLabel!)
        }
        
        self.fontSelectBtn = UIButton(type: .custom)
        self.fontSelectBtn?.backgroundColor = UIColor.clear
        self.fontSelectBtn?.addTarget(self, action: #selector(showFontNameAction(_:)), for: .touchUpInside)
        if(fontSelectBtn != nil) {
            self.dropMenuView?.addSubview(self.fontSelectBtn!)
        }
        
        fontStyleSelectBtn = UIButton(type: .custom)
        fontStyleSelectBtn?.backgroundColor = UIColor.clear
        fontStyleSelectBtn?.addTarget(self, action: #selector(showFontStyleNameAction(_:)), for: .touchUpInside)
        if(fontStyleSelectBtn != nil) {
            self.dropMenuView?.addSubview(fontStyleSelectBtn!)
        }
        
        self.opacityView?.rightMargin = 10
        self.opacityView?.leftMargin = 5
        self.opacityView?.rightTitleMargin = 10
        self.thickSliderView?.rightMargin = 20
        self.thickSliderView?.leftMargin = 5
        self.thickSliderView?.leftTitleMargin = 10
        self.fontNameSelectLabel?.text = "Helvetica"
        self.contentView.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.colorView?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: 90)
        self.opacityView?.frame = CGRect(x: 10, y: self.colorView?.frame.maxY ?? 0, width: self.frame.size.width-10, height: 90)
        self.fontView?.frame = CGRect(x: 10, y: (self.opacityView?.frame.maxY ?? 0) + 20, width: self.frame.size.width-20, height: 30)
        self.alignmentView?.frame = CGRect(x: 10, y: (self.fontView?.frame.maxY ?? 0) + 20, width: self.frame.size.width-20, height: 30)
        self.thickSliderView?.frame = CGRect(x: 10, y: (self.alignmentView?.frame.maxY ?? 0), width: self.frame.size.width-20, height: 90)
        
        self.alignmnetCoverView?.frame = CGRect(x: self.frame.size.width - 170, y: 0, width: 150, height: 30)
        
        self.fontNameLabel?.frame = CGRect(x: 10, y: 0, width: 30, height: 30)
        self.alignmentLabel?.frame = CGRect(x: 10, y: 0, width: 100, height: 30)
        
        self.leftAlignBtn?.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        self.centerAlignBtn?.frame = CGRect(x: 50, y: 0, width: 50, height: 30)
        self.rightAlignBtn?.frame = CGRect(x: 100, y: 0, width: 50, height: 30)
        
        let fontNameLabelMaxX = self.fontNameLabel?.frame.maxX ?? 0
        let dropMenuViewWidth = self.frame.size.width - fontNameLabelMaxX - 20 - 20

        self.dropMenuView?.frame = CGRect(x: fontNameLabelMaxX + 20, y: 0, width: dropMenuViewWidth, height: 30)

        let subWidth = (self.dropMenuView?.bounds.size.width ?? 0) - 10

        self.splitView?.frame = CGRect(x: 0, y: 29, width: (subWidth / 5 * 3), height: 1)
        self.splitStyleView?.frame = CGRect(x: (subWidth / 5 * 3) + 10, y: 29, width: (subWidth / 5 * 2), height: 1)

        self.dropDownIcon?.frame = CGRect(x: (subWidth / 5 * 3) - 24, y: 3, width: 24, height: 24)
        self.dropStyleDownIcon?.frame = CGRect(x: subWidth - 24 + 10, y: 3, width: 24, height: 24)

        self.fontNameSelectLabel?.frame = CGRect(x: 10, y: 0, width: (subWidth / 5 * 3) - 40, height: 29)
        self.fontStyleSelectLabel?.frame = CGRect(x: (subWidth / 5 * 3) + 30, y: 0, width: (subWidth / 5 * 2) - 40, height: 29)
        
        self.fontSelectBtn?.frame = CGRect(x: 0, y:0, width: subWidth / 5 * 3, height: 30)
        self.fontStyleSelectBtn?.frame = CGRect(x: subWidth / 5 * 3 + 10, y:0, width: subWidth / 5 * 2, height: 30)
    }
    
    func setPdfView(_ zpdfView: CPDFView) {
        self.pdfView = zpdfView
        let editingArea = self.pdfView?.editingArea()
        if editingArea != nil  {
            self.opacityView?.defaultValue = (pdfView?.getCurrentOpacity())!
            
            let alignment:NSTextAlignment = NSTextAlignment(rawValue: (self.pdfView?.editingSelectionAlignment(with: editingArea as? CPDFEditTextArea))!.rawValue) ?? .center
            if alignment == .left {
                self.leftAlignBtn?.isSelected = false
                if(leftAlignBtn != nil) {
                    fontAlignmentAction(self.leftAlignBtn!)
                }
            } else if alignment == .center {
                self.centerAlignBtn?.isSelected = false
                if(centerAlignBtn != nil) {
                    fontAlignmentAction(self.centerAlignBtn!)
                }
            } else if alignment == .right {
                self.rightAlignBtn?.isSelected = false
                if(rightAlignBtn != nil) {
                    fontAlignmentAction(self.rightAlignBtn!)
                }
            }
            
            self.colorView?.selectedColor = pdfView?.editingSelectionFontColor(with: editingArea as? CPDFEditTextArea)
            
            self.thickSliderView?.defaultValue = (pdfView?.editingSelectionFontSizes(with: editingArea as? CPDFEditTextArea) ?? 0 ) / 100
        } else {
            self.opacityView?.defaultValue = CPDFTextProperty.shared.textOpacity
            
            if CPDFTextProperty.shared.textAlignment == .left {
                self.leftAlignBtn?.isSelected = false
                if(leftAlignBtn != nil) {
                    fontAlignmentAction(self.leftAlignBtn!)
                }
            } else if CPDFTextProperty.shared.textAlignment == .center {
                self.centerAlignBtn?.isSelected = false
                if(centerAlignBtn != nil) {
                    fontAlignmentAction(self.centerAlignBtn!)
                }
            } else if CPDFTextProperty.shared.textAlignment == .right {
                self.rightAlignBtn?.isSelected = false
                if(rightAlignBtn != nil) {
                    fontAlignmentAction(self.rightAlignBtn!)
                }
            }
            
            self.colorView?.selectedColor = CPDFTextProperty.shared.fontColor
            
            self.thickSliderView?.defaultValue = CPDFTextProperty.shared.fontSize/100
        }
        
    }
    
    // MARK: - CPDFColorSelectViewDelegate
    func selectColorView(_ select: CPDFColorSelectView) {
        self.actionBlock?(.colorSelect)
    }
    
    func selectColorView(_ select: CPDFColorSelectView, color: UIColor) {
        self.colorBlock?(color)
    }
    
    // MARK: - OPacitySliderView
    func thicknessSliderView(_ opacitySliderView: CPDFThicknessSliderView, thickness: CGFloat) {
        self.fontSizeBlock?(thickness)
    }
    
    func opacitySliderView(_ opacitySliderView: CPDFOpacitySliderView, opacity: CGFloat) {
        self.opacityBlock?(opacity)
    }
    
    @objc func fontAlignmentAction(_ sender: UIButton) {
        if sender == self.lastSelectAlignBtn {
            return
        }
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.backgroundColor = UIColor(red: 73/255, green: 130/255, blue: 230/255, alpha: 0.16)
        }
        if sender == self.leftAlignBtn && sender.isSelected {
            self.centerAlignBtn?.isSelected = false
            self.rightAlignBtn?.isSelected = false
            self.centerAlignBtn?.backgroundColor = UIColor.clear
            self.rightAlignBtn?.backgroundColor = UIColor.clear
            
            if let alignmentBlock = self.alignmentBlock {
                alignmentBlock(.left)
            }
            self.lastSelectAlignBtn = self.leftAlignBtn
            
        } else if sender == self.centerAlignBtn && sender.isSelected {
            self.rightAlignBtn?.isSelected = false
            self.leftAlignBtn?.isSelected = false
            self.leftAlignBtn?.backgroundColor = UIColor.clear
            self.rightAlignBtn?.backgroundColor = UIColor.clear
            
            if let alignmentBlock = self.alignmentBlock {
                alignmentBlock(.center)
            }
            self.lastSelectAlignBtn = self.centerAlignBtn
            
        } else if sender == self.rightAlignBtn && sender.isSelected {
            self.leftAlignBtn?.isSelected = false
            self.centerAlignBtn?.isSelected = false
            self.centerAlignBtn?.backgroundColor = UIColor.clear
            self.leftAlignBtn?.backgroundColor = UIColor.clear
            
            if let alignmentBlock = self.alignmentBlock {
                alignmentBlock(.right)
            }
            
            self.lastSelectAlignBtn = self.rightAlignBtn
            
        } else {
            if let alignmentBlock = self.alignmentBlock {
                alignmentBlock(.natural)
            }
        }
        
    }
    
    @objc func showFontNameAction(_ button: UIButton) {
        self.actionBlock?(.fontNameSelect)
    }
    
    @objc func showFontStyleNameAction(_ button: UIButton) {
        self.actionBlock?(.fontStyleSelect)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

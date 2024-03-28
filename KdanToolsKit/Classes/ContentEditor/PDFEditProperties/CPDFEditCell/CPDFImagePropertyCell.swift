//
//  CPDFImagePropertyCell.swift
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

enum CPDFImageRotateType: Int {
    case left = -1
    case right = 1
}
enum CPDFImageTransFormType {
    case horizontal
    case vertical
}

class CPDFImagePropertyCell: UITableViewCell, CPDFOpacitySliderViewDelegate,CPDFDropDownMenuDelegate {
    var rotateBlock: ((CPDFImageRotateType, Bool) -> Void)?
    var transFormBlock: ((CPDFImageTransFormType, Bool) -> Void)?
    var transparencyBlock: ((CGFloat) -> Void)?
    var replaceImageBlock: (() -> Void)?
    var exportImageBlock: (() -> Void)?
    var cropImageBlock: (() -> Void)?
    var pdfView: CPDFView?
    
    var menu: CPDFDropDownMenu?
    var transparencySlider: UISlider?
    var rotateLabel: UILabel?
    var transformLabel: UILabel?
    var toolsLabel: UILabel?
    var leftRotateBtn: UIButton?
    var rightRotateBtn: UIButton?
    var transformView: UIView?
    var hBtn: UIButton?
    var vBtn: UIButton?
    var opacityView: CPDFOpacitySliderView?
    var replaceBtn: UIButton?
    var exportBtn: UIButton?
    var cropBtn: UIButton?
    var transformSplitView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.rotateLabel = UILabel()
        self.rotateLabel?.font = UIFont.systemFont(ofSize: 13)
        self.rotateLabel?.text = NSLocalizedString("Rotate", comment: "")
        self.rotateLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
        if(rotateLabel != nil) {
            self.contentView.addSubview(self.rotateLabel!)
        }
        
        self.leftRotateBtn = UIButton(type: .custom)
        self.leftRotateBtn?.addTarget(self, action: #selector(leftRotateAction(_:)), for: .touchUpInside)
        self.leftRotateBtn?.setImage(UIImage(named: "CPDFEditIRotate", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        let leftTitle = " " + NSLocalizedString("Rotate Left", comment: "")
        self.leftRotateBtn?.setTitle(leftTitle, for: .normal)
        self.leftRotateBtn?.setTitleColor(CPDFColorUtils.CPageEditToolbarFontColor(), for: .normal)
        self.leftRotateBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.leftRotateBtn?.layer.borderWidth = 1
        self.leftRotateBtn?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        self.leftRotateBtn?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if(leftRotateBtn != nil) {
            self.addSubview(self.leftRotateBtn!)
        }
        
        self.rightRotateBtn = UIButton(type: .custom)
        self.rightRotateBtn?.addTarget(self, action: #selector(rightRotateAction(_:)), for: .touchUpInside)
        self.rightRotateBtn?.setImage(UIImage(named: "CPDFEditRRotate", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        let rightTitle = " " + NSLocalizedString("Rotate Right", comment: "")
        self.rightRotateBtn?.setTitle(rightTitle, for: .normal)
        self.rightRotateBtn?.setTitleColor(CPDFColorUtils.CPageEditToolbarFontColor(), for: .normal)
        self.rightRotateBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.rightRotateBtn?.layer.borderWidth = 1
        self.rightRotateBtn?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        self.rightRotateBtn?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if(rightRotateBtn != nil) {
            self.addSubview(self.rightRotateBtn!)
        }
        
        self.transformLabel = UILabel()
        self.transformLabel?.font = UIFont.systemFont(ofSize: 13)
        self.transformLabel?.text = NSLocalizedString("Flip", comment: "")
        self.transformLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
        if(transformLabel != nil) {
            self.contentView.addSubview(self.transformLabel!)
        }
        
        self.transformView = UIView()
        self.transformView?.layer.borderWidth = 1
        self.transformView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        if(transformView != nil) {
            self.contentView.addSubview(self.transformView!)
        }
        
        self.vBtn = UIButton(type: .custom)
        self.vBtn?.setImage(UIImage(named: "CPDFEditVerticalFlip", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        self.vBtn?.addTarget(self, action: #selector(verticalAction(_:)), for: .touchUpInside)
        
        self.hBtn = UIButton(type: .custom)
        self.hBtn?.setImage(UIImage(named: "CPDFEditHorizontalFlip", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        self.hBtn?.addTarget(self, action: #selector(horizontalAction(_:)), for: .touchUpInside)
        if(hBtn != nil) {
            self.transformView?.addSubview(self.hBtn!)
        }
        if(vBtn != nil) {
            self.transformView?.addSubview(self.vBtn!)
        }
        
        self.opacityView = CPDFOpacitySliderView.init(frame: CGRect.zero)
        self.opacityView?.autoresizingMask = .flexibleWidth
        self.opacityView?.titleLabel?.text = NSLocalizedString("Opacity", comment: "")
        self.opacityView?.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        self.opacityView?.titleLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
        self.opacityView?.startLabel?.text = "0"
        self.opacityView?.defaultValue = 1
        self.opacityView?.bgColor = UIColor.clear
        self.opacityView?.delegate = self
        if(opacityView != nil) {
            self.contentView.addSubview(self.opacityView!)
        }
        
        self.toolsLabel = UILabel()
        self.toolsLabel?.font = UIFont.systemFont(ofSize: 13)
        self.toolsLabel?.text = NSLocalizedString("Tools", comment: "")
        self.toolsLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
        if(toolsLabel != nil) {
            self.contentView.addSubview(self.toolsLabel!)
        }
        
        self.replaceBtn = UIButton(type: .custom)
        self.replaceBtn?.addTarget(self, action: #selector(replaceImageAction(_:)), for: .touchUpInside)
        self.replaceBtn?.setImage(UIImage(named: "CPDFEditReplace", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        let replaceTitle = " " + NSLocalizedString("Replace", comment: "")
        self.replaceBtn?.setTitle(replaceTitle, for: .normal)
        self.replaceBtn?.setTitleColor(CPDFColorUtils.CPageEditToolbarFontColor(), for: .normal)
        self.replaceBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.replaceBtn?.layer.borderWidth = 1
        self.replaceBtn?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        if(replaceBtn != nil) {
            self.addSubview(self.replaceBtn!)
        }
        self.replaceBtn?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        
        self.exportBtn = UIButton(type: .custom)
        self.exportBtn?.addTarget(self, action: #selector(exportImageAction(_:)), for: .touchUpInside)
        self.exportBtn?.setImage(UIImage(named: "CPDFEditExport", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        let exportTitle = " " + NSLocalizedString("Export", comment: "")
        self.exportBtn?.setTitle(exportTitle, for: .normal)
        self.exportBtn?.setTitleColor(CPDFColorUtils.CPageEditToolbarFontColor(), for: .normal)
        self.exportBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.exportBtn?.layer.borderWidth = 1
        self.exportBtn?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        if(exportBtn != nil) {
            self.addSubview(self.exportBtn!)
        }
        
        self.exportBtn?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        self.cropBtn = UIButton(type: .custom)
        self.cropBtn?.addTarget(self, action: #selector(cropImageAction(_:)), for: .touchUpInside)
        self.cropBtn?.setImage(UIImage(named: "CPDFEditCrop", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        let cropTitle = " " + NSLocalizedString("Crop", comment: "")
        self.cropBtn?.setTitle(cropTitle, for: .normal)
        self.cropBtn?.setTitleColor(CPDFColorUtils.CPageEditToolbarFontColor(), for: .normal)
        self.cropBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.cropBtn?.layer.borderWidth = 1
        self.cropBtn?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        if(cropBtn != nil) {
            self.addSubview(self.cropBtn!)
        }
        self.cropBtn?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        
        self.transformSplitView = UIView()
        self.transformSplitView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        if(transformSplitView != nil) {
            self.transformView?.addSubview(self.transformSplitView!)
        }
        
        self.opacityView?.rightMargin = 10
        self.opacityView?.leftMargin = 5
        self.opacityView?.rightTitleMargin = 10
        self.contentView.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rotateLabel?.frame = CGRect(x: 16, y: 0, width: bounds.size.width, height: 20)
        
        leftRotateBtn?.frame = CGRect(x: 16, y: (rotateLabel?.frame.maxY ?? 0) + 12, width: (bounds.size.width - 16*2 - 8)/2, height: 32)
        
        rightRotateBtn?.frame = CGRect(x: (leftRotateBtn?.frame.maxX ?? 0) + 4, y: (rotateLabel?.frame.maxY ?? 0) + 12, width: (bounds.size.width - 16*2 - 8)/2, height: 32)
        
        transformLabel?.frame = CGRect(x: 16, y: (leftRotateBtn?.frame.maxY ?? 0) + 16, width: bounds.size.width, height: 20)
        
        transformView?.frame = CGRect(x: 16, y: (transformLabel?.frame.maxY ?? 0) + 16, width: 101, height: 32)
        hBtn?.frame = CGRect(x: 0, y: 0, width: 50, height: 32)
        transformSplitView?.frame = CGRect(x: 50, y: 0, width: 1, height: 32)
        vBtn?.frame = CGRect(x: 51, y: 0, width: 50, height: 32)
        
        opacityView?.frame = CGRect(x: 6, y: (transformView?.frame.maxY ?? 0) + 10, width: frame.size.width - 12, height: 90)
        
        toolsLabel?.frame = CGRect(x: 16, y: (opacityView?.frame.maxY ?? 0) + 16, width: bounds.size.width, height: 20)
        
        replaceBtn?.frame = CGRect(x: 16, y: (toolsLabel?.frame.maxY ?? 0) + 16, width: (bounds.size.width - 16 * 2 - 8*2)/3, height: 32)
        
        exportBtn?.frame = CGRect(x: (replaceBtn?.frame.maxX ?? 0) + 8, y: (toolsLabel?.frame.maxY ?? 0 ) + 16, width: (bounds.size.width - 16 * 2 - 8*2)/3, height: 32)
        
        cropBtn?.frame = CGRect(x: (exportBtn?.frame.maxX ?? 0) + 8, y: (toolsLabel?.frame.maxY ?? 0) + 16, width: (bounds.size.width - 16 * 2 - 8*2)/3, height: 32)
    }
    
    // MARK: - Action
    @objc func leftRotateAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.rotateBlock?(.left,sender.isSelected)
    }
    
    @objc func rightRotateAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.rotateBlock?(.right,sender.isSelected)
    }
    
    @objc func horizontalAction(_ button: UIButton) {
        if(button.isSelected) {
            button.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
        } else {
            button.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        }
        button.isSelected = !button.isSelected
        
        self.transFormBlock?(.horizontal,button.isSelected)
        
    }
    
    @objc func verticalAction(_ button: UIButton) {
        if(button.isSelected) {
            button.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
        } else {
            button.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        }
        button.isSelected = !button.isSelected
        
        self.transFormBlock?(.vertical,button.isSelected)
    }
    
    @objc func replaceImageAction(_ button: UIButton) {
        self.replaceImageBlock?()
    }
    
    @objc func exportImageAction(_ button: UIButton) {
        self.exportImageBlock?()
    }
    
    @objc func cropImageAction(_ button: UIButton) {
        self.cropImageBlock?()
    }
    
    @objc func sliderAction(_ button: UISlider) {
        self.menu?.defaultValue = String(format: "%.2f", button.value)
        self.transparencyBlock?(CGFloat(button.value))
    }
    
    // MARK: - CPDFDropDownMenuDelegate
    func dropDownMenu(_ menu: CPDFDropDownMenu, didEditWithText text: String) {
        if let floatValue = Float(text), floatValue >= 0 && floatValue <= 1 {
            self.transparencySlider?.value = floatValue
            
            self.transparencyBlock?(CGFloat(floatValue))
        }
    }
    
    func dropDownMenu(_ menu: CPDFDropDownMenu, didSelectWithIndex index: Int) {
        let value = (self.menu?.options[index] as AnyObject).floatValue
        self.transparencySlider?.value = value ?? 0
        self.transparencyBlock?(CGFloat(value ?? 0))
    }
    
    // MARK: - CPDFDropDownMenuDelegate
    func opacitySliderView(_ opacitySliderView: CPDFOpacitySliderView, opacity: CGFloat) {
        self.transparencyBlock?(opacity)
    }
    
    func setPdfView(_ pdfView: CPDFView) {
        self.pdfView = pdfView
        self.opacityView?.defaultValue = pdfView.getCurrentOpacity()
    }
    
    
}

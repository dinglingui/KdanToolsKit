//
//  CPDFInkTopToolBar.swift
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

public enum CPDFInkTopToolBarSelect: Int {
    case setting = 0
    case erase
    case undo
    case redo
    case clear
    case save
}

@objc public protocol CPDFInkTopToolBarDelegate: AnyObject {
    @objc optional func inkTopToolBar(_ inkTopToolBar: CPDFInkTopToolBar, tag: Int, isSelect: Bool)
}

public class CPDFInkTopToolBar: UIView {
    public weak var delegate: CPDFInkTopToolBarDelegate?
    public var buttonArray: [UIButton] = []
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderColor = UIColor(red: 170.0/255.0, green: 170.0/255.0, blue: 170.0/255.0, alpha: 1.0).cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5.0
        let width = self.bounds.size.width / 6
        let height = self.bounds.size.height
        
        self.buttonArray = []
        
        let settingButton = UIButton(type: .custom)
        settingButton.tag = CPDFInkTopToolBarSelect.setting.rawValue
        settingButton.frame = CGRect(x: 0, y: 0, width: width, height: height)
        settingButton.setImage(UIImage(named: "CPDFInkImageSetting", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        settingButton.addTarget(self, action: #selector(buttonItemClicked_Switch(_:)), for: .touchUpInside)
        self.addSubview(settingButton)
        self.buttonArray.append(settingButton)
        
        let eraseButton = UIButton(type: .custom)
        eraseButton.tag = CPDFInkTopToolBarSelect.erase.rawValue
        eraseButton.frame = CGRect(x: width, y: 0, width: width, height: height)
        eraseButton.setImage(UIImage(named: "CPDFInkImageEraer", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        eraseButton.addTarget(self, action: #selector(buttonItemClicked_Switch(_:)), for: .touchUpInside)
        self.addSubview(eraseButton)
        self.buttonArray.append(eraseButton)
        
        let undoButton = UIButton(type: .custom)
        undoButton.tag = CPDFInkTopToolBarSelect.undo.rawValue
        undoButton.frame = CGRect(x: width * 2, y: 0, width: width, height: height)
        undoButton.setImage(UIImage(named: "CPDFInkImageUndo", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        undoButton.addTarget(self, action: #selector(buttonItemClicked_Switch(_:)), for: .touchUpInside)
        self.addSubview(undoButton)
        self.buttonArray.append(undoButton)
        
        let redoButton = UIButton(type: .custom)
        redoButton.tag = CPDFInkTopToolBarSelect.redo.rawValue
        redoButton.frame = CGRect(x: width * 3, y: 0, width: width, height: height)
        redoButton.setImage(UIImage(named: "CPDFInkImageRedo", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        redoButton.addTarget(self, action: #selector(buttonItemClicked_Switch(_:)), for: .touchUpInside)
        self.addSubview(redoButton)
        self.buttonArray.append(redoButton)
        
        let clearButton = UIButton(type: .system)
        clearButton.tag = CPDFInkTopToolBarSelect.clear.rawValue
        clearButton.frame = CGRect(x: 4 * width, y: 0, width: width, height: height)
        clearButton.setTitle(NSLocalizedString("Clear", comment: ""), for: .normal)
        clearButton.setTitleColor(CPDFColorUtils.CPageEditToolbarFontColor(), for: .normal)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        clearButton.addTarget(self, action: #selector(buttonItemClicked_Switch(_:)), for: .touchUpInside)
        self.addSubview(clearButton)
        self.buttonArray.append(clearButton)
        
        let view = UIView(frame: CGRect(x: 4 * width, y: 10, width: 1, height: height - 20))
        view.backgroundColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.1)
        self.addSubview(view)
        
        let saveButton = UIButton(type: .system)
        saveButton.tag = CPDFInkTopToolBarSelect.save.rawValue
        saveButton.frame = CGRect(x: 5 * width, y: 0, width: width, height: height)
        saveButton.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        saveButton.setTitleColor(UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0), for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        saveButton.addTarget(self, action: #selector(buttonItemClicked_Switch(_:)), for: .touchUpInside)
        self.addSubview(saveButton)
        self.buttonArray.append(saveButton)
        
        self.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_Switch(_ button: UIButton) {
        for j in 0..<buttonArray.count {
            (buttonArray[j] ).backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        }
        
        
        buttonArray[button.tag].backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
        switch button.tag {
        case CPDFInkTopToolBarSelect.setting.rawValue:
            delegate?.inkTopToolBar?(self, tag: CPDFInkTopToolBarSelect(rawValue: button.tag)?.rawValue ?? 0, isSelect: button.isSelected)
        case CPDFInkTopToolBarSelect.erase.rawValue:
            button.isSelected = !button.isSelected
            if !button.isSelected {
                button.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
            }
            delegate?.inkTopToolBar?(self, tag: CPDFInkTopToolBarSelect(rawValue: button.tag)?.rawValue ?? 0, isSelect: button.isSelected)
        case CPDFInkTopToolBarSelect.undo.rawValue:
            delegate?.inkTopToolBar?(self, tag: CPDFInkTopToolBarSelect(rawValue: button.tag)?.rawValue ?? 0, isSelect: button.isSelected)
            (buttonArray[button.tag]).backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        case CPDFInkTopToolBarSelect.redo.rawValue:
            delegate?.inkTopToolBar?(self, tag: CPDFInkTopToolBarSelect(rawValue: button.tag)?.rawValue ?? 0, isSelect: button.isSelected)
            (buttonArray[button.tag]).backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        case CPDFInkTopToolBarSelect.clear.rawValue:
            delegate?.inkTopToolBar?(self, tag: CPDFInkTopToolBarSelect(rawValue: button.tag)?.rawValue ?? 0, isSelect: button.isSelected)
            removeFromSuperview()
        case CPDFInkTopToolBarSelect.save.rawValue:
            delegate?.inkTopToolBar?(self, tag: CPDFInkTopToolBarSelect(rawValue: button.tag)?.rawValue ?? 0, isSelect: button.isSelected)
            removeFromSuperview()
        default:
            break
        }
        
    }
    
    
}



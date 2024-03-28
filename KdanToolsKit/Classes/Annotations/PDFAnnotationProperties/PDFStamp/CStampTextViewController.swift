//
//  CStampTextViewController.swift
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

@objc protocol CStampTextViewControllerDelegate: AnyObject {
    @objc optional func stampTextViewController(_ stampTextViewController: CStampTextViewController, dictionary: NSDictionary)
}

class CStampTextViewController: UIViewController, UITextFieldDelegate, CStampColorSelectViewDelegate, CStampShapViewDelegate {
    weak var delegate: CStampTextViewControllerDelegate?
    // Your other properties and methods
    private var preView: CStampPreview?
    private var stampTextField: UITextField?
    private var haveDateSwitch: UISwitch?
    private var haveTimeSwitch: UISwitch?
    private var doneBtn: UIButton?
    private var titleLabel: UILabel?
    private var cancelBtn: UIButton?
    private var dateLabel: UILabel?
    private var timeLabel: UILabel?
    private var colorView: CStampColorSelectView?
    private var stampShapeViw: CStampShapView?
    private var textStampColorStyle: TextStampColorType = .black
    private var textStampStyle: TextStampType = .left
    private var scrcollView: UIScrollView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel = UILabel()
        self.titleLabel?.autoresizingMask = [.flexibleRightMargin]
        self.titleLabel?.text = NSLocalizedString("Create Stamp", comment: "")
        self.titleLabel?.textAlignment = .center
        self.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        if titleLabel != nil {
            self.view.addSubview(self.titleLabel!)
        }
        self.doneBtn = UIButton()
        self.doneBtn?.autoresizingMask = [.flexibleRightMargin]
        self.doneBtn?.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        self.doneBtn?.setTitleColor(.blue, for: .normal)
        self.doneBtn?.addTarget(self, action: #selector(buttonItemClicked_done), for: .touchUpInside)
        if doneBtn != nil {
            self.view.addSubview(self.doneBtn!)
        }
        self.scrcollView = UIScrollView()
        self.scrcollView?.isScrollEnabled = true
        self.scrcollView?.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
        if scrcollView != nil {
            self.view.addSubview(self.scrcollView!)
        }
        self.cancelBtn = UIButton()
        self.cancelBtn?.autoresizingMask = [.flexibleLeftMargin]
        self.cancelBtn?.titleLabel?.adjustsFontSizeToFitWidth = true
        self.cancelBtn?.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        self.cancelBtn?.setTitleColor(.black, for: .normal)
        self.cancelBtn?.addTarget(self, action: #selector(buttonItemClicked_cancel), for: .touchUpInside)
        if cancelBtn != nil {
            self.view.addSubview(self.cancelBtn!)
        }
        self.preView = CStampPreview()
        self.preView?.backgroundColor = .clear
        self.preView?.color = .black
        self.preView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        self.preView?.layer.borderWidth = 1.0
        self.preView?.autoresizingMask = [.flexibleRightMargin]
        if preView != nil {
            self.scrcollView?.addSubview(self.preView!)
        }
        self.stampTextField = UITextField()
        self.stampTextField?.contentVerticalAlignment = .center
        self.stampTextField?.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        self.stampTextField?.leftViewMode = .always
        self.stampTextField?.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        self.stampTextField?.rightViewMode = .always
        self.stampTextField?.returnKeyType = .done
        self.stampTextField?.clearButtonMode = .whileEditing
        self.stampTextField?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        self.stampTextField?.layer.borderWidth = 1.0
        self.stampTextField?.delegate = self
        self.stampTextField?.borderStyle = .none
        self.stampTextField?.addTarget(self, action: #selector(textFieldEditChange), for: .editingChanged)
        self.stampTextField?.placeholder = NSLocalizedString("Text", comment: "")
        if stampTextField != nil {
            self.scrcollView?.addSubview(self.stampTextField!)
        }
        self.colorView = CStampColorSelectView.init(frame: CGRect.zero)
        self.colorView?.delegate = self
        self.colorView?.autoresizingMask = [.flexibleWidth]
        self.colorView?.selectedColor = .black
        if colorView != nil {
            self.scrcollView?.addSubview(self.colorView!)
        }
        self.stampShapeViw = CStampShapView.init(frame: CGRect.zero)
        self.stampShapeViw?.delegate = self
        self.stampShapeViw?.autoresizingMask = [.flexibleWidth]
        if stampShapeViw != nil {
            self.scrcollView?.addSubview(self.stampShapeViw!)
        }
        self.dateLabel = UILabel()
        self.dateLabel?.text = NSLocalizedString("Date", comment: "")
        self.dateLabel?.textColor = .gray
        self.dateLabel?.font = UIFont.systemFont(ofSize: 12.0)
        if dateLabel != nil {
            self.scrcollView?.addSubview(self.dateLabel!)
        }
        self.haveDateSwitch = UISwitch()
        self.haveDateSwitch?.setOn(false, animated: false)
        self.haveDateSwitch?.autoresizingMask = [.flexibleLeftMargin]
        self.haveDateSwitch?.addTarget(self, action: #selector(switchChange_date), for: .valueChanged)
        if haveDateSwitch != nil {
            self.scrcollView?.addSubview(self.haveDateSwitch!)
        }
        self.timeLabel = UILabel()
        self.timeLabel?.text = NSLocalizedString("Time", comment: "")
        self.timeLabel?.textColor = .gray
        self.timeLabel?.font = UIFont.systemFont(ofSize: 12.0)
        self.timeLabel?.autoresizingMask = [.flexibleRightMargin]
        if timeLabel != nil {
            self.scrcollView?.addSubview(self.timeLabel!)
        }
        self.haveTimeSwitch = UISwitch()
        self.haveTimeSwitch?.setOn(false, animated: false)
        self.haveTimeSwitch?.autoresizingMask = [.flexibleLeftMargin]
        self.haveTimeSwitch?.addTarget(self, action: #selector(switchChange_time), for: .valueChanged)
        if haveTimeSwitch != nil {
            self.scrcollView?.addSubview(self.haveTimeSwitch!)
        }
        
        view.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        updatePreferredContentSizeWithTraitCollection(traitCollection: traitCollection)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        titleLabel?.frame = CGRect(x: (view.frame.size.width - 120)/2, y: 5, width: 120, height: 50)
        scrcollView?.frame = CGRect(x: 0, y: 50, width: view.frame.size.width, height: 560)
        scrcollView?.contentSize = CGSize(width: view.frame.size.width, height: 700)
        preView?.frame  = CGRect(x: (view.frame.size.width - 350)/2, y: 15, width: 350, height: 120)
        stampTextField?.frame = CGRect(x: (view.frame.size.width - 350)/2, y: 150, width: 350, height: 30)
        
        if #available(iOS 11.0, *) {
            doneBtn?.frame = CGRect(x: view.frame.size.width - 60 - view.safeAreaInsets.right, y: 5, width: 50, height: 50)
            cancelBtn?.frame = CGRect(x: view.safeAreaInsets.left + 10, y: 5, width: 50, height: 50)
            stampShapeViw?.frame = CGRect(x: view.safeAreaInsets.left, y: 180, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 90)
            colorView?.frame = CGRect(x: view.safeAreaInsets.left, y: 270, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 60)
            dateLabel?.frame = CGRect(x: view.safeAreaInsets.left+20, y: 330, width: 80, height: 50)
            haveDateSwitch?.frame = CGRect(x: view.frame.size.width - 80 - view.safeAreaInsets.right, y: 330, width: 60, height: 50)
            timeLabel?.frame = CGRect(x: view.safeAreaInsets.left+20, y: 380, width: 100, height: 45)
            haveTimeSwitch?.frame = CGRect(x: view.frame.size.width - 80 - view.safeAreaInsets.right, y: 380, width: 60, height: 50)
        } else {
            doneBtn?.frame = CGRect(x: view.frame.size.width - 60, y: 5, width: 50, height: 50)
            colorView?.frame = CGRect(x: 0, y: 270, width: view.frame.size.width, height: 60)
            stampShapeViw?.frame = CGRect(x: 0, y: 180, width: view.frame.size.width, height: 90)
            dateLabel?.frame = CGRect(x: 20, y: 330, width: 80, height: 50)
            haveDateSwitch?.frame = CGRect(x: view.frame.size.width - 80, y: 330, width: 60, height: 50)
            timeLabel?.frame = CGRect(x: 20, y: 380, width: 100, height: 45)
            haveTimeSwitch?.frame = CGRect(x: view.frame.size.width - 80, y: 380, width: 60, height: 50)
        }
        
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSizeWithTraitCollection(traitCollection: newCollection)
    }
    
    // MARK: - Private Mthods
    
    func updatePreferredContentSizeWithTraitCollection(traitCollection: UITraitCollection) {
        self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? 350 : 560)
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_done(_ sender: Any) {
        let tStampItem = NSMutableDictionary()
        if stampTextField?.text != "" || (haveDateSwitch?.isOn ?? false) || (haveTimeSwitch?.isOn ?? false) {
            if (stampTextField?.text?.count ?? 0) > 0 {
                tStampItem["text"] = stampTextField?.text
                tStampItem["colorStyle"] = NSNumber(value:textStampColorStyle.rawValue)
                tStampItem["style"] = NSNumber(value:textStampStyle.rawValue)
                tStampItem["haveDate"] = NSNumber(booleanLiteral:haveDateSwitch?.isOn ?? false)
                tStampItem["haveTime"] = NSNumber(booleanLiteral:haveTimeSwitch?.isOn ?? false)
            } else {
                tStampItem["text"] = preView?.dateTime
                tStampItem["colorStyle"] = textStampColorStyle
                tStampItem["style"] = NSNumber(value:textStampStyle.rawValue)
                tStampItem["haveDate"] = NSNumber(booleanLiteral: false)
                tStampItem["haveTime"] = NSNumber(booleanLiteral: false)
            }
            delegate?.stampTextViewController?(self, dictionary: tStampItem)
        } else if (stampTextField?.text == "" && !(haveDateSwitch?.isOn ?? true) && !(haveTimeSwitch?.isOn ?? true)) {
            tStampItem["text"] = "StampText"
            tStampItem["colorStyle"] = NSNumber(value:textStampColorStyle.rawValue)
            tStampItem["style"] = NSNumber(value:textStampStyle.rawValue)
            tStampItem["haveDate"] = NSNumber(booleanLiteral: haveDateSwitch?.isOn ?? false)
            tStampItem["haveTime"] = NSNumber(booleanLiteral:haveTimeSwitch?.isOn ?? false)
            
            delegate?.stampTextViewController?(self, dictionary: tStampItem)
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @objc func buttonItemClicked_cancel(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc func textFieldEditChange(_ sender: Any) {
        let textField = sender as? UITextField
        
        preView?.textStampText = textField?.text ?? ""
        preView?.setNeedsDisplay()
    }
    
    @objc func switchChange_date(_ sender: Any) {
        preView?.textStampHaveDate = haveDateSwitch?.isOn ?? false
        preView?.setNeedsDisplay()
    }
    
    @objc func switchChange_time(_ sender: Any) {
        preView?.textStampHaveTime = haveTimeSwitch?.isOn ?? false
        preView?.setNeedsDisplay()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if UIApplication.shared.statusBarOrientation.isPortrait {
            preferredContentSize = CGSize(width: view.bounds.size.width, height: 800)
        } else {
            // Handle landscape orientation
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if UIApplication.shared.statusBarOrientation.isPortrait {
            preferredContentSize = CGSize(width: view.bounds.size.width, height: 560)
        } else {
            // Handle landscape orientation
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - CStampShapViewDelegate
    
    func stampShapView(_ stampShapView: CStampShapView, tag: Int) {
        switch TextStampType(rawValue: tag) {
        case .center:
            self.preView?.textStampStyle = .center
            self.textStampStyle = .center
            self.preView?.setNeedsDisplay()
        case .left:
            self.preView?.textStampStyle = .left
            self.textStampStyle = .left
            self.preView?.setNeedsDisplay()
        case .right:
            self.preView?.textStampStyle = .right
            self.textStampStyle = .right
            self.preView?.setNeedsDisplay()
        case .none?:
            self.preView?.textStampStyle = .none
            self.textStampStyle = .none
            self.preView?.setNeedsDisplay()
        default:
            break
        }
        
    }
    
    // MARK: - CPDFColorSelectViewDelegate
    
    func stampColorSelectView(_ stampColorSelectView: CStampColorSelectView, tag: Int) {
        switch tag {
        case 0:
            self.preView?.textStampColorStyle = .black
            self.textStampColorStyle = .black
            self.preView?.setNeedsDisplay()
        case 1:
            self.preView?.textStampColorStyle = .red
            self.textStampColorStyle = .red
            self.preView?.setNeedsDisplay()
        case 2:
            self.preView?.textStampColorStyle = .green
            self.textStampColorStyle = .green
            self.preView?.setNeedsDisplay()
        case 3:
            self.preView?.textStampColorStyle = .blue
            self.textStampColorStyle = .blue
            self.preView?.setNeedsDisplay()
        default:
            break
        }
        
    }
    
}



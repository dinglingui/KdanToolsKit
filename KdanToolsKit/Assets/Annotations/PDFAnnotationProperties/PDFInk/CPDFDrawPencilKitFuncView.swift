//
//  CPDFDrawPencilKitFuncView.swift
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

public enum CPDFDrawPencilKitFuncType: Int {
    case eraser
    case cancel
    case done
}

public protocol CPDFDrawPencilViewDelegate: AnyObject {
    func drawPencilFuncView(_ view: CPDFDrawPencilKitFuncView, eraserBtn btn: UIButton)
    func drawPencilFuncView(_ view: CPDFDrawPencilKitFuncView, saveBtn btn: UIButton)
    func drawPencilFuncView(_ view: CPDFDrawPencilKitFuncView, cancelBtn btn: UIButton)
}

public class CPDFDrawPencilKitFuncView: UIView {
    public weak var delegate: CPDFDrawPencilViewDelegate?
    
    private var eraseButton: UIButton?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
        self.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5.0
        initSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let tWidth: CGFloat = 182.0
        let tHeight: CGFloat = 54.0
        
        self.transform = CGAffineTransform.identity
        self.frame = CGRect(x: 0, y: 0, width: tWidth, height: tHeight)
        
        let width = (self.superview?.bounds.size.width ?? 0) - 30
        let scale = width / self.bounds.size.width
        if self.frame.size.width > width {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
            
            self.center = CGPoint(x: (self.superview?.frame.size.width ?? 0) / 2.0,
                                  y: self.frame.size.height / 2.0 + 22)
        } else {
            if #available(iOS 11.0, *) {
                if self.window?.safeAreaInsets.bottom ?? 0 > 0 {
                    self.center = CGPoint(x: (self.superview?.frame.size.width ?? 0) - self.frame.size.width / 2.0 - 40,
                                          y: self.frame.size.height / 2.0 + 42)
                } else {
                    self.center = CGPoint(x: (self.superview?.frame.size.width ?? 0) - self.frame.size.width / 2.0 - 30,
                                          y: self.frame.size.height / 2.0 + 22)
                }
            }
        }
    }
    
    func initSubViews() {
        let tSpace: CGFloat = 10.0
        var tOffsetX: CGFloat = tSpace
        let tOffsetY: CGFloat = 5.0
        let tWidth: CGFloat = 44.0
        
        let eraseBtn = UIButton(type: .custom)
        eraseBtn.tag = CPDFDrawPencilKitFuncType.eraser.rawValue
        eraseBtn.layer.cornerRadius = 2.0
        eraseBtn.frame = CGRect(x: tOffsetX, y: tOffsetY, width: tWidth, height: self.m_height - tOffsetY * 2.0)
        eraseBtn.setImage(UIImage(named: "CImageNamePencilEraserOff", in: Bundle(for: Self.self), compatibleWith: nil), for: .normal)
        eraseBtn.setImage(UIImage(named: "CImageNamePencilEraserOn", in: Bundle(for: Self.self), compatibleWith: nil), for: .selected)
        eraseBtn.addTarget(self, action: #selector(eraserBtnClicked(_:)), for: .touchUpInside)
        self.addSubview(eraseBtn)
        self.eraseButton = eraseBtn
        tOffsetX = tOffsetX + eraseBtn.frame.size.width + tSpace
        
        let clearBtn = UIButton(type: .custom)
        clearBtn.tag = CPDFDrawPencilKitFuncType.cancel.rawValue
        clearBtn.layer.cornerRadius = 2.0
        clearBtn.frame = CGRect(x: tOffsetX, y: tOffsetY, width: tWidth + 10, height: self.m_height - tOffsetY * 2.0)
        if #available(iOS 13.0, *) {
            clearBtn.setTitleColor(.label, for: .normal)
        } else {
            clearBtn.setTitleColor(.black, for: .normal)
        }
        clearBtn.setTitle(NSLocalizedString("Discard", comment: ""), for: .normal)
        clearBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        clearBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        clearBtn.addTarget(self, action: #selector(clearBtnClicked(_:)), for: .touchUpInside)
        self.addSubview(clearBtn)
        tOffsetX = tOffsetX + clearBtn.frame.size.width + tSpace
        
        let saveBtn = UIButton(type: .custom)
        saveBtn.tag = CPDFDrawPencilKitFuncType.done.rawValue
        saveBtn.layer.cornerRadius = 2.0
        saveBtn.frame = CGRect(x: tOffsetX, y: tOffsetY, width: tWidth, height: self.frame.size.height - tOffsetY * 2.0)
        if #available(iOS 13.0, *) {
            saveBtn.setTitleColor(.label, for: .normal)
        } else {
            saveBtn.setTitleColor(.black, for: .normal)
        }
        saveBtn.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        saveBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        saveBtn.addTarget(self, action: #selector(saveBtnClicked(_:)), for: .touchUpInside)
        self.addSubview(saveBtn)
    }
    
    func resetAllSubviews() {
        // Reset all subviews
        for tSubview in subviews {
            if tSubview is UIButton {
                var tBtn = tSubview as? UIButton
                tBtn?.isSelected = false
                tBtn?.backgroundColor = UIColor.clear
            }
        }
    }
    
    // MARK: - Action
    
    @objc func clearBtnClicked(_ sender: UIButton) {
        resetAllSubviews()
        DispatchQueue.main.async {
            self.delegate?.drawPencilFuncView(self, cancelBtn: sender)
        }
    }
    
    @objc func saveBtnClicked(_ sender: UIButton) {
        resetAllSubviews()
        DispatchQueue.main.async {
            self.delegate?.drawPencilFuncView(self, saveBtn: sender)
        }
    }
    
    @objc func eraserBtnClicked(_ sender: UIButton) {
        let isSelected = !sender.isSelected
        resetAllSubviews()
        sender.isSelected = isSelected
        DispatchQueue.main.async {
            self.delegate?.drawPencilFuncView(self, eraserBtn: sender)
        }
    }
    
    var m_width: CGFloat {
        get {
            return frame.width
        }
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    
    var m_height: CGFloat {
        get {
            return frame.height
        }
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
}


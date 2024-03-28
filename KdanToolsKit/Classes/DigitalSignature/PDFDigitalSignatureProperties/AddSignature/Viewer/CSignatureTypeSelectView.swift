//
//  CSignatureTypeSelectView.swift
//  PDFViewer-Swift
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import UIKit

public enum CSignatureSelectType: Int {
    case none = 0
    case electronic
    case digital
}

@objc public protocol CSignatureTypeSelectViewDelegate: AnyObject {
    @objc optional func signatureTypeSelectViewElectronic(_ signatureTypeSelectView: CSignatureTypeSelectView)
    @objc optional func signatureTypeSelectViewDigital(_ signatureTypeSelectView: CSignatureTypeSelectView)
}

public class CSignatureTypeSelectView: UIView {
    public weak var delegate: CSignatureTypeSelectViewDelegate?
    private var titleLabel: UILabel?
    private var electronicBtn: UIButton?
    private var electronicSubBtn: UIButton?
    private var electronicLabel: UILabel?
    private var digitalBtn: UIButton?
    private var digitalSubBtn: UIButton?
    private var digitalLabel: UILabel?
    private var signatureTypeSelectView: UIView?
    private var splitView: UIView?
    private var centerSplitView: UIView?
    private var signBtn: UIButton?
    private var cancelBtn: UIButton?
    private var modelView: UIView?
    private var signatureSelectType: CSignatureSelectType = .none
    
    // MARK: - Initializers
    
    public init(frame: CGRect, height: CGFloat) {
        super.init(frame: frame)
        
        self.modelView = UIView(frame: frame)
        self.modelView?.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1)
        if modelView != nil {
            self.addSubview(self.modelView!)
        }
        
        self.signatureTypeSelectView = UIView(frame: CGRect(x: 0, y: 0, width: 240, height: height))
        if signatureTypeSelectView != nil {
            self.addSubview(self.signatureTypeSelectView!)
        }
        self.signatureTypeSelectView?.layer.borderColor = UIColor.gray.cgColor
        self.signatureTypeSelectView?.layer.borderWidth = 0.5
        self.signatureTypeSelectView?.layer.cornerRadius = 10
        self.signatureTypeSelectView?.layer.masksToBounds = true
        self.signatureTypeSelectView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        
        self.titleLabel = UILabel()
        self.titleLabel?.text = NSLocalizedString("Select Signature Type", comment: "")
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        self.titleLabel?.textAlignment = .center
        if titleLabel != nil {
            signatureTypeSelectView?.addSubview(self.titleLabel!)
        }
        
        self.electronicBtn = UIButton()
        self.electronicBtn?.setImage(UIImage(named: "CDigitalIDOff", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        self.electronicBtn?.setImage(UIImage(named: "CDigitalIDOn", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .selected)
        self.electronicBtn?.addTarget(self, action: #selector(buttonItemClicked_electronic(_:)), for: .touchUpInside)
        self.electronicBtn?.isSelected = true
        if electronicBtn != nil {
            signatureTypeSelectView?.addSubview(self.electronicBtn!)
        }
        
        self.electronicLabel = UILabel()
        self.electronicLabel?.text = NSLocalizedString("Sign with Electronic Signatures", comment: "")
        self.electronicLabel?.adjustsFontSizeToFitWidth = true
        if electronicLabel != nil {
            signatureTypeSelectView?.addSubview(self.electronicLabel!)
        }

        self.digitalBtn = UIButton()
        self.digitalBtn?.setImage(UIImage(named: "CDigitalIDOff", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        self.digitalBtn?.setImage(UIImage(named: "CDigitalIDOn", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .selected)
        if digitalBtn != nil {
            signatureTypeSelectView?.addSubview(self.digitalBtn!)
        }
        
        self.digitalLabel = UILabel()
        self.digitalLabel?.text = NSLocalizedString("Sign with Digital Signatures", comment: "")
        self.digitalLabel?.adjustsFontSizeToFitWidth = true
        if digitalLabel != nil {
            signatureTypeSelectView?.addSubview(self.digitalLabel!)
        }
        
        splitView = UIView()
        splitView?.backgroundColor = .gray
        if splitView != nil {
            signatureTypeSelectView?.addSubview(splitView!)
        }
        
        centerSplitView = UIView()
        centerSplitView?.backgroundColor = .gray
        if centerSplitView != nil {
            signatureTypeSelectView?.addSubview(centerSplitView!)
        }
        
        self.signBtn = UIButton()
        self.signBtn?.setTitle(NSLocalizedString("OKs", comment: ""), for: .normal)
        self.signBtn?.setTitleColor(CPDFColorUtils.CPageEditToolbarFontColor(), for: .normal)
        self.signBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.signBtn?.addTarget(self, action: #selector(buttonItemClicked_sign(_:)), for: .touchUpInside)
        if signBtn != nil {
            signatureTypeSelectView?.addSubview(self.signBtn!)
        }
        
        self.cancelBtn = UIButton()
        self.cancelBtn?.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        self.cancelBtn?.setTitleColor(CPDFColorUtils.CPageEditToolbarFontColor(), for: .normal)
        self.cancelBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.cancelBtn?.addTarget(self, action: #selector(buttonItemClicked_cancel(_:)), for: .touchUpInside)
        if cancelBtn != nil {
            signatureTypeSelectView?.addSubview(self.cancelBtn!)
        }
        
        self.electronicSubBtn = UIButton()
        self.electronicSubBtn?.backgroundColor = .clear
        self.electronicSubBtn?.addTarget(self, action: #selector(buttonItemClicked_electronic(_:)), for: .touchUpInside)
        if electronicSubBtn != nil {
            signatureTypeSelectView?.addSubview(self.electronicSubBtn!)
        }
        
        self.digitalSubBtn = UIButton()
        self.digitalSubBtn?.backgroundColor = .clear
        self.digitalSubBtn?.addTarget(self, action: #selector(buttonItemClicked_digital(_:)), for: .touchUpInside)
        if digitalSubBtn != nil {
            signatureTypeSelectView?.addSubview(self.digitalSubBtn!)
        }
        // Add your UI elements here, such as labels, buttons, and views, and set their properties.
        
        self.backgroundColor = .clear
        signatureSelectType = .electronic
        createGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func layoutSubviews() {
        // Implement your layout code here.
        super.layoutSubviews()
        self.signatureTypeSelectView?.center = self.center
        self.titleLabel?.frame = CGRect(x: 10, y: 5, width: (self.signatureTypeSelectView?.bounds.size.width ?? 0) - 20, height: 44)
        self.electronicBtn?.frame = CGRect(x: 15, y: (self.titleLabel?.frame.maxY ?? 0) + 10, width: 30, height: 30)
        self.electronicLabel?.frame = CGRect(x: 45, y: (self.titleLabel?.frame.maxY ?? 0) + 10, width: (self.signatureTypeSelectView?.bounds.size.width ?? 0) - 50, height: 30)
        self.digitalBtn?.frame = CGRect(x: 15, y: (self.electronicLabel?.frame.maxY ?? 0) + 10, width: 30, height: 30)
        self.digitalLabel?.frame = CGRect(x: 45, y:(self.electronicLabel?.frame.maxY ?? 0) + 10, width: (self.signatureTypeSelectView?.bounds.size.width ?? 0) - 50, height: 30)
        self.splitView?.frame = CGRect(x: 0, y: (self.signatureTypeSelectView?.size.height ?? 0) - 44, width: self.signatureTypeSelectView?.bounds.size.width ?? 0, height: 0.5)
        self.centerSplitView?.frame = CGRect(x: 120, y: (self.signatureTypeSelectView?.size.height ?? 0) - 44, width: 0.5, height: 44)
        self.signBtn?.frame = CGRect(x: 120, y: (self.signatureTypeSelectView?.size.height ?? 0) - 44, width: 120, height: 44)
        self.cancelBtn?.frame = CGRect(x: 0, y: (self.signatureTypeSelectView?.size.height ?? 0) - 44, width: 120, height: 44)
        
        self.electronicSubBtn?.frame = CGRect(x: 10, y:(self.titleLabel?.frame.maxY ?? 0) + 10, width: (self.signatureTypeSelectView?.bounds.size.width ?? 0) - 20, height: 30)
        self.digitalSubBtn?.frame = CGRect(x: 10, y:(self.electronicSubBtn?.frame.maxY ?? 0) + 10, width: (self.signatureTypeSelectView?.bounds.size.width ?? 0) - 20, height: 30)
        self.modelView?.frame = self.frame
    }
    
    // MARK: - Pubulic Methods
    
    public func showinView(_ superView: UIView?) {
        if let superView = superView {
            superView.addSubview(self)
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    private func createGestureRecognizer() {
        self.modelView?.isUserInteractionEnabled = true
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapModelView(_:)))
        self.modelView?.addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func tapModelView(_ gestureRecognizer: UIPanGestureRecognizer) {
        removeFromSuperview()
    }
    
   // MARK: - Action
    
    @objc func buttonItemClicked_electronic(_ button: UIButton) {
        electronicBtn?.isSelected = true
        digitalBtn?.isSelected = false
        
        signatureSelectType = .electronic
    }
    
    @objc func buttonItemClicked_digital(_ button: UIButton) {
        electronicBtn?.isSelected = false
        digitalBtn?.isSelected = true
        
        signatureSelectType = .digital
    }
    
    @objc func buttonItemClicked_sign(_ button: UIButton) {
        perform(#selector(done), with: nil, afterDelay: 0.3)
        
        switch signatureSelectType {
        case .electronic:
            delegate?.signatureTypeSelectViewElectronic?(self)
            break
        case .digital:
            delegate?.signatureTypeSelectViewDigital?(self)
            break
        default:
            break
        }
    }
    
    @objc func buttonItemClicked_cancel(_ button: UIButton) {
        removeFromSuperview()
    }
    
    @objc func done() {
        removeFromSuperview()
        removeFromSuperview()
    }
    
}


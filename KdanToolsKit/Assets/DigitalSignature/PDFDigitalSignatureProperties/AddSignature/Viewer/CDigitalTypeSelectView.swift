//
//  CDigitalTypeSelectView.swift
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

public enum CDigitalSelectType: Int {
    case none = 0
    case certificate
    case selfSigned
}

protocol NibLoadable {
    
}

@objc public protocol CDigitalTypeSelectViewDelegate: AnyObject {
    @objc optional func CDigitalTypeSelectViewUse(_ digitalTypeSelectView: CDigitalTypeSelectView)
    @objc optional func CDigitalTypeSelectViewCreate(_ digitalTypeSelectView: CDigitalTypeSelectView)
}


public class CDigitalTypeSelectView: UIView, NibLoadable {
    public weak var delegate: CDigitalTypeSelectViewDelegate?
    
    @IBOutlet weak var title: UILabel?
    @IBOutlet weak var certificateSelected: UIButton?
    @IBOutlet weak var selfSignedSelected: UIButton?
    @IBOutlet weak var certificateLabel: UILabel?
    @IBOutlet weak var selfSignedLabel: UILabel?
    @IBOutlet weak var doneButton: UIButton?
    @IBOutlet weak var contentView: UIView?
    @IBOutlet weak var cancelButton: UIButton?
    @IBOutlet weak var importButton: UIButton?
    @IBOutlet weak var createButton: UIButton?
    
    var digitalSelectType: CDigitalSelectType = .certificate
    
    // MARK: - Initialize
    
    public init() {
        super.init(frame: .zero)

    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        digitalSelectType = .selfSigned
        importButton?.setTitle("", for: .normal)
        createButton?.setTitle("", for: .normal)
        certificateSelected?.isSelected = true
        selfSignedSelected?.isSelected = false
        
        title?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
        title?.text = NSLocalizedString("Select A Digital ID", comment: "")
        certificateLabel?.text = NSLocalizedString("Use a Digital ID from A File", comment: "")
        selfSignedLabel?.text = NSLocalizedString("Create A New Digital ID", comment: "")
        cancelButton?.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        doneButton?.setTitle(NSLocalizedString("Continue", comment: ""), for: .normal)
        certificateLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
        selfSignedLabel?.textColor = CPDFColorUtils.CPageEditToolbarFontColor()
        certificateLabel?.adjustsFontSizeToFitWidth = true
        selfSignedLabel?.adjustsFontSizeToFitWidth = true
        
        certificateSelected?.setImage(UIImage(named: "CDigitalIDOff", in: Bundle(for: CDigitalTypeSelectView.self), compatibleWith: nil), for: .normal)
        certificateSelected?.setImage(UIImage(named: "CDigitalIDOn", in: Bundle(for: CDigitalTypeSelectView.self), compatibleWith: nil), for: .selected)
        
        selfSignedSelected?.setImage(UIImage(named: "CDigitalIDOff", in: Bundle(for: CDigitalTypeSelectView.self), compatibleWith: nil), for: .normal)
        selfSignedSelected?.setImage(UIImage(named: "CDigitalIDOn", in: Bundle(for: CDigitalTypeSelectView.self), compatibleWith: nil), for: .selected)
        
        contentView?.layer.borderColor = UIColor.gray.cgColor
        contentView?.layer.borderWidth = 0.5
        contentView?.layer.cornerRadius = 10
        contentView?.layer.masksToBounds = true
        contentView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
    }
    
    public func show(in superView: UIView) {
        superView.addSubview(self)
        setNeedsLayout()
        layoutIfNeeded()
        importClicked(importButton ?? UIButton())
    }
    
    // MARK: - Action
    
    @IBAction func doneClicked(_ sender: UIButton) {
        perform(#selector(done), with: nil, afterDelay: 0.3)
        switch digitalSelectType {
        case .certificate:
            delegate?.CDigitalTypeSelectViewUse?(self)
            break
        case .selfSigned:
            delegate?.CDigitalTypeSelectViewCreate?(self)
            break
        case .none:
            break
        }
    }
    
    @IBAction func importClicked(_ sender: UIButton) {
        certificateSelected?.isSelected = true
        selfSignedSelected?.isSelected = false
        digitalSelectType = .certificate
    }
    
    @IBAction func createClicked(_ sender: Any) {
        selfSignedSelected?.isSelected = true
        certificateSelected?.isSelected = false
        digitalSelectType = .selfSigned
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        perform(#selector(cancel), with: nil, afterDelay: 0.3)
    }
    
    @objc func done() {
        self.removeFromSuperview()
    }
    
    @objc func cancel() {
        removeFromSuperview()
    }
    
    func dissView() {
        removeFromSuperview()
    }
    
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        removeFromSuperview()
    }
}

public extension CDigitalTypeSelectView {
    class func loadFromNib() -> CDigitalTypeSelectView {
        Bundle(for: CDigitalTypeSelectView.self).loadNibNamed("CDigitalTypeSelectView", owner: self, options: nil)?.first as! Self
    }
}





//
//  CAddSignatureCell.swift
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

enum CAddSignatureCellType: Int {
    case alignment = 0
    case access
    case select
}

@objc protocol CAddSignatureCellDelegate: AnyObject {
    @objc optional func addSignatureCell(_ addSignatureCell: CAddSignatureCell, alignment isLeft: Bool)
    @objc optional func addSignatureCellAccess(_ addSignatureCell: CAddSignatureCell)
    @objc optional func addSignatureCell(_ addSignatureCell: CAddSignatureCell, button: UIButton)
}

class CAddSignatureCell: UITableViewCell {
    weak var delegate: CAddSignatureCellDelegate?
    var cellType: CAddSignatureCellType = .alignment
    var leftAlignmentBtn: UIButton?
    var rightAlignmentBtn: UIButton?
    var accessLabel: UILabel?
    var accessSelectLabel: UILabel?
    var accessSelectBtn: UIButton?
    var textSelectBtn: UIButton?
    var textSelectLabel: UILabel?
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - Pubulic Methods
    
    func setCellStyle(_ cellType: CAddSignatureCellType, label: String?) {
        self.cellType = cellType
        
        switch self.cellType {
        case .alignment:
            self.textLabel?.text = label
            self.textLabel?.font = UIFont.systemFont(ofSize: 13)
            self.selectionStyle = .none
            let alignmentSelectView = self.alignmentSelectViewCreate()
            self.accessoryView = alignmentSelectView
            self.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
            
        case .access:
            self.textLabel?.text = label
            self.textLabel?.font = UIFont.systemFont(ofSize: 13)
            self.selectionStyle = .none
            let accessSelectView = self.accessSelectViewCreate()
            self.accessoryView = accessSelectView
            self.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
            
        case .select:
            if self.textSelectBtn == nil {
                self.textSelectBtn = UIButton(frame: CGRect(x: 0, y: 5, width: 50, height: 50))
            }
            self.selectionStyle = .none
            self.textSelectBtn?.isSelected = false
            self.textSelectBtn?.setImage(UIImage(named: "CAddSignatureCellSelect", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .selected)
            self.textSelectBtn?.setImage(UIImage(named: "CAddSignatureCellNoSelect", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
            self.textSelectBtn?.addTarget(self, action: #selector(buttonItemClickedSelect(_:)), for: .touchUpInside)
            self.textSelectBtn?.layer.cornerRadius = 25.0
            self.textSelectBtn?.layer.masksToBounds = true
            self.contentView.addSubview(self.textSelectBtn!)
            
            if self.textSelectLabel == nil {
                self.textSelectLabel = UILabel(frame: CGRect(x: 50, y: 5, width: self.bounds.size.width - 80, height: 50))
            }
            self.textSelectLabel?.text = label
            self.textSelectLabel?.font = UIFont.systemFont(ofSize: 13)
            self.contentView.addSubview(self.textSelectLabel!)
            self.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
        }
    }
    
    func setLeftAlignment(isLeftAlignment: Bool) {
        if isLeftAlignment {
            leftAlignmentBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
            rightAlignmentBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        } else {
            rightAlignmentBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
            leftAlignmentBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        }
    }
    
    // MARK: - Private Methods
    
    @objc func buttonItemClickedSelect(_ button: UIButton) {
        self.delegate?.addSignatureCell?(self, button: button)
    }
    
    func alignmentSelectViewCreate() -> UIView {
        let tSelectView = UIView(frame: CGRect(x: 0, y: 8, width: 88, height: 44))
        tSelectView.layer.cornerRadius = 5
        tSelectView.layer.masksToBounds = true
        
        self.leftAlignmentBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        self.leftAlignmentBtn?.tag = 0
        self.leftAlignmentBtn?.isSelected = false
        self.leftAlignmentBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
        self.leftAlignmentBtn?.setImage(UIImage(named: "CAddSignatureCellLeft", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        self.leftAlignmentBtn?.addTarget(self, action: #selector(buttonItemClickedAlignment(_:)), for: .touchUpInside)
        
        self.rightAlignmentBtn = UIButton(frame: CGRect(x: 44, y: 0, width: 44, height: 44))
        self.rightAlignmentBtn?.isSelected = false
        self.rightAlignmentBtn?.tag = 1
        self.rightAlignmentBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        self.rightAlignmentBtn?.setImage(UIImage(named: "CAddSignatureCellRight", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        self.rightAlignmentBtn?.addTarget(self, action: #selector(buttonItemClickedAlignment(_:)), for: .touchUpInside)
        
        if leftAlignmentBtn != nil {
            tSelectView.addSubview(self.leftAlignmentBtn!)
        }
        if rightAlignmentBtn != nil {
            tSelectView.addSubview(self.rightAlignmentBtn!)
        }
        return tSelectView
    }
    
    func accessSelectViewCreate() -> UIView {
        let tSelectView = UIView(frame: CGRect(x: 0, y: 5, width: 240, height: 50))
        self.accessSelectLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        self.accessSelectLabel?.textAlignment = .right
        self.accessSelectLabel?.font = UIFont.systemFont(ofSize: 13)
        self.accessSelectLabel?.adjustsFontSizeToFitWidth = true
        self.accessSelectLabel?.text = NSLocalizedString("Close", comment: "")
        
        self.accessSelectBtn = UIButton(frame: CGRect(x: 200, y: 0, width: 40, height: 50))
        self.accessSelectBtn?.isSelected = false
        self.accessSelectBtn?.setImage(UIImage(named: "CInsertBlankPageCellSelect", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        self.accessSelectBtn?.addTarget(self, action: #selector(buttonItemClicked_access(_:)), for: .touchUpInside)
        
        if accessSelectLabel != nil {
            tSelectView.addSubview(self.accessSelectLabel!)
        }
        if accessSelectBtn != nil {
            tSelectView.addSubview(self.accessSelectBtn!)
        }
        
        return tSelectView
    }
    
    @objc func buttonItemClickedAlignment(_ button: UIButton) {
        self.rightAlignmentBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        self.leftAlignmentBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        
        if button.tag == 0 {
            self.leftAlignmentBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
            self.delegate?.addSignatureCell?(self, alignment: false)
        } else if button.tag == 1 {
            self.rightAlignmentBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
            self.delegate?.addSignatureCell?(self, alignment: true)
        }
    }
    
    
    @objc func buttonItemClicked_access(_ button: UIButton) {
        delegate?.addSignatureCellAccess?(self)
    }
    
}

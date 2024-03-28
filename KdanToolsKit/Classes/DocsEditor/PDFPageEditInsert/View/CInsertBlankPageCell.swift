//
//  CInsertBlankPageCell.swift
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

enum CInsertBlankPageCellType: Int {
    case CInsertBlankPageCellSize = 0
    case CInsertBlankPageCellDirection
    case CInsertBlankPageCellLocation
    case CInsertBlankPageCellSizeSelect
    case CInsertBlankPageCellLocationSelect
    case CInsertBlankPageCellLocationTextFiled
    case CInsertBlankPageCellRangeSelect
    case CInsertBlankPageCellRangeTextFiled
}

@objc protocol CInsertBlankPageCellDelegate: AnyObject {
    
    @objc optional func insertBlankPageCell(_ insertBlankPageCell: CInsertBlankPageCell, isSelect: Bool)
    @objc optional func insertBlankPageCell(_ insertBlankPageCell: CInsertBlankPageCell, rotate: Int)
    @objc optional func insertBlankPageCell(_ insertBlankPageCell: CInsertBlankPageCell, pageIndex: Int)
    @objc optional func insertBlankPageCellLocation(_ insertBlankPageCell: CInsertBlankPageCell, button: UIButton)
    @objc optional func insertBlankPageCellRange(_ insertBlankPageCell: CInsertBlankPageCell, button: UIButton)
    @objc optional func insertBlankPageCell(_ insertBlankPageCell: CInsertBlankPageCell, pageRange: String)
    @objc optional func insertBlankPageCellLocationTextFieldBegin(_ insertBlankPageCell: CInsertBlankPageCell)
    @objc optional func insertBlankPageCellRangeTextFieldBegin(_ insertBlankPageCell: CInsertBlankPageCell)
    
}

class CInsertBlankPageCell: UITableViewCell, UITextFieldDelegate {
    
    var cellType: CInsertBlankPageCellType = .CInsertBlankPageCellLocation
    weak var delegate: CInsertBlankPageCellDelegate?
    var sizeLabel = UILabel()
    var sizeSelectBtn: UIButton?
    var sizeSelectLabel: UILabel?
    var horizontalPageBtn: UIButton?
    var verticalPageBtn: UIButton?
    var locationSelectBtn: UIButton?
    var locationSelectLabel: UILabel?
    var rangeSelectLabel: UILabel?
    var locationTextField: UITextField?
    var rangeSelectBtn: UIButton?
    var rangeTextField: UITextField?
    var buttonSelectedStatus: Bool = false
    
    private var isSelect: Bool?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Initialization code
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if self.cellType == .CInsertBlankPageCellSizeSelect {
            if selected {
                self.accessoryType = .checkmark
            } else {
                self.accessoryType = .none
            }
        }
        
    }
    
    // MARK: - Pubulic Methods
    
    func setCellStyle(_ cellType: CInsertBlankPageCellType, label: String) {
        if let locationTextField = self.locationTextField {
            locationTextField.delegate = nil
        }
        self.locationSelectBtn = nil
        self.locationSelectLabel?.text = nil
        self.sizeSelectLabel?.text = nil
        self.textLabel?.text = nil
        self.sizeSelectLabel?.text = nil
        self.locationTextField = nil
        
        self.cellType = cellType
        switch self.cellType {
        case .CInsertBlankPageCellSize:
            self.textLabel?.text = label
            self.selectionStyle = .none
            
            let tSelectView = self.sizeSelectViewCreate()
            
            self.accessoryView = tSelectView
            self.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
            
        case .CInsertBlankPageCellDirection:
            self.textLabel?.text = label
            self.selectionStyle = .none
            
            let tSelectView = self.directSelectViewCreate()
            
            self.accessoryView = tSelectView
            self.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
            
        case .CInsertBlankPageCellLocation:
            self.textLabel?.text = label
            self.selectionStyle = .none
            self.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
            
        case .CInsertBlankPageCellSizeSelect:
            if self.sizeSelectLabel == nil {
                self.sizeSelectLabel = UILabel(frame: CGRect(x: 50, y: 5, width: self.bounds.size.width-60, height: 50))
            }
            self.sizeSelectLabel?.text = ""
            self.sizeSelectLabel?.text = label
            self.sizeLabel.font = UIFont.systemFont(ofSize: 15)
            if(self.sizeSelectLabel != nil) {
                self.contentView.addSubview(self.sizeSelectLabel!)
            }
            self.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
            
        case .CInsertBlankPageCellLocationSelect:
            if self.locationSelectBtn == nil {
                self.locationSelectBtn = UIButton(frame: CGRect(x: 30, y: 5, width: 50, height: 50))
            }
            self.selectionStyle = .none
            
            self.locationSelectBtn?.isSelected = false
            self.locationSelectBtn?.setImage(UIImage(named: "CInsertBlankPageCellLocationSelectOn", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .selected)
            self.locationSelectBtn?.setImage(UIImage(named: "CInsertBlankPageCellLocationSelectOff", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
            self.locationSelectBtn?.addTarget(self, action: #selector(buttonItemClicked_location(_:)), for: .touchUpInside)
            self.locationSelectBtn?.layer.cornerRadius = 25.0
            self.locationSelectBtn?.layer.masksToBounds = true
            if self.locationSelectBtn != nil {
                self.contentView.addSubview(self.locationSelectBtn!)
            }
            if self.locationSelectLabel == nil {
                self.locationSelectLabel = UILabel(frame: CGRect(x: 80, y: 5, width: self.bounds.size.width-80, height: 50))
            }
            self.locationSelectLabel?.text = label
            self.locationSelectLabel?.textColor = UIColor.gray
            if(self.locationSelectLabel != nil) {
                self.contentView.addSubview(self.locationSelectLabel!)
            }
            
            self.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
            
        case .CInsertBlankPageCellLocationTextFiled:
            self.selectionStyle = .none
            
            let tFieldRect = CGRect(x: 50.0, y: 15.0, width: 300.0, height: 30.0)
            let tTextField = self.textFieldItemCreate_text(rect: tFieldRect)
            tTextField.delegate = self
            tTextField.placeholder = label
            self.locationTextField = tTextField
            self.locationTextField?.addTarget(self, action: #selector(textField_location(_:)), for: .editingChanged)
            if(self.locationTextField != nil) {
                self.contentView.addSubview(self.locationTextField!)
            }
            self.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
            self.separatorInset = UIEdgeInsets(top: 0, left: self.bounds.size.width, bottom: 0, right: self.bounds.size.width)
            
        case .CInsertBlankPageCellRangeSelect:
            if rangeSelectBtn == nil {
                rangeSelectBtn = UIButton(frame: CGRect(x: 30, y: 5, width: 50, height: 50))
            }
            selectionStyle = .none
            rangeSelectBtn?.isSelected = false
            rangeSelectBtn?.setImage(UIImage(named: "CInsertBlankPageCellLocationSelectOn", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .selected)
            rangeSelectBtn?.setImage(UIImage(named: "CInsertBlankPageCellLocationSelectOff", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
            rangeSelectBtn?.addTarget(self, action: #selector(buttonItemClicked_range(_:)), for: .touchUpInside)
            rangeSelectBtn?.layer.cornerRadius = 25.0
            rangeSelectBtn?.layer.masksToBounds = true
            if(rangeSelectBtn != nil) {
                contentView.addSubview(rangeSelectBtn!)
            }
            
            if rangeSelectLabel == nil {
                rangeSelectLabel = UILabel(frame: CGRect(x: 80, y: 5, width: bounds.size.width-80, height: 50))
            }
            rangeSelectLabel?.text = label
            rangeSelectLabel?.textColor = UIColor.gray
            if(rangeSelectLabel != nil) {
                contentView.addSubview(rangeSelectLabel!)
            }
            
            backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
            
        case .CInsertBlankPageCellRangeTextFiled:
            selectionStyle = .none
            let tFieldRect = CGRect(x: 50.0, y: 15.0, width: 300.0, height: 30.0)
            let tTextField = textFieldItemCreate_text(rect: tFieldRect)
            tTextField.delegate = self
            tTextField.placeholder = label
            rangeTextField = tTextField
            rangeTextField?.addTarget(self, action: #selector(textField_range(_:)), for: .editingChanged)
            if(rangeTextField != nil) {
                contentView.addSubview(rangeTextField!)
            }
            backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
            
        }
    }
    
    // MARK: - Private Methods
    
    func sizeSelectViewCreate() -> UIView {
        let tSelectView = UIView(frame: CGRect(x: 0, y: 5, width: 240, height: 50))
        sizeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        sizeLabel.textAlignment = .right
        sizeLabel.font = UIFont.systemFont(ofSize: 18)
        sizeLabel.text = NSLocalizedString("A4 (210 X 297mm)", comment: "")
        sizeSelectBtn = UIButton(frame: CGRect(x: 200, y: 0, width: 40, height: 50))
        sizeSelectBtn?.isSelected = false;
        sizeSelectBtn?.setImage(UIImage(named: "CInsertBlankPageCellSelectDown", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .selected)
        sizeSelectBtn?.setImage(UIImage(named: "CInsertBlankPageCellSelect", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        sizeSelectBtn?.addTarget(self, action: #selector(buttonItemClicked_size(_:)), for: .touchUpInside)
        
        tSelectView.addSubview(sizeLabel)
        if(sizeSelectBtn != nil) {
            tSelectView.addSubview(sizeSelectBtn!)
        }
        
        return tSelectView
        
    }
    func directSelectViewCreate() -> UIView {
        let tSelectView = UIView(frame: CGRect(x: 0, y: 8, width: 88, height: 44))
        tSelectView.layer.cornerRadius = 5
        tSelectView.layer.masksToBounds = true
        verticalPageBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        verticalPageBtn?.tag = 0
        verticalPageBtn?.isSelected = false
        verticalPageBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        verticalPageBtn?.setImage(UIImage(named: "CInsertBlankPageCellVertical", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        verticalPageBtn?.addTarget(self, action: #selector(buttonItemClicked_direction(_:)), for: .touchUpInside)
        
        horizontalPageBtn = UIButton(frame: CGRect(x: 44, y: 0, width: 44, height: 44))
        horizontalPageBtn?.isSelected = false
        horizontalPageBtn?.tag = 1
        horizontalPageBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        horizontalPageBtn?.setImage(UIImage(named: "CInsertBlankPageCellHorizontal", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        horizontalPageBtn?.addTarget(self, action: #selector(buttonItemClicked_direction(_:)), for: .touchUpInside)
        
        if(horizontalPageBtn != nil) {
            tSelectView.addSubview(horizontalPageBtn!)
        }
        if(verticalPageBtn != nil) {
            tSelectView.addSubview(verticalPageBtn!)
        }
        
        return tSelectView
    }
    
    func textFieldItemCreate_text(rect: CGRect) -> UITextField {
        let tTextField = UITextField(frame: rect)
        tTextField.contentVerticalAlignment = .center
        tTextField.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        tTextField.returnKeyType = .done
        tTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        tTextField.leftViewMode = .always
        tTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        tTextField.rightViewMode = .always
        tTextField.clearButtonMode = .whileEditing
        tTextField.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        tTextField.layer.borderWidth = 1.0
        tTextField.borderStyle = .none
        
        return tTextField
        
    }
    
    func validateValue(number: String) -> Bool {
        var res = true
        let numberSet = CharacterSet(charactersIn: "0123456789")
        var i = 0
        while i < number.count {
            let str = String(number[number.index(number.startIndex, offsetBy: i)])
            let range = str.rangeOfCharacter(from: numberSet)
            
            if range == nil {
                res = false
                break
            }
            i += 1
        }
        
        return res
    }
    
    //MARK: - Public Methods
    
    func setVertical(status: Bool) {
        horizontalPageBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        verticalPageBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        
        if status {
            verticalPageBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
           
        } else {
            horizontalPageBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
        }
    }
    
    func setButtonSelectedStatus(buttonSelectedStatus: Bool) {
        self.buttonSelectedStatus = buttonSelectedStatus
        if buttonSelectedStatus {
            //           sizeSelectBtn?.isSelected = true
            sizeSelectBtn?.setImage(UIImage(named: "CInsertBlankPageCellSelectDown", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
            sizeSelectBtn?.setNeedsDisplay()
        } else {
            //           sizeSelectBtn?.isSelected = false
            sizeSelectBtn?.setImage(UIImage(named: "CInsertBlankPageCellSelect", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
            sizeSelectBtn?.setNeedsDisplay()
        }
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_size(_ button: UIButton) {
        delegate?.insertBlankPageCell?(self, isSelect: button.isSelected)
    }
    
    @objc func buttonItemClicked_direction(_ button: UIButton) {
        horizontalPageBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        verticalPageBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        
        if button.tag == 0 {
            verticalPageBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
            delegate?.insertBlankPageCell?(self, rotate: button.tag)
        } else if button.tag == 1 {
            horizontalPageBtn?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
            delegate?.insertBlankPageCell?(self, rotate: button.tag)
        }
    }
    
    @objc func textField_location(_ sender: UITextField) {
        let pageIndex = Int(sender.text ?? "0") ?? 0
        delegate?.insertBlankPageCell?(self, pageIndex: pageIndex)
    }
    
    @objc func textField_range(_ sender: UITextField) {
        delegate?.insertBlankPageCell?(self, pageRange: sender.text ?? "1")
    }
    
    @objc func buttonItemClicked_location(_ button: UIButton) {
        locationTextField?.resignFirstResponder()
        delegate?.insertBlankPageCellLocation?(self, button: button)
    }
    
    @objc func buttonItemClicked_range(_ button: UIButton) {
        delegate?.insertBlankPageCellRange?(self, button: button)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == locationTextField {
            return validateValue(number: string)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if locationTextField == textField {
            delegate?.insertBlankPageCellLocationTextFieldBegin?(self)
        } else if rangeTextField == textField {
            delegate?.insertBlankPageCellRangeTextFieldBegin?(self)
        }
    }
    
}


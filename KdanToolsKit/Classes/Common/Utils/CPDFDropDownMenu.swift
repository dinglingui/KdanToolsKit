//
//  CPDFDropDownMenu.swift
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

protocol CPDFDropDownMenuDelegate: AnyObject {
    func dropDownMenu(_ menu: CPDFDropDownMenu, didEditWithText text: String)
    func dropDownMenu(_ menu: CPDFDropDownMenu, didSelectWithIndex index: Int)
}

class CPDFDropDownMenu: UIView, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: CPDFDropDownMenuDelegate?
    var editable:Bool = false
    var buttonImage:UIImage?
    var placeHolder:String?
    var textColor:UIColor?
    var font:UIFont?
    var pullDownButton:UIButton?
    var isShown:Bool = false
    var menuMaxHeight:CGFloat = 0
    var contextField:UITextField?
    private var privateOptionList: UITableView?
    
    
    var showBorder: Bool = false {
        didSet {
            if showBorder {
                layer.borderColor = UIColor.lightGray.cgColor
                layer.borderWidth = 0.5
                layer.masksToBounds = true
                layer.cornerRadius = 2.5
            } else {
                layer.borderColor = UIColor.clear.cgColor
                layer.masksToBounds = false
                layer.cornerRadius = 0
                layer.borderWidth = 0
            }
        }
    }
    
    var menuHeight: CGFloat = 0 {
        didSet {
            self.reloadData()
        }
    }
    
    var rowHeight: CGFloat = 0 {
        didSet {
            self.reloadData()
        }
    }
    
    var options: NSMutableArray = [] {
        didSet {
            self.reloadData()
        }
    }
    
    var defaultValue: String? {
        didSet {
            contextField?.text = defaultValue
        }
    }
    
    var optionList: UITableView {
        if let existingOptionList = privateOptionList {
            return existingOptionList
        } else {
            let frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width, height: 0)
            privateOptionList = UITableView(frame: frame, style: .plain)
            privateOptionList?.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
            privateOptionList?.delegate = self
            privateOptionList?.dataSource = self
            privateOptionList?.layer.borderColor = UIColor.lightGray.cgColor
            privateOptionList?.layer.borderWidth = 0.5
            privateOptionList?.allowsSelection = true
            if privateOptionList != nil {
                addSubview(privateOptionList!)
            }
            return privateOptionList!
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        contextField = UITextField(frame: CGRect.zero)
        contextField?.delegate = self
        contextField?.isEnabled = true
        contextField?.textColor = UIColor.darkGray
        if contextField != nil {
            addSubview(contextField!)
        }
        
        pullDownButton = UIButton(type: .custom)
        pullDownButton?.addTarget(self, action: #selector(showOrHide), for: .touchUpInside)
        pullDownButton?.setImage(UIImage(named: "CPDFEditArrow", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        if pullDownButton != nil {
            addSubview(pullDownButton!)
        }
        
        showBorder = true
        textColor = UIColor.darkGray
        font = UIFont.systemFont(ofSize: 16)
        rowHeight = 40
        isUserInteractionEnabled = true
    }
    
    @objc func showOrHide() {
        if isShown {
            UIView.animate(withDuration: 0.3, animations: {
                self.pullDownButton?.transform = CGAffineTransform(rotationAngle: .pi * 2)
                let frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.size.height - 0.5, width: self.frame.size.width, height: 0)
                let newFrame = self.convert(frame, to: self.superview?.superview)
                self.optionList.frame = newFrame
            }) { _ in
                self.pullDownButton?.transform = CGAffineTransform(rotationAngle: 0)
                self.isShown = false
            }
        } else {
            contextField?.resignFirstResponder()
            optionList.reloadData()
            
            UIView.animate(withDuration: 0.3, animations: {
                self.pullDownButton?.transform = CGAffineTransform(rotationAngle: .pi)
                let frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.size.height - 0.5, width: self.frame.size.width, height: self.menuHeight)
                let newFrame = self.convert(frame, to: self.superview?.superview)
                self.optionList.frame = newFrame
            }) { _ in
                self.isShown = true
            }
        }
    }
    
    func reloadData() {
        guard isShown else {
            return
        }
        
        optionList.reloadData()
        
        UIView.animate(withDuration: 0.3) {
            self.pullDownButton?.transform = CGAffineTransform(rotationAngle: .pi)
            let frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.size.height - 0.5, width: self.frame.size.width, height: self.menuHeight)
            let newFrame = self.convert(frame, to: self.superview?.superview)
            
            self.optionList.frame = newFrame
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contextField?.frame = CGRect(x: 15, y: 5, width: self.frame.size.width - 50, height: self.frame.size.height - 10)
        self.pullDownButton?.frame = CGRect(x: self.frame.size.width - 35, y: 0, width: 30, height: 30)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            defaultValue = text
            self.delegate?.dropDownMenu(self, didEditWithText: text)
        }
        
        return true
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "tableViewIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
        }
        cell?.textLabel?.text = self.options[indexPath.row] as? String
        cell?.textLabel?.font = self.font
        cell?.textLabel?.textColor = self.textColor
        cell?.isUserInteractionEnabled = true
        return cell!
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        contextField!.text = self.options[indexPath.row] as? String
        defaultValue = contextField!.text
        self.delegate?.dropDownMenu(self, didSelectWithIndex: indexPath.row)
        showOrHide()
    }
}

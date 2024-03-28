//
//  CPDFEditFontNameSelectView.swift
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

@objc protocol CPDFEditFontNameSelectViewDelegate: AnyObject {
    @objc optional func pickerView(_ colorPickerView: CPDFEditFontNameSelectView, fontName: String);
}

class CPDFEditFontNameSelectView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: CPDFEditFontNameSelectViewDelegate?
    
    var fontNameArr: [Any]?
    var fontName: String = ""
    
    var titleLabel: UILabel = UILabel()
    var backBtn: UIButton = UIButton()
    var mTableView: UITableView?
    var selectedFontName: String = ""
    var current: IndexPath?
    var recordRow: NSInteger = 0
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel = UILabel(frame: CGRect(x: (frame.size.width - 120)/2, y: 0, width: 120, height: (bounds.size.height - 40)/6))
        titleLabel.text = NSLocalizedString("Font Style", comment: "")
        titleLabel.autoresizingMask = .flexibleHeight
        self.addSubview(titleLabel)
        
        backBtn = UIButton(frame: CGRect(x: 10, y: 0, width: 40, height: (bounds.size.height - 40)/6))
        backBtn.autoresizingMask = .flexibleHeight
        
        if fontNameArr == nil {
            fontNameArr = ["FontName1", "fontName2", "fontName3"]
        }
        
        backBtn.setImage(UIImage(named: "CPDFAnnotationBarImageUndo", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        backBtn.addTarget(self, action: #selector(buttonItemClicked_back(_:)), for: .touchUpInside)
        self.addSubview(backBtn)
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if mTableView == nil {
            mTableView = UITableView(frame: CGRect(x: 0, y: titleLabel.frame.maxY, width: self.frame.size.width, height: self.frame.size.height - titleLabel.frame.size.height))
            if(mTableView != nil) {
                self.addSubview(mTableView!)
            }
            mTableView?.delegate = self
            mTableView?.dataSource = self
            mTableView?.reloadData()
        }
    }
    
    // MARK: - Action
    @objc func buttonItemClicked_back(_ sender: UIButton) {
        self.removeFromSuperview()
        self.delegate?.pickerView?(self, fontName: self.selectedFontName)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.fontNameArr?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentity = "fontNameSelectCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentity)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentity)
        }
        let cellFont = UIFont(name: fontNameArr?[indexPath.row] as? String ?? "Helvetica", size: 15)
        let selectFont = UIFont(name: fontName, size: 15)
        if cellFont == selectFont {
            recordRow = indexPath.row
            current = indexPath
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }
        
        cell?.textLabel?.text = fontNameArr?[indexPath.row] as? String
        cell?.textLabel?.font = cellFont
        return cell!
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != self.current?.row  && current != nil {
            let cell = tableView.cellForRow(at: current!)
            cell?.accessoryType = .none
        }
        if indexPath.row != recordRow {
            recordRow = indexPath.row
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
            
            let selectedIndexPath = mTableView?.indexPathForSelectedRow
            UserDefaults.standard.set(NSNumber(value: selectedIndexPath!.row), forKey: "SetTodoRemindCycle")
        }
        
        selectedFontName = fontNameArr?[indexPath.row] as? String ?? ""
        fontName = selectedFontName

        self.delegate?.pickerView?(self, fontName: selectedFontName)
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
}

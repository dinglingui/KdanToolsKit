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
import ComPDFKit

@objc protocol CPDFEditFontNameSelectViewDelegate: AnyObject {
    @objc optional func pickerView(_ colorPickerView: CPDFEditFontNameSelectView, fontName: String);
}

class CPDFEditFontNameSelectView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: CPDFEditFontNameSelectViewDelegate?
    
    private var fontNameArr: [String]?
    private var fontName: String = ""
    private var fontStyle: String = ""
    private var isFontStyle: Bool = false

    var titleLabel: UILabel = UILabel()
    var backBtn: UIButton = UIButton()
    var mTableView: UITableView?
    var selectedFontName: String = ""
    var current: IndexPath?
    var recordRow: NSInteger = 0
    
    init(frame: CGRect,familyNames:String,styleName:String,isFontStyle: Bool) {
        super.init(frame: frame)
        if(isFontStyle == false) {
            fontNameArr = CPDFFont.familyNames
            fontName = familyNames
            self.selectedFontName = familyNames
        } else {
            fontNameArr = CPDFFont.fontNames(forFamilyName: familyNames)
            if((fontNameArr?.count ?? 0) < 1) {
                fontNameArr?.append("Regular")
            }
            self.selectedFontName = styleName
            if self.selectedFontName.count < 1 {
                self.selectedFontName = "Regular"
            }
        }
        fontName = familyNames
        fontStyle = styleName
        if fontStyle.count < 1 {
            fontStyle = "Regular"
        }
        self.isFontStyle = isFontStyle
        
        titleLabel = UILabel(frame: CGRect(x: (frame.size.width - 120)/2, y: 0, width: 120, height: 50))
        titleLabel.textAlignment = .center
        if(isFontStyle) {
            titleLabel.text = NSLocalizedString("Font Style", comment: "")
        } else {
            titleLabel.text = NSLocalizedString("Font List", comment: "")
        }
        self.addSubview(titleLabel)
        
        backBtn = UIButton(frame: CGRect(x: 10, y: 0, width: 40, height: 50))
        backBtn.autoresizingMask = .flexibleHeight
        
        if fontNameArr == nil {
            fontNameArr = ["FontName1", "fontName2", "fontName3"]
        }
        
        backBtn.setImage(UIImage(named: "CPDFAnnotationBarImageUndo", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        backBtn.addTarget(self, action: #selector(buttonItemClicked_back(_:)), for: .touchUpInside)
        self.addSubview(backBtn)
       
        if mTableView == nil {
            mTableView = UITableView(frame: CGRect(x: 0, y: titleLabel.frame.maxY, width: self.frame.size.width, height: self.frame.size.height - titleLabel.frame.size.height))
            if(mTableView != nil) {
                self.addSubview(mTableView!)
            }
            mTableView?.delegate = self
            mTableView?.dataSource = self
            mTableView?.reloadData()
        }
        if(fontNameArr?.count ?? 0 > 0) {
            var fontIndex = 0
            for i in 0..<(fontNameArr?.count ?? 0) {
                let h = fontNameArr![i]
                if self.selectedFontName == h {
                    fontIndex = i
                    break
                }
            }
            let indexPath = IndexPath(row: fontIndex, section: 0)
            
            mTableView?.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mTableView?.frame = CGRect(x: 0, y: titleLabel.frame.maxY, width: self.frame.size.width, height: self.frame.size.height - titleLabel.frame.size.height)

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
        
        let cellFontName = fontNameArr?[indexPath.row] ?? ""
        var familyName:String?
        var styleName:String?

        if(isFontStyle) {
            if(fontStyle == cellFontName) {
                recordRow = indexPath.row
                current = indexPath
                cell?.accessoryType = .checkmark
            } else {
                cell?.accessoryType = .none
            }
            styleName = fontStyle
            familyName = fontName
        } else {
            if(self.fontName == cellFontName) {
                recordRow = indexPath.row
                current = indexPath
                cell?.accessoryType = .checkmark
            } else {
                cell?.accessoryType = .none
            }
            let datasArray:[String] = CPDFFont.fontNames(forFamilyName: fontName)
            styleName = datasArray.first ?? ""
            familyName = cellFontName
        }
        
        let cFont = CPDFFont(familyName: familyName ?? "Helvetica", fontStyle: styleName ?? "")
                        
        let cellFont = UIFont.init(name: CPDFFont.convertAppleFont(cFont) ?? "Helvetica", size: 15.0)

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
        if(isFontStyle) {
            fontStyle = selectedFontName
        } else {
            fontName = selectedFontName
        }
        
        buttonItemClicked_back(backBtn)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
}

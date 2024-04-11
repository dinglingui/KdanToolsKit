//
//  CPDFFontStyleTableView.swift
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

@objc protocol CPDFFontStyleTableViewDelegate: AnyObject {
    @objc optional func fontStyleTableView(_ fontStyleTableView: CPDFFontStyleTableView, fontName: String,isFontStyle:Bool)
    
}

class CPDFFontStyleTableView: UIView, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: CPDFFontStyleTableViewDelegate?

    var backBtn:UIButton?
    var titleLabel:UILabel?
    var tableView:UITableView?
    var colorSlider:UIView?
    var headerView:UIView?
    var datasArray: [String] = []
    var isFontStyle = false
    var familyName:String = "Helvetica"
    var styleName:String = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        datasArray = CPDFFont.familyNames
        configSubView()
    }
    
    init(frame: CGRect,familyNames:String,styleName:String,isFontStyle:Bool) {
        super.init(frame: frame)
        self.isFontStyle = isFontStyle
        familyName = familyNames
        self.styleName = styleName
        if(isFontStyle) {
            datasArray = CPDFFont.fontNames(forFamilyName: familyNames)
            if(datasArray.count < 1) {
                datasArray.append("Regular")
            }
        } else {
            datasArray = CPDFFont.familyNames
        }
        
        if self.styleName.count < 1 {
            self.styleName = "Regular"
        }
        
        configSubView()
        
        if isFontStyle == false && datasArray.contains(familyNames) {
            guard let index = datasArray.firstIndex(of: familyNames) else { return }
            
            let indexPath = IndexPath(row: index, section: 0)
            tableView?.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
   
    func configSubView () {
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: 50))
        headerView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        headerView?.layer.borderWidth = 1.0
        headerView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        addSubview(headerView!)
        
        titleLabel = UILabel(frame: CGRect(x: (frame.size.width - 120)/2, y: 0, width: 120, height: 50))
        titleLabel?.text = NSLocalizedString("Font Style", comment: "")
        if(isFontStyle) {
            titleLabel?.text = NSLocalizedString("Font Style", comment: "")
        } else {
            titleLabel?.text = NSLocalizedString("Font List", comment: "")
        }
        titleLabel?.textAlignment = .center
        headerView?.addSubview(titleLabel!)
        
        backBtn = UIButton(frame: CGRect(x: 10, y: 0, width: 40, height: 50))
        backBtn?.autoresizingMask = .flexibleHeight
        backBtn?.setImage(UIImage(named: "CPFFormBack", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        backBtn?.addTarget(self, action: #selector(buttonItemClicked_back(_:)), for: .touchUpInside)
        headerView?.addSubview(backBtn!)
        
        tableView = UITableView(frame: CGRect(x: 0, y: 50, width: bounds.size.width, height: bounds.size.height), style: .plain)
        tableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
        addSubview(tableView!)
        
        backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Action
    @objc func buttonItemClicked_back(_ button: UIButton) {
        if self.superview != nil {
            self.removeFromSuperview()
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fontName") ?? UITableViewCell(style: .default, reuseIdentifier: "fontName")
        let fontName = datasArray[indexPath.row]

        if self.isFontStyle {
          
            let cFont = CPDFFont(familyName: familyName, fontStyle: fontName )
            var font = UIFont.init(name: CPDFFont.convertAppleFont(cFont) ?? "Helvetica", size: 16.0)

            if font == nil {
                font = UIFont(name: "Helvetica-Oblique", size: 16.0)
            }
            
            if(styleName == fontName) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }

            cell.textLabel?.font = font
        } else {
            
            let cFont = CPDFFont(familyName: fontName, fontStyle: "" )
            var font = UIFont.init(name: CPDFFont.convertAppleFont(cFont) ?? "Helvetica", size: 16.0)

            if font == nil {
                font = UIFont(name: "Helvetica-Oblique", size: 16.0)
            }
            
            if(familyName == fontName) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }

            cell.textLabel?.font = font
        }
        cell.textLabel?.text = fontName
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.fontStyleTableView?(self, fontName: datasArray[indexPath.row],isFontStyle: isFontStyle)
        
        if self.superview != nil {
            self.removeFromSuperview()
        }

    }

}

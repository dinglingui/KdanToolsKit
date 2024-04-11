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

@objc protocol CPDFFontStyleTableViewDelegate: AnyObject {
   @objc optional func fontStyleTableView(_ fontStyleTableView: CPDFFontStyleTableView, fontName: String)
}

class CPDFFontStyleTableView: UIView, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: CPDFFontStyleTableViewDelegate?

    var backBtn:UIButton?
    var titleLabel:UILabel?
    var tableView:UITableView?
    var colorSlider:UIView?
    var headerView:UIView?
    
    private lazy var datasArray: [String]  = {
        return [
            "Helvetica",
            "Courier",
            "Times-Roman",
        ]
    } ()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: 50))
        headerView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        headerView?.layer.borderWidth = 1.0
        headerView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        addSubview(headerView!)
        
        titleLabel = UILabel(frame: CGRect(x: (frame.size.width - 120)/2, y: 0, width: 120, height: 50))
        titleLabel?.text = NSLocalizedString("Font Style", comment: "")
        titleLabel?.autoresizingMask = .flexibleHeight
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
        
        cell.textLabel?.text = datasArray[indexPath.row]
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.fontStyleTableView?(self, fontName: self.datasArray[indexPath.row])
    }

}

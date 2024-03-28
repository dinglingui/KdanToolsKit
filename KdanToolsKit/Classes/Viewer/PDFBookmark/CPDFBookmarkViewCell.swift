//
//  CPDFBookmarkViewCell.swift
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

class CPDFBookmarkViewCell: UITableViewCell {
    
    var titleLabel: UILabel?
    
    var pageIndexLabel: UILabel?
    
    var moreButton: UIButton?
    
    var deleteButton: UIButton?
    
    var editButton: UIButton?
    
    private var bottomView: UIView?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel = UILabel(frame: CGRect(x: 15, y: 5, width: self.bounds.size.width - 110, height: self.bounds.size.height - 10))
        titleLabel!.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        pageIndexLabel = UILabel(frame: CGRect(x: self.bounds.size.width - 100, y: 5, width: 85, height: self.bounds.size.height - 10))
        pageIndexLabel!.textAlignment = .right
        pageIndexLabel!.autoresizingMask = [.flexibleLeftMargin, .flexibleHeight]

        bottomView = UIView(frame: CGRect(x: 0, y: self.bounds.size.height - 1, width: self.bounds.size.width, height: 1))
        bottomView!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        bottomView!.autoresizingMask = .flexibleWidth

        self.contentView.addSubview(titleLabel!)
        self.contentView.addSubview(pageIndexLabel!)
        self.contentView.addSubview(bottomView!)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Initialization code
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
    }
    
    // MARK: - Action

    @objc func buttonItemClicked_edit(sender: Any) {
        if let tableView = getTableView() {
            if let indexPath = tableView.indexPath(for: self) {
                tableView.setEditing(true, animated: true)
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
            }
        }
    }

    func getTableView() -> UITableView? {
        var tableView = self.superview
        while !(tableView is UITableView) && tableView != nil {
            tableView = tableView?.superview
        }
        return tableView as? UITableView
    }

}

//
//  CPDFInfoViewController.swift
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

class CPDFInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var currentPath: String?
    var pdfView: CPDFView?
    
    // MARK: - Accessors
    
    private lazy var curTableView: UITableView! =  {
        let curTableView = UITableView.init(frame: CGRect.zero, style: .grouped)
        curTableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        curTableView.delegate = self
        curTableView.dataSource = self
        curTableView.separatorStyle = .singleLine
        curTableView.backgroundColor = UIColor.clear
        
        return curTableView
    } ()
    
    private var curTableArray = [[[String: Any]]]()
    private var titleLabel: UILabel!
    private var doneBtn: UIButton!
    
    // MARK: - Initializers
    
    init(pdfView: CPDFView) {
        doneBtn = UIButton(type: .system)
        
        super.init(nibName: nil, bundle: nil)
        
        self.pdfView = pdfView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 12.0, *) {
            let isDark = (self.traitCollection.userInterfaceStyle == .dark)
            if isDark {
                self.view.backgroundColor = .black
            } else {
                self.view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            }
        } else {
            self.view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        }
        
        self.titleLabel = UILabel()
        self.titleLabel.text = NSLocalizedString("Document Info", comment: "")
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleLabel.textAlignment = .center
        self.view.addSubview(self.titleLabel)
        
        self.loadDocumentInfo()
        
        self.view.addSubview(self.curTableView)
        
        self.view.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
        updatePreferredContentSize(with: self.traitCollection)
        
        self.doneBtn = UIButton(type: .system)
        self.doneBtn.autoresizingMask = .flexibleLeftMargin
        self.doneBtn.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
        self.doneBtn.addTarget(self, action: #selector(buttonItemClicked_back(_:)), for: .touchUpInside)
        self.view.addSubview(self.doneBtn)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSize(with: newCollection)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        doneBtn.frame = CGRect(x: view.frame.size.width - 60, y: 5, width: 50, height: 50)
        titleLabel.frame = CGRect(x: (view.frame.size.width - 120)/2, y: 5, width: 120, height: 50)
        curTableView.frame = CGRect(x: 0, y: 70, width: view.frame.size.width, height: view.frame.size.height - 50)
    }

    func updatePreferredContentSize(with traitCollection: UITraitCollection) {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height

        let mWidth = min(width, height)
        let mHeight = max(width, height)
        let currentDevice = UIDevice.current
        if currentDevice.userInterfaceIdiom == .pad {
            // This is an iPad
            self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? mWidth * 0.7 : mHeight * 0.7)
        } else {
            // This is an iPhone or iPod touch
            self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? mWidth * 0.9 : mHeight * 0.9)
        }
    }
    
    @objc func buttonItemClicked_back(_ button: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - private method
    
    func fileSizeStr() -> String? {
        let defaultManager = FileManager.default
        if !defaultManager.fileExists(atPath: self.currentPath!) {
            return ""
        }
        
        guard let attrib = try? defaultManager.attributesOfItem(atPath: self.currentPath!),
              let fileSize = attrib[FileAttributeKey.size] as? Float else {
            return ""
        }
        
        var size = fileSize / 1024
        var unit: String
        if size >= 1024 {
            if size < 1048576 {
                size /= 1024.0
                unit = "M"
            } else {
                size /= 1048576.0
                unit = "G"
            }
        } else {
            unit = "K"
        }
        
        return String(format: "%0.1f%@", size, unit)
    }
    
    func loadDocumentInfo() -> Void {
        let documentAttributes = self.pdfView?.document.documentAttributes
        self.currentPath = self.pdfView?.document.documentURL?.path
        var tableArray = [[[String: Any]]]()
        
        guard let documentAttributes = documentAttributes else {
            return
        }
        
        // 1.abstract
        var mArray = [[String: Any]]()
        if let currentPath = self.currentPath {
            mArray.append([kDocumentInfoTitle: NSLocalizedString("File Name:", comment: ""), kDocumentInfoValue: (currentPath as NSString).lastPathComponent ])
            mArray.append([kDocumentInfoTitle: NSLocalizedString("Size:", comment: ""), kDocumentInfoValue: self.fileSizeStr() ?? ""])
        }
        if let title = documentAttributes()![CPDFDocumentAttribute.titleAttribute] {
            mArray.append([kDocumentInfoTitle: NSLocalizedString("Title:", comment: ""), kDocumentInfoValue: title])
        }
        if let author = documentAttributes()![CPDFDocumentAttribute.authorAttribute] {
            mArray.append([kDocumentInfoTitle: NSLocalizedString("Author:", comment: ""), kDocumentInfoValue: author])
        }
        if let subject = documentAttributes()![CPDFDocumentAttribute.subjectAttribute] {
            mArray.append([kDocumentInfoTitle: NSLocalizedString("Subject:", comment: ""), kDocumentInfoValue: subject])
        }
        if let keywords = documentAttributes()![CPDFDocumentAttribute.keywordsAttribute] {
            mArray.append([kDocumentInfoTitle: NSLocalizedString("Keywords:", comment: ""), kDocumentInfoValue: keywords])
        }
        tableArray.append(mArray)
        
        mArray = [[String: Any]]()

        // 2. create
        mArray = [[String: Any]]()
        let versionString = "\(self.pdfView?.document.majorVersion ?? 0).\(self.pdfView?.document.minorVersion ?? 0)"
        mArray.append([kDocumentInfoTitle: NSLocalizedString("Version:", comment: ""), kDocumentInfoValue: versionString])

        mArray.append([kDocumentInfoTitle: NSLocalizedString("Pages:", comment: ""), kDocumentInfoValue: "\(self.pdfView?.document.pageCount ?? 0)"])

        if let creator = documentAttributes()![CPDFDocumentAttribute.creatorAttribute] {
            mArray.append([kDocumentInfoTitle: NSLocalizedString("Creator:", comment: ""), kDocumentInfoValue: creator])
        }

        if let creationDate = documentAttributes()![CPDFDocumentAttribute.creationDateAttribute] as? String {
            var mString = ""
            if creationDate.count >= 16 {
                let start = creationDate.index(creationDate.startIndex, offsetBy: 2)
                let end = creationDate.index(creationDate.startIndex, offsetBy: 4)
                mString.append(String(creationDate[start..<end]))
                
                let range = creationDate.index(start, offsetBy: 2) ..< creationDate.index(start, offsetBy: 4)
                mString.append("\(creationDate[range])")
                
                let range1 = creationDate.index(start, offsetBy: 4) ..< creationDate.index(start, offsetBy: 6)
                mString.append("-\(creationDate[range1])")
                
                let range2 = creationDate.index(start, offsetBy: 6) ..< creationDate.index(start, offsetBy: 8)
                mString.append("-\(creationDate[range2])")
                
                let range3 = creationDate.index(start, offsetBy: 8) ..< creationDate.index(start, offsetBy: 10)
                mString.append(" \(creationDate[range3])")
                
                let range4 = creationDate.index(start, offsetBy: 10) ..< creationDate.index(start, offsetBy: 12)
                mString.append(":\(creationDate[range4])")
                
                let range5 = creationDate.index(start, offsetBy: 12) ..< creationDate.index(start, offsetBy: 14)
                mString.append(":\(creationDate[range5])")
                
                mArray.append([
                    kDocumentInfoTitle: NSLocalizedString("Creation Date:", comment: ""),
                    kDocumentInfoValue: mString
                ])
            }
        }

        if let creationDate = documentAttributes()![CPDFDocumentAttribute.modificationDateAttribute] as? String {
            var mString = ""
            if creationDate.count >= 16 {
                let start = creationDate.index(creationDate.startIndex, offsetBy: 2)
                let end = creationDate.index(creationDate.startIndex, offsetBy: 4)
                mString.append(String(creationDate[start..<end]))
                
                let range = creationDate.index(start, offsetBy: 2) ..< creationDate.index(start, offsetBy: 4)
                mString.append("\(creationDate[range])")
                
                let range1 = creationDate.index(start, offsetBy: 4) ..< creationDate.index(start, offsetBy: 6)
                mString.append("-\(creationDate[range1])")
                
                let range2 = creationDate.index(start, offsetBy: 6) ..< creationDate.index(start, offsetBy: 8)
                mString.append("-\(creationDate[range2])")
                
                let range3 = creationDate.index(start, offsetBy: 8) ..< creationDate.index(start, offsetBy: 10)
                mString.append(" \(creationDate[range3])")
                
                let range4 = creationDate.index(start, offsetBy: 10) ..< creationDate.index(start, offsetBy: 12)
                mString.append(":\(creationDate[range4])")
                
                let range5 = creationDate.index(start, offsetBy: 12) ..< creationDate.index(start, offsetBy: 14)
                mString.append(":\(creationDate[range5])")
                
                mArray.append([
                    kDocumentInfoTitle: NSLocalizedString("Modification Date:", comment: ""),
                    kDocumentInfoValue: mString
                ])
            }
        }

        tableArray.append(mArray)

        // 3. execute
        mArray = [[String: Any]]()

        mArray.append([kDocumentInfoTitle: NSLocalizedString("Printing:", comment: ""), kDocumentInfoValue: ((self.pdfView?.document.allowsPrinting ?? false) ? NSLocalizedString("Allowed", comment: "") : NSLocalizedString("Not Allowed", comment: ""))])

        mArray.append([kDocumentInfoTitle: NSLocalizedString("Content Copying:", comment: ""), kDocumentInfoValue: ((self.pdfView?.document.allowsCopying ?? false) ? NSLocalizedString("Allowed", comment: "") : NSLocalizedString("Not Allowed", comment: ""))])

        mArray.append([kDocumentInfoTitle: NSLocalizedString("Document Change:", comment: ""), kDocumentInfoValue: ((self.pdfView?.document.allowsDocumentChanges ?? false) ? NSLocalizedString("Allowed", comment: "") : NSLocalizedString("Not Allowed", comment: ""))])

        mArray.append([kDocumentInfoTitle: NSLocalizedString("Document Assembly:", comment: ""), kDocumentInfoValue: ((self.pdfView?.document.allowsDocumentAssembly ?? false) ? NSLocalizedString("Allowed", comment: "") : NSLocalizedString("Not Allowed", comment: ""))])

        mArray.append([kDocumentInfoTitle: NSLocalizedString("Commenting:", comment: ""), kDocumentInfoValue: ((self.pdfView?.document.allowsCommenting ?? false) ? NSLocalizedString("Allowed", comment: "") : NSLocalizedString("Not Allowed", comment: ""))])

        mArray.append([kDocumentInfoTitle: NSLocalizedString("Filling of Form Field:", comment: ""), kDocumentInfoValue: ((self.pdfView?.document.allowsFormFieldEntry ?? false) ? NSLocalizedString("Allowed", comment: "") : NSLocalizedString("Not Allowed", comment: ""))])

        tableArray.append(mArray)
        
        self.curTableArray = tableArray
    }
    
    // MARK: - tableview delegate & datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.curTableArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String = ""
        switch section {
        case 0:
            title = NSLocalizedString("Abstract", comment: "")
        case 1:
            title = NSLocalizedString("Create Information:", comment: "")
        case 2:
            title = NSLocalizedString("Access Permissions:", comment: "")
        default:
            title = ""
        }
        
        return title
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel.init(frame: CGRect(x: 20, y: 0, width: tableView.bounds.size.width, height: 20))
        var title: String = ""
        switch section {
        case 0:
            title = NSLocalizedString("Abstract:", comment: "")
        case 1:
            title = NSLocalizedString("Create Information:", comment: "")
        case 2:
            title = NSLocalizedString("Access Permissions:", comment: "")
        default:
            title = ""
        }
        
        title = "     \(title)"
        headerLabel.text = title
        headerLabel.font = UIFont.boldSystemFont(ofSize: 22)
        
        return headerLabel
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array = self.curTableArray[section]
        return (array as AnyObject).count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MyIdentifier") as? CPDFInfoTableCell
        if (cell == nil) {
            cell = CPDFInfoTableCell(style: .subtitle, reuseIdentifier: "MyIdentifier")
        }
        
        let array = curTableArray[indexPath.section]

        let dic = array[indexPath.row]
        cell?.setDataDictionary(dic)

        cell!.selectionStyle = .none
        
        return cell!
    }
    
}

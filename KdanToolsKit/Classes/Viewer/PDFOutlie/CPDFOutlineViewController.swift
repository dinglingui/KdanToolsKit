//
//  CPDFOutlineViewController.swift
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

let kPDFOutlineItemMaxDeep = 10
let kShowFlag = (1 << kPDFOutlineItemMaxDeep) - 1

@objc protocol CPDFOutlineViewControllerDelegate: AnyObject {
    @objc optional func outlineViewController(_ outlineViewController: CPDFOutlineViewController, pageIndex: Int)
}

class CPDFOutlineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CPDFOutlineViewCellDelegate  {
    
    weak var delegate: CPDFOutlineViewControllerDelegate?
    var pdfView: CPDFListView?
    
    private var tableView: UITableView?
    private var outlines: [CPDFOutlineModel] = []
    private var noDataLabel: UILabel?
    private var loadOutlines: [CPDFOutlineModel] = []
    
    // MARK: - Initializers
    
    init(pdfView: CPDFListView) {
        super.init(nibName: nil, bundle: nil)

        self.pdfView = pdfView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK - UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame:view.bounds, style: .plain)
        tableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
       
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 80
        tableView?.tableFooterView = UIView()
        tableView?.separatorStyle = .none
        tableView?.delegate = self
        tableView?.dataSource = self

        noDataLabel = UILabel()
        noDataLabel?.textColor = .gray
        noDataLabel?.text = NSLocalizedString("No Outlines", comment: "")
        noDataLabel?.sizeToFit()
        noDataLabel?.center = CGPoint(x: view.bounds.size.width/2.0, y: view.bounds.size.height/2.0)
        noDataLabel?.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]

        
        let outlineRoot = self.pdfView?.document.outlineRoot()
        self.loadOutline(outlineRoot, Level: 0, forOutlines: [])
        
        if(tableView != nil) {
            self.view.addSubview(tableView!)
        }
        if(noDataLabel != nil) {
            self.view.addSubview(noDataLabel!)
        }
    }
    
    func loadOutline(_ outline:CPDFOutline?, Level level:NSInteger, forOutlines outlines:[CPDFOutlineModel]) -> (Void) {
        if(outline != nil) {
            for i in 0..<outline!.numberOfChildren {
                let data = outline!.child(at: i)!
                var destination = data.destination
                if destination == nil {
                    let action = data.action
                    if let goToAction = action as? CPDFGoToAction {
                        destination = goToAction.destination()
                    }
                    
                }
                let model = CPDFOutlineModel()
                model.level = level
                model.hide = (1 << (kPDFOutlineItemMaxDeep - level)) - 1
                model.title = data.label
                model.count = Int(data.numberOfChildren)
                model.number = destination?.pageIndex ?? 0
                model.isShow = false
                self.loadOutlines = outlines
                self.loadOutlines.append(model)
                self.outlines.append(model)
                
                loadOutline(data, Level: level+1, forOutlines: self.loadOutlines)
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var n = 0
        for outline in self.outlines {
            if outline.hide == kShowFlag {
                n += 1
            }
        }
        self.noDataLabel?.isHidden = n > 0
        return n
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var t = -1
        var outline: CPDFOutlineModel?
        for model in self.outlines
        {
            if model.hide == kShowFlag {
                t += 1
            }
            if t == indexPath.row {
                outline = model
                break
            }
        }

    var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CPDFOutlineViewCell
    if cell == nil {
        cell = CPDFOutlineViewCell(style: .subtitle, reuseIdentifier: "cell")
    }
    cell?.outline = outline!
    cell?.delegate = self
    return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 32
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let cell = tableView.cellForRow(at: indexPath) as? CPDFOutlineViewCell
        let outline = cell?.outline
        if(outline != nil) {
            self.delegate?.outlineViewController?(self, pageIndex: outline!.number)
        }
    }
    
    // MARK: - Action
    
    func buttonItemClickedArrow(_ cell: CPDFOutlineViewCell) {
        guard let indexPath = self.tableView?.indexPath(for: cell) else {
            return
            
        }

        var t = -1, p = 0
        var outline: CPDFOutlineModel?
        for model in self.outlines {
            if model.hide == kShowFlag {
                t += 1
            }
            if t == indexPath.row {
                outline = model
                break
            }
            p += 1
        }

        guard let currentOutline = outline, currentOutline.level != kPDFOutlineItemMaxDeep-1 else {
            return
        }

        p += 1
        if p == self.outlines.count {
            return
        }
        var nextOutline = self.outlines[p]
        if nextOutline.level > currentOutline.level {
            if nextOutline.hide == kShowFlag {
                (self.tableView?.cellForRow(at: indexPath) as? CPDFOutlineViewCell)?.isShow = false
                var array = [IndexPath]()
                while true {
                    if nextOutline.hide == kShowFlag {
                        t += 1
                        let path = IndexPath(row: t, section: 0)
                        array.append(path)
                    }
                    nextOutline.hide ^= 1 << (kPDFOutlineItemMaxDeep - currentOutline.level - 1)
                    p += 1
                    if p == self.outlines.count {
                        break
                    }
                    nextOutline = self.outlines[p]
                    if nextOutline.level <= currentOutline.level {
                        break
                    }
                }
                self.tableView?.deleteRows(at: array, with: .fade)
            } else {
                (self.tableView?.cellForRow(at: indexPath) as? CPDFOutlineViewCell)?.isShow = true
                var array = [IndexPath]()
                while true {
                    nextOutline.hide ^= 1 << (kPDFOutlineItemMaxDeep - currentOutline.level - 1)
                    if nextOutline.hide == kShowFlag {
                        t += 1
                        let path = IndexPath(row: t, section: 0)
                        array.append(path)
                    }
                    p += 1
                    if p == self.outlines.count {
                        break
                    }
                    nextOutline = self.outlines[p]
                    if nextOutline.level <= currentOutline.level {
                        break
                    }
                }
                self.tableView?.insertRows(at: array, with: .fade)
            }
        }
    }
}

//
//  CPDFAnnotationViewController.swift
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

protocol CPDFAnnotationViewControllerDelegate: AnyObject {
    func annotationViewController(_ annotationViewController: CPDFAnnotationViewController, jumptoPage pageIndex: Int, selectAnnot annot: CPDFAnnotation)
    
}

class CPDFAnnotationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: CPDFAnnotationViewControllerDelegate?
    var pdfView:CPDFView?
    var tableView:UITableView?
    var sequenceList:[NSNumber] = []
    var annotsDict:NSMutableDictionary?
    var totalAnnotlistDict:NSMutableDictionary?
    var selectIndexArray:[Any] = []
    var emptyzLabel:UILabel?
    var zactivityView:CActivityIndicatorView?
    var stopLoadAnnots:Bool = false
    var sampelsLabel: UILabel?
    
    init(pdfView: CPDFView) {
        super.init(nibName: nil, bundle: nil)
        self.pdfView = pdfView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorStyle = .none
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 60
        tableView?.tableFooterView = UIView()
        if tableView != nil {
            view.addSubview(tableView!)
        }
        
        sampelsLabel = UILabel(frame: CGRect(x: 15, y: 0, width: self.view.frame.size.width - 30, height: 44))
        sampelsLabel?.autoresizingMask = [.flexibleWidth]
        sampelsLabel?.lineBreakMode = .byTruncatingTail
        sampelsLabel?.numberOfLines = 3
        sampelsLabel?.font = UIFont.systemFont(ofSize: 15.0)
        
        self.emptyLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadAndRefreshAnnots()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.stopLoadAnnots = false
        self.activityView.startAnimating()
        
    }
    
    var emptyLabel: UILabel {
        if emptyzLabel == nil {
            emptyzLabel = UILabel()
            if #available(iOS 13.0, *) {
                emptyzLabel?.textColor = UIColor.label
            } else {
                emptyzLabel?.textColor = UIColor.black
            }
            emptyzLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
            emptyzLabel?.text = NSLocalizedString("No annotations", comment: "")
            emptyzLabel?.textColor = UIColor.gray
            emptyzLabel?.sizeToFit()
            if emptyzLabel != nil {
                view.addSubview(emptyzLabel!)
                view.bringSubviewToFront(emptyzLabel!)
            }
            emptyzLabel?.center = CGPoint(x: view.bounds.size.width/2.0, y: view.bounds.size.height/2.0)
            emptyzLabel?.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        }
        return emptyzLabel!
    }
    
    var activityView: CActivityIndicatorView {
        if zactivityView == nil {
            zactivityView = CActivityIndicatorView(style: .gray)
            zactivityView?.center = view.center
            zactivityView?.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        }
        return zactivityView!
    }
    
    func loadAndRefreshAnnots() {
        stopLoadAnnots = false
        totalAnnotlistDict = NSMutableDictionary()
        annotsDict = NSMutableDictionary()
        sequenceList = [NSNumber]()

        activityView.startAnimating()
        
        DispatchQueue.global(qos: .default).async {
            let pageCount = self.pdfView?.document.pageCount
            var currentPage = 0
            for i in 0..<(pageCount ?? 0) {
                if self.stopLoadAnnots {
                    break
                }
                
                currentPage = Int(i)
                let page = self.pdfView?.document.page(at: i)
                let annotations:[CPDFAnnotation] = page?.annotations ?? []
                var annotsInpage = [CPDFAnnotation]()
                for annotation in annotations {
                    if !(annotation is CPDFWidgetAnnotation) && !(annotation is CPDFLinkAnnotation) && !(annotation is CPDFSignatureAnnotation) {
                        annotsInpage.append(annotation)
                    }
                }
                if annotsInpage.count > 0 {
                    let sortArray = annotsInpage
                    if sortArray.count > 0 {
                        self.totalAnnotlistDict?.setObject(NSMutableArray(array: sortArray), forKey: NSNumber(value: i))
                        self.sequenceList.append(NSNumber(value: i))
                    }
                }
                
                if currentPage == (pageCount ?? 0) - 1 {
                    self.stopLoadAnnots = true
                }
            }
            self.totalAnnotlistDict?.enumerateKeysAndObjects({ (key, obj, stop) in
                self.annotsDict?.setObject(NSMutableArray(array: obj as? [Any] ?? []), forKey: (key as? NSCopying)!)
            })
            DispatchQueue.main.async {
                self.activityView.stopAnimating()
                self.tableView?.reloadData()
            }
        }
        
    }
    
    func numberOfLinesForCell(_ string: String) -> Int {
        sampelsLabel?.text = string
        sampelsLabel?.sizeToFit()
        return sampelsLabel?.numberOfLines ?? 0
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = self.sequenceList.count
        if(count < 1) {
            self.emptyLabel.isHidden = false
            self.tableView?.isHidden = true
        } else {
            self.emptyLabel.isHidden = true
            self.tableView?.isHidden = false
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.sequenceList.count == section {
            return 1
        }
        
        if section >= self.sequenceList.count {
            return 0
        }
        
        let key = self.sequenceList[section]
        let val = self.annotsDict?[key] as? [CPDFAnnotation]
        
        return val?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CPDFAnnotationListCell
        if cell == nil {
            cell = CPDFAnnotationListCell(style: .default, reuseIdentifier: "cell")
        }
        cell?.selectionStyle = .none
        
        if self.sequenceList.count == indexPath.section {
            // Handle the case when section count matches sequenceList count
        } else {
            let key = self.sequenceList[indexPath.section]
            let val = self.annotsDict?[key] as? [CPDFAnnotation]
            let annot = val?[indexPath.row]
            
            cell?.updateCell(with: annot)
        }
        
        return cell!
        
    }
    
    // MARK: - UITableViewDelegate
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.sequenceList.count == section {
            return 0
        }
        
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.sequenceList.count == indexPath.section {
            return 44
        }
        
        let key = self.sequenceList[indexPath.section]
        let val = self.annotsDict?[key] as? [CPDFAnnotation]
        
        let annot = val?[indexPath.row]
        if let markupAnnotation = annot as? CPDFMarkupAnnotation {
            let text = markupAnnotation.markupText()
            let contextArray = text?.components(separatedBy: "\n")
            
            let lines = numberOfLinesForCell(text ?? "")
            
            let cellLines = lines > (contextArray?.count ?? 0) ? lines : contextArray?.count
            
            switch cellLines {
            case 0:
                return 44
            case 1:
                return 44 + 25
            case 2:
                return 44 + 45
            case 3:
                return 44 + 60
            default:
                return 44 + 60
            }
        } else if let contents = annot?.contents, !contents.isEmpty {
            let contextArray = contents.components(separatedBy: "\n")
            switch contextArray.count {
            case 1:
                return 44 + 25
            case 2:
                return 44 + 40
            case 3:
                return 44 + 60
            default:
                return 44 + 60
            }
        } else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.sequenceList.count == section {
            return nil
        }

        if section >= self.sequenceList.count {
            return nil
        }

        let key = self.sequenceList[section]
        let val = self.annotsDict?[key] as? [CPDFAnnotation]

        let headerView = CAnnotListHeaderInSection(reuseIdentifier: "header")
        headerView.frame = CGRect(x: 0, y: 0, width: self.tableView?.frame.size.width ?? 0, height: 44.0)
        headerView.setPageNumber(number: key.intValue + 1)
        headerView.setAnnotsCount(count: val?.count ?? 0)

        return headerView

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.sequenceList.count == indexPath.section {
            return
        }

        let key = self.sequenceList[indexPath.section]
        let val = self.annotsDict?[key] as? [CPDFAnnotation]
        guard let annot = val?[indexPath.row] else { return }

        self.delegate?.annotationViewController(self, jumptoPage: key.intValue, selectAnnot: annot)
    }
    
}

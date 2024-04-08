//
//  CPDFSigntureListViewController.swift
//  PDFViewer-Swift
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

@objc protocol CPDFSigntureListViewControllerDelegate: AnyObject {
    @objc optional func signtureListViewControllerUpdate(_ signtureListViewController: CPDFSigntureListViewController)
}

class CPDFSigntureModel {
    var certificate: CPDFSignatureCertificate?
    var level: Int = 0
    var hide: Int = 0
    var count: Int = 0
    var isShow: Bool = false
}

class CPDFSigntureListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CPDFSigntureDetailsViewControllerDelegate {
    weak var delegate: CPDFSigntureListViewControllerDelegate?
    var signer: CPDFSigner?
    var PDFListView: CPDFListView?
    
    private let kMaxDeep = 10
    private var kShowFlag: Int {
        return (1 << kMaxDeep) - 1
    }
    
    private var tableView: UITableView?
    private var models: [CPDFSigntureModel] = []
    
    // MARK: - Viewcontroller Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Signature List", comment: "")
        
        let backImage = UIImage(named: "CPDFViewImageBack", in: Bundle(for: CPDFSigntureDetailsViewController.self), compatibleWith: nil)
        let backItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(buttonItemClicked_back(_:)))
        navigationItem.leftBarButtonItems = [backItem]
        
        view.backgroundColor = .white
        tableView = UITableView(frame: view.bounds)
        tableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.estimatedRowHeight = 60
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.register(UINib(nibName: "CPDFSigntureCells", bundle:Bundle(for: CPDFSigntureListViewController.self)), forCellReuseIdentifier: "cell")
//        tableView?.register(CPDFSigntureDetailsCell.self, forCellReuseIdentifier: "cell")
        
        if tableView != nil {
            view.addSubview(tableView!)
        }
        
        if let signer = self.signer {
            models = signer.certificates.enumerated().map { (index, cert) in
                let model = CPDFSigntureModel()
                model.certificate = cert
                model.level = index
                model.hide = kShowFlag
                model.isShow = true
                model.count = signer.certificates.count - index - 1
                return model
            }
        }
        
        tableView?.reloadData()
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_back(_ button: UIButton) {
        // Handle the back button click
        navigationController?.dismiss(animated: true)
    }
    
    // MARK: - CPDFSigntureDetailsViewControllerDelegate
    
    func signtureDetailsViewControllerTrust(_ signtureDetailsViewController: CPDFSigntureDetailsViewController) {
        delegate?.signtureListViewControllerUpdate?(self)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var n = 0
        for model in models {
            if model.hide == kShowFlag {
                n += 1
            }
        }
        return n
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CPDFSigntureCells
        
        var t = -1
        var model: CPDFSigntureModel?
        for m in models {
            if m.hide == kShowFlag {
                t += 1
            }
            if t == indexPath.row {
                model = m
                break
            }
        }
        
        if let cert = model?.certificate {
            cell.titleLabel?.text = cert.subject
        }
        
        cell.indentationLevel = model?.level ?? 0
        cell.model = model
        let weakself = self
        cell.callback = { [weak weakself, weak cell] in
            weakself?.outLineCellArrowButtonTapped(cell!)
        }
        
        if let count = model?.count, count > 0 {
            cell.arrowButton?.isHidden = false
            cell.isShow = model?.isShow ?? false
        } else {
            cell.arrowButton?.isHidden = true
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) as? CPDFSigntureCells {
            let vc = CPDFSigntureDetailsViewController()
            vc.delegate = self
            vc.certificate = cell.model?.certificate
            let nav = CNavigationController(rootViewController: vc)
            present(nav, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: - Private Methods
    
    func outLineCellArrowButtonTapped(_ cell: CPDFSigntureCells) {
        if let indexPath = tableView?.indexPath(for: cell) {
            var t = -1
            var p = 0
            var m: CPDFSigntureModel?
            for model in models {
                if model.hide == kShowFlag {
                    t += 1
                }
                if t == indexPath.row {
                    m = model
                    break
                }
                p += 1
            }
            
            if m?.level == kMaxDeep - 1 {
                return
            }
            
            p += 1
            if p == models.count {
                return
            }
            var nxtModel: CPDFSigntureModel = models[p]
            if nxtModel.level > m?.level ?? 0 {
                if nxtModel.hide == kShowFlag {
                    if let cell = tableView?.cellForRow(at: indexPath) as? CPDFSigntureCells {
                        cell.isShow = false
                    }
                    var arr = [IndexPath]()
                    while true {
                        if nxtModel.hide == kShowFlag {
                            t += 1
                            let path = IndexPath(row: t, section: 0)
                            arr.append(path)
                        }
                        nxtModel.hide ^= 1 << (kMaxDeep - m!.level - 1)
                        p += 1
                        if p == models.count {
                            break
                        }
                        let nextModel = models[p]
                        if nextModel.level <= m?.level ?? 0 {
                            break
                        }
                        nxtModel = nextModel
                    }
                    tableView?.deleteRows(at: arr, with: .fade)
                } else {
                    if let cell = tableView?.cellForRow(at: indexPath) as? CPDFSigntureCells {
                        cell.isShow = true
                    }
                    var arr = [IndexPath]()
                    while true {
                        nxtModel.hide ^= 1 << (kMaxDeep - m!.level - 1)
                        
                        if nxtModel.hide == kShowFlag {
                            t += 1
                            let path = IndexPath(row: t, section: 0)
                            arr.append(path)
                        }
                        
                        p += 1
                        if p == models.count {
                            break
                        }
                        let nextModel = models[p]
                        if nextModel.level <= m?.level ?? 0 {
                            break
                        }
                        nxtModel = nextModel
                    }
                    tableView?.insertRows(at: arr, with: .fade)
                }
            }
            
        }
    }
    
}

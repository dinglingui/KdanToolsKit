//
//  CPDFBookmarkViewController.swift
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

@objc protocol CPDFBookmarkViewControllerDelegate: AnyObject {
    @objc optional func boomarkViewController(_ boomarkViewController: CPDFBookmarkViewController,pageIndex:NSInteger)
}

class CPDFBookmarkViewController: UIViewController {
    weak var delegate: CPDFBookmarkViewControllerDelegate?
    
    var pdfView:CPDFView?
    var bookmarks:[CPDFBookmark]?
    var tableView: UITableView?
    var noDataLabel: UILabel?
    var addBookmarkBtn: UIButton?
    
    // MARK: - Initializers
    
    init(pdfView: CPDFView) {
        super.init(nibName: nil, bundle: nil)
        self.pdfView = pdfView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 60
        tableView?.tableFooterView = UIView()
        tableView?.separatorStyle = .none
        if(tableView != nil) {
            view.addSubview(tableView!)
        }
        
        noDataLabel = UILabel()
        noDataLabel?.textColor = .gray
        noDataLabel?.text = NSLocalizedString("No Bookmarks", comment: "")
        noDataLabel?.sizeToFit()
        noDataLabel?.center = CGPoint(x: view.bounds.size.width/2.0, y: view.bounds.size.height/2.0)
        noDataLabel?.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        if(noDataLabel != nil) {
            view.addSubview(noDataLabel!)
        }
        
        addBookmarkBtn = UIButton(frame: CGRect(x: view.frame.size.width - 20 - 50, y: view.frame.size.height - 50 - 50, width: 50, height: 50))
        if #available(iOS 11.0, *) {
            addBookmarkBtn?.frame = CGRect(x: view.frame.size.width - view.safeAreaInsets.right - 50 - 20, y: view.frame.size.height - view.safeAreaInsets.bottom - 50, width: 50, height: 50)
        }
        addBookmarkBtn?.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        addBookmarkBtn?.setImage(UIImage(named: "CPDFBookmarkImageAdd", in: Bundle(for: Self.self), compatibleWith: nil), for: .normal)
        addBookmarkBtn?.addTarget(self, action: #selector(buttonItemClicked_add(_:)), for: .touchUpInside)
        if(addBookmarkBtn != nil) {
            self.view.addSubview(addBookmarkBtn!)
        }
        
        self.createGestureRecognizer()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.reloadData()
    }
    
    // MARK: - Private Methods
    
    func reloadData() {
        if(pdfView != nil) {
            if let bookmarks = pdfView!.document?.bookmarks(), bookmarks.count > 0 {
                self.bookmarks = bookmarks
                tableView?.isHidden = false
                noDataLabel?.isHidden = true
            } else {
                tableView?.isHidden = true
                noDataLabel?.isHidden = false
            }
            tableView?.reloadData()
        }
    }
    
    func createGestureRecognizer() {
        addBookmarkBtn?.isUserInteractionEnabled = true
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panaddBookmarkBtn(_:)))
        addBookmarkBtn?.addGestureRecognizer(panRecognizer)
    }
    
    
    // MARK: - Action
    @objc func panaddBookmarkBtn(_ gestureRecognizer: UIPanGestureRecognizer) {
        let point = gestureRecognizer.translation(in: view)
        let newX = (addBookmarkBtn?.center.x ?? 0) + point.x
        let newY = (addBookmarkBtn?.center.y ?? 0) + point.y
        let newPoint = CGPoint(x: newX, y: newY)
        if view.frame.contains(newPoint) {
            addBookmarkBtn?.center = newPoint
        }
        gestureRecognizer.setTranslation(.zero, in: view)
    }
    
    @objc func buttonItemClicked_add(_ sender: Any) {
        if pdfView!.document?.bookmark(forPageIndex: UInt(pdfView!.currentPageIndex)) == nil {
            let alert = UIAlertController(title:NSLocalizedString("Add Bookmarks", comment: ""), message: nil, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = NSLocalizedString("Bookmark Title", comment: "")
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
            
            let addAction = UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .default) { [weak self] action in
                if let title = alert.textFields?.first?.text, !title.isEmpty {
                    self?.pdfView!.document?.addBookmark(title, forPageIndex: UInt(self?.pdfView?.currentPageIndex ?? 0))
                    
                    if let page = self?.pdfView!.document?.page(at: UInt(self?.pdfView?.currentPageIndex ?? 0)) {
                        self?.pdfView?.setNeedsDisplayFor(page)
                    }
                    self?.reloadData()
                }
            }
            
            alert.addAction(cancelAction)
            alert.addAction(addAction)
            present(alert, animated: true, completion: nil)
        } else {
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
            
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { [weak self] action in
                guard let self = self, let pdfView = self.pdfView else { return }
                
                pdfView.document?.removeBookmark(forPageIndex: UInt(pdfView.currentPageIndex))
                if let page = pdfView.document?.page(at: UInt(pdfView.currentPageIndex)) {
                    pdfView.setNeedsDisplayFor(page)
                }
                if(self.tableView != nil) {
                    self.tableView!.setEditing(false, animated: true)
                    self.tableView!.isUserInteractionEnabled = true
                }
                self.reloadData()
            }
            
            let alert = UIAlertController(title: "", message: NSLocalizedString("Do you want to remove old mark?", comment: ""), preferredStyle: .alert)
            
            
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            
        }
    }
}

// MARK: - UITableViewDataSource

extension CPDFBookmarkViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if bookmarks?.count ?? 0 > 0 {
            noDataLabel?.isHidden = true
        } else {
            noDataLabel?.isHidden = false
        }
        return bookmarks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CPDFBookmarkViewCell
        if(cell == nil) {
            cell = CPDFBookmarkViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        
        let bookmark = bookmarks?[indexPath.row]
        cell!.pageIndexLabel?.text = "\(NSLocalizedString("Page", comment: "")) \((bookmark?.pageIndex ?? 0) + 1)"
        cell!.titleLabel?.text = bookmark?.label ?? ""
        
        return cell!
    }
}

// MARK: - UITableViewDelegate

extension CPDFBookmarkViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: NSLocalizedString("Delete",comment: "")) { (action, indexPath) in
            if let cell = tableView.cellForRow(at: indexPath) as? CPDFBookmarkViewCell {
                self.pdfView?.document.removeBookmark(forPageIndex: UInt(cell.pageIndexLabel?.text ?? "0")! - 1)
                if var bookmarks = self.bookmarks {
                    bookmarks.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.setEditing(false, animated: true)
                    tableView.isUserInteractionEnabled = true
                    self.reloadData()
                }
                
            }
            
        }
        
        let editAction = UITableViewRowAction(style: .destructive, title: NSLocalizedString("Edit",comment: "")) { (action, indexPath) in
            let alert = UIAlertController(title: NSLocalizedString("Edit Bookmark",comment: ""), message: nil, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = NSLocalizedString("Bookmark Title", comment: "")
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
            
            let addAction = UIAlertAction(title: NSLocalizedString("Create", comment: ""), style: .default) { (action) in
                if let cell = tableView.cellForRow(at: indexPath) as? CPDFBookmarkViewCell {
                    cell.titleLabel!.text = alert.textFields?.first?.text
                    self.pdfView!.document.bookmarks()[indexPath.row].label = alert.textFields?.first?.text
                }
            }
            
            alert.addAction(cancelAction)
            alert.addAction(addAction)
            
            self.present(alert, animated: true, completion: nil)
            tableView.setEditing(false, animated: true)
            tableView.isUserInteractionEnabled = true
        }
        
        deleteAction.backgroundColor = UIColor.red
        editAction.backgroundColor = UIColor.blue
        return [deleteAction, editAction]
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
            let bookmark = self.bookmarks?[indexPath.row]
            self.pdfView?.document.removeBookmark(forPageIndex: UInt(bookmark?.pageIndex ?? 0))
            
            let page = self.pdfView?.document.page(at: UInt(bookmark?.pageIndex ?? 0))
            self.pdfView?.setNeedsDisplayFor(page)
            
            if var bookmarks = self.bookmarks {
                bookmarks.remove(at: indexPath.row)
                self.bookmarks = bookmarks
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.tableView?.setEditing(false, animated: true)
                self.tableView?.isUserInteractionEnabled = true
                self.reloadData()
            }
            completion(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
            let alert = UIAlertController(title: NSLocalizedString("Edit Bookmark", comment: ""), message: nil, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = NSLocalizedString("Bookmark Title", comment: "")
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
            
            let addAction = UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .default) { (action) in
                if let cell = tableView.cellForRow(at: indexPath) as? CPDFBookmarkViewCell {
                    cell.titleLabel?.text = alert.textFields?.first?.text
                    self.pdfView?.document.bookmarks()[indexPath.row].label = alert.textFields?.first?.text
                }
            }
            
            alert.addAction(cancelAction)
            alert.addAction(addAction)
            
            self.present(alert, animated: true, completion: nil)
            tableView.setEditing(false, animated: true)
            tableView.isUserInteractionEnabled = true
            completion(true)
        }
        
        deleteAction.image = UIImage(named: "CPDFBookmarkImageDelete", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        deleteAction.backgroundColor = UIColor.red
        editAction.image = UIImage(named: "CPDFBookmarkImageEraser", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bookmark = self.bookmarks?[indexPath.row]
        self.delegate?.boomarkViewController?(self, pageIndex: bookmark?.pageIndex ?? 0)
    }
    
}

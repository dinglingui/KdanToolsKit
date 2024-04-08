//
//  CPDFFormListOptionVC.swift
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

@objc protocol CPDFFormListOptionControllerDelegate: AnyObject {
    @objc optional func CPDFFormListOptionVC(listOptionVC: CPDFFormListOptionVC, pageIndex: Int)
}

class CPDFFormListOptionVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: CPDFFormListOptionControllerDelegate?
    var pdfView:CPDFView?
    var annotation:CPDFAnnotation?
    
    var options: [CPDFChoiceWidgetItem] = []
    var tableView: UITableView?
    var noDataLabel: UILabel?
    var addOptionsBtn: UIButton?
    var backBtn: UIButton?
    var titleLabel: UILabel?
    var splitView: UIView?
    
    
    init(pdfView: CPDFView, annotation: CPDFAnnotation) {
        self.pdfView = pdfView
        self.annotation = annotation
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
        updatePreferredContentSize(with: self.traitCollection)
        
        self.backBtn = UIButton()
        self.backBtn?.autoresizingMask = [.flexibleLeftMargin]
        self.backBtn?.setImage(UIImage(named: "CPDFAnnotationBaseImageBack", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        self.backBtn?.addTarget(self, action: #selector(buttonItemClicked_back(_:)), for: .touchUpInside)
        self.view.addSubview(self.backBtn!)
        
        self.titleLabel = UILabel()
        if (self.annotation is CPDFChoiceWidgetAnnotation) {
            let widget = self.annotation as! CPDFChoiceWidgetAnnotation
            if widget.isListChoice {
                self.titleLabel?.text = NSLocalizedString("Edit List Box", comment: "")
            } else {
                self.titleLabel?.text = NSLocalizedString("Edit ComBo Box", comment: "")
            }
        }
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.textAlignment = .center
        self.view.addSubview(self.titleLabel!)
        
        self.tableView = UITableView(frame: self.view.bounds)
        self.tableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.separatorStyle = .singleLine
        self.tableView?.backgroundColor = .white
        if(tableView != nil) {
            self.view.addSubview(self.tableView!)
        }
        self.tableView?.reloadData()
        
        self.splitView = UIView()
        self.splitView?.backgroundColor = CPDFColorUtils.CTableviewCellSplitColor()
        if(splitView != nil) {
            self.view.addSubview(self.splitView!)
        }
        
        self.view.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
        self.tableView?.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
        
        if #available(iOS 11.0, *) {
            self.addOptionsBtn = UIButton(frame: CGRect(x: self.view.frame.size.width - self.view.safeAreaInsets.right - 50 - 20, y: self.view.frame.size.height - self.view.safeAreaInsets.bottom - 70, width: 50, height: 50))
        } else {
            self.addOptionsBtn = UIButton(frame: CGRect(x: self.view.frame.size.width - 20 - 50, y: self.view.frame.size.height - 50 - 50, width: 50, height: 50))
        }
        self.addOptionsBtn?.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        self.addOptionsBtn?.setImage(UIImage(named: "CPDFBookmarkImageAdd", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        self.addOptionsBtn?.addTarget(self, action: #selector(buttonItemClicked_add(_:)), for: .touchUpInside)
        if(addOptionsBtn != nil) {
            self.view.addSubview(self.addOptionsBtn!)
        }
        
        createGestureRecognizer()
        
        updatePreferredContentSize(with: self.traitCollection)
        
        self.noDataLabel = UILabel()
        self.noDataLabel?.textColor = .lightGray
        self.noDataLabel?.text = NSLocalizedString("No Data", comment: "")
        self.noDataLabel?.sizeToFit()
        self.noDataLabel?.center = CGPoint(x: self.view.bounds.size.width/2.0, y: self.view.bounds.size.height/2.0)
        self.noDataLabel?.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        if(noDataLabel != nil) {
            self.view.addSubview(self.noDataLabel!)
        }
        
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSize(with: newCollection)
    }
    
    func updatePreferredContentSize(with traitCollection: UITraitCollection) {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let mWidth = min(width, height)
        let mHeight = max(width, height)
        
        let currentDevice = UIDevice.current
        if currentDevice.userInterfaceIdiom == .pad {
            // This is an iPad
            self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? mWidth*0.5 : mHeight*0.6)
        } else {
            // This is an iPhone or iPod touch
            self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? mWidth*0.9 : mHeight*0.9)
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        self.titleLabel?.frame = CGRect(x: (self.view.frame.size.width - 120)/2, y: 5, width: 120, height: 50)
        self.backBtn?.frame = CGRect(x: self.view.frame.size.width - 60, y: 5, width: 50, height: 50)
        self.tableView?.frame = CGRect(x: 0, y: 60, width: self.view.frame.size.width, height: self.view.frame.size.height - 50)
        self.splitView?.frame = CGRect(x: 0, y: self.titleLabel?.frame.maxY ?? 0, width: self.view.frame.size.width, height: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadData()
    }
    
    func reloadData() {
        guard let mAnnotation = self.annotation as? CPDFChoiceWidgetAnnotation else { return }
        if(mAnnotation.items != nil) {
            self.options = mAnnotation.items
        }
        let page = mAnnotation.page
        mAnnotation.updateAppearanceStream()
        if(page != nil) {
            self.pdfView?.setNeedsDisplayFor(page)
        }
        self.tableView?.reloadData()
        self.tableView?.isHidden = false
        if self.options.count > 0 {
            self.noDataLabel?.isHidden = true
        } else {
            self.noDataLabel?.isHidden = false
        }
        
    }
    
    func createGestureRecognizer() {
        self.addOptionsBtn?.isUserInteractionEnabled = true
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panaddBookmarkBtn(_:)))
        self.addOptionsBtn?.addGestureRecognizer(panRecognizer)
        
    }
    @objc func panaddBookmarkBtn(_ gestureRecognizer: UIPanGestureRecognizer) {
        let point = gestureRecognizer.translation(in: self.view)
        let newX = (self.addOptionsBtn?.center.x ?? 0) + point.x
        let newY = (self.addOptionsBtn?.center.y ?? 0) + point.y
        if self.view.frame.contains(CGPoint(x: newX, y: newY)) {
            self.addOptionsBtn?.center = CGPoint(x: newX, y: newY)
        }
        gestureRecognizer.setTranslation(.zero, in: self.view)
    }
    
    
    
    // MARK: - Action
    
    @objc func buttonItemClicked_back(_ button: UIButton) {
        self.dismiss(animated: true)
    }
    
    @objc func buttonItemClicked_add(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("Add Items", comment: ""), message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("Input Option", comment: "")
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        let addAction = UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .default) { (action) in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                let widgetItem = CPDFChoiceWidgetItem()
                widgetItem.string = text
                widgetItem.value = text
                self.options.append(widgetItem)
                
                if let mAnnotation = self.annotation as? CPDFChoiceWidgetAnnotation {
                    mAnnotation.items = self.options
                    if !mAnnotation.isListChoice {
                        mAnnotation.selectItemAtIndex = 0
                    }
                }
                self.reloadData()
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if (cell == nil) {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        }
        let item = self.options[indexPath.row]
        cell!.textLabel?.text = item.string
        return cell!
        
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            if indexPath.row < self.options.count {
                self.options.remove(at: indexPath.row)
                if let mAnnotation = self.annotation as? CPDFChoiceWidgetAnnotation {
                    mAnnotation.items = self.options
                    if !mAnnotation.isListChoice {
                        mAnnotation.selectItemAtIndex = 0
                    }
                    mAnnotation.updateAppearanceStream()
                    let page = mAnnotation.page
                    self.pdfView?.setNeedsDisplayFor(page)
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.setEditing(false, animated: true)
                tableView.isUserInteractionEnabled = true
                self.reloadData()
            }
        }
        let editAction = UITableViewRowAction(style: .destructive, title: NSLocalizedString("Edit",comment: "")) { (action, indexPath) in
            let alert = UIAlertController(title: NSLocalizedString("Edit Items",comment: ""), message: nil, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = NSLocalizedString("Item Title", comment: "")
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
            
            let addAction = UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .default) { (alertAction) in
                if let text = alert.textFields?.first?.text, !text.isEmpty {
                    let widgetItem = CPDFChoiceWidgetItem()
                    widgetItem.string = text
                    widgetItem.value = text
                    self.options.append(widgetItem)
                    
                    if let mAnnotation = self.annotation as? CPDFChoiceWidgetAnnotation {
                        mAnnotation.items = self.options
                        if !mAnnotation.isListChoice {
                            mAnnotation.selectItemAtIndex = 0
                        }
                        mAnnotation.updateAppearanceStream()
                    }
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
        let deleteAction = UIContextualAction(style: .normal, title: nil) { (action, view, completionHandler) in
            if indexPath.row < self.options.count {
                self.options.remove(at: indexPath.row)
                if let mAnnotation = self.annotation as? CPDFChoiceWidgetAnnotation {
                    mAnnotation.items = self.options
                    if !mAnnotation.isListChoice {
                        mAnnotation.selectItemAtIndex = 0
                    }
                    mAnnotation.updateAppearanceStream()
                    let page = mAnnotation.page
                    self.pdfView?.setNeedsDisplayFor(page)
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.setEditing(false, animated: true)
                tableView.isUserInteractionEnabled = true
                self.reloadData()
            }
            completionHandler(true)
        }
        let editAction = UIContextualAction(style: .normal, title: nil) { (action, view, completionHandler) in
            let alert = UIAlertController(title: NSLocalizedString("Edit Item", comment: ""), message: nil, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = NSLocalizedString("Item Title", comment: "")
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
            
            let addAction = UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .default) { (alertAction) in
                if let text = alert.textFields?.first?.text, !text.isEmpty {
                    let widgetItem = self.options[indexPath.row]
                    widgetItem.string = text
                    widgetItem.value = text
                    if  self.annotation is CPDFChoiceWidgetAnnotation {
                        let choiceWidgetAnnotation = self.annotation as?CPDFChoiceWidgetAnnotation
                        choiceWidgetAnnotation?.items = self.options
                        if !(choiceWidgetAnnotation?.isListChoice ?? false) {
                            choiceWidgetAnnotation?.selectItemAtIndex = 0
                        }
                        choiceWidgetAnnotation?.updateAppearanceStream()
                    }
                    self.reloadData()
                }
            }
            
            alert.addAction(cancelAction)
            alert.addAction(addAction)
            
            self.present(alert, animated: true, completion: nil)
            tableView.setEditing(false, animated: true)
            tableView.isUserInteractionEnabled = true
            
            completionHandler(true)
        }
        
        deleteAction.image = UIImage(named: "CPDFBookmarkImageDelete", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        deleteAction.backgroundColor = UIColor.red
        editAction.image = UIImage(named: "CPDFBookmarkImageEraser", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}

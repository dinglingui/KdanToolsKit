//
//  CPDFPageEditViewController.swift
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

public protocol CPDFPageEditViewControllerDelegate: AnyObject {
    func pageEditViewControllerDone(_ pageEditViewController: CPDFPageEditViewController)
    func pageEditViewController(_ pageEditViewController: CPDFPageEditViewController, pageIndex: Int, isPageEdit: Bool)
}

public class CPDFPageEditViewController: CPDFThumbnailViewController,CPageEditToolBarDelegate {
    public weak var pageEditDelegate: CPDFPageEditViewControllerDelegate?
    public var isPageEdit: Bool = false
    
    private var backBarButtonItem: UIBarButtonItem?
    private var mEditButtonItem: UIBarButtonItem?
    private var doneButtonItem: UIBarButtonItem?
    private var selectAlButtonItem: UIBarButtonItem?
    private var pageEditToolBar: CPageEditToolBar = CPageEditToolBar()
    private var isSelecAll: Bool = false
    private var isEdit: Bool = false
    private var currentPage: CPDFPage?
    private var pageIndex: Int = 0
    
    // MARK: - UIViewController Methods
    
    public override init(pdfView: CPDFView) {
        super.init(pdfView: pdfView)
        self.pdfView = pdfView
        
        backBarButtonItem = UIBarButtonItem(image: UIImage(named: "CPDFPageEitImageBack", in: Bundle(for: CPDFPageEditViewController.self), compatibleWith: nil), style: .done, target: self, action: #selector(buttonItemClicked_back(_:)))
        mEditButtonItem = UIBarButtonItem(image: UIImage(named: "CPDFPageEitImageEdit", in: Bundle(for: CPDFPageEditViewController.self), compatibleWith: nil), style: .done, target: self, action: #selector(buttonItemClicked_edit(_:)))
        
        doneButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .done, target: self, action: #selector(buttonItemClicked_done(_:)))
        selectAlButtonItem = UIBarButtonItem(image: UIImage(named: "CPDFPageEitImageSelectAll", in: Bundle(for: CPDFPageEditViewController.self), compatibleWith: nil), style: .done, target: self, action: #selector(buttonItemClicked_selectAll(_:)))

    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Document Editor", comment: "")
        if(backBarButtonItem != nil) {
            navigationItem.leftBarButtonItem = backBarButtonItem!
        }
        if(mEditButtonItem != nil) {
            navigationItem.rightBarButtonItems = [mEditButtonItem!]
        }
        isEdit = false
        collectionView?.register(CPDFPageEditViewCell.self, forCellWithReuseIdentifier: "pageEditCell")
        collectionView?.isUserInteractionEnabled = true
        collectionView?.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
        if(collectionView != nil) {
            view.addSubview(collectionView!)
        }
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized(_:)))
        collectionView?.addGestureRecognizer(longPress)
        view.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
        pageEditToolBar.isHidden = true
        isPageEdit = false
        if(self.pdfView.document != nil) {
            currentPage = self.pdfView.document.page(at: UInt(pdfView.currentPageIndex))
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var height: CGFloat = 50.0
        if #available(iOS 11.0, *) {
            height += self.view.safeAreaInsets.bottom
        }
        pageEditToolBar.frame = CGRect(x: 0, y: self.view.frame.size.height - height, width: self.view.frame.size.width, height: height)
        if #available(iOS 11.0, *) {
            if isEdit {
                collectionView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: self.view.safeAreaInsets.top, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.frame.size.height - 60 - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom)
            } else {
                collectionView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: self.view.safeAreaInsets.top, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.frame.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom)
            }
        } else {
            if isEdit {
                collectionView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - 60)
            } else {
                collectionView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            }
        }
    }
    
    // MARK: - Action
    
    public func beginEdit() {
        buttonItemClicked_edit(UIBarButtonItem())
    }
    
    @objc func buttonItemClicked_edit(_ button: UIBarButtonItem) {
        if(pdfView.document == nil) {
            return
        }
        isEdit = true
        if(selectAlButtonItem != nil && doneButtonItem != nil) {
            navigationItem.rightBarButtonItems = [selectAlButtonItem!, doneButtonItem!]
        }
        isSelecAll = false
        pageEditToolBar = CPageEditToolBar.init(frame: CGRect.zero)
        pageEditToolBar.pdfView = pdfView
        pageEditToolBar.currentPageIndex = -1
        pageEditToolBar.delegate = self
        pageEditToolBar.parentVC = self
        pageEditToolBar.currentPageIndex = 1
        view.addSubview(pageEditToolBar)
        
        pageEditToolBar.isHidden = false
        
        collectionView?.allowsMultipleSelection = isEdit
        
        collectionView?.reloadData()
        let indexPath = IndexPath(item: pdfView.currentPageIndex, section: 0)
        collectionView?.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
        updateTitle()
        viewWillLayoutSubviews()
        
    }
    
    @objc func buttonItemClicked_done(_ button: UIButton) {
        isEdit = false
        if(mEditButtonItem != nil) {
            navigationItem.rightBarButtonItems = [mEditButtonItem!]
        }
        pageEditToolBar.isHidden = true
        
        collectionView?.allowsMultipleSelection = isEdit
        
        collectionView?.reloadData()
        
        pageIndex = Int(pdfView.document.index(for: currentPage))
        let indexPath = IndexPath(item: pageIndex, section: 0)
        
        collectionView?.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
        
        updateTitle()
        viewWillLayoutSubviews()
        
    }
    
    @objc override func buttonItemClicked_back(_ button: UIButton) {
        var result = true
        if isPageEdit {
            result = pdfView.document.write(to: pdfView.document.documentURL)
        }

        if result == true {
            pageEditDelegate?.pageEditViewControllerDone(self)
            pdfView.go(toPageIndex: pageIndex, animated: true)
        }
    }
    
    @objc func buttonItemClicked_selectAll(_ button: UIButton) {
        isSelecAll = !isSelecAll
        if isSelecAll {
            selectAlButtonItem?.image = UIImage(named: "CPDFPageEitImageSelectNoAll", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        } else {
            selectAlButtonItem?.image = UIImage(named: "CPDFPageEitImageSelectAll", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        }
        if isSelecAll {
            for section in 0..<(collectionView?.numberOfSections ?? 0) {
                for item in 0..<(collectionView?.numberOfItems(inSection: section) ?? 0) {
                    let indexPath = IndexPath(item: item, section: section)
                    collectionView?.selectItem(at: indexPath, animated: false, scrollPosition: [])
                }
            }
        } else {
            for section in 0..<(collectionView?.numberOfSections ?? 0) {
                for item in 0..<(collectionView?.numberOfItems(inSection: section) ?? 0) {
                    let indexPath = IndexPath(item: item, section: section)
                    collectionView?.deselectItem(at: indexPath, animated: true)
                }
            }
        }
        updateTitle()
        
    }
    
    // MARK: - Private Methods
    
    func updateTitle() {
        if isEdit {
            let count = collectionView?.indexPathsForSelectedItems?.count ?? 0
            title = "\(NSLocalizedString("Selected:", comment: ""))\(count)"
            pageEditToolBar.isSelect = self.getIsSelect()
            pageEditToolBar.currentPageIndex = getMaxSelectIndex()
        } else {
            title = NSLocalizedString("Document Editor", comment: "")
        }
    }
    
    func getMinSelectIndex() -> Int {
        var min = pdfView.document.pageCount
        if let selectedIndexPaths = collectionView?.indexPathsForSelectedItems {
            for indexPath in selectedIndexPaths {
                if indexPath.item < min {
                    min = UInt(indexPath.item)
                }
            }
        }
        return Int(min)
        
    }
    
    func getIsSelect() -> Bool {
        if self.collectionView?.indexPathsForSelectedItems?.count ?? 0 > 0 {
            return true;
        } else {
            return false;
        }
    }
    
    func getMaxSelectIndex() -> Int {
        var max = -1
        if let selectedIndexPaths = collectionView?.indexPathsForSelectedItems {
            for indexPath in selectedIndexPaths {
                if indexPath.item > max {
                    max = indexPath.item
                }
            }
        }
        return max + 1
        
    }
    
    func refreshPageIndex() {
        let count = collectionView?.numberOfItems(inSection: 0)
        for i in 0..<(count ?? 0) {
            let indexPath = IndexPath(item: i, section: 0)
            if let cell = collectionView?.cellForItem(at: indexPath) as? CPDFPageEditViewCell {
                cell.textLabel?.text = "\(i + 1)"
            }
        }
    }
    
    func fileNameWithSelectedPages() -> String {
        let selectPages = selectedPages()
        var fileName: String?
        if selectPages.count > 0 {
            if selectPages.count == 1 {
                let idx = pdfView.document.index(for: selectPages.first) + 1
                return "\(idx)"
            }
            var sortIndex = Set<Int>()
            for page in selectPages {
                let idx = (self.pdfView.document?.index(for: page) ?? 0) + 1
                sortIndex.insert(Int(idx))
            }
            let sortArray = sortIndex.sorted { $0 < $1 }
            var a = 0
            var b = 0
            
            for num in sortArray {
                if fileName != nil {
                    if num == b+1 {
                        b = num
                        if num == sortArray.last {
                            fileName = fileName! + "\(a)-\(b)"
                        }
                    } else {
                        if a == b {
                            fileName = fileName! + "\(a),"
                        } else {
                            fileName = fileName! + "\(a)-\(b),"
                        }
                        a = num
                        b = num
                        if num == sortArray.last {
                            fileName = fileName! + "\(a)"
                        }
                    }
                } else {
                    fileName = ""
                    a = num
                    b = num
                }
            }
            return fileName ?? ""
        }
        return ""
        
    }
    
    func selectedPages() -> [CPDFPage] {
        var pages = [CPDFPage]()
        if let selectedIndexPaths = collectionView?.indexPathsForSelectedItems {
            for indexPath in selectedIndexPaths {
                if indexPath.item < pdfView.document.pageCount {
                    pages.append(pdfView.document.page(at: UInt(indexPath.item)))
                }
            }
        }
        return pages
    }
    
    // MARK: - GestureRecognized
    
    @objc func longPressGestureRecognized(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if(collectionView != nil) {
            switch gestureRecognizer.state {
            case .began:
                if let indexPath = collectionView?.indexPathForItem(at: gestureRecognizer.location(in: collectionView!)) {
                    collectionView?.beginInteractiveMovementForItem(at: indexPath)
                    UIView.animate(withDuration: 0.2) {
                        self.collectionView?.updateInteractiveMovementTargetPosition(gestureRecognizer.location(in: self.collectionView!))
                    }
                }
            case .changed:
                collectionView?.updateInteractiveMovementTargetPosition(gestureRecognizer.location(in: collectionView!))
            case .ended:
                collectionView?.endInteractiveMovement()
                refreshPageIndex()
            default:
                collectionView?.cancelInteractiveMovement()
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(pdfView.document != nil) {
            return Int(pdfView.document.pageCount)
        } else {
            return 0
        }
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pageEditCell", for: indexPath) as? CPDFPageEditViewCell
        let page = pdfView.document.page(at: UInt(indexPath.item))
        let pageSize = pdfView.document.pageSize(at: UInt(indexPath.item))
        let multiple = max(pageSize.width / 110, pageSize.height / 173)
        cell?.imageSize = CGSize(width: pageSize.width / multiple, height: pageSize.height / multiple)
        cell?.setNeedsLayout()
        cell?.imageView?.image = page?.thumbnail(of: CGSize(width: pageSize.width / multiple, height: pageSize.height / multiple))
        cell?.textLabel?.text = "\(indexPath.item + 1)"
        cell?.setEdit(isEdit)
        if(cell != nil) {
            return cell!
        }
        return UICollectionViewCell.init()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.item != destinationIndexPath.item {
            pdfView.document.movePage(at: UInt(sourceIndexPath.item), withPageAt: UInt(destinationIndexPath.item))
            isPageEdit = true
            updateTitle()
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEdit {
            let cell = collectionView.cellForItem(at: indexPath)
            pageEditToolBar.currentPageIndex = indexPath.item
            pageEditToolBar.isSelect = getIsSelect()
            updateTitle()
            cell?.isSelected = true
        } else {
            var result = true
            if isPageEdit {
                result = pdfView.document.write(to: pdfView.document.documentURL)
            }
            
            if(result) {
                pageEditDelegate?.pageEditViewController(self, pageIndex: indexPath.item, isPageEdit: isPageEdit)
            }                        
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        updateTitle()
        cell?.isSelected = false
    }
    
    // MARK: - CPageEditToolBarDelegate
    
    public func pageEditToolBarBlankPageInsert(_ pageEditToolBar: CPageEditToolBar, pageModel: CBlankPageModel) {
        var size = pageModel.size
        if pageModel.rotation == 1 {
            size = CGSize(width: pageModel.size.height, height: pageModel.size.width)
        }
        
        var pageIndex = pageModel.pageIndex
        if pageModel.pageIndex == -2 {
            pageIndex = Int(pdfView.document.pageCount)
        }
        
        if pageIndex < 0 {
            pageIndex = 0
        }
        
        pdfView.document.insertPage(size, at: UInt(pageIndex))
        collectionView?.reloadData()
        pageEditToolBar.reloadData()
        
        let indexPath = IndexPath(item: pageIndex, section: 0)
        collectionView?.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
        updateTitle()
        isPageEdit = true
        
    }
    
    public func pageEditToolBarPDFInsert(_ pageEditToolBar: CPageEditToolBar, pageModel: CBlankPageModel, document: CPDFDocument) {
        if pageModel.pageIndex == -2 {
            pageModel.pageIndex = Int(pdfView.document.pageCount)
        }
        pdfView.document.importPages(pageModel.indexSet, from: document, at: UInt(pageModel.pageIndex))
        collectionView?.reloadData()
        for i in 0..<pageModel.indexSet.count {
            let indexPath = IndexPath(item: i + pageModel.pageIndex, section: 0)
            collectionView?.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
        }
        updateTitle()
        isPageEdit = true
        
    }
    
    public func pageEditToolBarExtract(_ pageEditToolBar: CPageEditToolBar) {
                
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = (pdfView.document.documentURL?.lastPathComponent as? NSString)?.deletingPathExtension
        let filePath = path.appendingPathComponent("\(fileName ?? "")_\(self.fileNameWithSelectedPages()).pdf")
        
        var indexSet = IndexSet()
        if let selectedIndexPaths = collectionView?.indexPathsForSelectedItems {
            for indexPath in selectedIndexPaths {
                indexSet.insert(indexPath.item)
            }
        }
        print(filePath)
        let document = CPDFDocument()
        document?.importPages(indexSet, from: pdfView.document, at: 0)
        let yy = document?.write(to: filePath)
        let activityVC = UIActivityViewController(activityItems: [filePath], applicationActivities: nil)
        activityVC.definesPresentationContext = true
        if UIDevice.current.userInterfaceIdiom == .pad {
            let zbutton = pageEditToolBar.pageEditBtns?[2]
            if(zbutton != nil) {
                activityVC.popoverPresentationController?.sourceView = zbutton
                activityVC.popoverPresentationController?.sourceRect = zbutton?.bounds ?? CGRect.zero
            }
        }
        present(activityVC, animated: true) {
            activityVC.completionWithItemsHandler = { (activityType, completed, returnedItems, activityError) in
                if completed {
                    print("Success!")
                } else {
                    print("Failed Or Canceled!")
                }
            }
        }
        pageEditToolBar.reloadData()
        isPageEdit = true
        updateTitle()
        
    }
    
    public func pageEditToolBarRotate(_ pageEditToolBar: CPageEditToolBar) {
        guard let indexPathsForSelectedItems = collectionView?.indexPathsForSelectedItems else { return }
        for indexPath in indexPathsForSelectedItems {
            let pPage = pdfView.document.page(at: UInt(indexPath.item))
            pPage?.rotation += 90
            if pPage?.rotation == 360 {
                pPage?.rotation = 0
            }
            collectionView?.reloadItems(at: [indexPath])
            collectionView?.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
        updateTitle()
        pageEditToolBar.reloadData()
        isPageEdit = true
    }
    
    public func pageEditToolBarDelete(_ pageEditToolBar: CPageEditToolBar) {
        let selectedCount = collectionView?.indexPathsForSelectedItems?.count ?? 0
        let totalCount = collectionView?.numberOfItems(inSection: 0)
        if selectedCount == totalCount {
            let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil)
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Can not delete all pages.", comment: ""), preferredStyle: .alert)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
            return
        }
        var indexSet = IndexSet()
        if let selectedIndexPaths = collectionView?.indexPathsForSelectedItems {
            for indexPath in selectedIndexPaths {
                indexSet.insert(indexPath.item)
            }
        }
        pdfView.document.removePage(at: indexSet)
        collectionView?.reloadData()
        pageEditToolBar.reloadData()
        updateTitle()
        isPageEdit = true
    }
    
    public func pageEditToolBarCopy(_ pageEditToolBar: CPageEditToolBar) {
        let max = getMaxSelectIndex()
        var indexSet = IndexSet()
        if let selectedIndexPaths = collectionView?.indexPathsForSelectedItems {
            for indexPath in selectedIndexPaths {
                indexSet.insert(indexPath.item)
            }
        }
        let document = CPDFDocument()
        document?.importPages(indexSet, from: pdfView.document, at: 0)
        var indexSetCopy = IndexSet()
        for i in 0..<(document?.pageCount ?? 0) {
            indexSetCopy.insert(IndexSet.Element(i))
        }
        pdfView.document.importPages(indexSetCopy, from: document, at: UInt(max))
        collectionView?.reloadData()
        pageEditToolBar.reloadData()
        for i in 0..<(document?.pageCount ?? 0) {
            let indexPath = IndexPath(item: Int(i) + max, section: 0)
            collectionView?.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
        }
        updateTitle()
        isPageEdit = true
    }
    
    public func pageEditToolBarReplace(_ pageEditToolBar: CPageEditToolBar, document: CPDFDocument) {
        let min = getMinSelectIndex()
        var indexSet = IndexSet()
        for i in 0..<document.pageCount {
            indexSet.insert(IndexSet.Element(i))
        }
        var deleteIndexSet = IndexSet()
        if let selectedIndexPaths = collectionView?.indexPathsForSelectedItems {
            for indexPath in selectedIndexPaths {
                deleteIndexSet.insert(indexPath.item)
            }
        }
        pdfView.document.removePage(at: deleteIndexSet)
//        collectionView?.deleteItems(at: collectionView?.indexPathsForSelectedItems ?? [])
        pdfView.document.importPages(indexSet, from: document, at: UInt(min))
        collectionView?.reloadData()
        pageEditToolBar.reloadData()
        for i in 0..<document.pageCount {
            let indexPath = IndexPath(item: Int(i) + min, section: 0)
            collectionView?.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
        }
        updateTitle()
        isPageEdit = true
    }
    
}

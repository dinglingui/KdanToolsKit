//
//  CPDFThumbnailViewController.swift
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

@objc public protocol CPDFThumbnailViewControllerDelegate: AnyObject {
    @objc optional func thumbnailViewController(_ thumbnailViewController: CPDFThumbnailViewController, pageIndex: Int)
    @objc optional func thumbnailViewControllerDismiss(_ thumbnailViewController: CPDFThumbnailViewController)
}

public class CPDFThumbnailViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    public var pdfView: CPDFView
    public weak var delegate: CPDFThumbnailViewControllerDelegate?
    
    public var collectionView: UICollectionView?
    
    // MARK: - Initializers
    
    public init(pdfView: CPDFView) {
        self.pdfView = pdfView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Methods
    
    public override func viewDidLoad() {
        super.viewDidLoad() // Do any additional setup after loading the view.
        
        changeLeftItem()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 110, height: 185)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 5, right: 5)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.frame = view.bounds
        
        collectionView?.register(CPDFThumbnailViewCell.self, forCellWithReuseIdentifier: "thumnailCell")
        collectionView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.alwaysBounceVertical = true
        if #available(iOS 11.0, *) {
            collectionView?.contentInsetAdjustmentBehavior = .always
        }
        
        view.backgroundColor = UIColor.white
        collectionView?.backgroundColor = UIColor(red: 0.804, green: 0.804, blue: 0.804, alpha: 1)
        
        guard let collectionView = self.collectionView else {
            return
        }
        view.addSubview(collectionView)
        
        updatePreferredContentSize(with: traitCollection)
        
        
        title = NSLocalizedString("Thumbnails", comment: "")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "CPDFEditClose", in: Bundle(for: CPDFThumbnailViewController.self), compatibleWith: nil), style: .done, target: self, action: #selector(buttonItemClicked_back(_:)))
        
        navigationItem.leftBarButtonItem = nil
        
        view.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
    }
    
    public override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSize(with: newCollection)
    }
    
    func updatePreferredContentSize(with traitCollection: UITraitCollection) {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let mWidth = min(width, height)
        let mHeight = max(width, height)
        preferredContentSize = CGSize(width: view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? mWidth * 0.9 : mHeight * 0.9)
    }
    
    @objc func buttonItemClicked_back(_ button: UIButton) {
        if delegate?.thumbnailViewControllerDismiss?(self) != nil {
            delegate?.thumbnailViewControllerDismiss!(self)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView?.reloadData()
        
        if self.pdfView.document != nil {
            let indexPath = NSIndexPath(item: pdfView.currentPageIndex, section: 0)
            collectionView?.selectItem(at: indexPath as IndexPath, animated: false, scrollPosition: .centeredVertically)
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.pdfView.document != nil {
            let indexPath = NSIndexPath(item: pdfView.currentPageIndex, section: 0)
            collectionView?.selectItem(at: indexPath as IndexPath, animated: false, scrollPosition: .centeredVertically)
        }
    }
    
    // MARK: - Class Methods
    
    func setCollectViewSize(_ size: CGSize) {
        // Implementation goes here
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = size
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        
        self.collectionView?.collectionViewLayout = layout
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(self.pdfView.document.pageCount)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumnailCell", for: indexPath) as? CPDFThumbnailViewCell
        let page = self.pdfView.document.page(at: UInt(indexPath.item))
        let pageSize = self.pdfView.document.pageSize(at: UInt(indexPath.item))
        let multiple = max(pageSize.width / 110, pageSize.height / 173)
        cell?.imageSize = CGSize(width: pageSize.width / multiple, height: pageSize.height / multiple)
        cell?.setNeedsLayout()
        cell?.imageView?.image = page?.thumbnail(of: CGSize(width: pageSize.width / multiple, height: pageSize.height / multiple))
        cell?.textLabel?.text = "(indexPath.item + 1)"
        return cell ?? UICollectionViewCell()
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.thumbnailViewController?(self, pageIndex: indexPath.row)
    }
    
}


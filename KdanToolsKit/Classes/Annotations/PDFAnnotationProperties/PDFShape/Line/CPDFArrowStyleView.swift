//
//  CPDFArrowStyleView.swift
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

protocol CPDFArrowStyleViewDelegate: AnyObject {
    func arrowStyleView(_ arrowStyleView: CPDFArrowStyleView, selectIndex: Int)
    func arrowStyleRemoveView(_ arrowStyleView: CPDFArrowStyleView)
}

class CPDFArrowStyleView: UIView {
    
    weak var delegate: CPDFArrowStyleViewDelegate?
    var selectIndex: Int = 0
    
    private var backBtn: UIButton!
    private var titleLabel: UILabel!
    private var collectView: UICollectionView!
    private var headerView: UIView!
    
    // MARK: - Initializers
    
    init(title: String) {
        super.init(frame: CGRect.zero)
        
        self.headerView = UIView()
        self.headerView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        self.headerView.layer.borderWidth = 1.0
        self.headerView.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        self.addSubview(self.headerView)
        self.backBtn = UIButton()
        self.backBtn.setImage(UIImage(named: "CPDFAnnotationBarImageUndo", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        self.backBtn.addTarget(self, action: #selector(buttonItemClicked_back(_:)), for: .touchUpInside)
        self.headerView.addSubview(self.backBtn)
        
        self.titleLabel = UILabel()
        self.titleLabel.text = title
        self.titleLabel.textAlignment = .center
        self.headerView.addSubview(self.titleLabel)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (frame.size.width - 5.0 * 7) / 6, height: 30)
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        self.collectView = UICollectionView(frame: CGRect(x: 0, y: 50, width: frame.size.width, height: frame.size.height), collectionViewLayout: layout)
        self.collectView.register(CPDFArrowStyleCell.self, forCellWithReuseIdentifier: "cell")
        self.collectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.collectView.delegate = self
        self.collectView.dataSource = self
        self.collectView.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
        self.addSubview(self.collectView)
        
        self.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backBtn.frame = CGRect(x: 15, y: 5, width: 60, height: 50)
        titleLabel.frame = CGRect(x: (frame.size.width - 150)/2, y: 5, width: 150, height: 50)
        headerView.frame = CGRect(x: 0, y: 0, width: Int(bounds.size.width), height: 50)
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_back(_ button: UIButton) {
        removeFromSuperview()
        
        delegate?.arrowStyleRemoveView(self)
    }
    
}

extension CPDFArrowStyleView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.frame.size.width - 5.0 * 7) / 6, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CPDFArrowStyleCell
        if self.selectIndex == indexPath.item {
            cell?.contextView.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
        }
        cell?.contextView.selectIndex = indexPath.item
        cell?.contentView.setNeedsDisplay()
        cell?.backgroundColor = UIColor.clear
        if(cell != nil) {
            return cell!
        }  else {
            return UICollectionViewCell.init()
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for cell in collectionView.visibleCells {
            if(cell is CPDFArrowStyleCell) {
                (cell as! CPDFArrowStyleCell).contextView.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
            }
        }
        let cell = collectionView.cellForItem(at: indexPath) as? CPDFArrowStyleCell
        cell?.contextView.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
        delegate?.arrowStyleView(self, selectIndex: indexPath.item)
    }
    
}

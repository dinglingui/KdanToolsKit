//
//  CPDFFormBaseViewController.swift
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

class CPDFFormBaseViewController: WPAutoSpringTextViewController {
    
    var scrcollView:UIScrollView?
    var backBtn:UIButton?
    var titleLabel:UILabel?
    var headerView:UIView?
    
    private var splitView:UIView?
    private var kisButton:UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView = UIView()
        headerView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        headerView?.layer.borderWidth = 1.0
        headerView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if(headerView != nil) {
            view.addSubview(headerView!)
        }
        
        splitView = UIView()
        splitView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        if(splitView != nil) {
            view.addSubview(splitView!)
        }
        
        titleLabel = UILabel()
        titleLabel?.autoresizingMask = [.flexibleRightMargin]
        titleLabel?.textAlignment = .center
        titleLabel?.font = UIFont.systemFont(ofSize: 20)
        titleLabel?.adjustsFontSizeToFitWidth = true
        if(titleLabel != nil) {
            headerView?.addSubview(titleLabel!)
        }
        
        scrcollView = UIScrollView()
        scrcollView?.isScrollEnabled = true
        if(scrcollView != nil) {
            view.addSubview(scrcollView!)
        }
        
        backBtn = UIButton()
        backBtn?.autoresizingMask = [.flexibleLeftMargin]
        backBtn?.setImage(UIImage(named: "CPDFAnnotationBaseImageBack", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        backBtn?.addTarget(self, action: #selector(buttonItemClicked_back(_:)), for: .touchUpInside)
        if(backBtn != nil) {
            view.addSubview(backBtn!)
        }
        
        // Do any additional setup after loading the view.
        view.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
        updatePreferredContentSize(with: traitCollection)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        titleLabel?.frame = CGRect(x: (view.frame.size.width - 120)/2, y: 5, width: 120, height: 50)
        scrcollView?.frame = CGRect(x: 0, y: 50, width: view.frame.size.width, height: 210)
        scrcollView?.contentSize = CGSize(width: view.frame.size.width, height: 330)
        if #available(iOS 11.0, *) {
            backBtn?.frame = CGRect(x: view.frame.size.width - 60 - view.safeAreaInsets.right, y: 0, width: 50, height: 50)
            splitView?.frame = CGRect(x: 0, y: 49, width: view.bounds.size.width, height: 1)
        } else {
            splitView?.frame = CGRect(x: 0, y: 49, width: view.bounds.size.width, height: 1)
            backBtn?.frame = CGRect(x: view.frame.size.width - 60, y: 5, width: 50, height: 50)
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSize(with: newCollection)
    }

    func updatePreferredContentSize(with traitCollection: UITraitCollection) {
        preferredContentSize = CGSize(width: view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? 350 : 420)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        commomInitTitle()
    }

    func commomInitTitle() {
        titleLabel?.text = NSLocalizedString("Note", comment: "")
    }

    // MARK: - Action
    @objc func buttonItemClicked_back(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}

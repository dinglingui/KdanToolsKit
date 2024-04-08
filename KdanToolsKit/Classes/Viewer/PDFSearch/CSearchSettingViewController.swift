//
//  CSearchSettingViewController.swift
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

class CSearchSettingViewController: UIViewController {
    
    var isSensitive: Bool = false
    
    var isWholeWord: Bool = false
    
    private var wholeWordLabel: UILabel?
    
    private var wholeWordSwitch: UISwitch?
    
    private var sensitiveLabel: UILabel?
    
    private var sensitiveSwitch: UISwitch?
    
    private let tipView = CPDFTipsView(frame: CGRect.zero)
    
   public var callback: ((CPDFSearchOptions) -> Void)?
    
    // MARK: - Initializers
    
    init(isSensitive: Bool, isWholeWord: Bool) {
        super.init(nibName: nil, bundle: nil)
        // Initialization code
        self.isSensitive = isSensitive
        self.isWholeWord = isWholeWord
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Setting", comment: "")
        
        sensitiveLabel = UILabel()
        sensitiveLabel?.text = NSLocalizedString("Ignore Case", comment: "")
        sensitiveLabel?.font = UIFont.systemFont(ofSize: 15)
        if sensitiveLabel != nil {
            view.addSubview(sensitiveLabel!)
        }
        
        sensitiveSwitch = UISwitch()
        sensitiveSwitch?.addTarget(self, action: #selector(selectChange_switch(_:)), for: .valueChanged)
        sensitiveSwitch?.isOn = isSensitive
        if sensitiveSwitch != nil {
            view.addSubview(sensitiveSwitch!)
        }
        
        wholeWordLabel = UILabel()
        wholeWordLabel?.text = NSLocalizedString("Whole Words only", comment: "")
        wholeWordLabel?.font = UIFont.systemFont(ofSize: 15)
        if wholeWordLabel != nil {
            view.addSubview(wholeWordLabel!)
        }
        
        wholeWordSwitch = UISwitch()
        wholeWordSwitch?.addTarget(self, action: #selector(selectChange_switch(_:)), for: .valueChanged)
        wholeWordSwitch?.isOn = isWholeWord
        if wholeWordSwitch != nil {
            view.addSubview(wholeWordSwitch!)
        }

        view.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
        updatePreferredContentSize(with: traitCollection)
        
        let searchBackItem = UIBarButtonItem(image: UIImage(named: "CPDFSearchImageClose", in: Bundle(for: self.classForCoder), compatibleWith: nil), style: .plain, target: self, action: #selector(buttonItemClicked_Done(_:)))
        self.navigationItem.rightBarButtonItems = [searchBackItem]

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        var searchOptions: CPDFSearchOptions = CPDFSearchOptions(rawValue: 0)

        if sensitiveSwitch?.isOn == false {
            searchOptions = .caseSensitive
        } else {
            searchOptions = CPDFSearchOptions(rawValue: 0)
        }

        if wholeWordSwitch?.isOn == false {
        } else {
            searchOptions.formUnion(.matchWholeWord)
        }
        callback?(searchOptions)

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var top: CGFloat = 0
        var bottom: CGFloat = 0
        var left: CGFloat = 0
        var right: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            bottom += self.view.safeAreaInsets.bottom
            top += self.view.safeAreaInsets.top
            left += self.view.safeAreaInsets.left
            right += self.view.safeAreaInsets.right
        }
        
        self.sensitiveLabel?.frame = CGRect(x: 25 + left, y: top+5, width: 150, height: 50)
        self.sensitiveSwitch?.frame = CGRect(x: self.view.frame.size.width - 75 - right, y: top+10, width: 50, height: 50)
        self.wholeWordLabel?.frame = CGRect(x: 25 + left, y: (self.sensitiveLabel?.frame.maxY ?? 0) + 10, width: 200, height: 50)
        self.wholeWordSwitch?.frame = CGRect(x: self.view.frame.size.width - 75 - right, y: (self.sensitiveLabel?.frame.maxY ?? 0) + 15, width: 50, height: 50)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSize(with: newCollection)
    }

    func updatePreferredContentSize(with traitCollection: UITraitCollection) {
        preferredContentSize = CGSize(width: view.bounds.size.width, height: 140)
    }
    
    // MARK: - Action
    
    @objc func selectChange_switch(_ sender: UISwitch) {
        if(self.tipView.superview == nil ) {
            self.tipView.postAlertWithMessage(message: NSLocalizedString("Effective immediately after setting", comment: ""))
            self.tipView.showView(self.view.window ?? self.view)
        } else {
            self.tipView.showTip()
        }
        
    }
    
    @objc func buttonItemClicked_Done(_ sender: Any) {
        self.dismiss(animated: true)
    }

}

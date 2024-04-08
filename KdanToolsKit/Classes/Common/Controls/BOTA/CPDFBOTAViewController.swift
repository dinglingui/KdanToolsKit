//
//  CPDFBOTAViewController.swift
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

public enum CPDFBOTATypeState: Int {
    case CPDFBOTATypeStateOutline = 0
    case CPDFBOTATypeStateBookmark
    case CPDFBOTATypeStateAnnotation
}

public protocol CPDFBOTAViewControllerDelegate: AnyObject {
    func botaViewControllerDismiss(_ botaViewController: CPDFBOTAViewController)
}

public class CPDFBOTAViewController: UIViewController, CPDFOutlineViewControllerDelegate, CPDFBookmarkViewControllerDelegate, CPDFAnnotationViewControllerDelegate {
    public weak var delegate: CPDFBOTAViewControllerDelegate?
    public var pdfView:CPDFListView?
    var outlineViewController:CPDFOutlineViewController?
    var bookmarkViewController:CPDFBookmarkViewController?
    var annotationViewController:CPDFAnnotationViewController?

    var doneBtn:UIButton?
    var segmmentArray:[CPDFBOTATypeState]?
    var type:CPDFBOTATypeState?
    
    var pageIndex:Int = 0
    var segmentedControl:UISegmentedControl?
    var currentViewController:UIViewController?

    public init(pdfView: CPDFListView) {
        super.init(nibName: nil, bundle: nil)
        self.pdfView = pdfView
        self.segmmentArray = [.CPDFBOTATypeStateOutline, .CPDFBOTATypeStateBookmark]
    }

    public init(customizeWith pdfView: CPDFListView, navArrays botaTypes: [CPDFBOTATypeState]) {
        super.init(nibName: nil, bundle: nil)
        self.pdfView = pdfView
        self.segmmentArray = botaTypes
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
        
        var segmmentTitleArray = [String]()
        for num in self.segmmentArray! {
            if .CPDFBOTATypeStateOutline == num {
                segmmentTitleArray.append(NSLocalizedString("Outlines", comment: ""))
                self.outlineViewController = CPDFOutlineViewController(pdfView: self.pdfView!)
                self.outlineViewController?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin]
                self.outlineViewController?.delegate = self
                self.addChild(self.outlineViewController!)
            } else if .CPDFBOTATypeStateBookmark == num {
                segmmentTitleArray.append(NSLocalizedString("Bookmarks", comment: ""))
                self.bookmarkViewController = CPDFBookmarkViewController(pdfView: self.pdfView!)
                self.bookmarkViewController?.delegate = self
                self.bookmarkViewController?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin]
                self.addChild(self.bookmarkViewController!)
            } else if .CPDFBOTATypeStateAnnotation == num {
                segmmentTitleArray.append(NSLocalizedString("Annotations", comment: ""))
                self.annotationViewController = CPDFAnnotationViewController(pdfView: self.pdfView!)
                self.annotationViewController?.delegate = self
                self.annotationViewController?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin]
                self.addChild(self.annotationViewController!)
            }
        }
        
        self.segmentedControl = UISegmentedControl(items: segmmentTitleArray)
        self.segmentedControl?.selectedSegmentIndex = 0
        self.segmentedControl?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.segmentedControl?.addTarget(self, action: #selector(segmentedControlValueChanged_BOTA(_:)), for: .valueChanged)
        self.navigationItem.titleView = self.segmentedControl!
        self.view.addSubview(self.segmentedControl!)
        
        self.view.addSubview(self.outlineViewController!.view)
        
        self.doneBtn = UIButton(type: .system)
        self.doneBtn?.autoresizingMask = .flexibleLeftMargin
        self.doneBtn?.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
        self.doneBtn?.addTarget(self, action: #selector(buttonItemClicked_back(_:)), for: .touchUpInside)
        self.view.addSubview(self.doneBtn!)
        
        self.view.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
        self.updatePreferredContentSize(with: self.traitCollection)
    }
    
    public override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSize(with: newCollection)
    }

    func updatePreferredContentSize(with traitCollection: UITraitCollection) {
        let screenSize = UIScreen.main.bounds.size
        let width = screenSize.width
        let height = screenSize.height
        
        let mWidth = min(width, height)
        let mHeight = max(width, height)
        
        let currentDevice = UIDevice.current
        if currentDevice.userInterfaceIdiom == .pad {
            // This is an iPad
            self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? mWidth * 0.7 : mHeight * 0.7)
        } else {
            // This is an iPhone or iPod touch
            self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? mWidth * 0.9 : mHeight * 0.9)
        }
    }
    
    public override func viewWillLayoutSubviews() {
        segmentedControl?.frame = CGRect(x: 15, y: 44, width: self.view.frame.size.width - 30, height: 30)
        doneBtn?.frame = CGRect(x: self.view.frame.size.width - 60, y: 5, width: 50, height: 50)
        
        if #available(iOS 11.0, *) {
            outlineViewController?.view.frame = CGRect(x: 0, y: self.view.safeAreaInsets.top + 80, width: self.view.bounds.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom - 80)
            
            bookmarkViewController?.view.frame = CGRect(x: 0, y: self.view.safeAreaInsets.top + 80, width: self.view.bounds.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom - 80)
            
            annotationViewController?.view.frame = CGRect(x: 0, y: self.view.safeAreaInsets.top + 80, width: self.view.bounds.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom - 80)
        } else {
            outlineViewController?.view.frame = CGRect(x: 0, y: 64 + 44, width: self.view.bounds.size.width, height: self.view.bounds.size.height - 64 - 44 - 30)
            
            bookmarkViewController?.view.frame = CGRect(x: 0, y: 64 + 44, width: self.view.bounds.size.width, height: self.view.bounds.size.height - 64 - 30 - 44)
            
            annotationViewController?.view.frame = CGRect(x: 0, y: 64 + 44, width: self.view.bounds.size.width, height: self.view.bounds.size.height - 64 - 30 - 44)
        }
    }
    
    // MARK: - Action
    @objc func buttonItemClicked_back(_ sender: Any) {
        self.delegate?.botaViewControllerDismiss(self)
    }

    @objc func segmentedControlValueChanged_BOTA(_ sender: Any) {
        currentViewController?.view.removeFromSuperview()
        
        if currentViewController == nil {
            outlineViewController?.view.removeFromSuperview()
            bookmarkViewController?.view.removeFromSuperview()
            annotationViewController?.view.removeFromSuperview()
        }
        
        type = CPDFBOTATypeState(rawValue: self.segmentedControl?.selectedSegmentIndex ?? 0)
        
        switch type {
        case .CPDFBOTATypeStateOutline:
            currentViewController = outlineViewController
            view.addSubview(outlineViewController?.view ?? UIView())
        case .CPDFBOTATypeStateBookmark:
            currentViewController = bookmarkViewController
            view.addSubview(bookmarkViewController?.view ?? UIView())
        case .CPDFBOTATypeStateAnnotation:
            currentViewController = annotationViewController
            view.addSubview(annotationViewController?.view ?? UIView())
        case .none: break
            
        }
    }
    
    // MARK: - CPDFOutlineViewControllerDelegate
    @objc func outlineViewController(_ outlineViewController: CPDFOutlineViewController, pageIndex: Int) {
        self.pdfView?.go(toPageIndex: pageIndex, animated: false)
        self.delegate?.botaViewControllerDismiss(self)
    }
    
    // MARK: - CPDFBookmarkViewControllerDelegate
    @objc func boomarkViewController(_ bookmarkViewController: CPDFBookmarkViewController, pageIndex: Int) {
        self.pdfView?.go(toPageIndex: pageIndex, animated: false)
        self.delegate?.botaViewControllerDismiss(self)
    }
    
    // MARK: - CPDFAnnotationViewControllerDelegate
    func annotationViewController(_ annotationViewController: CPDFAnnotationViewController, jumptoPage pageIndex: Int, selectAnnot annot: CPDFAnnotation) {
        self.pdfView?.go(toPageIndex: pageIndex, animated: false)

        if #available(iOS 12.0, *) {
            let visibleRect = pdfView?.documentView().visibleSize
            pdfView?.go(to: CGRect(x: annot.bounds.origin.x, y: annot.bounds.origin.y + visibleRect!.height/2, width: annot.bounds.size.width, height: annot.bounds.size.height), on: pdfView?.document.page(at: UInt(pageIndex)), animated: true)
        } else {
            pdfView?.go(to: CGRect(x: annot.bounds.origin.x, y: annot.bounds.origin.y + 100, width: annot.bounds.size.width, height: annot.bounds.size.height), on: pdfView?.document.page(at: UInt(pageIndex)), animated: true)
        }        
        self.delegate?.botaViewControllerDismiss(self)
    }
}

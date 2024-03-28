//
//  CPDFSignatureViewController.swift
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

@objc public protocol CPDFSignatureViewControllerDelegate: AnyObject {
    @objc optional func signatureViewControllerDismiss(_ signatureViewController: CPDFSignatureViewController)
    @objc optional func signatureViewController(_ signatureViewController: CPDFSignatureViewController, image: UIImage)
}


public class CPDFSignatureViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CPDFSignatureViewCellDelegate,CPDFSignatureEditViewControllerDelegate {
    var annotStyle: CAnnotStyle?
    public weak var delegate: CPDFSignatureViewControllerDelegate?
    var tableView: UITableView?
    
    private var backBtn: UIButton?
    private var titleLabel: UILabel?
    private var emptyLabel: UILabel?
    private var headerView: UIView?
    private var createButton: UIButton?
    
    // MARK: - Initializers
    
    public init(style annotStyle: CAnnotStyle?) {
        self.annotStyle = annotStyle
        self.tableView = UITableView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController Methods
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.headerView = UIView()
        self.headerView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        self.headerView?.layer.borderWidth = 1.0
        self.headerView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if(self.headerView != nil) {
            view.addSubview(self.headerView!)
        }
        self.titleLabel = UILabel()
        self.titleLabel?.autoresizingMask = .flexibleRightMargin
        self.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        self.titleLabel?.text = NSLocalizedString("Signatures", comment: "")
        self.titleLabel?.textAlignment = .center
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        if(self.titleLabel != nil) {
            self.headerView?.addSubview(self.titleLabel!)
        }
        self.backBtn = UIButton()
        self.backBtn?.autoresizingMask = .flexibleLeftMargin
        self.backBtn?.setImage(UIImage(named: "CPDFAnnotationBaseImageBack", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        self.backBtn?.addTarget(self, action: #selector(buttonItemClicked_back(_:)), for: .touchUpInside)
        if(self.backBtn != nil) {
            self.headerView?.addSubview(self.backBtn!)
        }
        self.tableView = UITableView(frame: CGRect(x: 0, y: 50, width: view.frame.size.width, height: view.frame.size.height - 70), style: .plain)
        self.tableView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.tableView?.rowHeight = 120
        if(self.tableView != nil) {
            view.addSubview(self.tableView!)
        }
        self.emptyLabel = UILabel()
        self.emptyLabel?.text = NSLocalizedString("NO Signature", comment: "")
        self.emptyLabel?.textAlignment = .center
        if(self.emptyLabel != nil) {
            view.addSubview(self.emptyLabel!)
        }
        self.createButton = UIButton()
        self.createButton?.layer.cornerRadius = 25.0
        self.createButton?.clipsToBounds = true
        self.createButton?.setImage(UIImage(named: "CPDFSignatureImageAdd", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        self.createButton?.addTarget(self, action: #selector(buttonItemClicked_create(_:)), for: .touchUpInside)
        if(self.createButton != nil) {
            view.addSubview(self.createButton!)
        }
        self.view.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
        updatePreferredContentSizeWithTraitCollection(traitCollection: self.traitCollection)
        createGestureRecognizer()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        titleLabel?.frame = CGRect(x: (view.frame.size.width - 120)/2, y: 5, width: 120, height: 50)
        headerView?.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50)
        emptyLabel?.frame = CGRect(x: (view.frame.size.width - 120)/2, y: (view.frame.size.height - 50)/2, width: 120, height: 50)
        
        if #available(iOS 11.0, *) {
            backBtn?.frame = CGRect(x: view.frame.size.width - 60 - view.safeAreaInsets.right, y: 5, width: 50, height: 50)
            createButton?.frame = CGRect(x: view.frame.size.width - 70 - view.safeAreaInsets.right, y: view.frame.size.height - 100 - view.safeAreaInsets.bottom, width: 50, height: 50)
        } else {
            backBtn?.frame = CGRect(x: view.frame.size.width - 60, y: 5, width: 50, height: 50)
            createButton?.frame = CGRect(x: view.frame.size.width - 70, y: view.frame.size.height - 100, width: 50, height: 50)
        }
        
    }
    
    public override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSizeWithTraitCollection(traitCollection: newCollection)
    }
    
    // MARK: - Protect Methods
    
    func updatePreferredContentSizeWithTraitCollection(traitCollection: UITraitCollection) {
        self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? 350 : 660)
    }
    
    // MARK: - Private Methods
    
    func createGestureRecognizer() {
        createButton?.isUserInteractionEnabled = true
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panaddBookmarkBtn(_:)))
        createButton?.addGestureRecognizer(panRecognizer)
        
    }
    
    @objc func panaddBookmarkBtn(_ gestureRecognizer: UIPanGestureRecognizer) {
        let point = gestureRecognizer.translation(in: view)
        let newX = (createButton?.center.x ?? 0) + point.x
        let newY = (createButton?.center.y ?? 0) + point.y
        if view.frame.contains(CGPoint(x: newX, y: newY)) {
            createButton?.center = CGPoint(x: newX, y: newY)
        }
        gestureRecognizer.setTranslation(.zero, in: view)
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.signatureViewControllerDismiss?(self)
    }
    
    @objc func buttonItemClicked_create(_ sender: Any) {
        let editVC = CPDFSignatureEditViewController.init(nibName: nil, bundle: nil)
        editVC.delegate = self
        let presentationController = SignatureCustomPresentationController(presentedViewController: editVC, presenting: self)
        
        editVC.transitioningDelegate = presentationController
        self.present(editVC, animated: true, completion: nil)

    }
    
    // MARK: - UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if CSignatureManager.sharedManager.signatures.count <= 0 {
            emptyLabel?.isHidden = false
            tableView.isHidden = true
        } else {
            emptyLabel?.isHidden = true
            tableView.isHidden = false
        }
        
        return CSignatureManager.sharedManager.signatures.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CPDFSignatureViewCell
        if cell == nil {
            cell = CPDFSignatureViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        
        cell?.signatureImageView?.image = UIImage.init(contentsOfFile: CSignatureManager.sharedManager.signatures[indexPath.row])
        
        cell?.deleteDelegate = self
        
        return cell!
    }
    
    // MARK: - UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
            dismiss(animated: true)
            let image = UIImage.init(contentsOfFile: CSignatureManager.sharedManager.signatures[indexPath.row])
            if(image != nil) {
                delegate?.signatureViewController?(self, image: image!)
            }
        }
    }
    
    // MARK: - CPDFSignatureViewCellDelegate
    
    func signatureViewCell(_ signatureViewCell: CPDFSignatureViewCell) {
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        let OKAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (action) in
            if let indexSet = self.tableView?.indexPath(for: signatureViewCell) {
                CSignatureManager.sharedManager.removeSignatures(at: IndexSet(integer: indexSet.row))
                if CSignatureManager.sharedManager.signatures.count < 1 {
                    self.setEditing(false, animated: true)
                }
                self.tableView?.reloadData()
            }
        }
        let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Are you sure to delete?", comment: ""), preferredStyle: .alert)
        alert.addAction(cancelAction)
        alert.addAction(OKAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - CPDFSignatureEditViewControllerDelegate
    
    func signatureEditViewController(_ signatureEditViewController: CPDFSignatureEditViewController, image: UIImage) {
        signatureEditViewController.dismiss(animated: true)
        CSignatureManager.sharedManager.addImageSignature(image)
        tableView?.reloadData()
    }
    
}


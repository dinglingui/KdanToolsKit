//
//  CPDFSignatureEditViewController.swift
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

enum CSignatureTopBarSelectedIndex: Int {
    case defaults = 0
    case text
    case image
}

let kKMSignayureTextMaxWidth:CGFloat = 200.0

@objc protocol CPDFSignatureEditViewControllerDelegate: AnyObject {
    @objc optional func signatureEditViewController(_ signatureEditViewController: CPDFSignatureEditViewController, image: UIImage)
    @objc optional func signatureEditViewControllerCancel(_ signatureEditViewController: CPDFSignatureEditViewController)
}

class CPDFSignatureEditViewController: UIViewController, UIPopoverPresentationControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIColorPickerViewControllerDelegate, UITextFieldDelegate,UIGestureRecognizerDelegate, CPDFColorSelectViewDelegate, CPDFColorPickerViewDelegate, CSignatureDrawViewDelegate {
    weak var delegate: CPDFSignatureEditViewControllerDelegate?
    var customType: CSignatureCustomType = .draw
    
    private var colorSelectView: CPDFColorSelectView?
    private var cancelButton: UIButton?
    private var saveButton: UIButton?
    var segmentedControl: UISegmentedControl?
    private var signatureDrawTextView: CSignatureDrawView?
    private var signatureDrawImageView: CSignatureDrawView?
    private var colorPicker: CPDFColorPickerView?
    private var textField: UITextField?
    private var bottomBorder: CALayer?
    private var createButton: UIButton?
    private var selectedIndex: CSignatureTopBarSelectedIndex?
    private var thicknessView: UIView?
    private var thicknessLabel: UILabel?
    private var thicknessSlider: UISlider?
    private var clearButton: UIButton?
    private var emptyLabel: UILabel?
    private var headerView: UIView?
    private var isDrawSignature = false
    private var isTextSignature = false
    private var isImageSignature = false
    
    // MARK: - ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.headerView = UIView()
        self.headerView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        self.headerView?.layer.borderWidth = 1.0
        self.headerView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if(self.headerView != nil) {
            self.view.addSubview(self.headerView!)
        }
        
        initSegmentedControl()
        
        self.emptyLabel = UILabel()
        self.emptyLabel?.font = UIFont.systemFont(ofSize: 22)
        self.emptyLabel?.textColor = UIColor.gray
        self.emptyLabel?.text = NSLocalizedString("Enter your signature", comment: "")
        self.emptyLabel?.textAlignment = .center
        if(emptyLabel != nil) {
            self.view.addSubview(self.emptyLabel!)
        }
        self.colorSelectView = CPDFColorSelectView()
        colorSelectView?.colorLabel?.removeFromSuperview()
        colorSelectView?.selectedColor = UIColor.black
        colorSelectView?.delegate = self
        if(colorSelectView != nil) {
            self.view.addSubview(colorSelectView!)
        }
        self.thicknessView = UIView()
        self.thicknessView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if(thicknessView != nil) {
            self.view.addSubview(self.thicknessView!)
        }
        self.thicknessLabel = UILabel()
        self.thicknessLabel?.text = NSLocalizedString("Thickness", comment: "")
        self.thicknessLabel?.textColor = UIColor.gray
        self.thicknessLabel?.font = UIFont.systemFont(ofSize: 12.0)
        if(thicknessLabel != nil) {
            self.thicknessView?.addSubview(self.thicknessLabel!)
        }
        self.thicknessSlider = UISlider()
        self.thicknessSlider?.maximumValue = 20
        self.thicknessSlider?.minimumValue = 1
        self.thicknessSlider?.value = 5
        self.thicknessSlider?.addTarget(self, action: #selector(buttonItemClicked_changes(_:)), for: .valueChanged)
        if(thicknessSlider != nil) {
            self.thicknessView?.addSubview(thicknessSlider!)
        }
        
        self.signatureDrawTextView = CSignatureDrawView(frame: CGRect.zero)
        self.signatureDrawTextView?.delegate = self
        self.signatureDrawTextView?.color = UIColor.black
        self.signatureDrawTextView?.autoresizingMask = .flexibleHeight
        if(thicknessSlider != nil) {
            self.signatureDrawTextView?.lineWidth = CGFloat(self.thicknessSlider!.value)
        }
        if(signatureDrawTextView != nil) {
            self.view.addSubview(self.signatureDrawTextView!)
        }
        self.signatureDrawImageView = CSignatureDrawView()
        self.signatureDrawImageView?.delegate = self
        self.signatureDrawImageView?.color = UIColor.black
        self.signatureDrawImageView?.lineWidth = 4
        self.signatureDrawImageView?.isUserInteractionEnabled = false
        if(signatureDrawImageView != nil) {
            self.view.addSubview(self.signatureDrawImageView!)
        }
        self.signatureDrawImageView?.isHidden = true
        self.cancelButton = UIButton()
        self.cancelButton?.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        self.cancelButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        self.cancelButton?.setTitleColor(UIColor.black, for: .normal)
        self.cancelButton?.addTarget(self, action: #selector(buttonItemClicked_Cancel(_:)), for: .touchUpInside)
        if(cancelButton != nil) {
            self.headerView?.addSubview(self.cancelButton!)
        }
        
        self.saveButton = UIButton()
        self.saveButton?.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        self.saveButton?.setTitleColor(UIColor.gray, for: .normal)
        self.saveButton?.isEnabled = false
        self.saveButton?.addTarget(self, action: #selector(buttonItemClicked_Save(_:)), for: .touchUpInside)
        if(saveButton != nil) {
            self.headerView?.addSubview(self.saveButton!)
        }
        self.bottomBorder = CALayer()
        self.bottomBorder?.backgroundColor = UIColor.black.cgColor
        self.textField = UITextField()
        self.textField?.delegate = self
        self.textField?.textColor = UIColor.black
        self.textField?.placeholder = NSLocalizedString("Enter your signature", comment: "")
        self.textField?.textAlignment = .center
        self.textField?.font = UIFont.systemFont(ofSize: 30)
        self.textField?.addTarget(self, action: #selector(textTextField_change(_:)), for: .editingChanged)
        if(textField != nil) {
            self.view.addSubview(self.textField!)
        }
        if(bottomBorder != nil) {
            self.textField?.layer.addSublayer(self.bottomBorder!)
        }
        self.textField?.isHidden = true
        self.createButton = UIButton()
        self.createButton?.layer.cornerRadius = 25.0
        self.createButton?.clipsToBounds = true
        self.createButton?.setImage(UIImage(named: "CPDFSignatureImageAdd", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        self.createButton?.backgroundColor = UIColor.blue
        self.createButton?.addTarget(self, action: #selector(buttonItemClicked_create(_:)), for: .touchUpInside)
        if(createButton != nil) {
            self.view.addSubview(self.createButton!)
        }
        self.createButton?.isHidden = true
        self.clearButton = UIButton()
        self.clearButton?.setImage(UIImage(named: "CPDFSignatureImageClean", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        self.clearButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        self.clearButton?.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        self.clearButton?.layer.borderColor = UIColor.gray.cgColor
        self.clearButton?.layer.borderWidth = 1.0
        self.clearButton?.layer.cornerRadius = 25.0
        self.clearButton?.layer.masksToBounds = true
        self.clearButton?.setTitleColor(UIColor.gray, for: .normal)
        self.clearButton?.addTarget(self, action: #selector(buttonItemClicked_clear(_:)), for: .touchUpInside)
        if(clearButton != nil) {
            self.view.addSubview(self.clearButton!)
        }
        self.selectedIndex = .defaults
        self.view.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        createGestureRecognizer()
        updatePreferredContentSizeWithTraitCollection(traitCollection: traitCollection)
        self.isImageSignature = false
        self.isDrawSignature = false
        self.isImageSignature = false
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        headerView?.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50)
        segmentedControl?.frame = CGRect(x: (view.frame.size.width - 220)/2, y: 10, width: 220, height: 30)
        emptyLabel?.frame = CGRect(x: (view.frame.size.width - 200)/2, y: (view.frame.size.height - 50)/2, width: 200, height: 50)
        if #available(iOS 11.0, *) {
            let currentOrientation = UIApplication.shared.statusBarOrientation
            if currentOrientation.isPortrait {
                colorSelectView?.frame = CGRect(x: view.safeAreaInsets.left, y: 50, width: 380, height: 60)
                colorSelectView?.colorPickerView?.frame = CGRect(x: 0, y: 0, width: colorSelectView?.frame.size.width ?? 0, height: colorSelectView?.frame.size.height ?? 0)
                thicknessView?.frame = CGRect(x: view.safeAreaInsets.left, y: 140, width: view.frame.size.width-view.safeAreaInsets.left-view.safeAreaInsets.right, height: 60)
                thicknessLabel?.frame = CGRect(x: 20, y: 15, width: 60, height: 30)
                thicknessSlider?.frame = CGRect(x: 90, y: 0, width: (thicknessView?.bounds.size.width ?? 0)-110, height: 60)
                signatureDrawTextView?.frame = CGRect(x: view.safeAreaInsets.left, y: 210, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: view.frame.size.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom-150)
            } else if currentOrientation.isLandscape {
                colorSelectView?.frame = CGRect(x: view.safeAreaInsets.left, y: 50, width: 380, height: 60)
                thicknessView?.frame = CGRect(x: 380, y: 70, width: view.frame.size.width-380-view.safeAreaInsets.right, height: 60)
                thicknessLabel?.frame = CGRect(x: 20, y: 15, width: 60, height: 30)
                thicknessSlider?.frame = CGRect(x: 90, y: 0, width: (thicknessView?.bounds.size.width ?? 0)-110, height: 60)
                signatureDrawTextView?.frame = CGRect(x: view.safeAreaInsets.left, y: 130, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: view.frame.size.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom-130)
            }
            saveButton?.frame = CGRect(x: view.frame.size.width - 60 - view.safeAreaInsets.right, y: 5, width: 50, height: 40)
            cancelButton?.frame = CGRect(x: view.safeAreaInsets.left+20, y: 5, width: 50, height: 40)
            signatureDrawImageView?.frame = CGRect(x: view.safeAreaInsets.left, y: 50, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: view.frame.size.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom-150)
            createButton?.frame = CGRect(x: view.frame.size.width - 70 - view.safeAreaInsets.right, y: view.frame.size.height - 100 - view.safeAreaInsets.bottom, width: 50, height: 50)
            clearButton?.frame = CGRect(x: view.frame.size.width - 70 - view.safeAreaInsets.right, y: view.frame.size.height - 100 - view.safeAreaInsets.bottom, width: 50, height: 50)
        } else {
            let currentOrientation = UIApplication.shared.statusBarOrientation
            if currentOrientation.isPortrait {
                colorSelectView?.frame = CGRect(x: 10, y: 50, width: 380, height: 60)
                colorSelectView?.colorPickerView?.frame = CGRect(x: 0, y: 0, width: colorSelectView?.frame.size.width ?? 0, height: colorSelectView?.frame.size.height ?? 0)
                thicknessView?.frame = CGRect(x: 10, y: 140, width: view.frame.size.width-20, height: 60)
                thicknessLabel?.frame = CGRect(x: 20, y: 15, width: 60, height: 30)
                thicknessSlider?.frame = CGRect(x: 90, y: 0, width: (thicknessView?.bounds.size.width ?? 0)-110, height: 60)
                signatureDrawTextView?.frame = CGRect(x: 10, y: 210, width: view.frame.size.width-20, height: view.frame.size.height-114-150)
            } else if currentOrientation.isLandscape {
                colorSelectView?.frame = CGRect(x: 10, y: 50, width: 380, height: 60)
                thicknessView?.frame = CGRect(x: 380, y: 70, width: view.frame.size.width-380-10, height: 60)
                thicknessLabel?.frame = CGRect(x: 20, y: 15, width: 60, height: 30)
                thicknessSlider?.frame = CGRect(x: 90, y: 0, width: (thicknessView?.bounds.size.width ?? 0)-110, height: 60)
                signatureDrawTextView?.frame = CGRect(x: 10, y: 130, width: view.frame.size.width-20, height: view.frame.size.height-114-130)
            }
            signatureDrawImageView?.frame = signatureDrawTextView?.frame ?? CGRect.zero
            createButton?.frame = CGRect(x: view.frame.size.width - 70, y: view.frame.size.height - 100, width: 50, height: 50)
            clearButton?.frame = CGRect(x: view.frame.size.width - 70, y: view.frame.size.height - 100, width: 50, height: 50)
            saveButton?.frame = CGRect(x: view.frame.size.width - 60, y: 5, width: 50, height: 40)
            cancelButton?.frame = CGRect(x: 20, y: 5, width: 50, height: 40)
            
        }
        textField?.frame = CGRect(x: (view.frame.size.width - 300)/2, y: 200, width: 300, height: 100)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if segmentedControl?.selectedSegmentIndex == 1 {
            textField?.resignFirstResponder()
        } else if (segmentedControl?.selectedSegmentIndex == 0) || (segmentedControl?.selectedSegmentIndex == 2) {
            signatureDrawTextView?.signatureClear();
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSizeWithTraitCollection(traitCollection: newCollection)
    }
    
    // MARK: - Private Methods
    
    func initSegmentedControl() {
        let segmmentArray = [NSLocalizedString("Trackpad", comment: ""), NSLocalizedString("Keyboard", comment: ""), NSLocalizedString("Image", comment: "")]
        segmentedControl = UISegmentedControl(items: segmmentArray)
        segmentedControl?.selectedSegmentIndex = 0
        segmentedControl?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        segmentedControl?.addTarget(self, action: #selector(segmentedControlValueChanged_singature(_:)), for: .valueChanged)
        if(segmentedControl != nil) {
            self.view.addSubview(segmentedControl!)
        }
    }
    
    func updatePreferredContentSizeWithTraitCollection(traitCollection: UITraitCollection) {
        if self.colorPicker?.superview != nil {
            let currentDevice = UIDevice.current
            if currentDevice.userInterfaceIdiom == .pad {
                // This is an iPad
                self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: 520)
            } else {
                // This is an iPhone or iPod touch
                self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: 320)
            }
        } else {
            let width = UIScreen.main.bounds.size.width
            let height = UIScreen.main.bounds.size.height
            let mWidth = min(width, height)
            let mHeight = max(width, height)
            let currentDevice = UIDevice.current
            if currentDevice.userInterfaceIdiom == .pad {
                // This is an iPad
                self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? mWidth * 0.5 : mHeight * 0.6)
            } else {
                // This is an iPhone or iPod touch
                self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? mWidth * 0.9 : mHeight * 0.9)
            }
            
        }
    }
    
    func createGestureRecognizer() {
        self.createButton?.isUserInteractionEnabled = true
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panaddBookmarkBtn(_:)))
        self.createButton?.addGestureRecognizer(panRecognizer)
        
    }
    
    @objc func panaddBookmarkBtn(_ gestureRecognizer: UIPanGestureRecognizer) {
        let point = gestureRecognizer.translation(in: self.view)
        let newX = (self.createButton?.center.x ?? 0) + point.x
        let newY = (self.createButton?.center.y ?? 0 ) + point.y
        if self.view.frame.contains(CGPoint(x: newX, y: newY)) {
            self.createButton?.center = CGPoint(x: newX, y: newY)
        }
        gestureRecognizer.setTranslation(.zero, in: self.view)
    }
    
    func image(with view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        if let ctx = UIGraphicsGetCurrentContext() {
            view.layer.render(in: ctx)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        return nil
    }
    
    func labelAutoCalculateRect(with text: String, font: UIFont) -> CGSize {
        let paragraphStyle = NSMutableParagraphStyle()
        let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        
        var labelSize = (text as NSString).boundingRect(with: maxSize, options: [.usesLineFragmentOrigin, .usesFontLeading, .truncatesLastVisibleLine], attributes: attributes, context: nil).size
        
        labelSize.height = ceil(labelSize.height)
        labelSize.width = ceil(labelSize.width)
        
        return labelSize
    }

    
    func initDrawSignatureViewProperties() {
        self.colorSelectView?.isHidden = false
        self.signatureDrawTextView?.isHidden = false
        self.selectedIndex? = .defaults
        self.colorSelectView?.isHidden = false
        self.clearButton?.isHidden = false
        self.signatureDrawTextView?.selectIndex = .text
        self.emptyLabel?.isHidden = false
        self.thicknessView?.isHidden = false
        self.signatureDrawImageView?.isHidden = true
        self.createButton?.isHidden = true
        self.textField?.isHidden = true
        self.textField?.resignFirstResponder()
        if self.isDrawSignature {
            self.saveButton?.setTitleColor(UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0), for: .normal)
            self.saveButton?.isEnabled = true
        } else {
            self.saveButton?.setTitleColor(UIColor.gray, for: .normal)
            self.saveButton?.isEnabled = false
        }
        
    }
    
    func initTextSignatureViewProperties() {
        self.colorSelectView?.isHidden = false
        self.signatureDrawTextView?.isHidden = true
        self.signatureDrawImageView?.isHidden = true
        self.textField?.isHidden = false
        self.selectedIndex = .text
        self.colorSelectView?.isHidden = false
        self.createButton?.isHidden = true
        self.thicknessView?.isHidden = true
        self.clearButton?.isHidden = false
        self.emptyLabel?.isHidden = true
        self.textField?.becomeFirstResponder()
        if self.isTextSignature {
            self.saveButton?.setTitleColor(UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0), for: .normal)
            self.saveButton?.isEnabled = true
        } else {
            self.saveButton?.setTitleColor(UIColor.gray, for: .normal)
            self.saveButton?.isEnabled = false
        }
        
    }
    
    func initImageSignatureViewProperties() {
        self.textField?.resignFirstResponder()
        self.colorSelectView?.isHidden = true
        self.signatureDrawTextView?.isHidden = true
        self.signatureDrawImageView?.isHidden = false
        self.textField?.isHidden = true
        self.selectedIndex = .image
        self.createButton?.isHidden = false
        self.colorSelectView?.isHidden = true
        self.signatureDrawImageView?.selectIndex = .image
        self.thicknessView?.isHidden = true
        self.clearButton?.isHidden = true
        self.emptyLabel?.isHidden = true
        self.signatureDrawImageView?.setNeedsDisplay()
        if self.isImageSignature {
            self.saveButton?.setTitleColor(UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0), for: .normal)
            self.saveButton?.isEnabled = true
        } else {
            self.saveButton?.setTitleColor(UIColor.gray, for: .normal)
            self.saveButton?.isEnabled = false
        }
        
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_Save(_ sender: Any) {
        if .defaults == self.selectedIndex {
            let image = self.signatureDrawTextView?.signatureImage()
            if(image != nil) {
                delegate?.signatureEditViewController?(self, image: image ?? UIImage())
            }
        } else if .image == self.selectedIndex {
            self.signatureDrawTextView?.signatureClear()
            let image = self.signatureDrawImageView?.signatureImage()
            if(image != nil) {
                delegate?.signatureEditViewController?(self, image: image ?? UIImage())
            }
        } else if .text == self.selectedIndex {
            let image = createTextSignature()
            if self.textField!.text?.isEmpty ?? true {
                let alertController = UIAlertController(title: "Info", message: "Please input Signature", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            if (self.textField?.text) != nil {
                delegate?.signatureEditViewController?(self, image: image )
            }
        }
    }
    
    @objc func buttonItemClicked_Cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func buttonItemClicked_create(_ sender: Any) {
        createImageSignature()
    }
    
    @objc func segmentedControlValueChanged_singature(_ sender: Any) {
        if self.segmentedControl?.selectedSegmentIndex == 0 {
            initDrawSignatureViewProperties()
        } else if self.segmentedControl?.selectedSegmentIndex == 1 {
            initTextSignatureViewProperties()
        } else if self.segmentedControl?.selectedSegmentIndex == 2 {
            initImageSignatureViewProperties()
        }
    }
    
    @objc func buttonItemClicked_changes(_ sender: UISlider) {
        self.signatureDrawTextView?.lineWidth = CGFloat(sender.value)
        self.signatureDrawTextView?.setNeedsDisplay()
    }
    
    @objc func buttonItemClicked_clear(_ button: UIButton) {
        if self.segmentedControl?.selectedSegmentIndex == 0 {
            self.signatureDrawTextView?.signatureClear()
            self.emptyLabel?.text = NSLocalizedString("Enter your signature", comment: "")
            self.isDrawSignature = false
            self.saveButton?.setTitleColor(UIColor.gray, for: .normal)
            self.saveButton?.isEnabled = false
        } else if self.segmentedControl?.selectedSegmentIndex == 1 {
            self.textField?.text = ""
            self.isTextSignature = false
            self.saveButton?.setTitleColor(UIColor.gray, for: .normal)
            self.saveButton?.isEnabled = false
        }
    }
    
    @objc func textTextField_change(_ textField: UITextField) {
        if self.textField?.text?.count ?? 0 > 0 {
            self.isTextSignature = true
            self.saveButton?.setTitleColor(UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0), for: .normal)
            self.saveButton?.isEnabled = true
        } else {
            self.isTextSignature = false
            self.saveButton?.setTitleColor(UIColor.gray, for: .normal)
            self.saveButton?.isEnabled = false
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if UIApplication.shared.statusBarOrientation.isPortrait {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.clearButton?.center = CGPoint(x: self.clearButton?.center.x ?? 0, y: (self.clearButton?.center.y ?? 0)-300)
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.clearButton?.center = CGPoint(x: self.clearButton?.center.x ?? 0, y: (self.clearButton?.center.y ?? 0)-150)
                self.textField?.center = CGPoint(x: self.textField?.center.x ?? 0, y: (self.textField?.center.y ?? 0)-150)
            }, completion: nil)
            self.colorSelectView?.isHidden = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if UIApplication.shared.statusBarOrientation.isPortrait {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.clearButton?.center = CGPoint(x: self.clearButton?.center.x ?? 0, y: (self.clearButton?.center.y ?? 0)+300)
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.clearButton?.center = CGPoint(x: self.clearButton?.center.x ?? 0, y: (self.clearButton?.center.y ?? 0)+150)
                self.textField?.center = CGPoint(x: self.textField?.center.x ?? 0, y: (self.textField?.center.y ?? 0)+150)
            }, completion: nil)
            self.colorSelectView?.isHidden = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Private Methods
    
    func createImageSignature() {
        let cameraAction = UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .default) { (action) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }
        let photoAction = UIAlertAction(title: NSLocalizedString("Choose from Album", comment: ""), style: .default) { (action) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.allowsEditing = true
            imagePickerController.modalPresentationStyle = .popover
            if UI_USER_INTERFACE_IDIOM() == .pad {
                if(self.segmentedControl != nil){
                    imagePickerController.popoverPresentationController?.sourceView = self.segmentedControl!
                    imagePickerController.popoverPresentationController?.sourceRect = CGRect(x: self.segmentedControl!.bounds.maxX, y: self.segmentedControl!.bounds.maxY, width: 1, height: 1)
            }
            }
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            if (self.segmentedControl != nil) {
                actionSheet.popoverPresentationController?.sourceView = self.segmentedControl!
                actionSheet.popoverPresentationController?.sourceRect = CGRect(x: self.segmentedControl!.bounds.maxX, y: self.segmentedControl!.bounds.maxY, width: 1, height: 1)
            }
        }
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(photoAction)
        actionSheet.addAction(cancelAction)
        actionSheet.modalPresentationStyle = .popover
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func createTextSignature() -> UIImage {
        if self.textField?.text?.count ?? 0 < 1 {
            return UIImage()
        }

        let string = self.textField?.text ?? ""
        let font = self.textField?.font
        let size = labelAutoCalculateRect(with: string, font: font ?? UIFont())
        let sideH = size.height + 10

        var w = size.width
        if w + 10 > kKMSignayureTextMaxWidth {
            w = kKMSignayureTextMaxWidth - 10
        }

        let backView = UIView(frame: CGRect(x: 0, y: 0, width: w + 10, height: sideH))
        backView.backgroundColor = UIColor.clear

        let label = UILabel(frame: CGRect(x: 5, y: 5, width: w, height: size.height))
        label.font = font
        label.text = string
        label.textAlignment = .center
        label.numberOfLines = 1
        label.textColor = self.textField?.textColor
        label.adjustsFontSizeToFitWidth = true
        backView.addSubview(label)

        let newImage = image(with: backView) ?? UIImage()
        
        return newImage
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        var image: UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = originalImage
        }
        if image != nil {
            self.isImageSignature = true
            self.saveButton?.setTitleColor(UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0), for: .normal)
            self.saveButton?.isEnabled = true
        }
        
        if let imageOrientation = image?.imageOrientation, imageOrientation != .up {
            UIGraphicsBeginImageContext(image?.size ?? CGSize.zero)
            image?.draw(in: CGRect(x: 0, y: 0, width: image?.size.width ?? 0, height: image?.size.height ?? 0))
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        if let imageData = image?.pngData(), var image = UIImage(data: imageData) {
            let colorMasking: [CGFloat] = [222, 255, 222, 255, 222, 255]
            let imageRef = image.cgImage?.copy(maskingColorComponents: colorMasking)
            if let imageRef = imageRef {
                image = UIImage(cgImage: imageRef)
            }
            
            self.signatureDrawImageView?.image = image
            self.signatureDrawImageView?.setNeedsDisplay()
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // MARK: - CPDFColorSelectViewDelegate
    
    func selectColorView(_ select: CPDFColorSelectView, color: UIColor) {
        self.textField?.textColor = color
        self.signatureDrawTextView?.color = color
        self.signatureDrawTextView?.setNeedsDisplay()
        
    }
    
    func selectColorView(_ select: CPDFColorSelectView) {
        if #available(iOS 14.0, *) {
            let picker = UIColorPickerViewController()
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        } else {
            let currentDevice = UIDevice.current
            if currentDevice.userInterfaceIdiom == .pad {
                // This is an iPad
                self.colorPicker = CPDFColorPickerView(frame: CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.size.width, height: 520))
            } else {
                // This is an iPhone or iPod touch
                self.colorPicker = CPDFColorPickerView(frame: CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.size.width, height: 320))
            }
            self.colorPicker?.delegate = self
            self.colorPicker?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
            if(self.colorPicker != nil) {
                self.view.addSubview(self.colorPicker!)
            }
            self.updatePreferredContentSizeWithTraitCollection(traitCollection: traitCollection)
        }
        
    }
    
    // MARK: - CPDFColorPickerViewDelegate
    
    func pickerView(_ colorPickerView: CPDFColorPickerView, color: UIColor) {
        signatureDrawTextView?.color = color
        
        self.textField?.textColor = color
        self.signatureDrawTextView?.color = color
        self.signatureDrawTextView?.setNeedsDisplay()
        
        self.updatePreferredContentSizeWithTraitCollection(traitCollection: traitCollection)
    }
    
    // MARK: - UIColorPickerViewControllerDelegate
    
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        signatureDrawTextView?.color = viewController.selectedColor
        
        self.textField?.textColor = viewController.selectedColor
        self.signatureDrawTextView?.setNeedsDisplay()
    }
    
    // MARK: - CSignatureDrawViewDelegate
    
    func signatureDrawViewStart(_ signatureDrawView: CSignatureDrawView) {
        if self.segmentedControl?.selectedSegmentIndex == 0 {
            self.saveButton?.setTitleColor(UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0), for: .normal)
            self.saveButton?.isEnabled = true
            self.isDrawSignature = true
            self.emptyLabel?.text = ""
        } else if self.segmentedControl?.selectedSegmentIndex == 2 {
            self.saveButton?.setTitleColor(UIColor(red: 20.0/255.0, green: 96.0/255.0, blue: 243.0/255.0, alpha: 1.0), for: .normal)
            self.saveButton?.isEnabled = true
            self.isImageSignature = true
            self.emptyLabel?.text = ""
        }
    }
    
    
}




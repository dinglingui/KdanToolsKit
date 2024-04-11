//
//  CPDFAddWatermarkViewController.swift
//  PDFViewer-Swift
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

@objc public protocol CPDFAddWatermarkViewControllerDelegate: AnyObject {
    @objc optional func addWatermarkViewControllerSave(_ addWatermarkViewControllerSave: CPDFAddWatermarkViewController, Text textWaterModel: CWatermarkModel)
    @objc optional func addWatermarkViewControllerSave(_ addWatermarkViewControllerSave: CPDFAddWatermarkViewController, Image imageWaterModel: CWatermarkModel)
}

public class CPDFAddWatermarkViewController: UIViewController, CPDFTextWatermarkSettingViewControllerDelegate, CPDFImageWatermarkSettingViewControllerDelegate {
    
    public weak var delegate: CPDFAddWatermarkViewControllerDelegate?
    
    private var segmentedControl: UISegmentedControl?
    private var fileURL: URL?
    private var preIamgeView: UIImageView?
    private var document: CPDFDocument?
    private var pageSize: CGSize = .zero
    private var page: CPDFPage?
    private var textWaterModel:  CWatermarkModel?
    private var imageWaterModel: CWatermarkModel?
    
    var moveBeginCenter = CGPoint.zero
    var moveBeginPoint = CGPoint.zero
    var rotateBeginTransform = CGAffineTransform.identity
    var moveBeginFontSize: CGFloat = 0.0
    var moveRotateBeginCenter: CGPoint = .zero
    var moveBeginBounds: CGRect = .zero
    var initialAngle:CGFloat = 0.0
   
    private var textWatermarkPreView: CTextWatermarkPreView?
    private var imageWatermarkPreView: CImageWatermarkPreView?
    private var textWatermarkSettingViewController: CPDFTextWatermarkSettingViewController?
    private var imageWatermarkSettingViewController: CPDFImageWatermarkSettingViewController?
    
    // MARK: - Init
    
    public init(fileURL: URL?, document: CPDFDocument?) {
        super.init(nibName: nil, bundle: nil)
        self.fileURL = fileURL
        
        self.document = document
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController Methods
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initWitNavigation()
        
        page = document?.page(at: 0)
        pageSize = document?.pageSize(at: 0) ?? .zero
        
        textWatermarkPreView = CTextWatermarkPreView.init(frame: view.bounds, Image: page?.thumbnail(of: pageSize))
        imageWatermarkPreView = CImageWatermarkPreView.init(frame: view.bounds, Image: page?.thumbnail(of: pageSize))
        
        let image = UIImage(named: "CLog", in: Bundle(for: CImageWatermarkPreView.classForCoder()), compatibleWith: nil) ?? UIImage()
        imageWatermarkPreView?.preImageView?.image = imageWithImageSimple(image,scale: CGSize(width: 60, height: 60))
        imageWatermarkPreView?.preImageView?.sizeToFit()
        
        if imageWatermarkPreView != nil {
            view.addSubview(imageWatermarkPreView!)
        }
        
        if textWatermarkPreView != nil {
            view.addSubview(textWatermarkPreView!)
        }
        
        textWatermarkPreView?.isHidden = false
        imageWatermarkPreView?.isHidden = true
        
        createTextPreViewGestureRecognizer()
        createImagePreViewGestureRecognizer()
        
        initTextWaterModel()
        initImageWaterModel()
        
        textWatermarkSettingViewController = CPDFTextWatermarkSettingViewController(waterModel: textWaterModel)
        textWatermarkSettingViewController?.delegate = self
        if textWatermarkSettingViewController != nil {
            let presentationController = AAPLCustomPresentationController.init(presentedViewController: textWatermarkSettingViewController!, presenting: self)
            textWatermarkSettingViewController?.transitioningDelegate = presentationController
            self.present(textWatermarkSettingViewController!, animated: true)
        }
    }
    
    public override func viewWillLayoutSubviews() {
        textWatermarkPreView?.frame = view.bounds
        imageWatermarkPreView?.frame = view.bounds
        let multiple = min(view.bounds.size.width / pageSize.width, view.bounds.size.height / pageSize.height)
        textWatermarkPreView?.documentSize = CGSize(width: pageSize.width * multiple, height: pageSize.height * multiple)
        textWatermarkPreView?.setNeedsLayout()
        imageWatermarkPreView?.documentSize = CGSize(width: pageSize.width * multiple, height: pageSize.height * multiple)
        imageWatermarkPreView?.setNeedsLayout()
        
        var bounds = textWatermarkPreView?.preLabel?.bounds
        bounds = adaptWidth(with: (textWatermarkPreView?.preLabel)!, fontSize: textWaterModel?.watermarkScale ?? 0)
        textWatermarkPreView?.preLabel?.bounds = bounds ?? .zero
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textWatermarkPreView?.setNeedsDisplay()
        imageWatermarkPreView?.setNeedsDisplay()
    }
    
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        textWatermarkPreView?.setNeedsDisplay()
        imageWatermarkPreView?.setNeedsDisplay()
    }
    
    // MARK: - Public Methods
    
    func showView() {
        buttonItemClicked_setting(UIButton())
    }
    
    // MARK: - Private Methods
    
    private func initTextWaterModel() {
        textWaterModel = CWatermarkModel()
        textWaterModel?.text = NSLocalizedString("Watermark", comment: "")
        textWaterModel?.watermarkScale = 24.0
        textWaterModel?.watermarkOpacity = 1.0
        textWaterModel?.isTile = false
        textWaterModel?.isFront = true
        textWaterModel?.textColor = .black
        textWaterModel?.fontName = "Helvetica"
        textWaterModel?.fontStyleName = "Regular"
        textWaterModel?.watermarkRotation = 0.0
        textWaterModel?.fileURL = fileURL
        textWaterModel?.horizontalSpacing = 30
        textWaterModel?.verticalSpacing = 30
        textWaterModel?.pageString = ""
        
        textTileViewRefresh()
    }
    
    private func initImageWaterModel() {
        imageWaterModel = CWatermarkModel()
        imageWaterModel?.watermarkScale = 24.0
        imageWaterModel?.watermarkOpacity = 1.0
        imageWaterModel?.isTile = false
        imageWaterModel?.isFront = true
        imageWaterModel?.watermarkRotation = 0.0
        imageWaterModel?.pageString = ""
        let image = UIImage(named: "CLog", in: Bundle(for: CImageWatermarkPreView.classForCoder()), compatibleWith: nil) ?? UIImage()
        imageWaterModel?.image = imageWithImageSimple(image,scale: CGSize(width: 60, height: 60))
        imageWaterModel?.fileURL = fileURL
        imageWaterModel?.horizontalSpacing = 30
        imageWaterModel?.verticalSpacing = 30
        imageWaterModel?.pageString = ""
        
        imageTileViewRefresh()
    }
    
    private func textTileViewRefresh() {
        textWatermarkPreView?.textTileView?.stransform = CGAffineTransform(rotationAngle: -(360.0-textWaterModel!.watermarkRotation)*CGFloat.pi/180.0)
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        textWaterModel?.textColor?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        textWatermarkPreView?.textTileView?.fontColor = UIColor(red: red, green: green, blue: blue, alpha: textWaterModel?.watermarkOpacity ?? 1)
        textWatermarkPreView?.textTileView?.fontSize = textWaterModel?.watermarkScale ?? 20.0
        textWatermarkPreView?.textTileView?.waterString = textWaterModel?.text
        textWatermarkPreView?.textTileView?.centerPoint = textWatermarkPreView?.preLabel?.center ?? .zero
        let familyName = textWaterModel?.fontName
        let styleName = textWaterModel?.fontStyleName

        textWatermarkPreView?.textTileView?.familyName = familyName
        textWatermarkPreView?.textTileView?.fontStyleName = styleName

        textWatermarkPreView?.textTileView?.setNeedsDisplay()
    }
    
    private func imageTileViewRefresh() {
        imageWatermarkPreView?.imageTileView?.stransform = CGAffineTransform(rotationAngle: -(360.0-imageWaterModel!.watermarkRotation)*CGFloat.pi/180.0)
        imageWatermarkPreView?.imageTileView?.waterImageView = imageWatermarkPreView?.preImageView
        imageWatermarkPreView?.imageTileView?.centerPoint = imageWatermarkPreView?.preImageView?.center ?? .zero
        
        imageWatermarkPreView?.imageTileView?.setNeedsDisplay()
    }
    
    private func initWitNavigation() {
        let backItem = UIBarButtonItem(image: UIImage(named: "CPDFViewImageBack", in: Bundle(for: CPDFAddWatermarkViewController.classForCoder()), compatibleWith: nil), style: .plain, target: self, action: #selector(buttonItemClicked_back(_:)))
        navigationItem.leftBarButtonItem = backItem
        
        let settingItem = UIBarButtonItem(image: UIImage(named: "CWatermarkNavigationSettingImage", in: Bundle(for: CPDFAddWatermarkViewController.classForCoder()), compatibleWith: nil), style: .plain, target: self, action: #selector(buttonItemClicked_setting(_:)))
        let saveIten = UIBarButtonItem(title: NSLocalizedString("Share", comment: ""), style: .plain, target: self, action: #selector(buttonItemClicked_save(_:)))
        var rightItems = [UIBarButtonItem]()
        rightItems.append(saveIten)
        rightItems.append(settingItem)
        navigationItem.rightBarButtonItems = rightItems
        
        let segmmentTitleArray = [NSLocalizedString("Text", comment: ""), NSLocalizedString("Image", comment: "")]
        segmentedControl = UISegmentedControl(items: segmmentTitleArray)
        if UIDevice.current.userInterfaceIdiom == .pad {
            segmentedControl?.frame = CGRect(x: 15, y: 44, width: self.view.frame.size.width - 400, height: 30)
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            segmentedControl?.frame = CGRect(x: 15, y: 44, width: self.view.frame.size.width - 200, height: 30)
        }
        segmentedControl?.autoresizingMask = .flexibleWidth
        segmentedControl?.selectedSegmentIndex = 0
        segmentedControl?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        segmentedControl?.addTarget(self, action: #selector(segmentedControlValueChanged_type(_:)), for: .valueChanged)
        if segmentedControl != nil {
            navigationItem.titleView = self.segmentedControl!
        }
    }
    
    private func createTextPreViewGestureRecognizer() {
        textWatermarkPreView?.documentView?.isUserInteractionEnabled = true
        textWatermarkPreView?.preLabel?.isUserInteractionEnabled = true
        textWatermarkPreView?.rotationBtn?.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapWatermarkLabel(_:)))
        textWatermarkPreView?.preLabel?.addGestureRecognizer(tapGestureRecognizer)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panWatermarkLabel(_:)))
        textWatermarkPreView?.preLabel?.addGestureRecognizer(panRecognizer)
        
        let panRotationBtnRecognizer = UIPanGestureRecognizer(target: self, action: #selector(rotationWatermarkLabel(_:)))
        textWatermarkPreView?.rotationBtn?.addGestureRecognizer(panRotationBtnRecognizer)
    }
    
    private func createImagePreViewGestureRecognizer() {
        imageWatermarkPreView?.documentView?.isUserInteractionEnabled = true
        imageWatermarkPreView?.preImageView?.isUserInteractionEnabled = true
        imageWatermarkPreView?.rotationBtn?.isUserInteractionEnabled = true
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panWatermarkImageView(_:)))
        imageWatermarkPreView?.preImageView?.addGestureRecognizer(panRecognizer)
        
        let panRotationBtnRecognizer = UIPanGestureRecognizer(target: self, action: #selector(rotationWatermarkImageView(_:)))
        imageWatermarkPreView?.rotationBtn?.addGestureRecognizer(panRotationBtnRecognizer)
    }
    
    private func imageWithImageSimple(_ image: UIImage) -> UIImage? {
        let multiple = max(image.size.width / 180, image.size.height / 240)
        let size = CGSize(width: image.size.width / multiple, height: image.size.height / multiple)
        
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    private func imageWithImageSimple(_ image: UIImage, scale size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func adaptWidth(with content: UILabel, fontSize: CGFloat) -> CGRect {
        if content.text == nil || content.text == "" {
            content.text = NSLocalizedString("", comment: "")
        }
        
        let fn = content.font.fontName 
        let font = UIFont(name: fn, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        content.font = font
        
        let attributedString = NSAttributedString(string: content.text ?? "", attributes: [.font: font])
        var rectSize = attributedString.boundingRect(with: CGSize(width: 0, height: 0), options: .usesLineFragmentOrigin, context: nil)
        rectSize = CGRect(x: rectSize.origin.x, y: rectSize.origin.y, width: rectSize.size.width + 20, height: rectSize.size.height + 20)
        
        content.backgroundColor = .clear
        
        return rectSize
    }
    
    func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        return sqrt(dx * dx + dy * dy)
    }
    
    func shareAction(url: URL?) {
        if (url != nil) {
            let activityVC = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
            activityVC.definesPresentationContext = true
            if UI_USER_INTERFACE_IDIOM() == .pad {
                activityVC.popoverPresentationController?.sourceView = self.navigationController?.navigationBar ?? self.view
                let x = self.navigationController?.navigationBar.frame.width ?? 0
                let rect = CGRect(x: x, y: 0, width: 0, height: 0)

                activityVC.popoverPresentationController?.sourceRect = rect
            }
            self.present(activityVC, animated: true) {
                self.navigationController?.popViewController(animated: false)
            }
            activityVC.completionWithItemsHandler = { (activityType, completed, returnedItems, activityError) in
                if completed {
                    print("Success!")
                } else {
                    print("Failed Or Canceled!")
                }
            }
        }
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_back(_ button: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func buttonItemClicked_setting(_ button: UIButton) {
        if ((imageWatermarkSettingViewController?.view.superview) == nil) && ((textWatermarkSettingViewController?.view.superview) == nil) {
            if segmentedControl?.selectedSegmentIndex == 0 {
                textWatermarkSettingViewController = CPDFTextWatermarkSettingViewController(waterModel: textWaterModel)
                textWatermarkSettingViewController?.delegate = self
                let presentationController = AAPLCustomPresentationController.init(presentedViewController: textWatermarkSettingViewController!, presenting: self)
                textWatermarkSettingViewController!.transitioningDelegate = presentationController
                self.present(textWatermarkSettingViewController!, animated: true)
                
            } else if (segmentedControl?.selectedSegmentIndex == 1) {
                imageWatermarkSettingViewController = CPDFImageWatermarkSettingViewController(waterModel: imageWaterModel)
                imageWatermarkSettingViewController?.delegate = self
                let presentationController = AAPLCustomPresentationController.init(presentedViewController: imageWatermarkSettingViewController!, presenting: self)
                imageWatermarkSettingViewController!.transitioningDelegate = presentationController
                self.present(imageWatermarkSettingViewController!, animated: true)
            }
        }
    }
    
    @objc func buttonItemClicked_save(_ button: UIButton) {
        if (!(FileManager.default.fileExists(atPath: TEMPOARTFOLDER))) {
            try? FileManager.default.createDirectory(atPath: TEMPOARTFOLDER, withIntermediateDirectories: true, attributes: nil)
        }
        
        guard let lastPathComponent = self.document?.documentURL.deletingPathExtension().lastPathComponent else { return  }
        
        let secPath = TEMPOARTFOLDER + "/" + lastPathComponent + "_Watermark.pdf"
        do {
            try FileManager.default.removeItem(atPath: secPath)
        } catch {
            // Handle the error, e.g., print an error message or perform other actions
        }
        
        let url = NSURL(fileURLWithPath: secPath) as URL
        
        self.document?.write(to: url)
        
        let waterDocument = CPDFDocument(url: url)
        
        if waterDocument?.isLocked == true {
            waterDocument?.unlock(withPassword: document?.password)
        }
    
        if segmentedControl?.selectedSegmentIndex == 0 {
            textWaterModel?.horizontalSpacing = 30.0 / (textWatermarkPreView?.documentView?.size.width ?? 0)
            textWaterModel?.verticalSpacing = 30.0 / (textWatermarkPreView?.documentView?.size.height ?? 0)
            
            let tx = (textWatermarkPreView?.preLabel?.centerX ?? 0) - ((textWatermarkPreView?.documentView?.size.width ?? 0) / 2)
            let ty = -((textWatermarkPreView?.preLabel?.centerY ?? 0) - ((textWatermarkPreView?.documentView?.size.height ?? 0) / 2))
            textWaterModel?.tx = tx / ((textWatermarkPreView?.documentView?.size.width ?? 0) / 2)
            textWaterModel?.ty = ty / ((textWatermarkPreView?.documentView?.size.height ?? 0) / 2)

            
            let page = waterDocument?.page(at: 0)
            
            let textWatermark = CPDFWatermark(document: waterDocument, type: .text)
            
            textWatermark?.text = textWaterModel?.text
            let familyName = textWaterModel?.fontName
            let styleName = textWaterModel?.fontStyleName

            let font = CPDFFont(familyName: familyName ?? "Helvetica", fontStyle: styleName ?? "")
            textWatermark?.cFont = font
            textWatermark?.fontSize = textWaterModel?.watermarkScale ?? 0
            textWatermark?.textColor = textWaterModel?.textColor
            textWatermark?.scale = (page?.size.width ?? 0) / (textWatermarkPreView?.documentView?.size.width ?? 24)
            textWatermark?.isTilePage = textWaterModel?.isTile ?? false
            textWatermark?.isFront = textWaterModel?.isFront ?? true
            textWatermark?.tx = (textWaterModel?.tx ?? 0) * ((page?.size.width ?? 0) / 2)
            textWatermark?.ty = (textWaterModel?.ty ?? 0) * ((page?.size.height ?? 0) / 2)
            textWatermark?.rotation = textWaterModel?.watermarkRotation ?? 0
            if textWaterModel?.pageString?.isEmpty == true {
                if let pageCount = waterDocument?.pageCount, pageCount > 1 {
                    textWaterModel?.pageString = "0-\(pageCount - 1)"
                } else {
                    textWaterModel?.pageString = "0"
                }
            }
            textWatermark?.pageString = textWaterModel?.pageString
            
            if textWatermark?.isTilePage == true {
                textWatermark?.verticalSpacing = (textWaterModel?.verticalSpacing ?? 0) * (page?.size.height ?? 0)
                textWatermark?.horizontalSpacing = (textWaterModel?.horizontalSpacing ?? 0) * (page?.size.width ?? 0)
            }
            
            waterDocument?.addWatermark(textWatermark)
            waterDocument?.write(to: url)
            
            shareAction(url: url)

        } else if segmentedControl?.selectedSegmentIndex == 1 {
            imageWaterModel?.horizontalSpacing = 30.0 / (imageWatermarkPreView?.documentView?.size.width ?? 0)
            imageWaterModel?.verticalSpacing = 30.0 / (imageWatermarkPreView?.documentView?.size.height ?? 0)
            
            let tx = (imageWatermarkPreView?.preImageView?.centerX ?? 0) - ((imageWatermarkPreView?.documentView?.size.width ?? 0) / 2)
            let ty = -((imageWatermarkPreView?.preImageView?.centerY ?? 0) - ((imageWatermarkPreView?.documentView?.size.height ?? 0) / 2))
            imageWaterModel?.tx = tx / ((imageWatermarkPreView?.documentView?.size.width ?? 0) / 2)
            imageWaterModel?.ty = ty / ((imageWatermarkPreView?.documentView?.size.height ?? 0) / 2)
            
            imageWaterModel?.watermarkScale = (imageWatermarkPreView?.preImageView?.frame.size.width ?? 0) / (imageWatermarkPreView?.documentView?.size.width ?? 0) / (imageWaterModel?.image?.size.width ?? 0)
            
            let page = waterDocument?.page(at: 0)
            
            let imageWatermark = CPDFWatermark(document: waterDocument, type: .image)
            
            imageWatermark?.image = imageWaterModel?.image
            imageWatermark?.scale = (imageWaterModel?.watermarkScale ?? 0) * (page?.size.width ?? 0)
            imageWatermark?.isTilePage = imageWaterModel?.isTile ?? false
            imageWatermark?.isFront = imageWaterModel?.isFront ?? true
            imageWatermark?.tx = (imageWaterModel?.tx ?? 0) * ((page?.size.width ?? 0) / 2)
            imageWatermark?.ty = (imageWaterModel?.ty ?? 0) * ((page?.size.height ?? 0) / 2)
            imageWatermark?.rotation = imageWaterModel?.watermarkRotation ?? 0
            if imageWaterModel?.pageString?.isEmpty == true {
                if let pageCount = waterDocument?.pageCount, pageCount > 1 {
                    imageWaterModel?.pageString = "0-\(pageCount - 1)"
                } else {
                    imageWaterModel?.pageString = "0"
                }
            }
            imageWatermark?.pageString = imageWaterModel?.pageString
            
            if imageWatermark?.isTilePage == true {
                imageWatermark?.verticalSpacing = (imageWaterModel?.verticalSpacing ?? 0) * (page?.size.height ?? 0)
                imageWatermark?.horizontalSpacing = (imageWaterModel?.horizontalSpacing ?? 0) *  (page?.size.width ?? 0)
            }
            
            waterDocument?.addWatermark(imageWatermark)
            waterDocument?.write(to: url)
          
            shareAction(url: url)
        }
    
    }
    
    @objc func segmentedControlValueChanged_type(_ sender: UISegmentedControl) {
        if segmentedControl?.selectedSegmentIndex == 0 {
            if ((imageWatermarkSettingViewController?.view.superview) != nil) {
                imageWatermarkSettingViewController?.dismiss(animated: false)
            }
            
            textWatermarkPreView?.isHidden = false
            imageWatermarkPreView?.isHidden = true
            
            textWatermarkSettingViewController = CPDFTextWatermarkSettingViewController(waterModel: textWaterModel)
            textWatermarkSettingViewController?.delegate = self
            let presentationController = AAPLCustomPresentationController.init(presentedViewController: textWatermarkSettingViewController!, presenting: self)
            textWatermarkSettingViewController!.transitioningDelegate = presentationController
            self.present(textWatermarkSettingViewController!, animated: true)
            
            imageWatermarkPreView?.imageTileView?.isHidden = true
            if textWaterModel?.isTile == true {
                textWatermarkPreView?.textTileView?.isHidden = false
            } else {
                textWatermarkPreView?.textTileView?.isHidden = true
            }
        } else if segmentedControl?.selectedSegmentIndex == 1 {
            if ((textWatermarkSettingViewController?.view.superview) != nil) {
                textWatermarkSettingViewController?.dismiss(animated: false)
            }
            
            textWatermarkPreView?.isHidden = true
            imageWatermarkPreView?.isHidden = false
            
            imageWatermarkSettingViewController = CPDFImageWatermarkSettingViewController(waterModel: imageWaterModel)
            imageWatermarkSettingViewController?.delegate = self
            let presentationController = AAPLCustomPresentationController.init(presentedViewController: imageWatermarkSettingViewController!, presenting: self)
            imageWatermarkSettingViewController!.transitioningDelegate = presentationController
            self.present(imageWatermarkSettingViewController!, animated: true)
            
            textWatermarkPreView?.textTileView?.isHidden = true
            if imageWaterModel?.isTile == true {
                imageWatermarkPreView?.imageTileView?.isHidden = false
            } else {
                imageWatermarkPreView?.imageTileView?.isHidden = true
            }
        }
    }
    
    @objc func tapWatermarkLabel(_ recognizer: UITapGestureRecognizer) {
        let alertController = UIAlertController(title: NSLocalizedString("Text Watermark", comment: ""), message:  NSLocalizedString("Type your watermark text here.", comment: ""), preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.clearButtonMode = .always
        }
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { actio in
            
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Apply", comment: ""), style: .default, handler: { actio in
            if (alertController.textFields?.first?.text?.count ?? 0) > 0 {
                self.textWatermarkPreView?.preLabel?.text = alertController.textFields?.first?.text
                self.textWaterModel?.text = alertController.textFields?.first?.text
                self.textTileViewRefresh()
                self.textWatermarkPreView?.setNeedsDisplay()
                var bounds = self.textWatermarkPreView?.preLabel?.bounds
                bounds = self.adaptWidth(with: (self.textWatermarkPreView?.preLabel)!, fontSize: self.textWaterModel?.watermarkScale ?? 0)
                self.textWatermarkPreView?.preLabel?.bounds = bounds ?? .zero
            }
        }))
        
        self.present(alertController, animated: true)
    }
    
    @objc func panWatermarkLabel(_ recognizer: UIPanGestureRecognizer) {
        if textWaterModel?.isTile == true {
            return
        }
        
        let point = recognizer.translation(in: textWatermarkPreView?.documentView)
        let newX = (textWatermarkPreView?.preLabel?.center.x ?? 0) + point.x
        let newY = (textWatermarkPreView?.preLabel?.center.y ?? 0) + point.y
        let newPoint = CGPoint(x: newX, y: newY)
        if let documentView = textWatermarkPreView?.documentView, documentView.bounds.contains(newPoint) {
            textWatermarkPreView?.preLabel?.center = newPoint
        }
        recognizer.setTranslation(.zero, in: textWatermarkPreView?.documentView)
        
        textTileViewRefresh()
        self.textWatermarkPreView?.setNeedsDisplay()
    }
    
    @objc func panWatermarkImageView(_ recognizer: UIPanGestureRecognizer) {
        if imageWaterModel?.isTile == true {
            return
        }
        
        let point = recognizer.translation(in: imageWatermarkPreView?.documentView)
        let newX = (imageWatermarkPreView?.preImageView?.center.x ?? 0) + point.x
        let newY = (imageWatermarkPreView?.preImageView?.center.y ?? 0) + point.y
        let newPoint = CGPoint(x: newX, y: newY)
        if let documentView = imageWatermarkPreView?.documentView, documentView.bounds.contains(newPoint) {
            imageWatermarkPreView?.preImageView?.center = newPoint
        }
        recognizer.setTranslation(.zero, in: imageWatermarkPreView?.documentView)
        
        imageTileViewRefresh()
        imageWatermarkPreView?.setNeedsDisplay()
    }
    
    @objc func rotationWatermarkImageView(_ recognizer: UIPanGestureRecognizer) {
        guard let label = imageWatermarkPreView?.preImageView,
              let superview = imageWatermarkPreView?.documentView else {
            return
        }
        
        switch recognizer.state {
        case .began:
            let location = recognizer.location(in: superview)
            moveBeginPoint = location
            moveBeginCenter = imageWatermarkPreView?.preImageView?.center ?? .zero
            rotateBeginTransform = imageWatermarkPreView?.preImageView?.transform ?? .identity
            moveBeginBounds = imageWatermarkPreView?.preImageView?.bounds ?? .zero
            let dx = label.center.x - location.x
            let dy = label.center.y - location.y
            initialAngle = atan2(dy, dx)
            let angleDifference = initialAngle - atan2(label.transform.b, label.transform.a)
            label.transform = label.transform.rotated(by: angleDifference)
        case .changed:
            let location = recognizer.location(in: superview)
            let scale = distance(from: location, to: moveBeginCenter) / distance(from: moveBeginPoint, to: moveBeginCenter)
            var bounds = moveBeginBounds
            bounds.size.width = bounds.size.width * scale
            bounds.size.height = bounds.size.height * scale
            imageWatermarkPreView?.preImageView?.bounds = bounds
            imageWatermarkPreView?.setNeedsDisplay()
            
            let dx = label.center.x - location.x
            let dy = label.center.y - location.y
            let angle = atan2(dy, dx)
            label.transform = CGAffineTransform(rotationAngle: angle)
            imageWaterModel?.watermarkRotation = (angle) * 180 / CGFloat.pi
            imageTileViewRefresh()
            imageWatermarkPreView?.setNeedsDisplay()
        default:
            break
        }
    }
        
    @objc func rotationWatermarkLabel(_ recognizer: UIPanGestureRecognizer) {
        guard let label = textWatermarkPreView?.preLabel,
              let superview = textWatermarkPreView?.documentView else {
            return
        }
    
        switch recognizer.state {
        case .began:
            let location = recognizer.location(in: superview)
            moveBeginPoint = location
            moveBeginCenter = textWatermarkPreView?.preLabel?.center ?? .zero
            rotateBeginTransform = textWatermarkPreView?.preLabel?.transform ?? .identity
            moveBeginFontSize = textWatermarkPreView?.preLabel?.font.pointSize ?? 0
            let dx = label.center.x - location.x
            let dy = label.center.y - location.y
            initialAngle = atan2(dy, dx)
            let angleDifference = initialAngle - atan2(label.transform.b, label.transform.a)
            label.transform = label.transform.rotated(by: angleDifference)
            moveRotateBeginCenter = textWatermarkPreView?.rotationBtn?.center ?? .zero
        case .changed:
            let location = recognizer.location(in: superview)
            let scale = distance(from: location, to: moveBeginCenter) / distance(from: moveBeginPoint, to: moveBeginCenter)
        
            let fn = textWatermarkPreView?.preLabel?.font.fontName ?? "Helvetica"
            let font = UIFont(name: fn, size: moveBeginFontSize*scale)?.pointSize ?? 14
            if font < 14.0 {
                return
            }
            textWatermarkPreView?.preLabel?.font = UIFont(name: fn, size: moveBeginFontSize*scale)
            textWaterModel?.watermarkScale = textWatermarkPreView?.preLabel?.font.pointSize ?? 14
            textWatermarkPreView?.preLabel?.sizeToFit()
            textWatermarkPreView?.setNeedsDisplay()
            var bounds = textWatermarkPreView?.preLabel?.bounds
            bounds = adaptWidth(with: (textWatermarkPreView?.preLabel)!, fontSize: textWaterModel!.watermarkScale)
            textWatermarkPreView?.preLabel?.bounds = bounds!
            
            let dx = label.center.x - location.x
            let dy = label.center.y - location.y
            let angle = atan2(dy, dx)
            label.transform = CGAffineTransform(rotationAngle: angle)
            textWaterModel?.watermarkRotation = (angle) * 180 / CGFloat.pi
            textTileViewRefresh()
            self.textWatermarkPreView?.setNeedsDisplay()
        default:
            break
        }
    }

    
    // MARK: - CPDFTextWatermarkSettingViewControllerDelegate
    
    func textWatermarkSettingViewControllerSetting(_ textWatermarkSettingViewController: CPDFTextWatermarkSettingViewController, Color color: UIColor) {
        textWaterModel?.textColor  = color
        textWatermarkPreView?.preLabel?.textColor = textWaterModel?.textColor
        textTileViewRefresh()
    }
    
    func textWatermarkSettingViewControllerSetting(_ textWatermarkSettingViewController: CPDFTextWatermarkSettingViewController, Opacity opacity: CGFloat) {
        textWaterModel?.watermarkOpacity = opacity
        textWatermarkPreView?.preLabel?.alpha = opacity
        textTileViewRefresh()
    }
    
    func textWatermarkSettingViewControllerSetting(_ textWatermarkSettingViewController: CPDFTextWatermarkSettingViewController, IsFront isFront: Bool) {
        textWaterModel?.isFront = isFront
    }
    
    func textWatermarkSettingViewControllerSetting(_ textWatermarkSettingViewController: CPDFTextWatermarkSettingViewController, IsTile isTile: Bool) {
        textWaterModel?.isTile = isTile
        textWatermarkPreView?.textTileView?.isHidden = !isTile
    }
    
    func textWatermarkSettingViewControllerSetting(_ textWatermarkSettingViewController: CPDFTextWatermarkSettingViewController, FamilyName familyName: String, FontStyleName styleName: String) {
        textWaterModel?.fontName = familyName
        textWaterModel?.fontStyleName = styleName
        let cFont = CPDFFont(familyName: familyName, fontStyle: styleName)
        
        textWatermarkPreView?.preLabel?.font = UIFont(name: CPDFFont.convertAppleFont(cFont) ?? "Helvetica", size: textWaterModel?.watermarkScale ?? 0)
        textTileViewRefresh()
        textWatermarkPreView?.setNeedsDisplay()
        
        var bounds = textWatermarkPreView?.preLabel?.bounds
        bounds = adaptWidth(with: (textWatermarkPreView?.preLabel)!, fontSize: textWaterModel?.watermarkScale ?? 0)
        textWatermarkPreView?.preLabel?.bounds = bounds ?? .zero
    }
    
    func textWatermarkSettingViewControllerSetting(_ textWatermarkSettingViewController: CPDFTextWatermarkSettingViewController, FontSize fontSize: CGFloat) {
        let familyName = textWaterModel?.fontName
        let styleName = textWaterModel?.fontStyleName

        
        let cFont = CPDFFont(familyName: familyName ?? "Helvetica", fontStyle: styleName ?? "")
        textWaterModel?.watermarkScale = fontSize
        textWatermarkPreView?.preLabel?.font = UIFont(name: CPDFFont.convertAppleFont(cFont) ?? "Helvetica", size: fontSize)
        textTileViewRefresh()
        textWatermarkPreView?.setNeedsDisplay()
        
        var bounds = textWatermarkPreView?.preLabel?.bounds
        bounds = adaptWidth(with: (textWatermarkPreView?.preLabel)!, fontSize: textWaterModel?.watermarkScale ?? 0)
        textWatermarkPreView?.preLabel?.bounds = bounds ?? .zero
    }
    
    func textWatermarkSettingViewControllerSetting(_ imageWatermarkSettingViewController: CPDFTextWatermarkSettingViewController, PageRange pageRange: String) {
        textWaterModel?.pageString = pageRange
    }
    
    // MARK: - CPDFImageWatermarkSettingViewControllerDelegate
    
    func imageWatermarkSettingViewControllerSetting(_ imageWatermarkSettingViewController: CPDFImageWatermarkSettingViewController, Image image: UIImage) {
        
        imageWatermarkPreView?.preImageView?.image = imageWithImageSimple(image)
        imageWatermarkPreView?.preImageView?.sizeToFit()
        imageWaterModel?.image = imageWithImageSimple(image)
        imageTileViewRefresh()
        imageWatermarkPreView?.setNeedsDisplay()
    }
    
    func imageWatermarkSettingViewControllerSetting(_ imageWatermarkSettingViewController: CPDFImageWatermarkSettingViewController, Opacity opacity: CGFloat) {
        imageWatermarkPreView?.preImageView?.alpha = opacity
        imageWaterModel?.watermarkOpacity = opacity
        
        imageTileViewRefresh()
    }
    
    func imageWatermarkSettingViewControllerSetting(_ imageWatermarkSettingViewController: CPDFImageWatermarkSettingViewController, IsTile isTile: Bool) {
        imageWaterModel?.isTile = isTile
        
        imageWatermarkPreView?.imageTileView?.isHidden = !isTile
    }
    
    func imageWatermarkSettingViewControllerSetting(_ imageWatermarkSettingViewController: CPDFImageWatermarkSettingViewController, IsFront isFront: Bool) {
        imageWaterModel?.isFront = isFront
    }
    
    func imageWatermarkSettingViewControllerSetting(_ imageWatermarkSettingViewController: CPDFImageWatermarkSettingViewController, PageRange pageRange: String) {
        imageWaterModel?.pageString = pageRange
    }
    
}

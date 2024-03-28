//
//  CPDFStampViewController.swift
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

import UIKit
@objc protocol CPDFStampViewControllerDelegate: AnyObject {
    @objc optional func stampViewController(_ stampViewController: CPDFStampViewController, selectedIndex: Int, stamp: [String: Any])
    @objc optional func stampViewControllerDismiss(_ stampViewController: CPDFStampViewController)
}

typealias PDFAnnotationStampKey = String

let PDFAnnotationStampKeyType: PDFAnnotationStampKey = "PDFAnnotationStampKeyType"
let PDFAnnotationStampKeyImagePath: PDFAnnotationStampKey = "PDFAnnotationStampKeyImagePath"
let PDFAnnotationStampKeyText: PDFAnnotationStampKey = "PDFAnnotationStampKeyText"
let PDFAnnotationStampKeyShowDate: PDFAnnotationStampKey = "PDFAnnotationStampKeyShowDate"
let PDFAnnotationStampKeyShowTime: PDFAnnotationStampKey = "PDFAnnotationStampKeyShowTime"
let PDFAnnotationStampKeyStyle: PDFAnnotationStampKey = "PDFAnnotationStampKeyStyle"
let PDFAnnotationStampKeyShape: PDFAnnotationStampKey = "PDFAnnotationStampKeyShape"

let kStamp_Cell_Height = 60

class CPDFStampViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UIPopoverPresentationControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource, CStampTextViewControllerDelegate, CCustomizeStampTableViewCellDelegate {
    weak var delegate: CPDFStampViewControllerDelegate?
    
    private var collectView: UICollectionView?
    private var tableView: UITableView?
    private var segmentedControl: UISegmentedControl?
    private var standardArray: [Any]?
    private var customTextArray: [Any]?
    private var customImageArray: [Any]?
    private var imgDicCache: NSMutableDictionary?
    private var backBtn: UIButton?
    private var titleLabel: UILabel?
    private var createButton: UIButton?
    private var emptyLabel: UILabel?
    private var standardView: UIView?
    private var customizeView: UIView?
    private var stampFileManager: CStampFileManager?
    private var textButton: CStampButton?
    private var imageButton: CStampButton?
    private var modelView: UIView?
    private var headerView: UIView?
    
    // MARK: - ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
        headerView = UIView()
        headerView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        headerView?.layer.borderWidth = 1.0
        headerView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if headerView != nil {
            view.addSubview(headerView!)
        }
        titleLabel = UILabel()
        titleLabel?.autoresizingMask = .flexibleRightMargin
        titleLabel?.text = NSLocalizedString("Stamp", comment: "")
        titleLabel?.textAlignment = .center
        titleLabel?.font = UIFont.systemFont(ofSize: 20)
        titleLabel?.adjustsFontSizeToFitWidth = true
        if titleLabel != nil {
            headerView?.addSubview(titleLabel!)
        }
        backBtn = UIButton()
        backBtn?.autoresizingMask = .flexibleLeftMargin
        backBtn?.setImage(UIImage(named: "CPDFAnnotationBaseImageBack", in: Bundle(for: Self.self), compatibleWith: nil), for: .normal)
        backBtn?.addTarget(self, action: #selector(buttonItemClicked_back(_:)), for: .touchUpInside)
        if backBtn != nil {
            headerView?.addSubview(backBtn!)
        }
        let segmmentArray = [NSLocalizedString("Standard", comment: ""), NSLocalizedString("Custom", comment: "")]
        segmentedControl = UISegmentedControl(items: segmmentArray)
        segmentedControl?.selectedSegmentIndex = 0
        segmentedControl?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        segmentedControl?.addTarget(self, action: #selector(segmentedControlValueChanged_singature(_:)), for: .valueChanged)
        if segmentedControl != nil {
            view.addSubview(segmentedControl!)
        }
        stampFileManager = CStampFileManager()
        stampFileManager?.readStampDataFromFile()
        customTextArray = stampFileManager?.getTextStampData()
        customImageArray = stampFileManager?.getImageStampData()
        // StandardView
        createStandardView()
        // CustomizeView
        createCustomizeView()
        // Data
        var array = [String]()
        for i in 1..<13 {
            var tPicName: String?
            if i < 10 {
                tPicName = "CPDFStampImage-0\(i).png"
            } else {
                tPicName = "CPDFStampImage-\(i).png"
            }
            array.append(tPicName!)
        }
        array.append(contentsOf: ["CPDFStampImage-13", "CPDFStampImage-14", "CPDFStampImage-15", "CPDFStampImage-16", "CPDFStampImage-20", "CPDFStampImage-18", "CPDFStampImage_chick", "CPDFStampImage_cross", "CPDFStampImage_circle"])
        standardArray = array
        imgDicCache = NSMutableDictionary()
        createGestureRecognizer()
        updatePreferredContentSizeWithTraitCollection(traitCollection: traitCollection)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        titleLabel?.frame = CGRect(x: (view.frame.size.width - 120)/2, y: 0, width: 120, height: 50)
        segmentedControl?.frame = CGRect(x: 50, y: 55, width: view.frame.size.width-100, height: 30)
        headerView?.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50)
        emptyLabel?.frame = CGRect(x: (view.frame.size.width - 120)/2, y: (view.frame.size.height - 50)/2, width: 120, height: 50)
        if #available(iOS 11.0, *) {
            backBtn?.frame = CGRect(x: view.frame.size.width - 60 - view.safeAreaInsets.right, y: 5, width: 50, height: 50)
            createButton?.frame = CGRect(x: view.frame.size.width - 70 - view.safeAreaInsets.right, y: view.bounds.size.height - 200 - view.safeAreaInsets.bottom, width: 50, height: 50)
            textButton?.frame = CGRect(x: view.frame.size.width - 180 - view.safeAreaInsets.right, y: view.bounds.size.height - 320 - view.safeAreaInsets.bottom, width: 160, height: 40)
            imageButton?.frame = CGRect(x: view.frame.size.width - 180 - view.safeAreaInsets.right, y: view.bounds.size.height - 270 - view.safeAreaInsets.bottom, width: 160, height: 40)
        } else {
            backBtn?.frame = CGRect(x: view.frame.size.width - 60, y: 5, width: 50, height: 50)
            createButton?.frame = CGRect(x: view.frame.size.width - 60, y: view.frame.size.height - 200, width: 50, height: 50)
            textButton?.frame = CGRect(x: view.frame.size.width - 180, y: view.frame.size.height - 320, width: 160, height: 40)
            imageButton?.frame = CGRect(x: view.frame.size.width - 180, y: view.frame.size.height - 270, width: 160, height: 40)
        }
        modelView?.frame = CGRect(x: 0, y: -200, width: view.bounds.size.width, height: view.bounds.size.height+200)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectView?.reloadData()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSizeWithTraitCollection(traitCollection: newCollection)
    }
    
    // MARK: - Protect Methods
    
    func updatePreferredContentSizeWithTraitCollection(traitCollection: UITraitCollection) {
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
    
    // MARK: - Private Methods
    
    func createStandardView() {
        standardView = UIView(frame: CGRect(x: 0, y: 100, width: view.bounds.size.width, height: view.bounds.size.height-100))
        standardView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if standardView != nil {
            view.addSubview(standardView!)
        }
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 170, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        
        collectView = UICollectionView(frame: standardView?.bounds ?? .zero, collectionViewLayout: layout)
        collectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectView?.delegate = self
        collectView?.dataSource = self
        collectView?.backgroundColor = UIColor.clear
        collectView?.register(StampCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectView?.register(StampCollectionHeaderView1.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header1")
        collectView?.register(CStampCollectionViewCell.self, forCellWithReuseIdentifier: "TStampViewCell")
        
        if #available(iOS 11.0, *) {
            collectView?.contentInsetAdjustmentBehavior = .always
        }
        if collectView != nil {
            standardView?.addSubview(collectView!)
        }
        
    }
    
    func createCustomizeView() {
        customizeView = UIView(frame: CGRect(x: 0, y: 100, width: view.bounds.size.width, height: view.bounds.size.height-100))
        customizeView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if customizeView != nil {
            view.addSubview(customizeView!)
        }
        customizeView?.isHidden = true
        tableView = UITableView(frame: customizeView?.bounds ?? .zero, style: .grouped)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView?.backgroundColor = .clear
        tableView?.rowHeight = 60
        if tableView != nil {
            customizeView?.addSubview(tableView!)
        }
        
        emptyLabel = UILabel()
        emptyLabel?.text = NSLocalizedString("NO Custom", comment: "")
        emptyLabel?.textAlignment = .center
        if emptyLabel != nil {
            customizeView?.addSubview(emptyLabel!)
        }
        
        if (customImageArray?.count ?? 0) < 1 && (customTextArray?.count ?? 0) < 1 {
            tableView?.isHidden = true
            emptyLabel?.isHidden = false
        } else {
            emptyLabel?.isHidden = true
            tableView?.isHidden = false
        }
        
        modelView = UIView()
        modelView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        if modelView != nil {
            customizeView?.addSubview(modelView!)
        }
        modelView?.isHidden = true
        
        createButton = UIButton()
        createButton?.layer.cornerRadius = 25.0
        createButton?.clipsToBounds = true
        createButton?.setImage(UIImage(named: "CPDFSignatureImageAdd", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        createButton?.backgroundColor = .blue
        createButton?.addTarget(self, action: #selector(buttonItemClicked_create(_:)), for: .touchUpInside)
        if createButton != nil {
            customizeView?.addSubview(createButton!)
        }
        
        textButton = CStampButton()
        textButton?.stampBtn?.setImage(UIImage(named: "CPDFStampImageText", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        textButton?.titleLabel?.text = NSLocalizedString("Text Stamp", comment: "")
        textButton?.stampBtn?.addTarget(self, action: #selector(buttonItemClicked_text(_:)), for: .touchUpInside)
        if textButton != nil {
            customizeView?.addSubview(textButton!)
        }
        textButton?.isHidden = true
        
        imageButton = CStampButton()
        imageButton?.stampBtn?.setImage(UIImage(named: "CPDFStampImageImage", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        imageButton?.titleLabel?.text = NSLocalizedString("Image Stamp", comment: "")
        imageButton?.stampBtn?.addTarget(self, action: #selector(buttonItemClicked_image(_:)), for: .touchUpInside)
        if imageButton != nil {
            customizeView?.addSubview(imageButton!)
        }
        imageButton?.isHidden = true
        
    }
    
    func createGestureRecognizer() {
        createButton?.isUserInteractionEnabled = true
        modelView?.isUserInteractionEnabled = true
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panaddBookmarkBtn(_:)))
        createButton?.addGestureRecognizer(panRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapModelView(_:)))
        modelView?.addGestureRecognizer(tapRecognizer)
        
    }
    
    @objc func panaddBookmarkBtn(_ gestureRecognizer: UIPanGestureRecognizer) {
        let point = gestureRecognizer.translation(in: view)
        let newX = (createButton?.center.x ?? 0) + point.x
        let newY = (createButton?.center.y ?? 0) + point.y
        if view.frame.contains(CGPoint(x: newX, y: newY)) {
            createButton?.center = CGPoint(x: newX, y: newY)
        }
        gestureRecognizer.setTranslation(CGPoint.zero, in: view)
    }
    
    @objc func tapModelView(_ gestureRecognizer: UITapGestureRecognizer) {
        textButton?.isHidden = true
        modelView?.isHidden = true
        imageButton?.isHidden = true
    }
    
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
            if UIDevice.current.userInterfaceIdiom == .pad {
                imagePickerController.popoverPresentationController?.sourceView = self.imageButton
                imagePickerController.popoverPresentationController?.sourceRect = self.imageButton?.bounds ?? .zero
            }
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            actionSheet.popoverPresentationController?.sourceView = self.imageButton
            actionSheet.popoverPresentationController?.sourceRect = self.imageButton?.bounds ?? .zero
        }
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(photoAction)
        actionSheet.addAction(cancelAction)
        actionSheet.modalPresentationStyle = .popover
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func compressImage(_ image: UIImage) -> UIImage {
        var maxWH = CGFloat(kStamp_Cell_Height)
        if UIScreen.main.responds(to: #selector(getter: UIScreen.scale)) {
            maxWH *= UIScreen.main.scale
        }
        var imageScale: CGFloat = 1.0
        if image.size.width > maxWH || image.size.height > maxWH {
            imageScale = min(maxWH / image.size.width, maxWH / image.size.height)
        }
        let newSize = CGSize(width: image.size.width * imageScale, height: image.size.height * imageScale)
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? UIImage()
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
        if var image = image {
            let imageOrientation = image.imageOrientation
            if imageOrientation != .up {
                UIGraphicsBeginImageContext(image.size)
                image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
                image = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
            }
            if let imageData = image.pngData(), imageData.count > 0 {
                image = UIImage(data: imageData)!
            }
            if(image.cgImage != nil) {
                let colorMasking: [CGFloat] = [222, 255, 222, 255, 222, 255]
                if let imageRef = image.cgImage!.copy(maskingColorComponents: colorMasking){
                    image = UIImage(cgImage: imageRef)
                }
                
                if let tPath = self.stampFileManager?.saveStamp(with: image) {
                    var tStampItem = [String: Any]()
                    tStampItem["path"] = tPath
                    self.stampFileManager?.insertStampItem(tStampItem as NSDictionary, type: .image)
                    customImageArray = self.stampFileManager?.getImageStampData()
                    self.tableView?.reloadData()
                    if (customImageArray?.count ?? 0) < 1 && (customTextArray?.count ?? 0) < 1 {
                        emptyLabel?.isHidden = false
                        tableView?.isHidden = true
                    } else {
                        emptyLabel?.isHidden = true
                        tableView?.isHidden = false
                    }
                }
                
            }
            
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.stampViewControllerDismiss?(self)
    }
    
    @objc func buttonItemClicked_create(_ sender: Any) {
        textButton?.isHidden = !(textButton?.isHidden ?? false)
        modelView?.isHidden = !(modelView?.isHidden ?? false)
        imageButton?.isHidden = !(imageButton?.isHidden ?? false)
    }
    
    @objc func segmentedControlValueChanged_singature(_ sender: Any) {
        if segmentedControl?.selectedSegmentIndex == 0 {
            standardView?.isHidden = false
            customizeView?.isHidden = true
        } else {
            standardView?.isHidden = true
            customizeView?.isHidden = false
        }
    }
    
    @objc func buttonItemClicked_text(_ sender: Any) {
        textButton?.isHidden = true
        modelView?.isHidden = true
        imageButton?.isHidden = true
        let stampTextVC = CStampTextViewController()
        
        let presentationController = AAPLCustomPresentationController(presentedViewController: stampTextVC, presenting: self)
        
        stampTextVC.delegate = self
        stampTextVC.transitioningDelegate = presentationController
        self.present(stampTextVC, animated: true)
    }
    
    @objc func buttonItemClicked_image(_ sender: Any) {
        textButton?.isHidden = true
        modelView?.isHidden = true
        imageButton?.isHidden = true
        createImageSignature()
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return standardArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TStampViewCell", for: indexPath) as? CStampCollectionViewCell
        cell?.editing = false
        cell?.stampImage?.image = UIImage(named: standardArray?[indexPath.item] as? String ?? "", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        if(cell != nil) {
            return cell!
        } else {
            return UICollectionViewCell.init()
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismiss(animated: true)
        delegate?.stampViewController?(self, selectedIndex: indexPath.row, stamp: [String : Any]())
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return customTextArray?.count ?? 0
        case 1:
            return customImageArray?.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("Text Stamp", comment: "")
        case 1:
            return NSLocalizedString("Image Stamp", comment: "")
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CCustomizeStampTableViewCell
        if (cell == nil) {
            cell = CCustomizeStampTableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        if (self.customTextArray?.count ?? 0) > 0 || (self.customImageArray?.count ?? 0) > 0 {
            if indexPath.section == 0 {
                let tDic = self.customTextArray?[indexPath.item]
                let tText = (tDic as? NSDictionary)?["text"] as? String ?? ""
                let tStyle = (tDic as? NSDictionary)?["style"] as? Int ?? 0
                let tColorStyle = (tDic as? NSDictionary)?["colorStyle"] as? Int ?? 0
                let tHaveDate = (tDic as? NSDictionary)?["haveDate"] as? Bool ?? false
                let tHaveTime = (tDic as? NSDictionary)?["haveTime"] as? Bool ?? false
                let tPreview = CStampPreview(frame: CGRect(x: 0, y: 0, width: 320, height: kStamp_Cell_Height))
                tPreview.textStampText = tText
                tPreview.textStampColorStyle = TextStampColorType(rawValue: tColorStyle)!
                tPreview.textStampStyle = TextStampType(rawValue: tStyle)!
                tPreview.textStampHaveDate = tHaveDate
                tPreview.textStampHaveTime = tHaveTime
                tPreview.leftMargin = 0
                let tImg = tPreview.renderImage()
                cell!.customizeStampImageView?.image = tImg
            } else {
                let tDic = self.customImageArray?[indexPath.item]
                if let img = self.imgDicCache?.object(forKey: tDic) {
                    cell!.customizeStampImageView?.image = img as? UIImage
                } else {
                    if let tPath = (tDic as? NSDictionary)?["path"] as? String {
                        let tFileName = FileManager.default.displayName(atPath: tPath)
                        let tRealPath = "\(kPDFStampDataFolder)/\(tFileName)"
                        if let tImg = UIImage(contentsOfFile: tRealPath) {
                            let img = compressImage(tImg)
                            self.imgDicCache?.setObject(img, forKey: tDic as! NSCopying)
                            cell!.customizeStampImageView?.image = img
                        }
                    }
                }
            }
            
        }
        cell!.deleteDelegate = self
        return cell!
        
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let tDic = self.customTextArray?[indexPath.item]
            let tText = (tDic as? NSDictionary)?["text"] as? String ?? ""
            let tStyle = (tDic as? NSDictionary)?["style"] as? Int ?? 0
            let tColorStyle = (tDic as? NSDictionary)?["colorStyle"] as? Int ?? 0
            let tHaveDate = (tDic as? NSDictionary)?["haveDate"] as? Bool ?? false
            let tHaveTime = (tDic as? NSDictionary)?["haveTime"] as? Bool ?? false
            
            var stampStype: Int = 0
            var stampShape: Int = 0
            switch TextStampColorType(rawValue: tColorStyle)! {
            case .black:
                stampStype = 0
            case .red:
                stampStype = 1
            case .green:
                stampStype = 2
            case .blue:
                stampStype = 3
            }
            
            switch TextStampType(rawValue: tStyle)! {
            case .none:
                stampShape = 3
            case .right:
                stampShape = 2
            case .left:
                stampShape = 1
            case .center:
                stampShape = 0
            }
            dismiss(animated: true)
            delegate?.stampViewController?(self, selectedIndex: indexPath.row, stamp: [PDFAnnotationStampKeyText: tText,
                                                                                   PDFAnnotationStampKeyShowDate: tHaveDate,
                                                                                   PDFAnnotationStampKeyShowTime: tHaveTime,
                                                                                      PDFAnnotationStampKeyStyle: stampStype,
                                                                                      PDFAnnotationStampKeyShape: stampShape])
        } else if indexPath.section == 1 {
            guard let tDict = self.customImageArray?[indexPath.row] as? [String: Any],
                  let tPath = tDict["path"] as? String else {
                return
            }
            let tFileName = FileManager.default.displayName(atPath: tPath)
            let tRealPath = "\(kPDFStampDataFolder)/\(tFileName)"
            dismiss(animated: true)
            delegate?.stampViewController?(self, selectedIndex: indexPath.row, stamp: [PDFAnnotationStampKeyImagePath: tRealPath])
        }
        
    }
    
    // MARK: - CCustomizeStampTableViewCellDelegate
    
    func customizeStampTableViewCell(_ customizeStampTableViewCell: CCustomizeStampTableViewCell) {
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        let OKAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (action) in
            if let select = self.tableView?.indexPath(for: customizeStampTableViewCell) {
                if select.section == 0 {
                    self.stampFileManager?.removeStampItem(index: select.row, stampType: .text)
                    self.customTextArray = self.stampFileManager?.getTextStampData()
                } else if select.section == 1 {
                    self.stampFileManager?.removeStampItem(index: select.row, stampType: .image)
                    self.customImageArray = self.stampFileManager?.getImageStampData()
                    
                }
                self.tableView?.reloadData()
                if (self.customImageArray?.count ?? 0) < 1 && (self.customTextArray?.count ?? 0) < 1 {
                    self.emptyLabel?.isHidden = false
                    self.tableView?.isHidden = true
                } else {
                    self.emptyLabel?.isHidden = true
                    self.tableView?.isHidden = false
                }
            }
            
        }
        let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Are you sure to delete?", comment: ""), preferredStyle: .alert)
        alert.addAction(cancelAction)
        alert.addAction(OKAction)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - CStampTextViewControllerDelegate
    
    func stampTextViewController(_ stampTextViewController: CStampTextViewController, dictionary: NSDictionary) {
        self.stampFileManager?.insertStampItem(dictionary, type: .text )
        self.customTextArray = self.stampFileManager?.getTextStampData()
        self.tableView?.reloadData()
        if (self.customImageArray?.count ?? 0) < 1 && (self.customTextArray?.count ?? 0) < 1 {
            self.emptyLabel?.isHidden = false
            self.tableView?.isHidden = true
        } else {
            self.emptyLabel?.isHidden = true
            self.tableView?.isHidden = false
        }
        
    }
    
}


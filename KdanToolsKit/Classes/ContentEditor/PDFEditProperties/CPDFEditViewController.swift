//
//  CPDFEditViewController.swift
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

public class CPDFEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIColorPickerViewControllerDelegate, CPDFColorPickerViewDelegate, CPDFEditFontNameSelectViewDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var titleLabel:UILabel?
    var pdfView:CPDFView?
    var splitView:UIView?
    var tableView:UITableView?
    var colorPickerView:CPDFColorPickerView?
    var fontSelectView:CPDFEditFontNameSelectView?
    var backBtn:UIButton?
    var textSampleView:CPDFEditTextSampleView?
    var imageSampleView:CPDFEditImageSampleView?
    
    public var editMode: CPDFEditMode = .text {
        didSet {
            updatePreferredContentSize(with: traitCollection)
        }
    }

    
    public init(pdfView: CPDFView) {
        super.init(nibName: nil, bundle: nil)
        self.pdfView = pdfView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        var bottomPadding: CGFloat = 0
        var leftPadding: CGFloat = 0
        var rightPadding: CGFloat = 0
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows.first
            bottomPadding = window?.safeAreaInsets.bottom ?? 0
            leftPadding = window?.safeAreaInsets.left ?? 0
            rightPadding = window?.safeAreaInsets.right ?? 0
        }
        self.view.frame = CGRect(
            x: leftPadding,
            y: UIScreen.main.bounds.size.height - bottomPadding,
            width: UIScreen.main.bounds.size.width - leftPadding - rightPadding,
            height: self.view.frame.size.height
        )
        self.titleLabel = UILabel()
        self.titleLabel?.autoresizingMask = .flexibleRightMargin
        self.titleLabel?.text = (self.editMode == .text) ? NSLocalizedString("Text Properties", comment: "") : NSLocalizedString("Image Properties", comment: "")
        self.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        if(titleLabel != nil) {
            self.view.addSubview(self.titleLabel!)
        }
        
        self.backBtn = UIButton()
        self.backBtn?.autoresizingMask = .flexibleLeftMargin
        self.backBtn?.setImage(UIImage(named: "CPDFEditClose", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        self.backBtn?.addTarget(self, action: #selector(buttonItemClicked_back(_:)), for: .touchUpInside)
        if(backBtn != nil) {
            self.view.addSubview(self.backBtn!)
        }
        
        self.splitView = UIView()
        self.splitView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        if(splitView != nil) {
            self.view.addSubview(self.splitView!)
        }
        
        self.view.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        self.updatePreferredContentSize(with: self.traitCollection)
        
        self.tableView = UITableView(frame: .zero, style: .plain)
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        if #available(iOS 15.0, *) {
            self.tableView?.sectionHeaderTopPadding = 0
        }
        else {
            // Fallback on earlier versions
        }
        self.tableView?.reloadData()
        if(tableView != nil) {
            self.view.addSubview(self.tableView!)
        }
        self.tableView?.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if #available(iOS 11.0, *) {
            self.titleLabel?.frame = CGRect(x: (self.view.frame.size.width - 120)/2, y: 5, width: 120, height: 50)
            self.splitView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: 51, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 1)
            self.tableView?.frame = CGRect(x: self.view.safeAreaInsets.left, y: 52, width: self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.frame.size.height - 52)
            self.backBtn?.frame = CGRect(x: self.view.frame.size.width - 60, y: 5, width: 50, height: 50)
        } else {
            self.titleLabel?.frame = CGRect(x: (self.view.frame.size.width - 120)/2, y: 5, width: 120, height: 50)
            self.splitView?.frame = CGRect(x: 0, y: 51, width: self.view.frame.size.width, height: 1)
            self.tableView?.frame = CGRect(x: 0, y: 52, width: self.view.frame.size.width, height: self.view.frame.size.height - 52)
            self.backBtn?.frame = CGRect(x: self.view.frame.size.width - 60, y: 5, width: 50, height: 50)
        }
    }
    
    public override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSize(with: newCollection)
    }
    
    func updatePreferredContentSize(with traitCollection: UITraitCollection) {
        if self.editMode == .text {
            self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? 300 : 600)
        } else {
            self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? 300 : 600)
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.editMode == .text {
            let view = UIView(frame: CGRect(x: 20, y: 0, width: self.view.bounds.size.width-40, height: 120))
            view.backgroundColor = UIColor.white
            view.layer.borderWidth = 1.0
            view.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
            view.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
            
            self.textSampleView = CPDFEditTextSampleView()
            self.textSampleView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
            self.textSampleView?.layer.borderWidth = 1.0
            self.textSampleView?.autoresizingMask = .flexibleRightMargin
            self.textSampleView?.frame = CGRect(x: (self.view.frame.size.width - 300)/2, y: 15, width: 300, height: view.bounds.size.height - 30)
            
            let editArea = self.pdfView?.editingArea()
            
            if editArea != nil {
                if editArea?.isTextArea() == true {
                    self.textSampleView?.textAlignmnet = self.pdfView?.editingSelectionAlignment(with: editArea as? CPDFEditTextArea) ?? .left
                    self.textSampleView?.textColor = self.pdfView?.editingSelectionFontColor(with: editArea as? CPDFEditTextArea) ?? UIColor.clear
                    self.textSampleView?.textOpacity = self.pdfView?.getCurrentOpacity() ?? 1.0
                    self.textSampleView?.fontName = self.pdfView?.editingSelectionFontName(with: editArea as? CPDFEditTextArea) as NSString?
                    self.textSampleView?.fontSize = self.pdfView?.editingSelectionFontSizes(with: editArea as? CPDFEditTextArea) ?? 0
                    self.textSampleView?.isBold = self.pdfView?.isBoldCurrentSelection(with: editArea as? CPDFEditTextArea) == true
                    self.textSampleView?.isItalic = self.pdfView?.isItalicCurrentSelection(with: editArea as? CPDFEditTextArea) == true
                }
                
            } else {
                self.textSampleView?.textAlignmnet = CPDFTextProperty.shared.textAlignment
                var color = CPDFTextProperty.shared.fontColor
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                var alpha: CGFloat = 0
                color?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                
                color = UIColor(red: red, green: green, blue: blue, alpha: CPDFTextProperty.shared.textOpacity)
                
                self.textSampleView?.textColor = color ?? .black
                self.textSampleView?.textOpacity = CPDFTextProperty.shared.textOpacity
                self.textSampleView?.fontName = CPDFTextProperty.shared.fontName
                self.textSampleView?.fontSize = CPDFTextProperty.shared.fontSize
                self.textSampleView?.isBold = CPDFTextProperty.shared.isBold
                self.textSampleView?.isItalic = CPDFTextProperty.shared.isItalic
            }
            
            if self.textSampleView != nil {
                view.addSubview(self.textSampleView!)
            }
            
            return view
        } else  {
            let view = UIView(frame: CGRect(x: 20, y: 0, width: self.view.bounds.size.width-40, height: 120))
            view.backgroundColor = UIColor.white
            view.layer.borderWidth = 1.0
            view.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
            view.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
            self.imageSampleView = CPDFEditImageSampleView()
            self.imageSampleView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
            self.imageSampleView?.layer.borderWidth = 1.0
            self.imageSampleView?.autoresizingMask = .flexibleRightMargin
            self.imageSampleView?.frame = CGRect(x: (self.view.frame.size.width - 300)/2, y: 15, width: 300, height: view.bounds.size.height - 30)
            
            var image: UIImage? = nil
            
            let editArea = self.pdfView?.editingArea()
            if let editImageArea = editArea as? CPDFEditImageArea {
                image = editImageArea.thumbnailImage(with: editImageArea.bounds.size)
            }
            
            
            if image != nil {
                self.imageSampleView?.imageView?.image = image
            } else {
                if(editArea?.isImageArea() == true) {
                    let imageArea:CPDFEditImageArea = editArea as! CPDFEditImageArea
                    let rotation:CGFloat = self.pdfView?.getRotationEdit(imageArea) ?? 0
                    
                    if rotation > 0 {
                        if rotation > 90 {
                            self.imageSampleView?.imageView?.transform = self.imageSampleView?.imageView?.transform.rotated(by: CGFloat(Double.pi)) ?? CGAffineTransform()
                        } else {
                            self.imageSampleView?.imageView?.transform = self.imageSampleView?.imageView?.transform.rotated(by: CGFloat(Double.pi/2)) ?? CGAffineTransform()
                        }
                    } else if (rotation < 0) {
                        self.imageSampleView?.imageView?.transform = self.imageSampleView?.imageView?.transform.rotated(by: CGFloat(-Double.pi/2)) ?? CGAffineTransform()
                        
                    }
                    
                    self.imageSampleView?.imageView?.alpha = self.pdfView?.getCurrentOpacity() ?? 0
                }
            }
            if(self.imageSampleView != nil) {
                view.addSubview(self.imageSampleView!)
            }
            
            return view
        }
        return nil
        
    }
    
    
    // MARK: - UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.editMode == .text {
            var cell = tableView.dequeueReusableCell(withIdentifier: "Textcell") as? CPDFTextPropertyCell
            if cell == nil {
                cell = CPDFTextPropertyCell(style: .default, reuseIdentifier: "Textcell")
            }
            cell?.backgroundColor = UIColor(red: 250/255, green: 252/255, blue: 255/255, alpha: 1)
            if self.fontSelectView?.fontName.count ?? 0 > 0 {
                cell?.currentSelectFontName = self.fontSelectView?.fontName
            } else {
                let editingArea = self.pdfView?.editingArea()
                if editingArea != nil {
                    cell?.currentSelectFontName = self.pdfView?.editingSelectionFontName(with: editingArea as? CPDFEditTextArea)
                } else {
                    cell?.currentSelectFontName = CPDFTextProperty.shared.fontName as String?
                }
            }
            if(self.pdfView != nil) {
                cell?.setPdfView(self.pdfView!)
            }
            var blockSelf = self
            
            cell?.actionBlock = { actionType in
                if actionType == .colorSelect {
                    if #available(iOS 14.0, *) {
                        let picker = UIColorPickerViewController()
                        picker.delegate = blockSelf
                        blockSelf.present(picker, animated: true, completion: nil)
                    } else {
                        blockSelf.colorPickerView = CPDFColorPickerView(frame: blockSelf.view.frame)
                        blockSelf.colorPickerView?.delegate = blockSelf
                        blockSelf.colorPickerView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        blockSelf.colorPickerView?.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
                        if(blockSelf.colorPickerView != nil) {
                            blockSelf.view.addSubview(blockSelf.colorPickerView!)
                        }
                    }
                } else if actionType == .fontNameSelect {
                    blockSelf.fontSelectView = CPDFEditFontNameSelectView(frame: blockSelf.view.bounds)
                    blockSelf.fontSelectView?.fontNameArr = NSMutableArray(array: blockSelf.pdfView?.getFontList() ?? []) as? [Any]
                    blockSelf.fontSelectView?.fontName = blockSelf.textSampleView?.fontName as? String ?? ""
                    blockSelf.fontSelectView?.delegate = blockSelf
                    blockSelf.fontSelectView?.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
                    if(blockSelf.fontSelectView != nil) {
                        blockSelf.view.addSubview(blockSelf.fontSelectView!)
                    }
                }
            }
            
            cell?.colorBlock = { selectColor in
                blockSelf.textSampleView?.textColor = selectColor
                let editingArea = blockSelf.pdfView?.editingArea()
                
                if editingArea != nil {
                    blockSelf.pdfView?.setEditingSelectionFontColor(selectColor, with: editingArea as? CPDFEditTextArea)
                } else {
                    CPDFTextProperty.shared.fontColor = selectColor
                }
            }
            
            cell?.boldBlock = { isBold in
                blockSelf.textSampleView?.isBold = isBold
                let editingArea = blockSelf.pdfView?.editingArea()
                
                if editingArea != nil {
                    blockSelf.pdfView?.setCurrentSelectionIsBold(isBold, with: editingArea as? CPDFEditTextArea)
                } else {
                    CPDFTextProperty.shared.isBold = isBold
                }
            }
            
            cell?.italicBlock = { isItalic in
                blockSelf.textSampleView?.isItalic = isItalic
                let editingArea = blockSelf.pdfView?.editingArea()
                
                if editingArea != nil {
                    blockSelf.pdfView?.setCurrentSelectionIsItalic(isItalic, with: editingArea as? CPDFEditTextArea)
                } else {
                    CPDFTextProperty.shared.isItalic = isItalic
                }
            }
            
            cell?.alignmentBlock = { alignment in
                
                let row:CPDFTextAlignment = alignment
                var textAlignmnet:NSTextAlignment = .left
                if (row == .left) {
                    textAlignmnet = .left
                } else if (row == .center) {
                    textAlignmnet = .center
                } else if row == .right {
                    textAlignmnet = .right
                } else if row == .justified {
                    textAlignmnet = .justified
                } else if row == .natural {
                    textAlignmnet = .natural
                }
                
                blockSelf.textSampleView?.textAlignmnet = textAlignmnet
                
                let editingArea = blockSelf.pdfView?.editingArea()
                
                if editingArea != nil {
                    blockSelf.pdfView?.setCurrentSelectionAlignment(textAlignmnet, with: editingArea as? CPDFEditTextArea)
                } else {
                    CPDFTextProperty.shared.textAlignment = textAlignmnet
                }
            }
            
            cell?.fontSizeBlock = { fontSize in
                blockSelf.textSampleView?.fontSize = fontSize * 10
                let editingArea = blockSelf.pdfView?.editingArea()
                
                if editingArea != nil {
                    blockSelf.pdfView?.setEditingSelectionFontSize(fontSize * 10, with: editingArea as? CPDFEditTextArea, isAutoSize: true)
                } else {
                    CPDFTextProperty.shared.fontSize = fontSize * 10
                }
            }
            
            cell?.opacityBlock = { opacity in
                blockSelf.textSampleView?.textOpacity = opacity
                let editingArea = blockSelf.pdfView?.editingArea()
                
                if editingArea != nil {
                    blockSelf.pdfView?.setCharsFontTransparency(Float(opacity), with: editingArea as? CPDFEditTextArea)
                } else {
                    CPDFTextProperty.shared.textOpacity = opacity
                }
            }
            
            cell?.selectionStyle = .none
            tableView.separatorStyle = .none
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell") as? CPDFImagePropertyCell
            if cell == nil {
                cell = CPDFImagePropertyCell(style: .default, reuseIdentifier: "CPDFImagePropertyCell")
            }
            cell?.backgroundColor = UIColor(red: 250/255, green: 252/255, blue: 255/255, alpha: 1)
            if(self.pdfView != nil) {
                cell?.setPdfView(self.pdfView!)
            }
            
            var blockSelf = self
            cell?.rotateBlock = { rotateType, isRotated in
                if rotateType == .left {
                    let editingArea = blockSelf.pdfView?.editingArea()
                    if(editingArea != nil) {
                        blockSelf.pdfView?.rotateEdit(editingArea as? CPDFEditImageArea, rotateAngle: -90)
                        blockSelf.imageSampleView?.imageView?.transform = blockSelf.imageSampleView?.imageView?.transform.rotated(by: -CGFloat.pi/2) ?? CGAffineTransform()
                        blockSelf.imageSampleView?.setNeedsLayout()
                    }
                } else if rotateType == .right {
                    let editingArea = blockSelf.pdfView?.editingArea()
                    if(editingArea != nil) {
                        blockSelf.pdfView?.rotateEdit(editingArea as? CPDFEditImageArea, rotateAngle: 90)
                        blockSelf.imageSampleView?.imageView?.transform = blockSelf.imageSampleView?.imageView?.transform.rotated(by: CGFloat.pi/2) ?? CGAffineTransform()
                        blockSelf.imageSampleView?.setNeedsLayout()
                    }
                }
            }
            
            cell?.transFormBlock = { transformType, isTransformed in
                if transformType == .vertical {
                    let editingArea = blockSelf.pdfView?.editingArea()
                    if(editingArea != nil) {
                        blockSelf.pdfView?.verticalMirrorEdit(editingArea as? CPDFEditImageArea)
                        blockSelf.imageSampleView?.imageView?.transform = blockSelf.imageSampleView?.imageView?.transform.scaledBy(x: 1.0, y: -1.0) ?? CGAffineTransform()
                        blockSelf.imageSampleView?.setNeedsLayout()
                    }
                } else if transformType == .horizontal {
                    let editingArea = blockSelf.pdfView?.editingArea()
                    if(editingArea != nil) {
                        blockSelf.pdfView?.horizontalMirrorEdit(editingArea as? CPDFEditImageArea)
                        blockSelf.imageSampleView?.imageView?.transform = blockSelf.imageSampleView?.imageView?.transform.scaledBy(x: -1.0, y: 1.0) ?? CGAffineTransform()
                        blockSelf.imageSampleView?.setNeedsLayout()
                    }
                }
            }
            
            cell?.transparencyBlock = { transparency in
                let editingArea = blockSelf.pdfView?.editingArea()
                if(editingArea != nil) {
                    blockSelf.pdfView?.setImageTransparencyEdit(editingArea as? CPDFEditImageArea, transparency: Float(transparency))
                    blockSelf.imageSampleView?.imageView?.alpha = transparency
                    blockSelf.imageSampleView?.setNeedsLayout()
                }
            }
            
            cell?.replaceImageBlock = {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = blockSelf
                blockSelf.present(imagePicker, animated: true, completion: nil)
            }
            
            cell?.cropImageBlock = {
                let editingArea = blockSelf.pdfView?.editingArea()
                if(editingArea != nil) {
                    blockSelf.pdfView?.beginCropEdit(editingArea as? CPDFEditImageArea)
                    blockSelf.controllerDismiss()
                }
            }
            
            cell?.exportImageBlock = {
                let editingArea = blockSelf.pdfView?.editingArea()
                if(editingArea != nil) {
                    let saved = blockSelf.pdfView?.extractImage(withEditImageArea: editingArea)
                    if saved ?? false {
                        let alertController = UIAlertController(title: "", message: NSLocalizedString("Export Successfully!", comment: ""), preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { action in
                            blockSelf.controllerDismiss()
                        }))
                        blockSelf.present(alertController, animated: true, completion: nil)
                    } else {
                        let alertController = UIAlertController(title: "", message: NSLocalizedString("Export Failed!", comment: ""), preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { action in
                            blockSelf.controllerDismiss()
                        }))
                        blockSelf.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            
            cell?.selectionStyle = .none
            tableView.separatorStyle = .none
            return cell!
        }
        
    }
    
    
    // MARK: - UITableViewDelegate
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 120
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.editMode == .text {
            return 400
        } else {
            return 380
        }
    }
    
    // MARK: - ColorPickerDelegate
    func pickerView(_ colorPickerView: CPDFColorPickerView, color: UIColor) {
        self.textSampleView?.textColor = color
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let editingArea = self.pdfView?.editingArea()
        
        if editingArea != nil {
            self.pdfView?.setEditingSelectionFontColor(color, with: editingArea as? CPDFEditTextArea)
        } else {
            CPDFTextProperty.shared.fontColor = color
        }
        
    }
    
    // MARK: - CPDFEditFontNameSelectViewDelegate
    func pickerView(_ colorPickerView: CPDFEditFontNameSelectView, fontName: String) {
        textSampleView?.fontName = NSString(string: fontName)
        let editingArea = self.pdfView?.editingArea()
        
        if editingArea != nil {
            pdfView?.setEditingSelectionFontName(fontName, with: editingArea as? CPDFEditTextArea)
        } else {
            CPDFTextProperty.shared.fontName = NSString(string: fontName)
        }
        tableView?.reloadData()
    }
    
    // MARK: - UIColorPickerViewControllerDelegate
    @available(iOS 14.0, *)
    public func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        textSampleView?.textColor = viewController.selectedColor
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        viewController.selectedColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let editingArea = self.pdfView?.editingArea()
        
        if editingArea != nil {
            pdfView?.setEditingSelectionFontColor(viewController.selectedColor, with: editingArea as? CPDFEditTextArea)
            pdfView?.setCharsFontTransparency(Float(alpha), with: editingArea as? CPDFEditTextArea)
        } else {
            CPDFTextProperty.shared.fontColor = viewController.selectedColor
            CPDFTextProperty.shared.textOpacity = CGFloat(Float(alpha))
        }
        
        textSampleView?.textOpacity = CGFloat(Float(alpha))
        tableView?.reloadData()
        
    }
    
    // MARK: - UIImagePickerControllerDelegate
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let editingArea = self.pdfView?.editingArea()

        if(editingArea != nil) {
            if #available(iOS 11.0, *) {
                let url = info[UIImagePickerController.InfoKey.imageURL] as? URL
                if(url != nil) {
                    let image = UIImage.init(contentsOfFile: url!.path)
                    let size:CGSize = image?.size ?? CGSize.init(width: 10, height: 10)
                    pdfView?.replace(editingArea as? CPDFEditImageArea, imagePath: url!.path,rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                }
            } else {
                let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL
                if(url != nil) {
                    let image = UIImage.init(contentsOfFile: url!.path)
                    let size:CGSize = image?.size ?? CGSize.init(width: 10, height: 10)
                    pdfView?.replace(editingArea as? CPDFEditImageArea, imagePath: url!.path,rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                }
            }
            
            picker.dismiss(animated: true, completion: nil)
        }
        
        controllerDismiss()
        
    }
    
    // MARK: - Action
    @objc func buttonItemClicked_back(_ sender: UIButton) {
        controllerDismiss()
    }
    
    @objc func controllerDismiss() {
        self.dismiss(animated: true)
    }
    
    
}

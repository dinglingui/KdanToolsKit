//
//  CImageSelectView.swift
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

@objc protocol CImageSelectViewDelegate: AnyObject {
    @objc optional func imageSelectView(_ imageSelectView: CImageSelectView, image: UIImage)
}

class CImageSelectView: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var delegate: CImageSelectViewDelegate?
    
    var parentVC: UIViewController?
    
    private var titleLabel: UILabel?
    
    private var cameraButton: UIButton?
    
    private var photoButton: UIButton?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        titleLabel = UILabel()
        titleLabel?.autoresizingMask = .flexibleRightMargin
        titleLabel?.text = NSLocalizedString("Choose Picture", comment: "")
        titleLabel?.textColor = .gray
        titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        if titleLabel != nil {
            addSubview(titleLabel!)
        }
        
        cameraButton = UIButton()
        cameraButton?.setImage(UIImage(named: "CImageSelectCameraImage", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        cameraButton?.addTarget(self, action: #selector(buttonItemClicked_camera), for: .touchUpInside)
        if cameraButton != nil {
            addSubview(self.cameraButton!)
        }
        
        photoButton = UIButton()
        photoButton?.setImage(UIImage(named: "CImageSelectPhotoImage", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        photoButton?.addTarget(self, action: #selector(buttonItemClicked_photo), for: .touchUpInside)
        if photoButton != nil {
            addSubview(self.photoButton!)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel?.frame = CGRect(x: 20, y: 0, width: 200, height: 30)
        cameraButton?.frame = CGRect(x: bounds.size.width - 65, y: 0, width: 45, height: 30)
        photoButton?.frame = CGRect(x: bounds.size.width - 110, y: 0, width: 45, height: 30)
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_camera(_ sender: UIButton) {
        cameraButton?.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        photoButton?.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        
        cameraButton?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
        
        let tRootViewControl = parentVC
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        tRootViewControl?.present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func buttonItemClicked_photo(_ sender: UIButton) {
        cameraButton?.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        photoButton?.backgroundColor = CPDFColorUtils.CAnnotationBarNoSelectBackgroundColor()
        
        photoButton?.backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()
        
        let tRootViewControl = parentVC
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        imagePickerController.modalPresentationStyle = .popover
        if UI_USER_INTERFACE_IDIOM() == .pad {
            imagePickerController.popoverPresentationController?.sourceView = self.photoButton
            imagePickerController.popoverPresentationController?.sourceRect = ((self.photoButton)?.bounds) ?? .zero
        }
        tRootViewControl?.present(imagePickerController, animated: true, completion: nil)
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
        let imageOrientation = image?.imageOrientation
        if imageOrientation != .up {
            UIGraphicsBeginImageContext((image?.size)!)
            image?.draw(in: CGRect(x: 0, y: 0, width: (image?.size.width ?? 0), height: (image?.size.height ?? 0)))
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        guard let imageData = image!.pngData() else {
            return
        }
        
        image = UIImage(data: imageData)
        let colorMasking: [CGFloat] = [222, 255, 222, 255, 222, 255]
        let imageRef = image?.cgImage?.copy(maskingColorComponents: colorMasking)
        if let cgImage = imageRef {
            image = UIImage(cgImage: cgImage)
        }
      
        delegate?.imageSelectView?(self, image: image ?? UIImage())
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}

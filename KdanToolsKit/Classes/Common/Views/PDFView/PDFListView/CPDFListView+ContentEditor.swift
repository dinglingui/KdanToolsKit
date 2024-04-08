//
//  CPDFListView+ContentEditor.swift
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

extension CPDFListView {
    public override func menuItemsEditing(at point: CGPoint, for page: CPDFPage) -> [UIMenuItem]? {
        var menuItems = super.menuItemsEditing(at: point, for: page) ?? []
        
        self.menuPoint = point
        self.menuPage = page
        
        var isCropMode = false
        let editingArea = self.editingArea()
        if editingArea != nil && editingArea?.isImageArea() == true {
            let imageEditingArea:CPDFEditImageArea = (self.editingArea() as? CPDFEditImageArea) ?? CPDFEditImageArea()
            isCropMode = imageEditingArea.isCropMode
        }
        
        var editItem: UIMenuItem?
        var copyItem: UIMenuItem?
        var cutItem: UIMenuItem?
        var deleteItem: UIMenuItem?
        var pasteItem: UIMenuItem?
        var pasteMatchStyleItem: UIMenuItem?

        for item in menuItems {
            let action = item.action
            
            if NSStringFromSelector(action) == "editEditingItemAction:" {
                editItem = item
            } else if NSStringFromSelector(action) == "copyEditingItemAction:" {
                if self.document.allowsCopying == true {
                    copyItem = item
                } else {
                    copyItem = UIMenuItem(title: NSLocalizedString("Copy", comment: ""), action: #selector(copyActionClick(_ :)))
                }
                
            }else if NSStringFromSelector(action) == "cutEditingItemAction:" {
                cutItem = item
            } else if NSStringFromSelector(action) == "deleteEditingItemAction:" {
                deleteItem = item
            } else if NSStringFromSelector(action) == "pastEditingItemAction:" {
                pasteItem = item
            } else if NSStringFromSelector(action) == "pasteMatchStyleEditingItemAction:" {
                pasteMatchStyleItem = item
            }
        }
        
        if self.editStatus() == CEditingSelectState(rawValue: 0) {
            menuItems.removeAll()
            if(self.editingLoadType == .text) {
                let addTextItem = UIMenuItem(title: NSLocalizedString("Add Text", comment: ""), action: #selector(addTextEditingItemAction(_:)))
                
                menuItems.append(addTextItem)
            } else if (self.editingLoadType == .image) {
                let addImageItem = UIMenuItem(title: NSLocalizedString("Add Images", comment: ""), action: #selector(addImageEditingItemAction(_:)))
                
                menuItems.append(addImageItem)

            }
            
            if(pasteItem != nil) {
                menuItems.append(pasteItem!)
            }
            
            if(pasteMatchStyleItem != nil) {
                menuItems.append(pasteMatchStyleItem!)
            }
        }
        
        if (isCropMode) {
            let doneItem = UIMenuItem(title: NSLocalizedString("Done", comment: ""), action: #selector(doneActionClick(_:)))

            let cancelItem = UIMenuItem(title: NSLocalizedString("Cancel", comment: ""), action: #selector(cancelActionClick(_:)))
            menuItems.append(doneItem)
            menuItems.append(cancelItem)
        } else {
            let propertyItem = UIMenuItem(title: NSLocalizedString("Properties", comment: ""), action: #selector(propertyEditingItemAction(_:)))
            
            if self.editingArea() != nil {
                if (self.editingArea().isImageArea() == true) {
                    menuItems.removeAll()
                    
                    let leftRotateItem = UIMenuItem(title: NSLocalizedString("Rotate", comment: ""), action: #selector(leftRotateCropActionClick(_:)))
                    
                    let rPlaceItem = UIMenuItem(title: NSLocalizedString("Replace", comment: ""), action: #selector(replaceActionClick(_:)))

                    let cropItem = UIMenuItem(title: NSLocalizedString("Crop", comment: ""), action: #selector(enterCropActionClick(_:)))

                    let opacityItem = UIMenuItem(title: NSLocalizedString("Opacity", comment: ""), action: #selector(opacityEditingItemAction(_:)))

                    let hMirrorItem = UIMenuItem(title: NSLocalizedString("Flip horizontal", comment: ""), action: #selector(horizontalMirrorClick(_:)))

                    let vMirrorItem = UIMenuItem(title: NSLocalizedString("Flip vertical", comment: ""), action: #selector(verticalMirrorClick(_:)))

                    let extractItem = UIMenuItem(title: NSLocalizedString("Export", comment: ""), action: #selector(extractActionClick(_:)))
                    
                    menuItems.append(propertyItem)

                    menuItems.append(leftRotateItem)
                    menuItems.append(rPlaceItem)
                    menuItems.append(extractItem)
                    menuItems.append(opacityItem)
                    menuItems.append(hMirrorItem)
                    menuItems.append(vMirrorItem)
                    
                    menuItems.append(cropItem)
                    
                    if(cutItem != nil) {
                        menuItems.append(cutItem!)
                    }
                    if(copyItem != nil) {
                        menuItems.append(copyItem!)
                    }
                    if(deleteItem != nil) {
                        menuItems.append(deleteItem!)
                    }
                } else if (self.editingArea().isTextArea()) {
                    let state:CEditingSelectState = self.editStatus()
                    if state == .editSelectText {
                        menuItems.removeAll()
                        let opacityItem = UIMenuItem(title: NSLocalizedString("Opacity", comment: ""), action: #selector(opacityEditingItemAction(_:)))
                        menuItems.append(propertyItem)
                        menuItems.append(opacityItem)
                        
                        if(cutItem != nil) {
                            menuItems.append(cutItem!)
                        }
                        if(copyItem != nil) {
                            menuItems.append(copyItem!)
                        }
                        if(deleteItem != nil) {
                            menuItems.append(deleteItem!)
                        }
                    } else if state == .editTextArea {
                        menuItems.removeAll()
                        menuItems.append(propertyItem)
                        
                        if(editItem != nil) {
                            menuItems.append(editItem!)
                        }
                        if(cutItem != nil) {
                            menuItems.append(cutItem!)
                        }
                        if(copyItem != nil) {
                            menuItems.append(copyItem!)
                        }
                        if(deleteItem != nil) {
                            menuItems.append(deleteItem!)
                        }
                    }
                }
            }

        }
       
        if let customizeMenuItems = self.performDelegate?.PDFListView?(self, customizeMenuItems: menuItems, forPage: page, forPagePoint: bounds.origin) {
            if customizeMenuItems.count > 0 {
                menuItems = customizeMenuItems
            } else {
                menuItems.removeAll()
            }
        }

        return menuItems
    }
    
    // MARK: - Action
    @objc func leftRotateCropActionClick(_ sender: UIMenuController) {
        if(self.editingArea() != nil && self.editingArea().isImageArea() == true) {
            let imageArea:CPDFEditImageArea = (self.editingArea() as? CPDFEditImageArea) ?? CPDFEditImageArea()
            self.rotateEdit(imageArea, rotateAngle: -90)
        }
    }
    
    @objc func addTextEditingItemAction(_ sender: UIMenuController) {
        var fontColor = CPDFTextProperty.shared.fontColor
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        fontColor?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        fontColor = UIColor(red: red, green: green, blue: blue, alpha: CPDFTextProperty.shared.textOpacity)
        
        var font = UIFont(name: (CPDFTextProperty.shared.fontName ?? "Helvetica-Oblique") as String, size: CPDFTextProperty.shared.fontSize)
        if font == nil {
            font = UIFont(name: "Helvetica-Oblique", size: 10)
        }
        
        guard let page = self.menuPage else { return }
        let rect = CGRect(x: self.menuPoint.x, y: self.menuPoint.y, width: 60.0, height: 20)

        
        let atributes = CEditAttributes()
        atributes.font = font ?? UIFont()
        atributes.fontColor = fontColor ?? .black
        atributes.isBold = CPDFTextProperty.shared.isBold
        atributes.isItalic = CPDFTextProperty.shared.isItalic
        atributes.alignment = CPDFTextProperty.shared.textAlignment
        
        self.createStringBounds(rect, with: atributes, page: page)
    }
    
    @objc func addImageEditingItemAction(_ sender: UIMenuController) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.parentVC?.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func doneActionClick(_ sender: UIMenuController) {
        if(self.editingArea() != nil && self.editingArea().isImageArea() == true) {
            let imageArea:CPDFEditImageArea = (self.editingArea() as? CPDFEditImageArea) ?? CPDFEditImageArea()
            self.cropEdit(imageArea, with: imageArea.cropRect)
            self.endCropEdit(imageArea)
        }
    }
    
    @objc func copyActionClick(_ sender: UIMenuController) {
        self.enterPermissionPassword(pdfDocument: self.document)
    }
    
    @objc func cancelActionClick(_ sender: UIMenuController) {
        if(self.editingArea() != nil && self.editingArea().isImageArea() == true) {
            let imageArea:CPDFEditImageArea = (self.editingArea() as? CPDFEditImageArea) ?? CPDFEditImageArea()
            self.endCropEdit(imageArea)
        }
    }
    
    @objc func replaceActionClick(_ sender: UIMenuController) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.parentVC?.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func propertyEditingItemAction(_ sender: UIMenuController) {
        self.performDelegate?.PDFListViewContentEditProperty?(self, point: self.menuPoint)
    }
    
    @objc func opacityEditingItemAction(_ sender: UIMenuController) {
        var menuItems = [UIMenuItem]()
        let opacity25Item = UIMenuItem(title: NSLocalizedString("25%", comment: ""), action: #selector(opacity25ItemAction(_:)))
        let opacity50Item = UIMenuItem(title: NSLocalizedString("50%", comment: ""), action: #selector(opacity50ItemAction(_:)))
        let opacity75Item = UIMenuItem(title: NSLocalizedString("75%", comment: ""), action: #selector(opacity75ItemAction(_:)))
        let opacity100Item = UIMenuItem(title: NSLocalizedString("100%", comment: ""), action: #selector(opacity100ItemAction(_:)))
        menuItems.append(opacity25Item)
        menuItems.append(opacity50Item)
        menuItems.append(opacity75Item)
        menuItems.append(opacity100Item)

        var bounds = self.editingArea().bounds
        bounds = bounds.insetBy(dx: -15, dy: -15)
        let rect = self.convert(bounds, from: self.editingArea().page)

        if let customizeMenuItems = self.performDelegate?.PDFListView?(self, customizeMenuItems: menuItems, forPage: self.editingArea().page, forPagePoint: bounds.origin) {
            if customizeMenuItems.count > 0 {
                menuItems = customizeMenuItems
            } else {
                menuItems.removeAll()
            }
        }
        self.becomeFirstResponder()
        UIMenuController.shared.menuItems = menuItems
        UIMenuController.shared.setTargetRect(rect, in: self)
        UIMenuController.shared.setMenuVisible(true, animated: true)
    }
    
    @objc func opacity25ItemAction(_ sender: UIMenuController) {
        if(self.editingArea() != nil ) {
            if(self.editingArea().isTextArea()) {
                let textArea:CPDFEditTextArea = (self.editingArea() as? CPDFEditTextArea) ?? CPDFEditTextArea()
                self.setCharsFontTransparency(0.25, with: textArea)
            } else if (self.editingArea().isImageArea()) {
                let imageArea:CPDFEditImageArea = (self.editingArea() as? CPDFEditImageArea) ?? CPDFEditImageArea()
                self.setImageTransparencyEdit(imageArea, transparency: 0.25)
            }
        }
    }
    
    @objc func opacity50ItemAction(_ sender: UIMenuController) {
        if(self.editingArea() != nil ) {
            if(self.editingArea().isTextArea()) {
                let textArea:CPDFEditTextArea = (self.editingArea() as? CPDFEditTextArea) ?? CPDFEditTextArea()
                self.setCharsFontTransparency(0.5, with: textArea)
            } else if (self.editingArea().isImageArea()) {
                let imageArea:CPDFEditImageArea = (self.editingArea() as? CPDFEditImageArea) ?? CPDFEditImageArea()
                self.setImageTransparencyEdit(imageArea, transparency: 0.5)
            }
        }
    }
    
    @objc func opacity75ItemAction(_ sender: UIMenuController) {
        if(self.editingArea() != nil ) {
            if(self.editingArea().isTextArea()) {
                let textArea:CPDFEditTextArea = (self.editingArea() as? CPDFEditTextArea) ?? CPDFEditTextArea()
                self.setCharsFontTransparency(0.75, with: textArea)
            } else if (self.editingArea().isImageArea()) {
                let imageArea:CPDFEditImageArea = (self.editingArea() as? CPDFEditImageArea) ?? CPDFEditImageArea()
                self.setImageTransparencyEdit(imageArea, transparency: 0.75)
            }
        }
    }
    
    @objc func opacity100ItemAction(_ sender: UIMenuController) {
        if(self.editingArea() != nil ) {
            if(self.editingArea().isTextArea()) {
                let textArea:CPDFEditTextArea = (self.editingArea() as? CPDFEditTextArea) ?? CPDFEditTextArea()
                self.setCharsFontTransparency(1.0, with: textArea)
            } else if (self.editingArea().isImageArea()) {
                let imageArea:CPDFEditImageArea = (self.editingArea() as? CPDFEditImageArea) ?? CPDFEditImageArea()
                self.setImageTransparencyEdit(imageArea, transparency: 1.0)
            }
        }
    }
    
    @objc func enterCropActionClick(_ sender: UIMenuController) {
        if(self.editingArea() != nil && self.editingArea().isImageArea() == true) {
            let imageArea:CPDFEditImageArea = (self.editingArea() as? CPDFEditImageArea) ?? CPDFEditImageArea()
            self.beginCropEdit(imageArea)
        }
    }
    
    @objc func horizontalMirrorClick(_ sender: UIMenuController) {
        if(self.editingArea() != nil && self.editingArea().isImageArea() == true) {
            let imageArea:CPDFEditImageArea = (self.editingArea() as? CPDFEditImageArea) ?? CPDFEditImageArea()
            self.horizontalMirrorEdit(imageArea)
        }
    }
    
    @objc func verticalMirrorClick(_ sender: UIMenuController) {
        if(self.editingArea() != nil && self.editingArea().isImageArea() == true) {
            let imageArea:CPDFEditImageArea = (self.editingArea() as? CPDFEditImageArea) ?? CPDFEditImageArea()
            self.verticalMirrorEdit(imageArea)
        }
    }
    
    @objc func extractActionClick(_ sender: UIMenuController) {
        if(self.editingArea() != nil && self.editingArea().isImageArea() == true) {
            let imageArea:CPDFEditImageArea = (self.editingArea() as? CPDFEditImageArea) ?? CPDFEditImageArea()
            let saved = self.extractImage(withEditImageArea: imageArea)
            
            if saved == true {
                let alertController = UIAlertController(title: "", message: NSLocalizedString("Export Successfully!", comment: ""), preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                
                let tRootViewControl = self.parentVC
                
                tRootViewControl?.present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "", message: NSLocalizedString("Export Failed!", comment: ""), preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                
                let tRootViewControl = self.parentVC
                
                tRootViewControl?.present(alertController, animated: true, completion: nil)
            }

        }
    }
    
    // MARK: - imagePickerDelegate

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if #available(iOS 11.0, *) {
            if let url = info[.imageURL] as? URL {
                if self.editStatus() == CEditingSelectState(rawValue: 0) {
                    if var image = UIImage(contentsOfFile: url.path) {
                        var imgWidth: CGFloat = 0
                        var imgHeight: CGFloat = 0
                        var scaledWidth: CGFloat = 149
                        var scaledHeight: CGFloat = 210

                        if image.imageOrientation != .up {
                            UIGraphicsBeginImageContext(image.size)
                            image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
                            if let rotatedImage = UIGraphicsGetImageFromCurrentImageContext() {
                                image = rotatedImage
                            }
                            UIGraphicsEndImageContext()
                            imgWidth = image.size.height
                            imgHeight = image.size.width
                        } else {
                            imgWidth = image.size.width
                            imgHeight = image.size.height
                        }

                        let scaled = min(scaledWidth / imgWidth, scaledHeight / imgHeight)
                         scaledHeight = imgHeight * scaled
                         scaledWidth = imgWidth * scaled

                        let rect = CGRect(x: self.menuPoint.x, y: self.menuPoint.y, width: scaledWidth, height: scaledHeight)
                        self.createEmptyImage(rect, page: self.menuPage, path: url.path)
                    }
                } else {
                    if var image = UIImage(contentsOfFile: url.path) {
                        var imgWidth: CGFloat = 0
                        var imgHeight: CGFloat = 0
                        var scaledWidth: CGFloat = 149
                        var scaledHeight: CGFloat = 210
                        
                        if image.imageOrientation != .up {
                            UIGraphicsBeginImageContext(image.size)
                            image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
                            if let rotatedImage = UIGraphicsGetImageFromCurrentImageContext() {
                                image = rotatedImage
                            }
                            UIGraphicsEndImageContext()
                            imgWidth = image.size.height
                            imgHeight = image.size.width
                        } else {
                            imgWidth = image.size.width
                            imgHeight = image.size.height
                        }
                        
                        let scaled = min(scaledWidth / imgWidth, scaledHeight / imgHeight)
                        scaledHeight = imgHeight * scaled
                        scaledWidth = imgWidth * scaled
                        
                        let rect = CGRect(x: self.menuPoint.x, y: self.menuPoint.y, width: scaledWidth, height: scaledHeight)
                        
                        if(self.editingArea() != nil && self.editingArea().isImageArea()) {
                            let imageArea:CPDFEditImageArea = (self.editingArea() as? CPDFEditImageArea) ?? CPDFEditImageArea()
                            self.replace(imageArea, imagePath: url.path, rect: rect)
                            
                        }
                    }
                }
            }
        } else {
            if let url = info[.mediaURL] as? URL {
                if self.editStatus() == CEditingSelectState(rawValue: 0) {
                    if var image = UIImage(contentsOfFile: url.path) {
                        var imgWidth: CGFloat = 0
                        var imgHeight: CGFloat = 0
                        let scaledWidth: CGFloat = 14
                        var scaledHeight: CGFloat = 0

                        if image.imageOrientation != .up {
                            UIGraphicsBeginImageContext(image.size)
                            image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
                            if let rotatedImage = UIGraphicsGetImageFromCurrentImageContext() {
                                image = rotatedImage
                            }
                            UIGraphicsEndImageContext()
                            imgWidth = image.size.height
                            imgHeight = image.size.width
                        } else {
                            imgWidth = image.size.width
                            imgHeight = image.size.height
                        }
                        scaledHeight = scaledWidth * imgHeight / imgWidth

                        let rect = CGRect(x: self.menuPoint.x, y: self.menuPoint.y, width: scaledWidth, height: scaledHeight)
                        self.createEmptyImage(rect, page: self.menuPage, path: url.path)
                    }
                } else {
                    if var image = UIImage(contentsOfFile: url.path) {
                        var imgWidth: CGFloat = 0
                        var imgHeight: CGFloat = 0
                        let scaledWidth: CGFloat = 14
                        var scaledHeight: CGFloat = 0
                        
                        if image.imageOrientation != .up {
                            UIGraphicsBeginImageContext(image.size)
                            image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
                            if let rotatedImage = UIGraphicsGetImageFromCurrentImageContext() {
                                image = rotatedImage
                            }
                            UIGraphicsEndImageContext()
                            imgWidth = image.size.height
                            imgHeight = image.size.width
                        } else {
                            imgWidth = image.size.width
                            imgHeight = image.size.height
                        }
                        scaledHeight = scaledWidth * imgHeight / imgWidth
                        
                        let rect = CGRect(x: self.menuPoint.x, y: self.menuPoint.y, width: scaledWidth, height: scaledHeight)
                        self.createEmptyImage(rect, page: self.menuPage, path: url.path)
                        
                        if(self.editingArea() != nil && self.editingArea().isImageArea()) {
                            let imageArea:CPDFEditImageArea = (self.editingArea() as? CPDFEditImageArea) ?? CPDFEditImageArea()
                            
                            self.replace(imageArea, imagePath: url.path, rect: rect)
                        }
                    }
                }
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }


}

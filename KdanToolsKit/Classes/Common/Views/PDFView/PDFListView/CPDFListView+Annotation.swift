//
//  CPDFListView+Annotation.swift
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
import MobileCoreServices
import ComPDFKit

extension CPDFListView {
    func compressImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        var imageScale: CGFloat = 1.0
        if image.size.width > size.width || image.size.height > size.height {
            imageScale = min(size.width / image.size.width, size.height / image.size.height)
        }
        let newSize = CGSize(width: image.size.width * imageScale, height: image.size.height * imageScale)
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func updateScrollEnabled() {
        if self.activeAnnotation != nil {
            self.scrollEnabled = false
        } else {
            if (self.annotationMode == .link) {
                self.scrollEnabled = false
            } else {
                self.scrollEnabled = true
            }
        }
    }
    
    func isPasteboardValid() -> Bool {
        let textType = kUTTypeText as String
        let urlType = kUTTypeURL as String
        let urlFileType = kUTTypeFileURL as String
        let jpegImageType = kUTTypeJPEG as String
        let pngImageType = kUTTypePNG as String
        let rawImageType = "com.apple.uikit.image"
        
        let pasteboard = UIPasteboard.general
        
        return pasteboard.contains(pasteboardTypes: [textType, urlType, urlFileType, jpegImageType, pngImageType, rawImageType])
    }
    
    
    func showMenuForAnnotation(_ annotation: CPDFAnnotation?) {
        if(annotation == nil) {
            UIMenuController.shared.menuItems = nil
            if #available(iOS 13.0, *) {
                UIMenuController.shared.hideMenu(from: self)
            } else {
                UIMenuController.shared.setMenuVisible(false, animated: true)
            }
            return
        }
        
        let editNoteItem = UIMenuItem(title: NSLocalizedString("Edit", comment: ""), action: #selector(menuItemClick_Edit(_:)))
        
        let deleteItem = UIMenuItem(title: NSLocalizedString("Delete", comment: ""), action: #selector(menuItemClick_Delete(_:)))
        
        let propertiesItem = UIMenuItem(title: NSLocalizedString("Properties", comment: ""), action: #selector(menuItemClick_Properties(_:)))
        
        let noteItem = UIMenuItem(title: NSLocalizedString("Note", comment: ""), action: #selector(menuItemClick_Note(_:)))
        
        var menuItems:[UIMenuItem] = []
        if annotation is CPDFTextAnnotation {
            
        } else if (annotation is CPDFMarkupAnnotation ||
                   annotation is CPDFInkAnnotation ||
                   annotation is CPDFCircleAnnotation ||
                   annotation is CPDFSquareAnnotation ||
                   annotation is CPDFLineAnnotation) {
            menuItems.append(propertiesItem)
            menuItems.append(noteItem)
            menuItems.append(deleteItem)
        } else if (annotation is CPDFFreeTextAnnotation) {
            menuItems.append(propertiesItem)
            menuItems.append(editNoteItem)
            menuItems.append(deleteItem)
        } else if (annotation is CPDFStampAnnotation) {
            menuItems.append(noteItem)
            menuItems.append(deleteItem)
        } else if annotation is CPDFSoundAnnotation ||
                  annotation is CPDFMovieAnnotation {
            if annotation is CPDFSoundAnnotation {
                let playItem = UIMenuItem(title: NSLocalizedString("Play", comment: ""), action: #selector(menuItemClick_Play(_:)))
                menuItems.append(playItem)
            }
            menuItems.append(deleteItem)
        } else if (annotation is CPDFLinkAnnotation) {
            menuItems.append(editNoteItem)
            menuItems.append(deleteItem)
        } else if (annotation is CPDFSignatureAnnotation) {
            let addHereItem = UIMenuItem(title: NSLocalizedString("Sign", comment: ""), action: #selector(menuItemClick_Sign(_:)))
            menuItems.append(addHereItem)
            menuItems.append(deleteItem)
        }
        
        if(menuItems.count <= 0) {
            return
        }
        
        if(annotation != nil && annotation?.page != nil) {
            let bounds:CGRect = annotation?.bounds ?? CGRect.zero
            
            if let customizeMenuItems = self.performDelegate?.PDFListView?(self, customizeMenuItems: menuItems, forPage: annotation?.page ?? CPDFPage(), forPagePoint: bounds.origin) {
                if customizeMenuItems.count > 0 {
                    menuItems = customizeMenuItems
                } else {
                    menuItems.removeAll()
                }
            }
            let zBounds = bounds.insetBy(dx: -15, dy: -15)
            let rect = self.convert(zBounds, from: annotation?.page)
            UIMenuController.shared.menuItems = menuItems
            self.becomeFirstResponder()
            
            if #available(iOS 13.0, *) {
                UIMenuController.shared.showMenu(from: self, rect: rect)
            } else {
                UIMenuController.shared.setTargetRect(rect, in: self)
                UIMenuController.shared.setMenuVisible(true, animated: true)
            }
        }
    }
    
    func showMenuForMedia(at point: CGPoint, for page: CPDFPage) {
        var menuItems: [UIMenuItem] = []
        let cancelItem = UIMenuItem(title: NSLocalizedString("Delete", comment: ""), action: #selector(menuItemClick_MediaDelete(_:)))
        let mediaRecordItem = UIMenuItem(title: NSLocalizedString("Record", comment: ""), action: #selector(menuItemClick_MediaRecord(_:)))
        
        menuItems.append(mediaRecordItem)
        menuItems.append(cancelItem)
        
        let bounds = CGRect(x: point.x-18, y: point.y-18, width: 37, height: 37)
        let rect = convert(bounds, from: page)
        
        if let customizeMenuItems = self.performDelegate?.PDFListView?(self, customizeMenuItems: menuItems, forPage: page, forPagePoint: bounds.origin) {
            if customizeMenuItems.count > 0 {
                menuItems = customizeMenuItems
            } else {
                menuItems.removeAll()
            }
        }
        
        becomeFirstResponder()
        UIMenuController.shared.menuItems = menuItems
        if #available(iOS 13.0, *) {
            UIMenuController.shared.showMenu(from: self, rect: rect)
        } else {
            UIMenuController.shared.setTargetRect(rect, in: self)
            UIMenuController.shared.setMenuVisible(true, animated: true)
        }
    }
    
    // MARK: - Action
    @objc func menuItemClick_Edit(_ sender: UIMenuController) {
        if(self.activeAnnotation is CPDFTextAnnotation || self.activeAnnotation is CPDFLinkAnnotation) {
            self.performDelegate?.PDFListViewEditNote?(self, forAnnotation: activeAnnotation ?? CPDFAnnotation())
        } else if (self.activeAnnotation is CPDFFreeTextAnnotation) {
            self.editAnnotationFreeText(activeAnnotation as? CPDFFreeTextAnnotation)
            self.updateActiveAnnotations([])
        }
    }
    
    @objc func menuItemClick_Delete(_ sender: UIMenuController) {
        activeAnnotation?.page.removeAnnotation(activeAnnotation)
        setNeedsDisplayFor(activeAnnotation?.page)
        updateActiveAnnotations([])
        updateScrollEnabled()
    }
    
    @objc func menuItemClick_Note(_ sender: UIMenuController) {
        if(activeAnnotation != nil) {
            self.performDelegate?.PDFListViewEditNote?(self, forAnnotation: activeAnnotation!)
        }
    }
    
    @objc func menuItemClick_Properties(_ sender: UIMenuController) {
        if(activeAnnotation != nil) {
            self.performDelegate?.PDFListViewEditProperties?(self, forAnnotation: activeAnnotation!)
        }
    }
    
    @objc func menuItemClick_Sign(_ sender: UIMenuController) {
        if(activeAnnotation != nil) {
            if(activeAnnotation is CPDFSignatureAnnotation) {
                let signatureAnnotation:CPDFSignatureAnnotation = activeAnnotation as! CPDFSignatureAnnotation
                signatureAnnotation.signature()
                setNeedsDisplayFor(activeAnnotation!.page)
                updateActiveAnnotations([])
                updateScrollEnabled()
            }
        }
    }
    
    @objc func menuItemClick_Paste(_ sender: UIMenuController) {
        let textType = kUTTypeText as String
        let utf8TextType = kUTTypeUTF8PlainText as String
        let urlType = kUTTypeURL as String
        let urlFileType = kUTTypeFileURL as String
        let jpegImageType = kUTTypeJPEG as String
        let pngImageType = kUTTypePNG as String
        let rawImageType = "com.apple.uikit.image"
        
        let pasteArray = UIPasteboard.general.items
        for item in pasteArray {
            if item.keys.contains(where: { $0 == textType ||
                $0 == utf8TextType ||
                $0 == urlType ||
                $0 == urlFileType }) {
                var contents: String?
                if let text = item[textType] as? String ?? item[utf8TextType] as? String {
                    contents = text
                } else if let url = item[urlType] as? URL ?? item[urlFileType] as? URL {
                    contents = url.absoluteString
                }
                
                if let contents = contents {
                    let font = UIFont.systemFont(ofSize: 12.0)
                    let attributes = [NSAttributedString.Key.font: font]
                    let bounds = contents.boundingRect(with: CGSize(width: 280, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
                    
                    let annotation = CPDFFreeTextAnnotation(document: self.document)
                    annotation?.contents = contents
                    annotation?.setModificationDate(NSDate() as Date)
                    annotation?.setUserName(self.annotationUserName)
                    annotation?.bounds = CGRect(x: self.menuPoint.x - bounds.size.width/2.0,
                                                y: self.menuPoint.y - bounds.size.height/2.0,
                                                width: bounds.size.width, height: bounds.size.height)
                    self.menuPage?.addAnnotation(annotation)
                    self.setNeedsDisplayFor(self.menuPage)
                }
            } else if item.keys.contains(where: { $0 == jpegImageType ||
                $0 == pngImageType ||
                $0 == rawImageType }) {
                if let image = UIPasteboard.general.image,
                   let compressImage = self.compressImage(image, to: CGSize(width: 240.0, height: 240.0)) {
                    let annotation = CPDFStampAnnotation(document: self.document, image: compressImage)
                    annotation?.setModificationDate(NSDate() as Date)
                    annotation?.setUserName(self.annotationUserName)
                    annotation?.bounds = CGRect(x: self.menuPoint.x - compressImage.size.width/2.0,
                                                y: self.menuPoint.y - compressImage.size.height/2.0,
                                                width: compressImage.size.width, height: compressImage.size.height)
                    self.menuPage?.addAnnotation(annotation)
                    self.setNeedsDisplayFor(self.menuPage)
                }
            }
        }
    }
    
    @objc func menuItemClick_TextNote(_ sender: UIMenuController) {
        if(self.currentSelection != nil) {
            var quadrilateralPoints = [CGPoint]()
            let annotation = CPDFMarkupAnnotation(document: self.document, markupType: .highlight)
            for selection in currentSelection.selectionsByLine {
                let bounds = selection.bounds
                quadrilateralPoints.append(CGPoint(x: bounds.minX, y: bounds.maxY))
                quadrilateralPoints.append(CGPoint(x: bounds.maxX, y: bounds.maxY))
                quadrilateralPoints.append(CGPoint(x: bounds.minX, y: bounds.minY))
                quadrilateralPoints.append(CGPoint(x: bounds.maxX, y: bounds.minY))
            }
            annotation?.quadrilateralPoints = quadrilateralPoints
            annotation?.setMarkupText(currentSelection.string())
            annotation?.setModificationDate(NSDate() as Date)
            annotation?.setUserName(self.annotationUserName)
            self.currentSelection.page.addAnnotation(annotation)
            annotation?.createPopup()
            
            clearSelection()
            setNeedsDisplayFor(annotation?.page)
        } else {
            [self .addAnnotation(.note, at: menuPoint, for: menuPage ?? CPDFPage())]
        }
    }
    
    @objc func menuItemClick_FreeText(_ sender: UIMenuController) {
        self.addAnnotationFreeTextAtPoint(self.menuPoint, forPage: self.menuPage ?? CPDFPage())
    }
    
    @objc func menuItemClick_Stamp(_ sender: UIMenuController) {
        self.performDelegate?.PDFListViewPerformAddStamp?(self, atPoint: self.menuPoint, forPage: self.menuPage ?? CPDFPage())
    }
    
    @objc func menuItemClick_Image(_ sender: UIMenuController) {
        self.performDelegate?.PDFListViewPerformAddImage?(self, atPoint: self.menuPoint, forPage: self.menuPage ?? CPDFPage())
    }
    
    @objc func menuItemClick_Play(_ sender: UIMenuController) {
        if(activeAnnotation != nil) {
            if(activeAnnotation is CPDFSoundAnnotation) {
                self.performDelegate?.PDFListViewPerformPlay?(self, forAnnotation: activeAnnotation as! CPDFSoundAnnotation)
            }
        }
    }
    
    @objc func menuItemClick_MediaDelete(_ sender: UIMenuController) {
        let point = CGPoint(x: self.mediaSelectionRect.midX, y: self.mediaSelectionRect.midY)
        guard let page = self.mediaSelectionPage else { return }
        
        self.performDelegate?.PDFListViewPerformCancelMedia?(self, atPoint: point, forPage: page)
        
        self.mediaSelectionPage = nil
        setNeedsDisplayFor(page)
    }
    
    
    @objc func menuItemClick_MediaRecord(_ sender: UIMenuController) {
        let point = CGPoint(x: self.mediaSelectionRect.midX, y: self.mediaSelectionRect.midY)
        guard let page = self.mediaSelectionPage else { return }
        self.performDelegate?.PDFListViewPerformRecordMedia?(self, atPoint: point, forPage: page)
    }
            
    // MARK: - Menu
    func annotationMenuItems(at point: CGPoint, for page: CPDFPage) -> [UIMenuItem] {
        self.menuPoint = point
        self.menuPage = page
        var menuItems = [UIMenuItem]()
        
        if self.currentSelection != nil {
            if let menus = super.menuItems(at: point, for: page), !menus.isEmpty {
                menuItems = menus
            }
        } else {
            let pasteItem = UIMenuItem(title: NSLocalizedString("Paste", comment: ""), action: #selector(menuItemClick_Paste(_:)))
            if isPasteboardValid() {
                menuItems.append(pasteItem)
            }
            let textNoteItem = UIMenuItem(title: NSLocalizedString("Note", comment: ""), action: #selector(menuItemClick_TextNote(_:)))
            let textItem = UIMenuItem(title: NSLocalizedString("Text", comment: ""), action: #selector(menuItemClick_FreeText(_:)))
            let stampItem = UIMenuItem(title: NSLocalizedString("Stamp", comment: ""), action: #selector(menuItemClick_Stamp(_:)))
            let imageItem = UIMenuItem(title: NSLocalizedString("Image", comment: ""), action: #selector(menuItemClick_Image(_:)))
            menuItems.append(textNoteItem)
            menuItems.append(textItem)
            menuItems.append(stampItem)
            menuItems.append(imageItem)
        }
        
        return menuItems
    }
    
    // MARK: - Touch
    func annotationTouchBegan(at point: CGPoint, for page: CPDFPage) {
        if self.textSelectionMode {
        } else {
            self.addAnnotationPoint = point
            self.addAnnotationRect = CGRect.zero
            
            self.draggingType = .none
            if(self.activeAnnotation == nil || self.activeAnnotation?.page != page) {
                return
            }
            
            let topLeftRect = self.topLeftRect.insetBy(dx: -5, dy: -5)
            let bottomLeftRect = self.bottomLeftRect.insetBy(dx: -5, dy: -5)
            let topRightRect = self.topRightRect.insetBy(dx: -5, dy: -5)
            let bottomRightRect = self.bottomRightRect.insetBy(dx: -5, dy: -5)
            let startPointRect = self.startPointRect.insetBy(dx: -5, dy: -5)
            let endPointRect = self.endPointRect.insetBy(dx: -5, dy: -5)
            if topLeftRect.contains(point) {
                self.draggingType = .topLeft
            } else if bottomLeftRect.contains(point) {
                self.draggingType = .bottomLeft
            } else if topRightRect.contains(point) {
                self.draggingType = .topRight
            } else if bottomRightRect.contains(point) {
                self.draggingType = .bottomRight
            } else if startPointRect.contains(point) {
                self.draggingType = .start
            } else if endPointRect.contains(point) {
                self.draggingType = .end
            } else if page.annotation(self.activeAnnotation, at: point) {
                self.draggingType = .center
            }
            self.draggingPoint = point
        }
    }
    
    func annotationTouchMoved(at point: CGPoint, for page: CPDFPage) {
        if self.textSelectionMode {
        } else if self.draggingType != .none {
            if !self.undoMove {
                self.undoPDFManager?.beginUndoGrouping()
                self.undoMove = true
            }
            if self.activeAnnotation != nil {
                self.moveAnnotation(self.activeAnnotation!, fromPoint: self.draggingPoint, toPoint: point, forType: self.draggingType)
                self.setNeedsDisplayFor(page)
                self.draggingPoint = point
            }
        } else if (self.annotationMode == .link) {
            var rect = CGRect.zero
            if point.x > self.addAnnotationPoint.x {
                rect.origin.x = self.addAnnotationPoint.x
                rect.size.width = point.x - self.addAnnotationPoint.x
            } else {
                rect.origin.x = point.x
                rect.size.width = self.addAnnotationPoint.x - point.x
            }
            if point.y > self.addAnnotationPoint.y {
                rect.origin.y = self.addAnnotationPoint.y
                rect.size.height = point.y - self.addAnnotationPoint.y
            } else {
                rect.origin.y = point.y
                rect.size.height = self.addAnnotationPoint.y - point.y
            }
            self.addAnnotationRect = rect
            setNeedsDisplayFor(page)
        }
    }
    
    func annotationTouchEnded(at point: CGPoint, for page: CPDFPage) {
        if self.textSelectionMode {
            if self.currentSelection != nil {
                self.addAnnotation(self.annotationMode, at: point, for: page)
            }  else {
                let annotation = page.annotation(at: point)
                if annotation != nil && annotation?.isHidden() == false {
                    if (annotation is CPDFMarkupAnnotation) {
                        if !(self.activeAnnotations?.contains(annotation!) ?? false) {
                            self.updateActiveAnnotations([annotation!])
                            setNeedsDisplayFor(page)
                        }
                        self.showMenuForAnnotation(annotation)
                    }
                } else {
                    if self.activeAnnotation != nil {
                        self.updateActiveAnnotations([])
                        setNeedsDisplayFor(page)
                    } else {
                        if (self.annotationMode == .highlight ||
                            self.annotationMode == .underline ||
                            self.annotationMode == .strikeout ||
                            self.annotationMode == .squiggly) {
                            self.performDelegate?.PDFListViewPerformTouchEnded?(self)
                        }
                    }
                }
            }
        } else if self.draggingType == .none {
            if (self.activeAnnotation != nil && !(self.annotationMode == .link && !self.addAnnotationRect.isEmpty)) {
                let previousPage = self.activeAnnotation?.page
                self.updateActiveAnnotations([])
                setNeedsDisplayFor(previousPage)
                self.updateScrollEnabled()
            } else {
                if (self.annotationMode == .CPDFViewAnnotationModenone) {
                    var annotation = page.annotation(at: point)
                    if annotation != nil && annotation?.isHidden() == true {
                        annotation = nil
                    }
                    
                    if annotation != nil && annotation is CPDFTextAnnotation {
                        if !(self.activeAnnotations?.contains(annotation!) ?? false) {
                            self.updateActiveAnnotations([annotation!])
                            setNeedsDisplayFor(page)
                            self.updateScrollEnabled()
                        }
                        
                        self.performDelegate?.PDFListViewEditNote?(self, forAnnotation: annotation!)
                        self.showMenuForAnnotation(annotation)
                    } else if (annotation != nil && annotation is CPDFMarkupAnnotation) {
                        if !(self.activeAnnotations?.contains(annotation!) ?? false) {
                            self.updateActiveAnnotations([annotation!])
                            setNeedsDisplayFor(page)
                        }
                        self.showMenuForAnnotation(annotation)
                    } else if (annotation != nil && annotation is CPDFLinkAnnotation) {
                        super .touchEnded(at: point, for: page)
                    } else if (annotation != nil && annotation is CPDFMovieAnnotation) {
                        super .touchEnded(at: point, for: page)
                    } else if (annotation != nil && annotation is CPDFWidgetAnnotation) {
                        if annotation is CPDFSignatureWidgetAnnotation {
                            let signatureWidgetAnnotation:CPDFSignatureWidgetAnnotation = annotation as! CPDFSignatureWidgetAnnotation
                            if signatureWidgetAnnotation.isSigned() {
                                self.showMenuForAnnotation(signatureWidgetAnnotation)
                            } else {
                                self.performDelegate?.PDFListViewPerformSignatureWidget?(self, forAnnotation: signatureWidgetAnnotation)
                            }
                        } else {
                            super.touchEnded(at: point, for: page)
                        }
                    } else {
                        if (annotation != nil) {
                            if !(self.activeAnnotations?.contains(annotation!) ?? false) {
                                self.updateActiveAnnotations([annotation!])
                            }
                        } else {
                            self.updateActiveAnnotations([])
                        }
                        setNeedsDisplayFor(page)
                        self.updateScrollEnabled()
                        self.showMenuForAnnotation(annotation)
                        
                        if self.activeAnnotation == nil {
                            self.performDelegate?.PDFListViewPerformTouchEnded?(self)
                        }
                    }
                } else if (self.annotationMode == .link) {
                    if self.addAnnotationRect.isEmpty {
                        var annotation = page.annotation(at: point)
                        if annotation != nil && annotation?.isHidden() == true {
                            annotation = nil
                        }
                        
                        if annotation != nil && annotation is CPDFLinkAnnotation {
                            self.updateActiveAnnotations([annotation!])
                            setNeedsDisplayFor(page)
                            self.updateScrollEnabled()
                            self.showMenuForAnnotation(annotation)
                        }
                    } else {
                        self.addAnnotationLinkAtPoint(point, forPage: page)
                    }
                } else if (self.annotationMode == .freeText) {
                    self.addAnnotationFreeTextAtPoint(point, forPage: page)
                } else if (self.annotationMode == .sound) {
                    var isAudioRecord:Bool = false
                    isAudioRecord = self.performDelegate?.PDFListViewerTouchEndedIsAudioRecordMedia?(self) == true
                    if !isAudioRecord {
                        self.addAnnotationMedia(at: point, for: page)
                    }
                } else if (self.annotationMode == .stamp ||
                           self.annotationMode == .signature ||
                           self.annotationMode == .image) {
                    self .setAnnotationMode(.CPDFViewAnnotationModenone)
                    self.addAnnotationAtPoint(point, forPage: page)
                } else {
                    self.addAnnotation(self.annotationMode, at: point, for: page)
                }
            }
        } else {
            if (self.draggingType != .center && activeAnnotation != nil) {
                if activeAnnotation is CPDFFreeTextAnnotation ||
                    activeAnnotation is CPDFStampAnnotation ||
                    activeAnnotation is CPDFSignatureAnnotation {
                    activeAnnotation?.updateAppearanceStream()
                    setNeedsDisplayFor(page)
                }
            }
            if self.undoMove {
                self.undoPDFManager?.endUndoGrouping()
                self.undoMove = false
            }
            
            self.draggingType = .none
            self.showMenuForAnnotation(activeAnnotation)
        }
    }
    
    func annotationTouchCancelled(at point: CGPoint, for page: CPDFPage) {
        self.draggingType = .none
        
        if self.undoMove {
            self.undoPDFManager?.endUndoGrouping()
            self.undoMove = false
        }
    }
    
    // MARK: - Draw
    func annotationDrawPage(_ page: CPDFPage, to context: CGContext) {
        if(self.annotationMode == .link) {
            context.setLineWidth(1.0)
            context.setStrokeColor(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.8).cgColor)
            context.setFillColor(UIColor(red: 100.0/255.0, green: 149.0/255.0, blue: 237.0/255.0, alpha: 0.4).cgColor)
            context.addRect(self.addAnnotationRect)
            context.drawPath(using: .fillStroke)
        }
        
        if self.mediaSelectionPage != nil && self.mediaSelectionPage == page {
            let image = UIImage(named: "CPDFListViewImageNameSoundRecoding", in: Bundle(for: self.classForCoder), compatibleWith: nil)
            context.draw(image!.cgImage!, in: self.mediaSelectionRect)
        }
        
        if self.activeAnnotation?.page != page {
            return
        }
        let dragDotSize = CGSize(width: 30, height: 30)
        context.setStrokeColor(UIColor(red: 72.0/255.0, green: 183.0/255.0, blue: 247.0/255.0, alpha: 1.0).cgColor)
        
        if (self.activeAnnotations != nil) {
            for annotation in self.activeAnnotations! {
                if annotation is CPDFLineAnnotation {
                    let line = self.activeAnnotation as! CPDFLineAnnotation
                    let startPoint = line.startPoint
                    let endPoint = line.endPoint
                    
                    var tStartPoint = startPoint
                    var tEndPoint = endPoint
                    
                    let final: CGFloat = 40.0
                    if abs(tStartPoint.x - tEndPoint.x) < 0.00001 {
                        if tStartPoint.y > endPoint.y {
                            tStartPoint.y += final
                            tEndPoint.y -= final
                        } else {
                            tStartPoint.y -= final
                            tEndPoint.y += final
                        }
                    }   else if abs(tStartPoint.y - tEndPoint.y) < 0.00001 {
                        if tStartPoint.x > tEndPoint.x {
                            tStartPoint.x += final
                            tEndPoint.x -= final
                        } else {
                            tStartPoint.x -= final
                            tEndPoint.x += final
                        }
                    } else {
                        let k = (tEndPoint.y - tStartPoint.y) / (tEndPoint.x - tStartPoint.x)
                        let atank = atan(k)
                        if endPoint.x > startPoint.x {
                            tEndPoint.x += cos(atank) * final
                            tEndPoint.y += sin(atank) * final
                            tStartPoint.x -= cos(atank) * final
                            tStartPoint.y -= sin(atank) * final
                        } else {
                            tEndPoint.x -= cos(atank) * final
                            tEndPoint.y -= sin(atank) * final
                            tStartPoint.x += cos(atank) * final
                            tStartPoint.y += sin(atank) * final
                        }
                    }
                    
                    context.setLineWidth(1.0)
                    let dashArray: [CGFloat] = [3,3]
                    context.setLineDash(phase: 0, lengths: dashArray)
                    context.move(to: tStartPoint)
                    context.addLine(to: startPoint)
                    context.strokePath()
                    context.move(to: endPoint)
                    context.addLine(to: endPoint)
                    context.strokePath()
                    
                    let startPointRect = CGRect(x: tStartPoint.x - dragDotSize.width/2.0, y: tStartPoint.y - dragDotSize.height/2.0, width: dragDotSize.width, height: dragDotSize.height)
                    let endPointRect = CGRect(x: endPoint.x - dragDotSize.width/2.0, y: endPoint.y - dragDotSize.height/2.0, width: dragDotSize.width, height: dragDotSize.height)
                    
                    let image = UIImage.init(named: "CPDFListViewImageNameAnnotationDragDot", in: Bundle(for: self.classForCoder), compatibleWith: nil)
                    let dragDotImage = image?.cgImage
                    
                    context.draw(dragDotImage!, in: startPointRect)
                    context.draw(dragDotImage!, in: endPointRect)
                    
                    self.startPointRect = startPointRect
                    self.endPointRect = endPointRect
                } else if (annotation is CPDFMarkupAnnotation) {
                    if(annotation.bounds.isEmpty) {
                        continue
                    }
                    
                    if let markupAnnotation = annotation as? CPDFMarkupAnnotation {
                        guard let points = markupAnnotation.quadrilateralPoints else {
                            continue
                        }
                        
                        let lineWidth: CGFloat = 1.0
                        context.saveGState()
                        context.setLineWidth(lineWidth)
                        
                        let count = 4
                        var i = 0
                        while i + count <= points.count {
                            let ptltv:NSValue = points[i] as? NSValue ?? NSValue()
                            let ptrtv:NSValue = points[i+1] as? NSValue ?? NSValue()
                            let ptlbv:NSValue = points[i+2] as? NSValue ?? NSValue()
                            let ptrbv:NSValue = points[i+3] as! NSValue 
                            
                            let _:CGPoint = ptltv.cgPointValue
                            let ptrt:CGPoint = ptrtv.cgPointValue
                            let ptlb:CGPoint = ptlbv.cgPointValue
                            let _:CGPoint = ptrbv.cgPointValue

                            let rect = CGRect(x: ptlb.x-3*lineWidth, y: ptlb.y-3*lineWidth, width: ptrt.x-ptlb.x+6*lineWidth, height: ptrt.y-ptlb.y+6*lineWidth)
                            context.stroke(rect.insetBy(dx: lineWidth, dy: lineWidth))
                            
                            i += count
                        }
                        
                        context.restoreGState()
                    }
                } else if annotation is CPDFFreeTextAnnotation {
                    var rect = activeAnnotation!.bounds.insetBy(dx: -dragDotSize.width/2.0, dy: -dragDotSize.height/2.0)
                    context.setLineWidth(1.0)
                    let lengths: [CGFloat] = [6, 6]
                    context.setLineDash(phase: 0, lengths: lengths)
                    context.stroke(rect)
                    context.strokePath()
                    
                    let transform = page.transform()
                    if CPDFKitConfig.sharedInstance().enableAnnotationNoRotate() {
                        rect = rect.applying(transform)
                    }
                    
                    var leftCenterRect = CGRect(x: rect.minX - dragDotSize.width/2.0, y: rect.midY - dragDotSize.height/2.0, width: dragDotSize.width, height: dragDotSize.height)
                    var rightCenterRect = CGRect(x: rect.maxX - dragDotSize.width/2.0, y: rect.midY - dragDotSize.height/2.0, width: dragDotSize.width, height: dragDotSize.height)
                    if CPDFKitConfig.sharedInstance().enableAnnotationNoRotate() {
                        leftCenterRect = leftCenterRect.applying(transform.inverted())
                        rightCenterRect = rightCenterRect.applying(transform.inverted())
                    }
                    
                    let image = UIImage.init(named: "CPDFListViewImageNameAnnotationDragDot", in: Bundle(for: self.classForCoder), compatibleWith: nil)
                    let dragDotImage = image?.cgImage
                    
                    context.draw(dragDotImage!, in: leftCenterRect)
                    context.draw(dragDotImage!, in: rightCenterRect)
                    
                    self.startPointRect = leftCenterRect
                    self.endPointRect = rightCenterRect
                } else {
                    let rect = annotation.bounds.insetBy(dx: -dragDotSize.width/2.0, dy: -dragDotSize.height/2.0)
                    context.setLineWidth(1.0)
                    let lengths: [CGFloat] = [6, 6]
                    context.setLineDash(phase: 0, lengths: lengths)
                    context.stroke(rect)
                    context.strokePath()
                    
                    if annotation is CPDFSoundAnnotation || annotation is CPDFMovieAnnotation {
                        continue
                    }
                    
                    let topLeftRect = CGRect(x: rect.minX - dragDotSize.width/2.0, y: rect.maxY - dragDotSize.height/2.0, width: dragDotSize.width, height: dragDotSize.height)
                    let bottomLeftRect = CGRect(x: rect.minX - dragDotSize.width/2.0, y: rect.minY - dragDotSize.height/2.0, width: dragDotSize.width, height: dragDotSize.height)
                    let topRightRect = CGRect(x: rect.maxX - dragDotSize.width/2.0, y: rect.maxY - dragDotSize.height/2.0, width: dragDotSize.width, height: dragDotSize.height)
                    let bottomRightRect = CGRect(x: rect.maxX - dragDotSize.width/2.0, y: rect.minY - dragDotSize.height/2.0, width: dragDotSize.width, height: dragDotSize.height)
                    
                    let image = UIImage.init(named: "CPDFListViewImageNameAnnotationDragDot", in: Bundle(for: self.classForCoder), compatibleWith: nil)
                    let dragDotImage = image?.cgImage
                    
                    context.draw(dragDotImage!, in: topLeftRect)
                    context.draw(dragDotImage!, in: bottomLeftRect)
                    context.draw(dragDotImage!, in: topRightRect)
                    context.draw(dragDotImage!, in: bottomRightRect)
                    
                    self.topLeftRect = topLeftRect
                    self.bottomLeftRect = bottomLeftRect
                    self.topRightRect = topRightRect
                    self.bottomRightRect = bottomRightRect
                }
            }
        }
    }
    
    // MARK: - Annotation
    func moveAnnotation(_ annotation: CPDFAnnotation, fromPoint zfromPoint: CGPoint, toPoint ztoPoint: CGPoint, forType draggingType: CPDFAnnotationDraggingType) {
        var toPoint:CGPoint = ztoPoint
        var fromPoint:CGPoint = zfromPoint
        var bounds = annotation.bounds
        var offsetPoint = CGPoint.init(x: toPoint.x - fromPoint.x, y: toPoint.y - fromPoint.y)
        let scale = bounds.size.height / bounds.size.width
        if annotation is CPDFLineAnnotation {
            let line = annotation as! CPDFLineAnnotation
            var startPoint = line.startPoint
            var endPoint = line.endPoint
            
            switch draggingType {
            case .center:
                startPoint.x += offsetPoint.x
                startPoint.y += offsetPoint.y
                endPoint.x += offsetPoint.x
                endPoint.y += offsetPoint.y
                
            case .start:
                startPoint.x += offsetPoint.x
                startPoint.y += offsetPoint.y
                
            case .end:
                endPoint.x += offsetPoint.x
                endPoint.y += offsetPoint.y
                
            default:
                break
            }
            
            line.startPoint = startPoint
            line.endPoint = endPoint
            bounds = line.bounds
        } else if annotation is CPDFFreeTextAnnotation {
            let transform = annotation.page.transform()
            if CPDFKitConfig.sharedInstance().enableAnnotationNoRotate() {
                bounds = bounds.applying(transform)
                toPoint = toPoint.applying(transform)
                fromPoint = fromPoint.applying(transform)
                offsetPoint = CGPoint.init(x: toPoint.x - fromPoint.x, y: toPoint.y - fromPoint.y)
            }
            
            let freeText = annotation as! CPDFFreeTextAnnotation
            let attributes = [NSAttributedString.Key.font: freeText.font]
            switch draggingType {
            case .center:
                bounds.origin.x += offsetPoint.x
                bounds.origin.y += offsetPoint.y
                
            case .start:
                let x = bounds.maxX
                bounds.size.width -= offsetPoint.x
                bounds.size.width = max(bounds.size.width, 5.0)
                bounds.origin.x = x - bounds.size.width
                
                var rect = (freeText.contents as NSString).boundingRect(with: CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes as [NSAttributedString.Key: Any], context: nil)
                rect.size.height += 6
                bounds.origin.y = bounds.maxY - rect.size.height
                bounds.size.height = rect.size.height
                
            case .end:
                bounds.size.width += offsetPoint.x
                bounds.size.width = max(bounds.size.width, 5.0)
                var rect = (freeText.contents as NSString).boundingRect(with: CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes as [NSAttributedString.Key: Any], context: nil)
                rect.size.height += 6
                bounds.origin.y = bounds.maxY - rect.size.height
                bounds.size.height = rect.size.height
                
            default:
                break
            }
            
            if CPDFKitConfig.sharedInstance().enableAnnotationNoRotate() {
                bounds = bounds.applying(transform.inverted())
            }
        } else {
            switch draggingType {
            case .center:
                bounds.origin.x += offsetPoint.x
                bounds.origin.y += offsetPoint.y
                
            case .topLeft:
                let x = bounds.maxX
                bounds.size.width -= offsetPoint.x
                bounds.size.height += offsetPoint.y
                
                if annotation is CPDFStampAnnotation ||
                    annotation is CPDFSignatureAnnotation ||
                    annotation is CPDFInkAnnotation {
                    bounds.size.height = bounds.size.width * scale
                    bounds.size.width = max(bounds.size.width, 5.0)
                    bounds.size.height = max(bounds.size.height, 5.0 * scale)
                } else {
                    bounds.size.width = max(bounds.size.width, 5.0)
                    bounds.size.height = max(bounds.size.height, 5.0)
                }
                
                bounds.origin.x = x - bounds.size.width
                
            case .bottomLeft:
                let x = bounds.maxX
                let y = bounds.maxY
                bounds.size.width -= offsetPoint.x
                bounds.size.height -= offsetPoint.y
                
                if annotation is CPDFStampAnnotation ||
                    annotation is CPDFSignatureAnnotation ||
                    annotation is CPDFInkAnnotation {
                    bounds.size.height = bounds.size.width * scale
                    bounds.size.width = max(bounds.size.width, 5.0)
                    bounds.size.height = max(bounds.size.height, 5.0 * scale)
                } else {
                    bounds.size.width = max(bounds.size.width, 5.0)
                    bounds.size.height = max(bounds.size.height, 5.0)
                }
                
                bounds.origin.x = x - bounds.size.width;
                bounds.origin.y = y - bounds.size.height
                
            case .topRight:
                bounds.size.width += offsetPoint.x
                bounds.size.height += offsetPoint.y
                
                if annotation is CPDFStampAnnotation ||
                    annotation is CPDFSignatureAnnotation ||
                    annotation is CPDFInkAnnotation {
                    bounds.size.height = bounds.size.width * scale
                    bounds.size.width = max(bounds.size.width, 5.0)
                    bounds.size.height = max(bounds.size.height, 5.0 * scale)
                } else {
                    bounds.size.width = max(bounds.size.width, 5.0)
                    bounds.size.height = max(bounds.size.height, 5.0)
                }
                
            case .bottomRight:
                let y = bounds.maxY
                bounds.size.width += offsetPoint.x
                bounds.size.height -= offsetPoint.y
                
                if annotation is CPDFStampAnnotation ||
                    annotation is CPDFSignatureAnnotation ||
                    annotation is CPDFInkAnnotation {
                    bounds.size.height = bounds.size.width * scale
                    bounds.size.width = max(bounds.size.width, 5.0)
                    bounds.size.height = max(bounds.size.height, 5.0 * scale)
                } else {
                    bounds.size.width = max(bounds.size.width, 5.0)
                    bounds.size.height = max(bounds.size.height, 5.0)
                }
                
                bounds.origin.y = y - bounds.size.height
                
            default:
                break
            }
            
            if bounds.minX < 0 {
                bounds.origin.x = 0
            }
            if bounds.maxX > annotation.page.bounds.width {
                bounds.origin.x = annotation.page.bounds.width - bounds.width
            }
            if bounds.minY < 0 {
                bounds.origin.y = 0
            }
            if bounds.maxY > annotation.page.bounds.height {
                bounds.origin.y = annotation.page.bounds.height - bounds.height
            }
        }
        annotation.bounds = bounds
    }
    
    func addAnnotation(_ mode: CPDFViewAnnotationMode, at point: CGPoint, for page: CPDFPage) {
        var annotation: CPDFAnnotation?
        let annotStyle = CAnnotStyle(annotionMode: mode, annotations: [])
        switch mode {
        case .note:
            let width: CGFloat = 57.0 / 1.5
            annotation = CPDFTextAnnotation.init(document: self.document)
            annotation?.color = annotStyle.color
            annotation?.opacity = annotStyle.opacity
            annotation!.bounds = CGRect(x: point.x - width/2.0, y: point.y - width/2.0, width: width, height: width)
            
        case .highlight:
            if self.currentSelection == nil {
                return
            }
            
            var quadrilateralPoints = [NSValue]()
            annotation = CPDFMarkupAnnotation.init(document: self.document, markupType: .highlight)
            
            for selection in self.currentSelection.selectionsByLine {
                let bounds = selection.bounds
                quadrilateralPoints.append(NSValue(cgPoint: CGPoint(x: bounds.minX, y: bounds.maxY)))
                quadrilateralPoints.append(NSValue(cgPoint: CGPoint(x: bounds.maxX, y: bounds.maxY)))
                quadrilateralPoints.append(NSValue(cgPoint: CGPoint(x: bounds.minX, y: bounds.minY)))
                quadrilateralPoints.append(NSValue(cgPoint: CGPoint(x: bounds.maxX, y: bounds.minY)))
            }
            annotation?.color = annotStyle.color
            annotation?.opacity = annotStyle.opacity
            (annotation as! CPDFMarkupAnnotation).quadrilateralPoints = quadrilateralPoints
            (annotation as! CPDFMarkupAnnotation).setMarkupText(self.currentSelection.string())
            self.clearSelection()
            
        case .underline:
            if self.currentSelection == nil {
                return
            }
            
            var quadrilateralPoints = [NSValue]()
            annotation = CPDFMarkupAnnotation.init(document: self.document, markupType: .underline)
            
            for selection in self.currentSelection.selectionsByLine {
                let bounds = selection.bounds
                quadrilateralPoints.append(NSValue(cgPoint: CGPoint(x: bounds.minX, y: bounds.maxY)))
                quadrilateralPoints.append(NSValue(cgPoint: CGPoint(x: bounds.maxX, y: bounds.maxY)))
                quadrilateralPoints.append(NSValue(cgPoint: CGPoint(x: bounds.minX, y: bounds.minY)))
                quadrilateralPoints.append(NSValue(cgPoint: CGPoint(x: bounds.maxX, y: bounds.minY)))
            }
            annotation?.color = annotStyle.color
            annotation?.opacity = annotStyle.opacity
            
            (annotation as! CPDFMarkupAnnotation).quadrilateralPoints = quadrilateralPoints
            (annotation as! CPDFMarkupAnnotation).setMarkupText(self.currentSelection.string())
            self.clearSelection()
            
        case .strikeout:
            if self.currentSelection == nil {
                return
            }
            
            var quadrilateralPoints = [NSValue]()
            annotation = CPDFMarkupAnnotation.init(document: self.document, markupType: .strikeOut)
            
            for selection in self.currentSelection.selectionsByLine {
                let bounds = selection.bounds
                quadrilateralPoints.append(NSValue(cgPoint: CGPoint(x: bounds.minX, y: bounds.maxY)))
                quadrilateralPoints.append(NSValue(cgPoint: CGPoint(x: bounds.maxX, y: bounds.maxY)))
                quadrilateralPoints.append(NSValue(cgPoint: CGPoint(x: bounds.minX, y: bounds.minY)))
                quadrilateralPoints.append(NSValue(cgPoint: CGPoint(x: bounds.maxX, y: bounds.minY)))
            }
            annotation?.color = annotStyle.color
            annotation?.opacity = annotStyle.opacity
            (annotation as! CPDFMarkupAnnotation).quadrilateralPoints = quadrilateralPoints
            (annotation as! CPDFMarkupAnnotation).setMarkupText(self.currentSelection.string())
            self.clearSelection()
            
        case .squiggly:
            if self.currentSelection == nil {
                return
            }
            
            var quadrilateralPoints = [NSValue]()
            annotation = CPDFMarkupAnnotation.init(document: self.document, markupType: .squiggly)
            
            for selection in self.currentSelection.selectionsByLine {
                let bounds = selection.bounds
                quadrilateralPoints.append(NSValue(cgPoint: CGPoint(x: bounds.minX, y: bounds.maxY)))
                quadrilateralPoints.append(NSValue(cgPoint: CGPoint(x: bounds.maxX, y: bounds.maxY)))
                quadrilateralPoints.append(NSValue(cgPoint: CGPoint(x: bounds.minX, y: bounds.minY)))
                quadrilateralPoints.append(NSValue(cgPoint: CGPoint(x: bounds.maxX, y: bounds.minY)))
            }
            annotation?.color = annotStyle.color
            annotation?.opacity = annotStyle.opacity
            (annotation as! CPDFMarkupAnnotation).quadrilateralPoints = quadrilateralPoints
            (annotation as! CPDFMarkupAnnotation).setMarkupText(self.currentSelection.string())
            self.clearSelection()
            
        case .circle:
            annotation = CPDFCircleAnnotation.init(document: self.document)
            if let circleAnnotation = annotation as? CPDFCircleAnnotation {
                circleAnnotation.bounds = CGRect(x: point.x - 50, y: point.y - 50, width: 100, height: 100)
                circleAnnotation.border = CPDFBorder(style: annotStyle.style, lineWidth: annotStyle.lineWidth, dashPattern: annotStyle.dashPattern)
                circleAnnotation.color = annotStyle.color
                circleAnnotation.opacity = annotStyle.opacity
                circleAnnotation.interiorColor = annotStyle.interiorColor
                circleAnnotation.interiorOpacity = annotStyle.interiorOpacity
            }
        case .square:
            annotation = CPDFSquareAnnotation.init(document: self.document)
            if let squareAnnotation = annotation as? CPDFSquareAnnotation {
                squareAnnotation.bounds = CGRect(x: point.x - 50, y: point.y - 50, width: 100, height: 100)
                squareAnnotation.border = CPDFBorder(style: annotStyle.style, lineWidth: annotStyle.lineWidth, dashPattern: annotStyle.dashPattern)
                squareAnnotation.color = annotStyle.color
                squareAnnotation.opacity = annotStyle.opacity
                squareAnnotation.interiorColor = annotStyle.interiorColor
                squareAnnotation.interiorOpacity = annotStyle.interiorOpacity
            }
            
        case .arrow:
            annotation = CPDFLineAnnotation.init(document: self.document)
            if let lineAnnotation = annotation as? CPDFLineAnnotation {
                lineAnnotation.startPoint = CGPoint(x: point.x - 50, y: point.y)
                lineAnnotation.endPoint = CGPoint(x: point.x + 50, y: point.y)
                lineAnnotation.endLineStyle = annotStyle.endLineStyle
                lineAnnotation.startLineStyle = annotStyle.startLineStyle
                lineAnnotation.color = annotStyle.color
                lineAnnotation.opacity = annotStyle.opacity
                lineAnnotation.border = CPDFBorder(style: annotStyle.style, lineWidth: annotStyle.lineWidth, dashPattern: annotStyle.dashPattern)
            }
            
        case .line:
            annotation = CPDFLineAnnotation.init(document: self.document)
            if let lineAnnotation = annotation as? CPDFLineAnnotation {
                lineAnnotation.startPoint = CGPoint(x: point.x - 50, y: point.y)
                lineAnnotation.endPoint = CGPoint(x: point.x + 50, y: point.y)
                lineAnnotation.endLineStyle = annotStyle.endLineStyle
                lineAnnotation.startLineStyle = annotStyle.startLineStyle
                lineAnnotation.color = annotStyle.color
                lineAnnotation.opacity = annotStyle.opacity
                lineAnnotation.border = CPDFBorder(style: annotStyle.style, lineWidth: annotStyle.lineWidth, dashPattern: annotStyle.dashPattern)
                
            }
        default:
            break
        }
        
        if annotation == nil {
            return
        }
        
        annotation?.setModificationDate(Date.init())
        annotation?.setUserName(self.annotationUserName)
        page.addAnnotation(annotation)
        
        if annotation is CPDFTextAnnotation {
            self.updateActiveAnnotations([annotation!])
            setNeedsDisplayFor(page)
            self.performDelegate?.PDFListViewEditNote?(self, forAnnotation: annotation!)
            self.showMenuForAnnotation(annotation)
        } else if annotation is CPDFMarkupAnnotation {
            self.updateActiveAnnotations([annotation!])
            setNeedsDisplayFor(page)
            self.showMenuForAnnotation(annotation)
        } else {
            self.updateActiveAnnotations([annotation!])
            setNeedsDisplayFor(page)
            self.updateScrollEnabled()
            
            self.showMenuForAnnotation(annotation)
        }
    }
    
    func addAnnotationAtPoint(_ point: CGPoint, forPage page: CPDFPage) {
        let annotation = self.addAnnotation
        if annotation == nil {
            return
        }
        
        annotation?.bounds = CGRect(x: point.x - annotation!.bounds.size.width/2.0, y: point.y - annotation!.bounds.size.height/2.0, width: annotation!.bounds.size.width, height: annotation!.bounds.size.height)
        annotation?.setModificationDate(NSDate() as Date)
        annotation?.setUserName(self.annotationUserName)
        page.addAnnotation(annotation)
        
        self.updateActiveAnnotations([annotation!])
        setNeedsDisplayFor(page)
        self.updateScrollEnabled()
        
        self.showMenuForAnnotation(annotation)
    }
    
    func addAnnotationMedia(at point: CGPoint, for page: CPDFPage) {
        if self.mediaSelectionPage != nil {
            let selectionPage = mediaSelectionPage
            self.mediaSelectionPage = nil
            setNeedsDisplayFor(selectionPage)
        }
        
        self.mediaSelectionPage = page
        self.mediaSelectionRect = CGRect(x: point.x-20, y: point.y-20, width: 40, height: 40)
        setNeedsDisplayFor(page)
        
        showMenuForMedia(at: point, for: page)
    }
    
    func addAnnotationLinkAtPoint(_ point: CGPoint, forPage page: CPDFPage) {
        let annotation = CPDFLinkAnnotation.init(document: self.document)
        annotation?.bounds = self.addAnnotationRect
        annotation?.setModificationDate(NSDate() as Date)
        annotation?.setUserName(self.annotationUserName)
        page.addAnnotation(annotation)
        
        self.addAnnotationPoint = CGPoint.zero
        self.addAnnotationRect = CGRect.zero
        
        if annotation != nil {
            self.updateActiveAnnotations([annotation!])
            setNeedsDisplayFor(page)
            
            self.performDelegate?.PDFListViewEditProperties?(self, forAnnotation: annotation!)
        }
    }
    
    func addAnnotationFreeTextAtPoint(_ zpoint: CGPoint, forPage page: CPDFPage) {
        let annotStyle = CAnnotStyle(annotionMode: .freeText, annotations: [])

        let annotation = CPDFFreeTextAnnotation.init(document: self.document)
        if (annotation == nil) {
            return
        }
        var point:CGPoint = zpoint
        
        if CPDFKitConfig.sharedInstance().enableAnnotationNoRotate() {
            var width: CGFloat?
            let transform = page.transform()
            point = point.applying(transform)
            if page.rotation == 90 ||
                page.rotation == 270 {
                width = page.bounds.maxY - point.x - 20
            } else {
                width = page.bounds.maxX - point.x - 20
            }
            
            var bounds = CGRect(x: point.x, y: point.y, width: width!, height: annotation!.font.pointSize)
            bounds = bounds.applying(transform.inverted())
            annotation?.bounds = bounds
        } else {
            let width = page.bounds.maxX - point.x - 20
            annotation?.bounds = CGRect(x: point.x, y: point.y, width: width, height: annotation!.font.pointSize)
        }
        annotation?.font = UIFont(name: annotStyle.fontName, size: annotStyle.fontSize)
        annotation?.fontColor = annotStyle.fontColor
        annotation?.opacity = annotStyle.opacity
        annotation?.setModificationDate(NSDate() as Date)
        annotation?.setUserName(self.annotationUserName)
        page.addAnnotation(annotation)
        self.editAnnotationFreeText(annotation!)
    }
    
}

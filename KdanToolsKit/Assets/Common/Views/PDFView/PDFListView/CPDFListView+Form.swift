//
//  CPDFListView+Form.swift
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
    
    // MARK: - Touch
    func formTouchBegan(at point: CGPoint, for page: CPDFPage) {
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
    
    func formTouchMoved(at point: CGPoint, for page: CPDFPage) {
        if self.textSelectionMode {
        } else if self.draggingType != .none {
            if !self.undoMove {
                self.undoPDFManager?.beginUndoGrouping()
                self.undoMove = true
            }
            if self.activeAnnotation != nil && self.activeAnnotation is CPDFWidgetAnnotation {
                self.moveFormAnnotation(self.activeAnnotation as! CPDFWidgetAnnotation, fromPoint: self.draggingPoint, toPoint: point, forType: self.draggingType)
                self.setNeedsDisplayFor(page)
                self.draggingPoint = point
            }
        } else if self.isWidgetForm(with: self.annotationMode) {
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
    
    func formTouchEnded(at point: CGPoint, for page: CPDFPage) {
        if self.textSelectionMode {
            if self.currentSelection != nil {
            } else {
                var annotation = page.annotation(at: point)
                
                if annotation != nil && annotation?.isHidden() == true {
                    annotation = nil
                }
                
                if (annotation != nil  && annotation is CPDFWidgetAnnotation) {
                    if !(self.activeAnnotations?.contains(annotation!) ?? false) {
                        self.updateActiveAnnotations([annotation!])
                        setNeedsDisplayFor(page)
                        self.updateFormScrollEnabled()
                    }
                } else {
                    if self.activeAnnotation != nil {
                        self.updateActiveAnnotations([])
                        setNeedsDisplayFor(page)
                        self.updateFormScrollEnabled()
                    } else {
                        if self.annotationMode == .CPDFViewAnnotationModenone {
                            self.performDelegate?.PDFListViewPerformTouchEnded?(self)
                        }
                    }
                }
            }
        } else if self.draggingType == .none {
            if (self.activeAnnotation != nil && !(self.isWidgetForm(with: self.annotationMode) && !self.addAnnotationRect.isEmpty)) {
                let previousPage = self.activeAnnotation?.page
                self.updateActiveAnnotations([])
                setNeedsDisplayFor(previousPage)
                self.updateFormScrollEnabled()
            } else {
                if (self.annotationMode == .CPDFViewAnnotationModenone) {
                    var annotation = page.annotation(at: point)
                    if annotation != nil && annotation?.isHidden() == true {
                        annotation = nil
                    }
                    
                    if annotation != nil && annotation is CPDFWidgetAnnotation {
                        if !(self.activeAnnotations?.contains(annotation!) ?? false) {
                            self.updateActiveAnnotations([annotation!])
                            setNeedsDisplayFor(page)
                            self.updateFormScrollEnabled()
                        }
                        
                        self.showMenuForWidgetAnnotation(annotation)
                    } else {
                        self.performDelegate?.PDFListViewPerformTouchEnded?(self)
                    }
                } else if (self.isWidgetForm(with: self.annotationMode)) {
                    if self.addAnnotationRect.isEmpty {
                        var annotation = page.annotation(at: point)
                        if annotation != nil && annotation?.isHidden() == true {
                            annotation = nil
                        }
                        
                        if annotation != nil && annotation is CPDFWidgetAnnotation {
                            self.updateActiveAnnotations([annotation!])
                            setNeedsDisplayFor(page)
                            self.updateFormScrollEnabled()
                        }
                        self.showMenuForWidgetAnnotation(annotation)
                    } else {
                        self.addWidgetAnnotation(at: point, forPage: page)
                    }
                }
            }
        } else {
            if (self.draggingType != .center && self.activeAnnotation != nil) {
                if self.activeAnnotation is CPDFWidgetAnnotation  {
                    self.activeAnnotation?.updateAppearanceStream()
                    setNeedsDisplayFor(page)
                }
            }
            if self.undoMove {
                self.undoPDFManager?.endUndoGrouping()
                self.undoMove = false
            }
            
            self.draggingType = .none
            if(activeAnnotation != nil && activeAnnotation is CPDFWidgetAnnotation) {
                self.showMenuForWidgetAnnotation(activeAnnotation)
            }
        }
    }
    
    func formTouchCancelled(at point: CGPoint, for page: CPDFPage) {
        self.draggingType = .none
        
        if self.undoMove {
            self.undoPDFManager?.endUndoGrouping()
            self.undoMove = false
        }
    }
    
    // MARK: - Draw
    func formDrawPage(_ page: CPDFPage, to context: CGContext) {
        if(self.isWidgetForm(with: self.annotationMode)) {
            context.setLineWidth(1.0)
            context.setStrokeColor(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.8).cgColor)
            context.setFillColor(UIColor(red: 100.0/255.0, green: 149.0/255.0, blue: 237.0/255.0, alpha: 0.4).cgColor)
            context.addRect(self.addAnnotationRect)
            context.drawPath(using: .fillStroke)
        }
        
        if activeAnnotation?.page != page {
            return
        }
        let dragDotSize = CGSize(width: 30, height: 30)
        context.setStrokeColor(UIColor(red: 72.0/255.0, green: 183.0/255.0, blue: 247.0/255.0, alpha: 1.0).cgColor)
        
        if (self.activeAnnotations != nil) {
            for annotation in self.activeAnnotations! {
                let rect = annotation.bounds.insetBy(dx: -dragDotSize.width/2.0, dy: -dragDotSize.height/2.0)
                context.setLineWidth(1.0)
                let lengths: [CGFloat] = [6, 6]
                context.setLineDash(phase: 0, lengths: lengths)
                context.stroke(rect)
                context.strokePath()
                
                if !(annotation is CPDFWidgetAnnotation)  {
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
    
    func formMenuItems(at point: CGPoint, for page: CPDFPage) -> [UIMenuItem] {
        
        var menuItems = [UIMenuItem]()
        
        if let menus = super.menuItems(at: point, for: page), !menus.isEmpty {
            menuItems = menus
        }
        return menuItems
    }
    
    func moveFormAnnotation(_ annotation: CPDFWidgetAnnotation, fromPoint: CGPoint, toPoint: CGPoint, forType draggingType: CPDFAnnotationDraggingType) {
        var bounds = annotation.bounds
        let offsetPoint = CGPoint.init(x: toPoint.x - fromPoint.x, y: toPoint.y - fromPoint.y)
        
        switch draggingType {
        case .center:
            bounds.origin.x += offsetPoint.x
            bounds.origin.y += offsetPoint.y
        case .topLeft:
            let x = bounds.maxX
            bounds.size.width -= offsetPoint.x
            bounds.size.height += offsetPoint.y
            
            bounds.size.width = max(bounds.size.width, 5.0)
            bounds.size.height = max(bounds.size.height, 5.0)
            
            bounds.origin.x = x - bounds.size.width
        case .bottomLeft:
            let x = bounds.maxX
            let y = bounds.maxY
            bounds.size.width -= offsetPoint.x
            bounds.size.height -= offsetPoint.y
            
            bounds.size.width = max(bounds.size.width, 5.0)
            bounds.size.height = max(bounds.size.height, 5.0)
            
            bounds.origin.x = x - bounds.size.width;
            bounds.origin.y = y - bounds.size.height
        case .topRight:
            bounds.size.width += offsetPoint.x
            bounds.size.height += offsetPoint.y
            
            bounds.size.width = max(bounds.size.width, 5.0)
            bounds.size.height = max(bounds.size.height, 5.0)
        case .bottomRight:
            let y = bounds.maxY
            bounds.size.width += offsetPoint.x
            bounds.size.height -= offsetPoint.y
            
            bounds.size.width = max(bounds.size.width, 5.0)
            bounds.size.height = max(bounds.size.height, 5.0)
            
            bounds.origin.y = y - bounds.size.height
            
        default:
            break
        }
        
        if bounds.minX < 0 {
            bounds.origin.x = 0
        }
        if bounds.maxX > (annotation.page?.bounds.width ?? 0) {
            bounds.origin.x = (annotation.page?.bounds.width ?? 0) - bounds.width
        }
        if bounds.minY < 0 {
            bounds.origin.y = 0
        }
        if bounds.maxY > (annotation.page?.bounds.height ?? 0) {
            bounds.origin.y = (annotation.page?.bounds.height ?? 0) - bounds.height
        }
        annotation.bounds = bounds
    }
    
    func addWidgetAnnotation(at point: CGPoint, forPage page: CPDFPage) {
        var widgetAnnotation:CPDFWidgetAnnotation?
        let formsStyle = CFormStyle(formMode: self.annotationMode)
        var isPushButton:Bool = false
        
        let cfont = CPDFFont.init(familyName: formsStyle.fontFamilyName, fontStyle: formsStyle.fontStyleName)
        
        switch self.annotationMode {
        case .formModeText:
            widgetAnnotation = CPDFTextWidgetAnnotation.init(document: self.document)
            widgetAnnotation?.setFieldName("Text Field_" + tagString())
            widgetAnnotation?.fontColor = formsStyle.fontColor
            widgetAnnotation?.borderWidth = formsStyle.lineWidth
            widgetAnnotation?.borderColor = formsStyle.color
            widgetAnnotation?.backgroundColor = formsStyle.interiorColor
            widgetAnnotation?.cFont = cfont
            widgetAnnotation?.fontSize = formsStyle.fontSize
            (widgetAnnotation as? CPDFTextWidgetAnnotation)?.alignment = formsStyle.textAlignment
            (widgetAnnotation as? CPDFTextWidgetAnnotation)?.isMultiline = formsStyle.isMultiline
        case .formModeCheckBox:
            widgetAnnotation = CPDFButtonWidgetAnnotation.init(document: self.document, controlType:.checkBoxControl)
            widgetAnnotation?.setFieldName("Check Button_" + tagString())
            widgetAnnotation?.borderWidth = formsStyle.lineWidth
            widgetAnnotation?.borderColor = formsStyle.color
            widgetAnnotation?.backgroundColor = formsStyle.interiorColor
            widgetAnnotation?.fontColor = formsStyle.fontColor
            (widgetAnnotation as? CPDFButtonWidgetAnnotation)?.setState(formsStyle.isChecked ? 1 : 0)
            (widgetAnnotation as? CPDFButtonWidgetAnnotation)?.setWidgetCheck(formsStyle.checkedStyle)
        case .formModeRadioButton:
            widgetAnnotation = CPDFButtonWidgetAnnotation.init(document: self.document, controlType:.radioButtonControl)
            widgetAnnotation?.setFieldName("Radio Button_" + tagString())
            widgetAnnotation?.borderWidth = formsStyle.lineWidth
            widgetAnnotation?.borderColor = formsStyle.color
            widgetAnnotation?.backgroundColor = formsStyle.interiorColor
            widgetAnnotation?.fontColor = formsStyle.fontColor
            (widgetAnnotation as? CPDFButtonWidgetAnnotation)?.setState(formsStyle.isChecked ? 1 : 0)
            (widgetAnnotation as? CPDFButtonWidgetAnnotation)?.setWidgetCheck(formsStyle.checkedStyle)
        case .formModeCombox:
            widgetAnnotation = CPDFChoiceWidgetAnnotation.init(document: self.document, listChoice: false)
            widgetAnnotation?.setFieldName("Combox Choice_" + tagString())
            widgetAnnotation?.fontColor = formsStyle.fontColor
            widgetAnnotation?.borderWidth = formsStyle.lineWidth
            widgetAnnotation?.borderColor = formsStyle.color
            widgetAnnotation?.backgroundColor = formsStyle.interiorColor
            widgetAnnotation?.cFont = cfont
            widgetAnnotation?.fontSize = formsStyle.fontSize
        case .formModeList:
            widgetAnnotation = CPDFChoiceWidgetAnnotation.init(document: self.document, listChoice: true)
            widgetAnnotation?.setFieldName("List Choice_" + tagString())
            widgetAnnotation?.fontColor = formsStyle.fontColor
            widgetAnnotation?.borderWidth = formsStyle.lineWidth
            widgetAnnotation?.borderColor = formsStyle.color
            widgetAnnotation?.backgroundColor = formsStyle.interiorColor
            widgetAnnotation?.cFont = cfont
            widgetAnnotation?.fontSize = formsStyle.fontSize
        case .formModeButton:
            isPushButton = true
            widgetAnnotation = CPDFButtonWidgetAnnotation.init(document: self.document, controlType:.pushButtonControl)
            let buttonWidgetAnnotation:CPDFButtonWidgetAnnotation = widgetAnnotation as! CPDFButtonWidgetAnnotation
            buttonWidgetAnnotation.setCaption(formsStyle.title as String?)
            widgetAnnotation?.fontColor = formsStyle.fontColor
            widgetAnnotation?.borderWidth = formsStyle.lineWidth
            widgetAnnotation?.borderColor = formsStyle.color
            widgetAnnotation?.backgroundColor = formsStyle.interiorColor
            widgetAnnotation?.cFont = cfont
            widgetAnnotation?.fontSize = formsStyle.fontSize
            widgetAnnotation?.setFieldName("Push Button_" + tagString())
        case .formModeSign:
            widgetAnnotation = CPDFSignatureWidgetAnnotation.init(document: self.document)
            widgetAnnotation?.setFieldName("Signature_" + tagString())
            widgetAnnotation?.setLineWidth(formsStyle.lineWidth)
            widgetAnnotation?.borderColor = formsStyle.color
            widgetAnnotation?.backgroundColor = formsStyle.interiorColor
            widgetAnnotation?.backgroundOpacity = 1.0
            widgetAnnotation?.setBorderStyle(formsStyle.style)
          
        default:
            break
        }
        
        widgetAnnotation?.bounds = self.addAnnotationRect
        widgetAnnotation?.setModificationDate(NSDate() as Date)
        page.addAnnotation(widgetAnnotation)
        
        self.addAnnotationRect = CGRect.zero
        self.addAnnotationPoint = CGPoint.zero
        
        if(widgetAnnotation != nil) {
            self.updateActiveAnnotations([widgetAnnotation!])
            setNeedsDisplayFor(page)
        }
        self.updateFormScrollEnabled()
        
        if widgetAnnotation != nil && (widgetAnnotation is CPDFChoiceWidgetAnnotation || (widgetAnnotation is CPDFButtonWidgetAnnotation && isPushButton)) {
            self.performDelegate?.PDFListViewEditNote?(self, forAnnotation: widgetAnnotation!)
        } else {
            self.showMenuForWidgetAnnotation(widgetAnnotation)

        }
    }
    
     func updateFormScrollEnabled() {
        if self.activeAnnotation != nil {
            self.scrollEnabled = false
        } else {
            if (self.isWidgetForm(with: self.annotationMode)) {
                self.scrollEnabled = false
            } else {
                self.scrollEnabled = true
            }
        }
    }

    func isWidgetForm(with annotationMode: CPDFViewAnnotationMode) -> Bool {
        if annotationMode == .formModeText ||
            annotationMode == .formModeCheckBox ||
            annotationMode == .formModeRadioButton ||
            annotationMode == .formModeCombox ||
            annotationMode == .formModeList ||
            annotationMode == .formModeButton ||
            annotationMode == .formModeSign {
            return true
        }
        
        return false
    }
    
    func tagString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss SS"
        let dateString = formatter.string(from: Date())
        return dateString
    }
    
    func showMenuForWidgetAnnotation(_ annotation: CPDFAnnotation?) {
        if(annotation == nil || annotation?.page == nil) {
            UIMenuController.shared.menuItems = nil
            if #available(iOS 13.0, *) {
                UIMenuController.shared.hideMenu(from: self)
            } else {
                UIMenuController.shared.setMenuVisible(false, animated: true)
            }
            return
        }
        
        let propertiesItem = UIMenuItem(title: NSLocalizedString("Properties", comment: ""), action: #selector(menuItemClick_FormProperties(_:)))

        let optionItem = UIMenuItem(title: NSLocalizedString("Option", comment: ""), action: #selector(menuItemClick_Option(_:)))
        
        let deleteItem = UIMenuItem(title: NSLocalizedString("Delete", comment: ""), action: #selector(menuItemClick_FormDelete(_:)))
        
        var menuItems:[UIMenuItem] = []
        if (annotation is CPDFTextWidgetAnnotation) {
            menuItems.append(propertiesItem)
            menuItems.append(deleteItem)
        } else if (annotation is CPDFButtonWidgetAnnotation) {
            let mAnnotation:CPDFButtonWidgetAnnotation = annotation as! CPDFButtonWidgetAnnotation
            if mAnnotation.controlType() == .pushButtonControl {
                menuItems.append(optionItem)
            }
            
            menuItems.append(propertiesItem)
            menuItems.append(deleteItem)
        } else if (annotation is CPDFChoiceWidgetAnnotation) {
            menuItems.append(optionItem)
            menuItems.append(propertiesItem)
            menuItems.append(deleteItem)
        } else if annotation is CPDFSignatureWidgetAnnotation {
            menuItems.append(deleteItem)
        }
        
        if(menuItems.count <= 0) {
            return
        }
        
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
    
    // MARK: - Action
    @objc func menuItemClick_Option(_ sender: UIMenuController) {
        if (self.activeAnnotation != nil) {
            self.performDelegate?.PDFListViewEditNote?(self, forAnnotation: self.activeAnnotation!)
        }
    }
        
    @objc func menuItemClick_FormDelete(_ sender: UIMenuController) {
        if (self.activeAnnotation != nil && self.activeAnnotation?.page != nil) {
            self.activeAnnotation?.page?.removeAnnotation(self.activeAnnotation)
            setNeedsDisplayFor(self.activeAnnotation?.page)
            self.updateActiveAnnotations([])
        }
    }

    @objc func menuItemClick_FormProperties(_ sender: UIMenuController) {
        if (self.activeAnnotation != nil) {
            self.performDelegate?.PDFListViewEditProperties?(self, forAnnotation: self.activeAnnotation!)
        }
        
    }
    
}

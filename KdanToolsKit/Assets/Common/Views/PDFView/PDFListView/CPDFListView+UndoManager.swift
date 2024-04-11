//
//  CPDFListView+UndoManager.swift
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
    func registerAsObserver() {
        self.undoPDFManager = UndoManager()

        NotificationCenter.default.addObserver(self, selector: #selector(PDFPageDidLoadAnnotationNotification(_:)), name: NSNotification.Name.CPDFPageDidLoadAnnotation, object: self.document)
        NotificationCenter.default.addObserver(self, selector: #selector(PDFPageDidAddAnnotationNotification(_:)), name: NSNotification.Name.CPDFPageDidAddAnnotation, object: self.document)
        NotificationCenter.default.addObserver(self, selector: #selector(PDFPageDidRemoveAnnotationNotification(_:)), name: NSNotification.Name.CPDFPageDidRemoveAnnotation, object: self.document)

        NotificationCenter.default.addObserver(self, selector: #selector(redoChangeNotification(_:)), name: NSNotification.Name.NSUndoManagerDidUndoChange, object: undoPDFManager)
        NotificationCenter.default.addObserver(self, selector: #selector(redoChangeNotification(_:)), name: NSNotification.Name.NSUndoManagerDidRedoChange, object: undoPDFManager)
        NotificationCenter.default.addObserver(self, selector: #selector(redoChangeNotification(_:)), name: NSNotification.Name.NSUndoManagerWillCloseUndoGroup, object: undoPDFManager)

    }
    
    func startObservingNotes(newNotes: [CPDFAnnotation]) {
        if self.notes == nil {
            self.notes = []
        }
        for note in newNotes {
            if self.notes?.contains(note) == false {
                self.notes?.append(note)
            }
            let keys: Set<String> = note.keysForValuesToObserveForUndo()
            for key in keys {
                note.addObserver(self, forKeyPath: key, options: [.new, .old], context: &CPDFAnnotationPropertiesObservationContext)
            }
        }
    }

     @objc func removeAnnotation(annotation: CPDFAnnotation) {
        let page = annotation.page

        if self.activeAnnotation == annotation {
            updateActiveAnnotations([])
        }
        page?.removeAnnotation(annotation)

        setNeedsDisplayFor(page)
    }

    func undoRemoveAnnotation(annotation: CPDFAnnotation) {
        if(undoPDFManager != nil) {
            undoPDFManager!.registerUndo(withTarget: self) { target in
                target.undoAddAnnotation(annotation, forPage: annotation.page)
            }
        }
    }
    
    @objc func undoAddAnnotation(annotation: CPDFAnnotation) {
        if(undoPDFManager != nil) {
            undoPDFManager!.registerUndo(withTarget: self, selector: #selector(removeAnnotation(annotation:)), object: annotation)
        }
    }
    
    @objc func undoAddAnnotation(_ annotation: CPDFAnnotation?, forPage page: CPDFPage?) {
        if(annotation == nil || page == nil) {
            return
        }
        
        var annotationUserName: String
        if annotation is CPDFWidgetAnnotation {
            let widgetAnnotation:CPDFWidgetAnnotation = annotation as? CPDFWidgetAnnotation ?? CPDFWidgetAnnotation()
            annotationUserName = widgetAnnotation.fieldName()
        } else {
            annotationUserName = CPDFKitConfig.sharedInstance().annotationAuthor() ?? UIDevice.current.name
        }
        
        annotation?.setModificationDate(NSDate() as Date)
        annotation?.setUserName(annotationUserName)
        page?.addAnnotation(annotation)
        
        setNeedsDisplayFor(page)
        if activeAnnotation != nil {
            scrollEnabled = false
        } else {
            if annotationMode == .link {
                scrollEnabled = false
            } else {
                scrollEnabled = true
            }
        }
    }
    
    @objc func setNoteProperties(_ propertiesPerNote: NSMapTable<AnyObject, AnyObject>?) {
        guard let propertiesPerNote = propertiesPerNote else {
            return
        }
        
        for note in propertiesPerNote.keyEnumerator() {
            if let note = note as? CPDFAnnotation, let noteProperties = propertiesPerNote.object(forKey: note) as? [String: Any] {
                note.setValuesForKeys(noteProperties)
                
                if note is CPDFWidgetAnnotation {
                    note.updateAppearanceStream()
                }
                setNeedsDisplayFor(note.page)
            }
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &CPDFAnnotationPropertiesObservationContext {
            if let note = object as? CPDFAnnotation {
                let newValue = change?[NSKeyValueChangeKey.newKey] ?? NSNull()
                let oldValue = change?[NSKeyValueChangeKey.oldKey] ?? NSNull()
                if (newValue as AnyObject).isEqual(oldValue) == false {
                    let undoManager = undoPDFManager
                    let isUndoOrRedo = undoManager?.isUndoing == true || undoManager?.isRedoing == true
                    if keyPath == CPDFAnnotationStateKey ||
                       keyPath == CPDFAnnotationSelectItemAtIndexKey {
                        if isUndoOrRedo == false {
                            undoManager?.setActionName(NSLocalizedString("Edit Note", comment: "Undo action name"))
                        }
                    } else {
                        undoGroupOldPropertiesPerNote = NSMapTable<AnyObject, AnyObject>(keyOptions: .objectPointerPersonality, valueOptions: [.strongMemory, .objectPointerPersonality])
                        undoManager?.registerUndo(withTarget: self, selector: #selector(setNoteProperties(_:)), object: undoGroupOldPropertiesPerNote)
                        if isUndoOrRedo == false {
                            undoManager?.setActionName(NSLocalizedString("Edit Note", comment: "Undo action name"))
                        }
                        
                        var oldNoteProperties = undoGroupOldPropertiesPerNote?.object(forKey: note) as? NSMutableDictionary
                        if oldNoteProperties == nil {
                            oldNoteProperties = NSMutableDictionary()
                            undoGroupOldPropertiesPerNote?.setObject(oldNoteProperties, forKey: note)
                            if isUndoOrRedo == false &&
                                keyPath != CPDFAnnotationModificationDateKey {
                                note.setModificationDate(NSDate() as Date)
                            }
                        }
                        
                        if oldNoteProperties?[keyPath ?? ""] == nil {
                            oldNoteProperties?[keyPath ?? ""] = oldValue
                        }
                    }
                }
            }
            
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    // MARK: - NSNotification
    @objc func PDFPageDidLoadAnnotationNotification(_ notification: Notification) {
        if let annotation = notification.object as? CPDFAnnotation,
           annotation.page != nil,
           !(annotation is CPDFLinkAnnotation) {
            startObservingNotes(newNotes: [annotation])
        }
    }

    @objc func PDFPageDidAddAnnotationNotification(_ notification: Notification) {
        if let annotation = notification.object as? CPDFAnnotation,
           annotation.page != nil ,
           (annotation.page.document == self.document) == true,
           !(annotation is CPDFLinkAnnotation) {
            startObservingNotes(newNotes: [annotation])
            undoAddAnnotation(annotation: annotation)
        }
    }

    @objc func PDFPageDidRemoveAnnotationNotification(_ notification: Notification) {
        if let annotation = notification.object as? CPDFAnnotation,
           annotation.page != nil,
           (annotation.page.document == self.document) == true,
           !(annotation is CPDFLinkAnnotation) {
            undoRemoveAnnotation(annotation: annotation)
            stopObservingNotes(oldNotes: [annotation])
            
            if ((notes?.contains(annotation)) == true) {
                if let index = notes!.firstIndex(of: annotation) {
                    notes?.remove(at: index)
                }
                
            }
        }
    }
    
    @objc func redoChangeNotification(_ notification: Notification) {
        if canUndo() || canRedo() {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: CPDFListViewAnnotationsOperationChangeNotification, object: self)
                
                self.performDelegate?.PDFListViewAnnotationsOperationChange?(self)
            }
        }
    }

    
}

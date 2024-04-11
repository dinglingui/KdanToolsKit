//
//  CPDFConfiguration.swift
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

public class CPDFConfiguration: NSObject {
    
    public override init() {
        super.init()
        
        let thumbnail = CNavBarButtonItem(viewLeftBarButtonItem: .thumbnail)
        let back = CNavBarButtonItem(viewLeftBarButtonItem: .back)
        let search = CNavBarButtonItem(viewRightBarButtonItem: .search)
        let bota = CNavBarButtonItem(viewRightBarButtonItem: .bota)
        let more = CNavBarButtonItem(viewRightBarButtonItem: .more)
        
        self.showleftItems = [back, thumbnail]
        self.showRightItems = [search, bota, more]        
    }
    
    public var showleftItems: [CNavBarButtonItem] = []
    
    public var showRightItems: [CNavBarButtonItem] = []
    
    public var enterToolModel: CPDFToolFunctionTypeState = .viewer
    
    public var availableViewModes: [CPDFToolFunctionTypeState] = [.viewer, .annotation, .edit, .form, .signature]
    
    public var readerOnly: Bool = false
    
    public var showMoreItems: [CPDFPopMenuViewType] = [.setting, .pageEdit, .info, .save, .flattened, .share, .addFile]
    
    public var annotationsTypes: [CPDFAnnotationToolbarType] = [.note, .highlight, .underline, .strikeout, .squiggly, .freehand, .pencilDrawing, .shapeCircle, .shapeRectangle, .shapeArrow, .shapeLine, .freeText, .signature, .stamp, .image,.link, .sound]
    
    public var annotationsTools: [CPDFAnnotationPropertieType] = [.setting, .undo, .redo]
    
    public var contentEditorTypes: [CPDFEditMode] = [.text, .image]
    
    public var contentEditorTools: [CPDFEditToolMode] = [.setting, .undo, .redo]
    
    public var formTypes: [CPDFFormToolbarSelectedIndex] = [.text, .checkBox, .radioButton, .comboBox, .list, .button, .sign]
    
    public var formTools: [CPDFFormPropertieType] = [.undo, .redo]
    
    public var annotationAttribute: [String: Any] = [:]
    
    public var contentEditorAttribute: [String: Any] = [:]
    
    public var formsAttribute: [String: Any] = [:]
    
    public var readerViewConfig: [String: Any] = [:]
    
}

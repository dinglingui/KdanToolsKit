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
        self.availableViewModes = [.viewer, .annotation, .edit, .form, .signature]
        self.annotationsTypes = [.note, .highlight, .underline, .strikeout, .squiggly, .freehand, .pencilDrawing, .shapeCircle, .shapeRectangle, .shapeArrow, .shapeLine, .freeText, .signature, .stamp, .image, .sound]
        self.annotationsTools = [.setting, .undo, .redo]
        self.contentEditorTools = [.setting, .undo, .redo]
        self.contentEditorTypes = [.text, .image]
        self.formTypes = [.text, .checkBox, .radioButton, .comboBox, .list, .button, .sign]
        self.formTools = [.undo, .redo]
        
        self.showMoreItems = [.setting, .pageEdit, .info, .save, .flattened, .share, .addFile]
    }
    
    public var showleftItems: [CNavBarButtonItem] = []
    
    public var showRightItems: [CNavBarButtonItem] = []
    
    public var enterToolModel: CPDFToolFunctionTypeState = .viewer
    
    public var availableViewModes: [CPDFToolFunctionTypeState] = []
    
    public var readerOnly: Bool = false
    
    public var showMoreItems: [CPDFPopMenuViewType] = []
    
    public var annotationsTypes: [CPDFAnnotationToolbarType] = []
    
    public var annotationsTools: [CPDFAnnotationPropertieType] = []
    
    public var contentEditorTypes: [CPDFEditMode] = []
    
    public var contentEditorTools: [CPDFEditToolMode] = []
    
    public var formTypes: [CPDFFormToolbarSelectedIndex] = []
    
    public var formTools: [CPDFFormPropertieType] = []
    
    public var annotationAttribute: [String: Any] = [:]
    
    public var contentEditorAttribute: [String: Any] = [:]
    
    public var formsAttribute: [String: Any] = [:]
    
    public var readerViewConfig: [String: Any] = [:]
    
}

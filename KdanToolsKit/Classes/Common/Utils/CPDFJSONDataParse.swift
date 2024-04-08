//
//  CPDFJSONDataParse.swift
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
import Foundation


open class CPDFJSONDataParse: NSObject {
    
    public var configuration: CPDFConfiguration?
    
    public init(filePath jsonFilePath: String) {
        super.init()
        
        let jsonDic = readJSONFromPath(jsonFilePath)
        
        self.configuration = parseJSON(jsonDic)
        
        
    }
    
    public init(String jsonSting: String) {
        super.init()
        
        let jsonDic = readJSONSting(jsonSting)
        
        self.configuration = parseJSON(jsonDic)
    }
    
    public init(HttpURL httpUrl:String) {
        super.init()
        
        fetchJSONData(from: httpUrl) { result in
            switch result {
            case .success(let json):
                let jsonDic = self.getConfigDic(json)
                self.configuration = self.parseJSON(jsonDic)
                // Handle your JSON data here
            case .failure(let error):
                print("Failed to fetch JSON with error: \(error)")
                // Handle the error here
            }
        }
    }
    
    func fetchJSONData(from url: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
                completion(.success(json))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func readJSONFromPath(_ jsonFilePath: String) -> Dictionary<String, Any> {
        do {
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: jsonFilePath))
            
            let jsonDic = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] ?? [String: Any]()
            
            return jsonDic
        } catch{
            
        }
        
        return Dictionary()
    }
    
    func readJSONSting(_ jsonSting: String) -> Dictionary<String, Any> {
        do {
            if let jsonData = jsonSting.data(using: .utf8) {
                
                let jsonDic = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] ?? [String: Any]()
                
                return jsonDic
            }
            
        } catch{
            
        }
        
        return Dictionary()
    }
    
    func getConfigDic(_ jsonDic: Dictionary<String, Any>) -> Dictionary<String, Any> {
        for (key, value) in jsonDic {
            if key == "list" {
                if let innerArray = value as? [Any] {
                    for (_, item) in innerArray.enumerated() {
                        if let innerDict = item as? [String: Any] {
                            for (innerKey, innerValue) in innerDict {
                                if innerKey == "detail" {
                                    if let string = innerValue as? String {
                                        return readJSONSting(string)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return [String: Any]()
    }
        
    func parseJSON(_ jsonDic: Dictionary<String, Any>) -> CPDFConfiguration {
        let configuration = CPDFConfiguration()
        
        for (key, value) in jsonDic {
            
            if key == "modeConfig" {
                if let innerDict = value as? [String: Any] {
                    for (innerKey, innerValue) in innerDict {
                        if innerKey == "initialViewMode" {
                            let innerValueString = innerValue as? String ?? ""
                            
                            if innerValueString == "viewer" {
                                configuration.enterToolModel = .viewer
                            } else if innerValueString == "annotations" {
                                configuration.enterToolModel = .annotation
                            } else if innerValueString == "contentEditor" {
                                configuration.enterToolModel = .edit
                            } else if innerValueString == "forms" {
                                configuration.enterToolModel = .form
                            } else if innerValueString == "signatures" {
                                configuration.enterToolModel = .signature
                            }
                        } else if innerKey == "readerOnly" {
                            configuration.readerOnly = innerValue as? Bool ?? false
                        } else if innerKey == "availableViewModes" {
                            if let innerArray = innerValue as? [Any] {
                                var availableViewModes: [CPDFToolFunctionTypeState] = []
                                for (_, item) in innerArray.enumerated() {
                                    let itemString = item as? String ?? ""
                                    
                                    if itemString == "viewer" && !availableViewModes.contains(.viewer) {
                                        availableViewModes.append(.viewer)
                                    } else if itemString == "annotations" && !availableViewModes.contains(.annotation) {
                                        availableViewModes.append(.annotation)
                                    } else if itemString == "contentEditor" && !availableViewModes.contains(.edit) {
                                        availableViewModes.append(.edit)
                                    } else if itemString == "forms" && !availableViewModes.contains(.form) {
                                        availableViewModes.append(.form)
                                    } else if itemString == "signatures" && !availableViewModes.contains(.signature) {
                                        availableViewModes.append(.signature)
                                    }
                                }
                                configuration.availableViewModes = availableViewModes
                            }
                        }
                    }
                }
            } else if key == "toolbarConfig" {
                if let innerDict = value as? [String: Any] {
                    for (innerKey, innerValue) in innerDict {
                        if let innerArray = innerValue as? [Any] {
                            if innerKey == "iosRightBarAvailableActions" {
                                var showRightItems: [CNavBarButtonItem] = []
                                var rightItems: [CPDFViewBarRightButtonItem] = []
                                for (_, item) in innerArray.enumerated() {
                                    let itemString = item as? String ?? ""
                                    
                                    if itemString == "search" && !rightItems.contains(.search) {
                                        let search = CNavBarButtonItem(viewRightBarButtonItem: .search)
                                        showRightItems.append(search)
                                        rightItems.append(.search)
                                    } else if itemString == "bota" && !rightItems.contains(.bota) {
                                        let bota = CNavBarButtonItem(viewRightBarButtonItem: .bota)
                                        showRightItems.append(bota)
                                        rightItems.append(.bota)
                                    } else if itemString == "menu" && !rightItems.contains(.more) {
                                        let more = CNavBarButtonItem(viewRightBarButtonItem: .more)
                                        showRightItems.append(more)
                                        rightItems.append(.more)
                                    }
                                }
                                configuration.showRightItems = showRightItems
                            } else if innerKey == "iosLeftBarAvailableActions" {
                                var showleftItems: [CNavBarButtonItem] = []
                                var leftItems: [CPDFViewBarLeftButtonItem] = []
                                for (_, item) in innerArray.enumerated() {
                                    let itemString = item as? String ?? ""
                                    
                                    if itemString == "back" && !leftItems.contains(.back) {
                                        let back = CNavBarButtonItem(viewLeftBarButtonItem: .back)
                                        showleftItems.append(back)
                                        leftItems.append(.back)
                                    } else if itemString == "thumbnail" && !leftItems.contains(.thumbnail) {
                                        let thumbnail = CNavBarButtonItem(viewLeftBarButtonItem: .thumbnail)
                                        showleftItems.append(thumbnail)
                                        leftItems.append(.thumbnail)
                                    }
                                }
                                configuration.showleftItems = showleftItems
                            } else if innerKey == "availableMenus" {
                                var showMoreItems: [CPDFPopMenuViewType] = []
                                for (_, item) in innerArray.enumerated() {
                                    let itemString = item as? String ?? ""
                                    
                                    if itemString == "viewSettings" && !showMoreItems.contains(.setting) {
                                        showMoreItems.append(.setting)
                                    } else if itemString == "documentEditor" && !showMoreItems.contains(.pageEdit) {
                                        showMoreItems.append(.pageEdit)
                                    } else if itemString == "security" && !showMoreItems.contains(.security) {
                                        showMoreItems.append(.security)
                                    } else if itemString == "watermark" && !showMoreItems.contains(.watermark) {
                                        showMoreItems.append(.watermark)
                                    } else if itemString == "documentInfo" && !showMoreItems.contains(.info) {
                                        showMoreItems.append(.info)
                                    } else if itemString == "save" && !showMoreItems.contains(.save) {
                                        showMoreItems.append(.save)
                                    } else if itemString == "share" && !showMoreItems.contains(.share) {
                                        showMoreItems.append(.share)
                                    } else if itemString == "openDocument" && !showMoreItems.contains(.addFile) {
                                        showMoreItems.append(.addFile)
                                    } else if itemString == "flattened" && !showMoreItems.contains(.flattened) {
                                        showMoreItems.append(.flattened)
                                    }
                                }
                                configuration.showMoreItems = showMoreItems
                            }
                        }
                    }
                }
            } else if key == "annotationsConfig" {
                if let innerDict = value as? [String: Any] {
                    for (innerKey, innerValue) in innerDict {
                        if let innerArray = innerValue as? [Any] {
                            if innerKey == "availableTypes" {
                                var annotationsTypes: [CPDFAnnotationToolbarType] = []
                                for (_, item) in innerArray.enumerated() {
                                    let itemString = item as? String ?? ""
                                    
                                    if itemString == "note" && !annotationsTypes.contains(.note) {
                                        annotationsTypes.append(.note)
                                    } else if itemString == "highlight" && !annotationsTypes.contains(.highlight) {
                                        annotationsTypes.append(.highlight)
                                    } else if itemString == "underline" && !annotationsTypes.contains(.underline) {
                                        annotationsTypes.append(.underline)
                                    } else if itemString == "squiggly" && !annotationsTypes.contains(.squiggly) {
                                        annotationsTypes.append(.squiggly)
                                    } else if itemString == "strikeout" && !annotationsTypes.contains(.strikeout) {
                                        annotationsTypes.append(.strikeout)
                                    } else if itemString == "ink" && !annotationsTypes.contains(.freehand) {
                                        annotationsTypes.append(.freehand)
                                    } else if itemString == "pencil" && !annotationsTypes.contains(.pencilDrawing) {
                                        annotationsTypes.append(.pencilDrawing)
                                    } else if itemString == "circle" && !annotationsTypes.contains(.shapeCircle) {
                                        annotationsTypes.append(.shapeCircle)
                                    } else if itemString == "square" && !annotationsTypes.contains(.shapeRectangle) {
                                        annotationsTypes.append(.shapeRectangle)
                                    } else if itemString == "arrow" && !annotationsTypes.contains(.shapeArrow) {
                                        annotationsTypes.append(.shapeArrow)
                                    } else if itemString == "line" && !annotationsTypes.contains(.shapeLine) {
                                        annotationsTypes.append(.shapeLine)
                                    } else if itemString == "freetext" && !annotationsTypes.contains(.freeText) {
                                        annotationsTypes.append(.freeText)
                                    } else if itemString == "signature" && !annotationsTypes.contains(.signature) {
                                        annotationsTypes.append(.signature)
                                    } else if itemString == "stamp" && !annotationsTypes.contains(.stamp) {
                                        annotationsTypes.append(.stamp)
                                    } else if itemString == "pictures" && !annotationsTypes.contains(.image) {
                                        annotationsTypes.append(.image)
                                    } else if itemString == "link" && !annotationsTypes.contains(.link) {
                                        annotationsTypes.append(.link)
                                    } else if itemString == "sound" && !annotationsTypes.contains(.sound) {
                                        annotationsTypes.append(.sound)
                                    }
                                }
                                configuration.annotationsTypes = annotationsTypes
                            } else if innerKey == "availableTools" {
                                var annotationsTools: [CPDFAnnotationPropertieType] = []
                                for (_, item) in innerArray.enumerated() {
                                    let itemString = item as? String ?? ""
                                    
                                    if itemString == "setting" && !annotationsTools.contains(.setting) {
                                        annotationsTools.append(.setting)
                                    } else if itemString == "undo" && !annotationsTools.contains(.undo) {
                                        annotationsTools.append(.undo)
                                    } else if itemString == "redo" && !annotationsTools.contains(.redo) {
                                        annotationsTools.append(.redo)
                                    }
                                }
                                configuration.annotationsTools = annotationsTools
                            }
                        } else if let innerDict = innerValue as? [String: Any] {
                            if innerKey == "initAttribute" {
                                configuration.annotationAttribute = innerDict
                            }
                        }
                    }
                }
            } else if key == "contentEditorConfig" {
                if let innerDict = value as? [String: Any] {
                    for (innerKey, innerValue) in innerDict {
                        if let innerArray = innerValue as? [Any] {
                            if innerKey == "availableTypes" {
                                var contentEditorTypes: [CPDFEditMode] = []
                                for (_, item) in innerArray.enumerated() {
                                    let itemString = item as? String ?? ""
                                    
                                    if itemString == "editorText"  && !contentEditorTypes.contains(.text) {
                                        contentEditorTypes.append(.text)
                                    } else if itemString == "editorImage" && !contentEditorTypes.contains(.image) {
                                        contentEditorTypes.append(.image)
                                    }
                                }
                                configuration.contentEditorTypes = contentEditorTypes
                            } else if innerKey == "availableTools" {
                                var contentEditorTools: [CPDFEditToolMode] = []
                                for (_, item) in innerArray.enumerated() {
                                    let itemString = item as? String ?? ""
                                    
                                    if itemString == "setting" && !contentEditorTools.contains(.setting) {
                                        contentEditorTools.append(.setting)
                                    } else if itemString == "undo" && !contentEditorTools.contains(.undo) {
                                        contentEditorTools.append(.undo)
                                    } else if itemString == "redo" && !contentEditorTools.contains(.redo) {
                                        contentEditorTools.append(.redo)
                                    }
                                }
                                configuration.contentEditorTools = contentEditorTools
                            }
                        } else if let innerDict = innerValue as? [String: Any] {
                            if innerKey == "initAttribute" {
                                configuration.contentEditorAttribute = innerDict
                                CPDFJSONDataParse.initializeContentEditorAttribute(Configuration: configuration)
                            }
                        }
                    }
                }
            } else if key == "formsConfig" {
                if let innerDict = value as? [String: Any] {
                    for (innerKey, innerValue) in innerDict {
                        if let innerArray = innerValue as? [Any] {
                            if innerKey == "availableTypes" {
                                var formTypes: [CPDFFormToolbarSelectedIndex] = []
                                for (_, item) in innerArray.enumerated() {
                                    let itemString = item as? String ?? ""
                                    if itemString == "textField" && !formTypes.contains(.text) {
                                        formTypes.append(.text)
                                    } else if itemString == "checkBox" && !formTypes.contains(.checkBox) {
                                        formTypes.append(.checkBox)
                                    } else if itemString == "radioButton" && !formTypes.contains(.radioButton) {
                                        formTypes.append(.radioButton)
                                    } else if itemString == "listBox" && !formTypes.contains(.list) {
                                        formTypes.append(.list)
                                    } else if itemString == "comboBox" && !formTypes.contains(.comboBox) {
                                        formTypes.append(.comboBox)
                                    } else if itemString == "signaturesFields" && !formTypes.contains(.sign) {
                                        formTypes.append(.sign)
                                    } else if itemString == "pushButton" && !formTypes.contains(.button) {
                                        formTypes.append(.button)
                                    }
                                }
                                configuration.formTypes = formTypes
                            } else if innerKey == "availableTools" {
                                var formTools: [CPDFFormPropertieType] = []
                                for (_, item) in innerArray.enumerated() {
                                    let itemString = item as? String ?? ""
                                    
                                    if itemString == "undo" && !formTools.contains(.undo) {
                                        formTools.append(.undo)
                                    } else if itemString == "redo" && !formTools.contains(.redo) {
                                        formTools.append(.redo)
                                    }
                                }
                                configuration.formTools = formTools
                            }
                        } else if let innerDict = innerValue as? [String: Any] {
                            if innerKey == "initAttribute" {
                                configuration.formsAttribute = innerDict
                                CPDFJSONDataParse.initializeFormsAttribute(Configuration: configuration)
                            }
                        }
                    }
                }
            } else if key == "readerViewConfig" {
                if let innerDict = value as? [String: Any] {
                    for (innerKey, innerValue) in innerDict {
                        configuration.readerViewConfig = innerDict
                        if innerKey == "linkHighlight" {
                            let linkHighlight = innerValue as? Bool ?? false
                            CPDFKitConfig.sharedInstance().setEnableLinkFieldHighlight(linkHighlight)
                        } else if innerKey == "formFieldHighlight" {
                            let formFieldHighlight = innerValue as? Bool ?? false
                            CPDFKitConfig.sharedInstance().setEnableFormFieldHighlight(formFieldHighlight)
                        }
                    }
                }
            }
        }
        
        return configuration
    }
    
    class func initializeReaderViewConfig(_ configuration: CPDFConfiguration, PDFView pdfListView: CPDFListView) {
   
        for (key, value) in configuration.readerViewConfig {
            if key == "displayMode" {
                let valueString = value as? String ?? ""
                if valueString == "singlePage" {
                    pdfListView.displayTwoUp = false
                    pdfListView.displaysAsBook = false
                } else if valueString == "doublePage" {
                    pdfListView.displayTwoUp = true
                    pdfListView.displaysAsBook = false
                } else if valueString == "coverPage" {
                    pdfListView.displayTwoUp = true
                    pdfListView.displaysAsBook = true
                }
            } else if key == "continueMode" {
                let continueMode = value as? Bool ?? false
                pdfListView.displaysPageBreaks = continueMode
            } else if key == "verticalMode" {
                let verticalMode = value as? Bool ?? false
                if verticalMode {
                    pdfListView.displayDirection = .vertical
                } else {
                    pdfListView.displayDirection = .horizontal
                }
            } else if key == "cropMode" {
                let cropMode = value as? Bool ?? false
                pdfListView.displayCrop = cropMode
            } else if key == "themes" {
                let valueString = value as? String ?? ""
                if valueString == "light" {
                    pdfListView.displayMode = .normal
                } else if valueString == "dark" {
                    pdfListView.displayMode = .night
                } else if valueString == "sepia" {
                    pdfListView.displayMode = .soft
                } else if valueString == "reseda" {
                    pdfListView.displayMode = .green
                }
            } else if key == "enableSliderBar" {
                let enableSliderBar = value as? Bool ?? false
                pdfListView.pageSliderView?.isHidden = !enableSliderBar
            } else if key == "enablePageIndicator" {
                let enablePageIndicator = value as? Bool ?? false
                pdfListView.pageIndicatorView?.alpha = enablePageIndicator ? 1 : 0
            } else if key == "pageSpacing" {
                let pageSpacing = value as? CGFloat ?? 0
                pdfListView.pageBreakMargins = UIEdgeInsets(top: pageSpacing, left: 10.0, bottom: pageSpacing, right: 10.0)
            }
        }
        
        pdfListView.layoutDocumentView()
        
        for (key, value) in configuration.readerViewConfig {
            if key == "pageScale" {
               var pageScale = value as? CGFloat ?? 0
               if pageScale < 1 {
                   pageScale = 1
               }
               pdfListView.setScaleFactor(pageScale, animated: false)
           }
        }
    }
    
    class func initializeFormsAttribute(Configuration configuration: CPDFConfiguration) {
        let userDefaults = UserDefaults.standard
        for (key, value) in configuration.formsAttribute {
            if key == "textField" {
                if let innerDict = value as? [String: Any] {
                    var isBold = false
                    var isItalic = false
                    var baseName = ""
                    
                    for (innerKey, innerValue) in innerDict {
                        if innerKey == "fillColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CTextFieldInteriorColorKey)
                        } else if innerKey == "borderColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CTextFieldColorKey)
                        } else if innerKey == "borderWidth" {
                            let borderWidth = innerValue as? CGFloat ?? 1
                            userDefaults.set(borderWidth, forKey: CTextFieldLineWidthKey)
                        } else if innerKey == "fontColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CTextFieldFontColorKey)
                        } else if innerKey == "fontSize" {
                            let fontSize = innerValue as? CGFloat ?? 10
                            userDefaults.set(fontSize, forKey: CTextFieldFontSizeKey)
                        } else if innerKey == "isBold" {
                            isBold = innerValue as? Bool ?? false
                            userDefaults.set(isBold, forKey: CTextFieldIsBoldKey)
                        } else if innerKey == "isItalic" {
                            isItalic = innerValue as? Bool ?? false
                            userDefaults.set(isItalic, forKey: CTextFieldIsItalicKey)
                        } else if innerKey == "alignment" {
                            let string = innerValue as? String ?? ""
                            
                            if string == "left" {
                                userDefaults.set(0, forKey: CTextFieldAlignmentKey)
                            } else if string == "center" {
                                userDefaults.set(1, forKey: CTextFieldAlignmentKey)
                            } else if string == "right" {
                                userDefaults.set(2, forKey: CTextFieldAlignmentKey)
                            }
                        } else if innerKey == "typeface" {
                            baseName = innerValue as? String ?? ""
                        } else if innerKey == "multiline" {
                            let multiline = innerValue as? Bool ?? false
                            userDefaults.set(multiline, forKey: CTextFieldIsMultilineKey)
                        }
                    }
                    
                    let constructName = CPDFJSONDataParse.constructionFontName(BaseName: baseName, isBold: isBold, isItalic: isItalic)
                    userDefaults.set(constructName, forKey: CTextFieldFontNameKey)
                }
            } else if key == "checkBox" {
                if let innerDict = value as? [String: Any] {
                    for (innerKey, innerValue) in innerDict {
                        if innerKey == "fillColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CCheckBoxInteriorColorKey)
                        } else if innerKey == "borderColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CCheckBoxColorKey)
                        } else if innerKey == "borderWidth" {
                            let borderWidth = innerValue as? CGFloat ?? 1
                            userDefaults.set(borderWidth, forKey: CCheckBoxLineWidthKey)
                        } else if innerKey == "checkedColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CCheckBoxCheckedColorKey)
                        } else if innerKey == "isChecked" {
                            let isChecked = innerValue as? Bool ?? false
                            userDefaults.set(isChecked, forKey: CCheckBoxIsCheckedKey)
                        } else if innerKey == "checkedStyle" {
                            let string = innerValue as? String ?? ""
                            
                            if string == "check" {
                                userDefaults.set(0, forKey: CCheckBoxCheckedStyleKey)
                            } else if string == "circle," {
                                userDefaults.set(1, forKey: CCheckBoxCheckedStyleKey)
                            } else if string == "cross" {
                                userDefaults.set(2, forKey: CCheckBoxCheckedStyleKey)
                            } else if string == "diamond" {
                                userDefaults.set(3, forKey: CCheckBoxCheckedStyleKey)
                            } else if string == "square" {
                                userDefaults.set(4, forKey: CCheckBoxCheckedStyleKey)
                            } else if string == "star" {
                                userDefaults.set(5, forKey: CCheckBoxCheckedStyleKey)
                            }
                        }
                    }
                }
            } else if key == "radioButton" {
                if let innerDict = value as? [String: Any] {
                    for (innerKey, innerValue) in innerDict {
                        if innerKey == "fillColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CRadioButtonInteriorColorKey)
                        } else if innerKey == "borderColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CRadioButtonColorKey)
                        } else if innerKey == "borderWidth" {
                            let borderWidth = innerValue as? CGFloat ?? 1
                            userDefaults.set(borderWidth, forKey: CRadioButtonLineWidthKey)
                        } else if innerKey == "checkedColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CRadioButtonCheckedColorKey)
                        } else if innerKey == "isChecked" {
                            let isChecked = innerValue as? Bool ?? false
                            userDefaults.set(isChecked, forKey: CRadioButtonIsCheckedKey)
                        } else if innerKey == "checkedStyle" {
                            let string = innerValue as? String ?? ""
                            
                            if string == "check" {
                                userDefaults.set(0, forKey: CRadioButtonCheckedStyleKey)
                            } else if string == "circle" {
                                userDefaults.set(1, forKey: CRadioButtonCheckedStyleKey)
                            } else if string == "cross" {
                                userDefaults.set(2, forKey: CRadioButtonCheckedStyleKey)
                            } else if string == "diamond" {
                                userDefaults.set(3, forKey: CRadioButtonCheckedStyleKey)
                            } else if string == "square" {
                                userDefaults.set(4, forKey: CRadioButtonCheckedStyleKey)
                            } else if string == "star" {
                                userDefaults.set(5, forKey: CRadioButtonCheckedStyleKey)
                            }
                        }
                    }
                }
            } else if key == "listBox" {
                if let innerDict = value as? [String: Any] {
                    var isBold = false
                    var isItalic = false
                    var baseName = ""
                    
                    for (innerKey, innerValue) in innerDict {
                        if innerKey == "fillColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CListBoxInteriorColorKey)
                        } else if innerKey == "borderColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CListBoxColorKey)
                        } else if innerKey == "borderWidth" {
                            let borderWidth = innerValue as? CGFloat ?? 1
                            userDefaults.set(borderWidth, forKey: CListBoxLineWidthKey)
                        } else if innerKey == "fontColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CListBoxFontColorKey)
                        } else if innerKey == "fontSize" {
                            let fontSize = innerValue as? CGFloat ?? 10
                            userDefaults.set(fontSize, forKey: CListBoxFontSizeKey)
                        } else if innerKey == "isBold" {
                            isBold = innerValue as? Bool ?? false
                            userDefaults.set(isBold, forKey: CListBoxIsBoldKey)
                        } else if innerKey == "isItalic" {
                            isItalic = innerValue as? Bool ?? false
                            userDefaults.set(isItalic, forKey: CListBoxIsItalicKey)
                        } else if innerKey == "typeface" {
                            baseName = innerValue as? String ?? ""
                        }
                    }
                    
                    let constructName = CPDFJSONDataParse.constructionFontName(BaseName: baseName, isBold: isBold, isItalic: isItalic)
                    userDefaults.set(constructName, forKey: CListBoxFontNameKey)
                }
            } else if key == "comboBox" {
                if let innerDict = value as? [String: Any] {
                    var isBold = false
                    var isItalic = false
                    var baseName = ""
                    
                    for (innerKey, innerValue) in innerDict {
                        if innerKey == "fillColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CComboBoxInteriorColorKey)
                        } else if innerKey == "borderColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CComboBoxColorKey)
                        } else if innerKey == "borderWidth" {
                            let borderWidth = innerValue as? CGFloat ?? 1
                            userDefaults.set(borderWidth, forKey: CComboBoxLineWidthKey)
                        } else if innerKey == "fontColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CComboBoxFontColorKey)
                        } else if innerKey == "fontSize" {
                            let fontSize = innerValue as? CGFloat ?? 10
                            userDefaults.set(fontSize, forKey: CComboBoxFontSizeKey)
                        } else if innerKey == "isBold" {
                            isBold = innerValue as? Bool ?? false
                            userDefaults.set(isBold, forKey: CComboBoxIsBoldKey)
                        } else if innerKey == "isItalic" {
                            isItalic = innerValue as? Bool ?? false
                            userDefaults.set(isItalic, forKey: CComboBoxIsItalicKey)
                        } else if innerKey == "typeface" {
                            baseName = innerValue as? String ?? ""
                        }
                    }
                    
                    let constructName = CPDFJSONDataParse.constructionFontName(BaseName: baseName, isBold: isBold, isItalic: isItalic)
                    userDefaults.set(constructName, forKey: CComboBoxFontNameKey)
                }
            } else if key == "pushButton" {
                if let innerDict = value as? [String: Any] {
                    var isBold = false
                    var isItalic = false
                    var baseName = ""
                    
                    for (innerKey, innerValue) in innerDict {
                        if innerKey == "fillColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CPushButtonInteriorColorKey)
                        } else if innerKey == "borderColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CPushButtonColorKey)
                        } else if innerKey == "borderWidth" {
                            let borderWidth = innerValue as? CGFloat ?? 1
                            userDefaults.set(borderWidth, forKey: CPushButtonLineWidthKey)
                        } else if innerKey == "fontColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CPushButtonFontColorKey)
                        } else if innerKey == "fontSize" {
                            let fontSize = innerValue as? CGFloat ?? 10
                            userDefaults.set(fontSize, forKey: CPushButtonFontSizeKey)
                        } else if innerKey == "isBold" {
                            isBold = innerValue as? Bool ?? false
                            userDefaults.set(isBold, forKey: CPushButtonIsBoldKey)
                        } else if innerKey == "isItalic" {
                            isItalic = innerValue as? Bool ?? false
                            userDefaults.set(isItalic, forKey: CPushButtonIsItalicKey)
                        } else if innerKey == "typeface" {
                            baseName = innerValue as? String ?? ""
                        } else if innerKey == "title" {
                            let string = innerValue as? String ?? ""
                            userDefaults.set(string, forKey: CPushButtonTitleKey)
                        }
                    }
                    
                    let constructName = CPDFJSONDataParse.constructionFontName(BaseName: baseName, isBold: isBold, isItalic: isItalic)
                    userDefaults.set(constructName, forKey: CPushButtonFontNameKey)
                }
            } else if key == "signaturesFields" {
                if let innerDict = value as? [String: Any] {
                    for (innerKey, innerValue) in innerDict {
                        if innerKey == "fillColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CSignaturesFieldsInteriorColorKey)
                        } else if innerKey == "borderColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CSignaturesFieldsColorKey)
                        } else if innerKey == "borderWidth" {
                            let borderWidth = innerValue as? CGFloat ?? 1
                            userDefaults.set(borderWidth, forKey: CSignaturesFieldsLineWidthKey)
                        } else if innerKey == "borderStyle" {
                            let string = innerValue as? String ?? ""
                            
                            if string == "solid" {
                                userDefaults.set(0, forKey: CSignaturesFieldsLineStyleKey)
                            } else if string == "dashed" {
                                userDefaults.set(1, forKey: CSignaturesFieldsLineStyleKey)
                            } else if string == "beveled" {
                                userDefaults.set(2, forKey: CSignaturesFieldsLineStyleKey)
                            } else if string == "inset" {
                                userDefaults.set(3, forKey: CSignaturesFieldsLineStyleKey)
                            } else if string == "underline" {
                                userDefaults.set(4, forKey: CSignaturesFieldsLineStyleKey)
                            }
                        }
                    }
                }
            }
        }
        userDefaults.synchronize()
    }

    
    class func initializeContentEditorAttribute(Configuration configuration: CPDFConfiguration) {
        let userDefaults = UserDefaults.standard
        
        for (key, value) in configuration.contentEditorAttribute {
            if key == "text" {
                if let innerDict = value as? [String: Any] {
                    var isBold = false
                    var isItalic = false
                    var baseName = ""
                    
                    for (innerKey, innerValue) in innerDict {
                        if innerKey == "fontColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CPDFContentEditTextCreateFontColorKey)
                        } else if innerKey == "fontColorAlpha" {
                            let opacity = innerValue as? CGFloat ?? 10
                            
                            userDefaults.set(opacity / 255.0, forKey: CPDFContentEditTextCreateFontOpacityKey)
                        } else if innerKey == "fontSize" {
                            let fontSize = innerValue as? CGFloat ?? 10
                            userDefaults.set(fontSize, forKey: CPDFContentEditTextCreateFontSizeKey)
                        } else if innerKey == "isBold" {
                            isBold = innerValue as? Bool ?? false
                            userDefaults.set(isBold, forKey: CPDFContentEditTextCreateFontIsBoldKey)
                        } else if innerKey == "isItalic" {
                            isItalic = innerValue as? Bool ?? false
                            userDefaults.set(isItalic, forKey: CPDFContentEditTextCreateFontIsItalicKey)
                        } else if innerKey == "alignment" {
                            let string = innerValue as? String ?? ""
                            
                            if string == "left" {
                                userDefaults.set(0, forKey: CPDFContentEditTextCreateFontAlignmentKey)
                            } else if string == "center" {
                                userDefaults.set(1, forKey: CPDFContentEditTextCreateFontAlignmentKey)
                            } else if string == "right" {
                                userDefaults.set(2, forKey: CPDFContentEditTextCreateFontAlignmentKey)
                            }
                        } else if innerKey == "typeface" {
                            baseName = innerValue as? String ?? ""
                            userDefaults.set(baseName, forKey: CPDFContentEditTextCreateFontNameKey)
                        }
                    }
                }
            }
        }
        userDefaults.synchronize()
    }
    
    
    class func initializeAnnotationAttribute(Configuration configuration: CPDFConfiguration) {
        let userDefaults = UserDefaults.standard
        
        for (key, value) in configuration.annotationAttribute {
            if key == "note" {
                if let innerDict = value as? [String: Any] {
                    for (innerKey, innerValue) in innerDict {
                        if innerKey == "color" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CAnchoredNoteColorKey)
                        } else if innerKey == "alpha" {
                            let opacity = innerValue as? CGFloat ?? 10
                            
                            userDefaults.set(opacity / 255.0, forKey: CAnchoredNoteOpacityKey)
                        }
                    }
                }
            } else if key == "highlight" {
                if let innerDict = value as? [String: Any] {
                    for (innerKey, innerValue) in innerDict {
                        if innerKey == "color" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CHighlightNoteColorKey)
                        } else if innerKey == "alpha" {
                            let opacity = innerValue as? CGFloat ?? 10
                            
                            userDefaults.set(opacity / 255.0, forKey: CHighlightNoteOpacityKey)
                        }
                    }
                }
            } else if key == "underline" {
                if let innerDict = value as? [String: Any] {
                    for (innerKey, innerValue) in innerDict {
                        if innerKey == "color" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CUnderlineNoteColorKey)
                        } else if innerKey == "alpha" {
                            let opacity = innerValue as? CGFloat ?? 10
                            
                            userDefaults.set(opacity / 255.0, forKey: CUnderlineNoteOpacityKey)
                        }
                    }
                }
            } else if key == "squiggly" {
                if let innerDict = value as? [String: Any] {
                    for (innerKey, innerValue) in innerDict {
                        if innerKey == "color" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CSquigglyNoteColorKey)
                        } else if innerKey == "alpha" {
                            let opacity = innerValue as? CGFloat ?? 10
                            
                            userDefaults.set(opacity / 255.0, forKey: CSquigglyNoteOpacityKey)
                        }
                    }
                }
            } else if key == "strikeout" {
                if let innerDict = value as? [String: Any] {
                    for (innerKey, innerValue) in innerDict {
                        if innerKey == "color" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CStrikeOutNoteColorKey)
                        } else if innerKey == "alpha" {
                            let opacity = innerValue as? CGFloat ?? 10
                            
                            userDefaults.set(opacity / 255.0, forKey: CStrikeOutNoteOpacityKey)
                        }
                    }
                }
            } else if key == "ink" {
                if let innerDict = value as? [String: Any] {
                    for (innerKey, innerValue) in innerDict {
                        if innerKey == "color" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            CPDFKitConfig.sharedInstance().setFreehandAnnotationColor(color)
                        } else if innerKey == "alpha" {
                            let opacity = innerValue as? CGFloat ?? 10
                            CPDFKitConfig.sharedInstance().setFreehandAnnotationOpacity((opacity / 255.0) * 100)
                        } else if innerKey == "borderWidth" {
                            let borderWidth = innerValue as? CGFloat ?? 1
                            CPDFKitConfig.sharedInstance().setFreehandAnnotationBorderWidth(borderWidth)
                        }
                    }
                }
            } else if key == "square" {
                if let innerDict = value as? [String: Any] {
                    for (innerKey, innerValue) in innerDict {
                        if innerKey == "fillColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CSquareNoteInteriorColorKey)
                        } else if innerKey == "borderColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CSquareNoteColorKey)
                        } else if innerKey == "colorAlpha" {
                            let opacity = innerValue as? CGFloat ?? 10
                            userDefaults.set(opacity / 255.0, forKey: CSquareNoteOpacityKey)
                            userDefaults.set(opacity / 255.0, forKey: CSquareNoteInteriorOpacityKey)
                        }  else if innerKey == "borderWidth" {
                            let borderWidth = innerValue as? CGFloat ?? 1
                            userDefaults.set(borderWidth, forKey: CSquareNoteLineWidthKey)
                        } else if innerKey == "borderStyle" {
                            if let innerDict = innerValue as? [String: Any] {
                                for (innerSubKey, innerSubValue) in innerDict {
                                    if innerSubKey == "style" {
                                        let innerValueString = innerSubValue as? String ?? ""
                                        if innerValueString == "solid" {
                                            userDefaults.set(0, forKey: CSquareNoteLineStyleKey)
                                        } else if innerValueString == "dashed" {
                                            userDefaults.set(1, forKey: CSquareNoteLineStyleKey)
                                        }
                                    } else if innerSubKey == "dashGap" {
                                        let dashPattern = innerSubValue as? Int ?? 0
                                        userDefaults.set(dashPattern, forKey:  CSquareNoteDashPatternKey )
                                    }
                                }
                            }
                        }
                    }
                }
            } else if key == "circle" {
                if let innerDict = value as? [String: Any] {
                    for (innerKey, innerValue) in innerDict {
                        if innerKey == "fillColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CCircleNoteInteriorColorKey)
                        } else if innerKey == "borderColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CCircleNoteColorKey)
                        } else if innerKey == "colorAlpha" {
                            let opacity = innerValue as? CGFloat ?? 10
                            userDefaults.set(opacity / 255.0, forKey: CCircleNoteOpacityKey)
                            userDefaults.set(opacity / 255.0, forKey: CCircleNoteInteriorOpacityKey)
                        }  else if innerKey == "borderWidth" {
                            let borderWidth = innerValue as? CGFloat ?? 1
                            userDefaults.set(borderWidth, forKey: CCircleNoteLineWidthKey)
                        } else if innerKey == "borderStyle" {
                            if let innerDict = innerValue as? [String: Any] {
                                for (innerSubKey, innerSubValue) in innerDict {
                                    if innerSubKey == "style" {
                                        let innerValueString = innerSubValue as? String ?? ""
                                        if innerValueString == "solid" {
                                            userDefaults.set(0, forKey: CCircleNoteLineStyleKey)
                                        } else if innerValueString == "dashed" {
                                            userDefaults.set(1, forKey: CCircleNoteLineStyleKey)
                                        }
                                    } else if innerSubKey == "dashGap" {
                                        let dashPattern = innerSubValue as? Int ?? 0
                                        userDefaults.set(dashPattern, forKey:  CCircleNoteDashPatternKey )
                                    }
                                }
                            }
                        }
                    }
                }
            } else if key == "line" {
                if let innerDict = value as? [String: Any] {
                    for (innerKey, innerValue) in innerDict {
                        if innerKey == "borderColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CLineNoteColorKey)
                        } else if innerKey == "borderAlpha" {
                            let opacity = innerValue as? CGFloat ?? 10
                            userDefaults.set(opacity / 255.0, forKey: CLineNoteOpacityKey)
                        }  else if innerKey == "borderWidth" {
                            let borderWidth = innerValue as? CGFloat ?? 1
                            userDefaults.set(borderWidth, forKey: CLineNoteLineWidthKey)
                        } else if innerKey == "borderStyle" {
                            if let innerDict = innerValue as? [String: Any] {
                                for (innerSubKey, innerSubValue) in innerDict {
                                    if innerSubKey == "style" {
                                        let innerValueString = innerSubValue as? String ?? ""
                                        if innerValueString == "solid" {
                                            userDefaults.set(0, forKey: CLineNoteLineStyleKey)
                                        } else if innerValueString == "dashed" {
                                            userDefaults.set(1, forKey: CLineNoteLineStyleKey)
                                        }
                                    } else if innerSubKey == "dashGap" {
                                        let dashPattern = innerSubValue as? Int ?? 0
                                        userDefaults.set(dashPattern, forKey:  CLineNoteDashPatternKey )
                                    }
                                }
                            }
                        }
                    }
                    
                    userDefaults.set(0, forKey: CLineNoteStartStyleKey)
                    userDefaults.set(0, forKey: CLineNoteEndStyleKey)
                }
            } else if key == "arrow" {
                if let innerDict = value as? [String: Any] {
                    for (innerKey, innerValue) in innerDict {
                        if innerKey == "borderColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CArrowNoteColorKey)
                        } else if innerKey == "borderAlpha" {
                            let opacity = innerValue as? CGFloat ?? 10
                            userDefaults.set(opacity / 255.0, forKey: CArrowNoteOpacityKey)
                        }  else if innerKey == "borderWidth" {
                            let borderWidth = innerValue as? CGFloat ?? 1
                            userDefaults.set(borderWidth, forKey: CArrowNoteLineWidthKey)
                        } else if innerKey == "borderStyle" {
                            if let innerDict = innerValue as? [String: Any] {
                                for (innerSubKey, innerSubValue) in innerDict {
                                    if innerSubKey == "style" {
                                        let innerValueString = innerSubValue as? String ?? ""
                                        if innerValueString == "solid" {
                                            userDefaults.set(0, forKey: CArrowNoteLineStyleKey)
                                        } else if innerValueString == "dashed" {
                                            userDefaults.set(1, forKey: CArrowNoteLineStyleKey)
                                        }
                                    } else if innerSubKey == "dashGap" {
                                        let dashPattern = innerSubValue as? Int ?? 0
                                        userDefaults.set(dashPattern, forKey:  CArrowNoteDashPatternKey )
                                    }
                                }
                            }
                        } else if innerKey == "startLineType" {
                            let innerValueString = innerValue as? String ?? ""
                            if innerValueString == "none" {
                                userDefaults.set(0, forKey: CArrowNoteStartStyleKey)
                            } else if innerValueString == "openArrow" {
                                userDefaults.set(1, forKey: CArrowNoteStartStyleKey)
                            } else if innerValueString == "closedArrow" {
                                userDefaults.set(2, forKey: CArrowNoteStartStyleKey)
                            } else if innerValueString == "square" {
                                userDefaults.set(3, forKey: CArrowNoteStartStyleKey)
                            } else if innerValueString == "circle" {
                                userDefaults.set(4, forKey: CArrowNoteStartStyleKey)
                            } else if innerValueString == "diamond" {
                                userDefaults.set(5, forKey: CArrowNoteStartStyleKey)
                            }
                        } else if innerKey == "tailLineType" {
                            let innerValueString = innerValue as? String ?? ""
                            if innerValueString == "none" {
                                userDefaults.set(0, forKey: CArrowNoteEndStyleKey)
                            } else if innerValueString == "openArrow" {
                                userDefaults.set(1, forKey: CArrowNoteEndStyleKey)
                            } else if innerValueString == "closedArrow" {
                                userDefaults.set(2, forKey: CArrowNoteEndStyleKey)
                            } else if innerValueString == "square" {
                                userDefaults.set(3, forKey: CArrowNoteEndStyleKey)
                            } else if innerValueString == "circle" {
                                userDefaults.set(4, forKey: CArrowNoteEndStyleKey)
                            } else if innerValueString == "diamond" {
                                userDefaults.set(5, forKey: CArrowNoteEndStyleKey)
                            }
                        }
                    }
                }
            } else if key == "freeText" {
                if let innerDict = value as? [String: Any] {
                    var isBold = false
                    var isItalic = false
                    var baseName = ""
                    
                    for (innerKey, innerValue) in innerDict {
                        if innerKey == "fontColor" {
                            let string = innerValue as? String ?? ""
                            let color = UserDefaults.colorWithHexString(string)
                            userDefaults.setPDFListViewColor(color, forKey: CFreeTextNoteFontColorKey)
                        } else if innerKey == "fontColorAlpha" {
                            let opacity = innerValue as? CGFloat ?? 10
                            
                            userDefaults.set(opacity / 255.0, forKey: CFreeTextNoteOpacityKey)
                        } else if innerKey == "fontSize" {
                            let fontSize = innerValue as? CGFloat ?? 10
                            userDefaults.set(fontSize, forKey: CFreeTextNoteFontSizeKey)
                        } else if innerKey == "isBold" {
                            isBold = innerValue as? Bool ?? false
                        } else if innerKey == "isItalic" {
                            isItalic = innerValue as? Bool ?? false
                        } else if innerKey == "alignment" {
                            let string = innerValue as? String ?? ""
                            
                            if string == "left" {
                                userDefaults.set(0, forKey: CFreeTextNoteAlignmentKey)
                            } else if string == "center" {
                                userDefaults.set(1, forKey: CFreeTextNoteAlignmentKey)
                            } else if string == "right" {
                                userDefaults.set(2, forKey: CFreeTextNoteAlignmentKey)
                            }
                        } else if innerKey == "typeface" {
                            baseName = innerValue as? String ?? ""
                        }
                    }
                    
                    let constructName = CPDFJSONDataParse.constructionFontName(BaseName: baseName, isBold: isBold, isItalic: isItalic)
                    userDefaults.set(constructName, forKey: CFreeTextNoteFontNameKey)
                }
            }
        }
    
        userDefaults.synchronize()
    }
    
    class func constructionFontName(BaseName baseName: String, isBold: Bool, isItalic: Bool) -> String {
        var result: String
        if baseName.range(of: "Times") != nil {
            if isBold || isItalic {
                if isBold && isItalic {
                    return "Times-BoldItalic"
                }
                if isBold {
                    return "Times-Bold"
                }
                if isItalic {
                    return "Times-Italic"
                }
            } else {
                return "Times-Roman"
            }
        }
        
        if isBold || isItalic {
            result = "\(baseName)-"
            if isBold {
                result = "\(result)Bold"
            }
            if isItalic {
                result = "\(result)Oblique"
            }
        } else {
            return baseName
        }
        
        return result
    }
}

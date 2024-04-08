//
//  CStampFileManger.swift
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


let kPDFStampDataFolder = NSHomeDirectory().appending("/Library/PDFKitResources/Stamp")
let kPDFStampTextList = NSHomeDirectory().appending("/Library/PDFKitResources/Stamp/stamp_text.plist")
let kPDFStampImageList = NSHomeDirectory().appending("/Library/PDFKitResources/Stamp/stamp_image.plist")

enum PDFStampCustomType: Int {
    case text
    case image
}

class CStampFileManager: NSObject {
    var stampTextList: [NSDictionary] = []
    var stampImageList: [NSDictionary] = []
    var deleteList: [NSDictionary] = []
    
    // MARK: - Init Method
    
    override init() {
        super.init()
        deleteList = []
    }
    
    func getDateTime() -> String {
        let timename = NSTimeZone.system
        let outputFormatter = DateFormatter()
        outputFormatter.timeZone = timename
        var tDate: String? = nil
        
        outputFormatter.dateFormat = "YYYYMMddHHmmss"
        tDate = outputFormatter.string(from: Date())
        
        return tDate ?? ""
        
    }
    
    // MARK: - File Manager
    
    func readStampDataFromFile() {
        readCustomStamp_TextStamp()
        readCustomStamp_ImageStamp()
    }
    
    func readCustomStamp_TextStamp() {
        let tManager = FileManager.default
        if !tManager.fileExists(atPath: kPDFStampTextList) {
            stampTextList = []
        } else {
            if !stampTextList.isEmpty {
                stampTextList = []
            }
            stampTextList = (NSMutableArray(contentsOfFile: kPDFStampTextList) as? [NSDictionary]) ?? []
            if stampTextList.isEmpty {
                stampTextList = []
            }
        }
        
    }
    
    func readCustomStamp_ImageStamp() {
        let tManager = FileManager.default
        if !tManager.fileExists(atPath: kPDFStampImageList) {
            stampImageList = []
        } else {
            if !stampImageList.isEmpty {
                stampImageList = []
            }
            stampImageList = NSMutableArray(contentsOfFile: kPDFStampImageList) as? [NSDictionary] ?? []
            if stampImageList.isEmpty {
                stampImageList = []
            }
        }
        
    }
    
    
    func getTextStampData() -> [Any] {
        return stampTextList
    }
    
    func getImageStampData() -> [Any] {
        return stampImageList
    }
    
    func saveStamp(with image: UIImage) -> String? {
        let tManager = FileManager.default
        guard let imageData = image.pngData() else {
            return nil
        }
        if imageData.isEmpty {
            return nil
        }
        
        let tName = getDateTime()
        let tPath = kPDFStampDataFolder.appending("/\(tName).png")
        
        if (imageData as NSData).write(toFile: tPath, atomically: false) {
            return tPath
        } else {
            var tPathDic = kPDFStampDataFolder
            var tIsDirectory = ObjCBool(false)
            while true {
                if tManager.fileExists(atPath: tPathDic, isDirectory: &tIsDirectory) {
                    if tIsDirectory.boolValue {
                        break
                    }
                } else {
                    try? tManager.createDirectory(atPath: tPathDic, withIntermediateDirectories: true, attributes: nil)
                }
                tPathDic = (tPathDic as NSString).deletingLastPathComponent
            }
            
            if (imageData as NSData).write(toFile: tPath, atomically: false) {
                return tPath
            }
        }
        
        return nil
        
    }
    
    func removeStampImage() {
        for tDict in deleteList {
            if let tPath = tDict["path"] as? String {
                let tFileManager = FileManager.default
                try? tFileManager.removeItem(atPath: tPath)
            }
        }
    }
    
    
    func saveStampDataToFile(stampType: PDFStampCustomType) -> Bool {
        let tManager = FileManager.default
        switch stampType {
        case .text:
            let array = NSMutableArray(array: stampTextList)

            if array.write(toFile: kPDFStampTextList, atomically: false) {
                return true
            } else {
                var tPathDic = kPDFStampTextList
                var tIsDirectory = ObjCBool(false)
                while true {
                    tPathDic = (tPathDic as NSString).deletingLastPathComponent
                    if tManager.fileExists(atPath: tPathDic, isDirectory: &tIsDirectory) {
                        if tIsDirectory.boolValue {
                            break
                        }
                    } else {
                        try? tManager.createDirectory(atPath: tPathDic, withIntermediateDirectories: true, attributes: nil)
                    }
                   
                }
                let array = NSMutableArray(array: stampTextList)

                if array.write(toFile: kPDFStampTextList, atomically: false) {
                    return true
                }
            }
            return false
            
        case .image:
            let array = NSMutableArray(array: stampImageList)

            if array.write(toFile: kPDFStampImageList, atomically: false) {
                return true
            } else {
                var tPathDic = kPDFStampImageList
                var tIsDirectory = ObjCBool(false)
                while true {
                    tPathDic = (tPathDic as NSString).deletingLastPathComponent
                    if tManager.fileExists(atPath: tPathDic, isDirectory: &tIsDirectory) {
                        if tIsDirectory.boolValue {
                            break
                        }
                    } else {
                        try? tManager.createDirectory(atPath: tPathDic, withIntermediateDirectories: true, attributes: nil)
                    }
                }
                let array = NSMutableArray(array: stampImageList)

                if array.write(toFile: kPDFStampImageList, atomically: false) {
                    return true
                }
            }
            return false
            
        }
        
    }
    
    func insertStampItem(_ stampItem: NSDictionary, type stampType: PDFStampCustomType) -> Bool {
        switch stampType {
        case .text:
            if stampTextList.isEmpty {
                readCustomStamp_TextStamp()
            }
            if stampItem is [AnyHashable: Any] {
                let array = NSMutableArray(array: stampTextList)

                array.insert(stampItem, at: 0)
                stampTextList = array as? [NSDictionary] ?? []
                if saveStampDataToFile(stampType: .text) {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
            
        case .image:
            if stampImageList.isEmpty {
                readCustomStamp_ImageStamp()
            }
            
            if let item = stampItem as? [AnyHashable: Any] {
                let array = NSMutableArray(array: stampImageList)
                array.insert(item, at: 0)
                stampImageList = array as? [NSDictionary] ?? []

                if saveStampDataToFile(stampType: .image) {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
            
        }
        
    }
    
    
    func removeStampItem(index: Int, stampType: PDFStampCustomType) -> Bool {
        switch stampType {
        case .text:
            if stampTextList.isEmpty {
                readCustomStamp_TextStamp()
            }
            if index >= 0 && index <= stampTextList.count {
                stampTextList.remove(at: index)
                if saveStampDataToFile(stampType: .text) {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
            
        case .image:
            if stampImageList.isEmpty {
                readCustomStamp_ImageStamp()
            }
            if index >= 0 && index < stampImageList.count {
                if deleteList.isEmpty {
                    deleteList = []
                }
                if let tDict = stampImageList[index] as? [AnyHashable: Any] {
                    let array = NSMutableArray(array: deleteList)

                    array.add(tDict)
                    deleteList = array as? [NSDictionary] ?? []
                }
                
                stampImageList.remove(at: index)
                if saveStampDataToFile(stampType: .image) {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
            
        }
        
    }
    
}

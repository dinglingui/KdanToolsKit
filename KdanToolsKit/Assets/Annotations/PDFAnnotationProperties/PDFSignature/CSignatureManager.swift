//
//  CSignatureManager.swift
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

let kPDFSignatureDataFileName = "PDFKitResources/Signature/PDFSignatureData.plist"
let kPDFSignatureImageFolder = "PDFKitResources/Signature/PDFSignatureImageFolder"

class CSignatureManager {
    var signatures: [String] = []
    
    static let sharedManager = CSignatureManager()
    
    private init() {
        let library = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first ?? ""
        let filePath = (library as NSString).appendingPathComponent(kPDFSignatureDataFileName)
        let folderPath = (library as NSString).appendingPathComponent(kPDFSignatureImageFolder)
        if FileManager.default.fileExists(atPath: filePath) {
            var signatures = [String]()
            if let fileNames = NSArray(contentsOfFile: filePath) as? [String] {
                for fileName in fileNames {
                    signatures.append((folderPath as NSString).appendingPathComponent(fileName))
                }
            }
            self.signatures = signatures
        } else {
            self.signatures = []
        }
    }
    
    func randomString() -> String {
        let cfuuid = CFUUIDCreate(kCFAllocatorDefault)
        let cfstring = CFUUIDCreateString(kCFAllocatorDefault, cfuuid) as String
        
        return cfstring
    }
    
    func save() {
        let library = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: "")
        let filePath = library.appendingPathComponent(kPDFSignatureDataFileName).path
        if FileManager.default.fileExists(atPath: filePath) {
            try? FileManager.default.removeItem(atPath: filePath)
        }
        var fileNames = [String]()
        for filePath in signatures {
            fileNames.append(URL(fileURLWithPath: filePath).lastPathComponent)
        }
        if fileNames.count > 0 {
            (fileNames as NSArray).write(toFile: filePath, atomically: true)
        }
    }
    
    func addImageSignature(_ image: UIImage?) {
        let library = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: "")
        let folderPath = library.appendingPathComponent(kPDFSignatureImageFolder).path
        let randomStr = self.randomString()
        if let image = image {
            if !FileManager.default.fileExists(atPath: folderPath) {
                try? FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
            }
            let imageName = randomStr.appending(".png")
            let imagePath = (folderPath as NSString).appendingPathComponent(imageName)
            if let imageData = image.pngData() {
                if (try? imageData.write(to: URL(fileURLWithPath: imagePath))) != nil {
                    var array = self.signatures
                    array.insert(imagePath, at: 0)
                    self.signatures = array
                    self.save()
                }
            }
        }
    }
    
    func addTextSignature(_ text: String) {
        var array = self.signatures
        array.insert(text, at: 0)
        self.signatures = array
        self.save()
    }
    
    func removeSignatures(at indexes: IndexSet) {
        let signaturesToRemove = self.signatures.enumerated().filter { indexes.contains($0.offset) }.map { $0.element }
        for filePath in signaturesToRemove {
            try? FileManager.default.removeItem(atPath: filePath)
        }
        
        var array = NSMutableArray(array: self.signatures)
        let indexesToRemove = IndexSet(indexes)
        array.removeObjects(at: indexesToRemove)
        self.signatures = array as? [String] ?? []
        
        self.save()
    }
    
    func removeSignature(at row: Int) {
        var array = self.signatures
        array.remove(at: row)
        self.signatures = array
        self.save()
    }
    
}



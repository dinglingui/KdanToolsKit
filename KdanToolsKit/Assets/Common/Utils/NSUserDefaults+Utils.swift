//
//  NSUserDefaults+Utils.swift
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import Foundation
import UIKit

extension UserDefaults {
    func PDFListViewColorForKey(_ key: String) -> UIColor? {
        if let colorString = self.object(forKey: key) {
            if let data = colorString as? Data {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? UIColor
            } else if let string = colorString as? String {
                return UserDefaults.colorWithHexString(string)
            }
        }
        return nil
    }
    
    func setPDFListViewColor(_ color: UIColor?, forKey key: String) {
        guard let color = color else {
            self.removeObject(forKey: key)
            return
        }
        
        let colorString = UserDefaults.hexStringWithAlphaColor(color)
        self.set(colorString, forKey: key)
        self.synchronize()
    }
    
    static func hexStringWithAlphaColor(_ color: UIColor) -> String? {
        guard let colorStr = UserDefaults.hexStringWithColor(color) else { return "" }
        var a: CGFloat = 1.0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let alphaStr = UserDefaults.getHexByDecimal(Int(a) * 255)
        var finalAlphaStr = alphaStr
        if alphaStr.count < 2 {
            finalAlphaStr = "0" + alphaStr
        }
        
        return "#" + finalAlphaStr + colorStr
    }
    
    static func hexStringWithColor(_ color: UIColor) -> String? {
        guard let components = color.cgColor.components else {
            return nil
        }
        
        let r = components[0]
        let g = components[1]
        let b = components[2]
        
        return String(format: "%@%@%@", UserDefaults.colorString(withValue: r), UserDefaults.colorString(withValue: g), UserDefaults.colorString(withValue: b))
    }
    
    static func colorString(withValue value: CGFloat) -> String {
        let str = UserDefaults.getHexByDecimal(Int(value * 255))
        if str.count < 2 {
            return "0" + str
        }
        return str
    }
    
    static func getHexByDecimal(_ decimal: Int) -> String {
        var hex = ""
        var number = decimal
        var letter: String
        var decimalz = decimal
        for _ in 0..<9 {
            number = decimalz % 16
            decimalz = decimalz / 16
            
            switch number {
            case 10:
                letter = "A"
            case 11:
                letter = "B"
            case 12:
                letter = "C"
            case 13:
                letter = "D"
            case 14:
                letter = "E"
            case 15:
                letter = "F"
            default:
                letter = String(number)
            }
            
            hex = letter + hex
            
            if decimalz == 0 {
                break
            }
        }
        
        return hex
    }
    
    static func colorWithHexString(_ hexStr: String) -> UIColor? {
        var cString = hexStr.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // String should be 6 or 8 characters
        if cString.count < 6 {
            return nil
        }
        
        if cString.hasPrefix("0X") {
            cString = String(cString.dropFirst(2))
        }
        
        if cString.hasPrefix("#") {
            cString = String(cString.dropFirst())
        }
        
        if cString.count < 6 {
            return nil
        }
        
        if cString.count == 6 {
            let rRange = cString.startIndex ..< cString.index(cString.startIndex, offsetBy: 2)
            let rString = cString.substring(with: rRange)

            let gRange = cString.index(cString.startIndex, offsetBy: 2) ..< cString.index(cString.startIndex, offsetBy: 4)
            let gString = cString.substring(with: gRange)

            let bRange = cString.index(cString.startIndex, offsetBy: 4) ..< cString.index(cString.startIndex, offsetBy: 6)
            let bString = cString.substring(with: bRange)

            
            var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0

            Scanner(string: rString).scanHexInt32(&r)

            Scanner(string: gString).scanHexInt32(&g)

            Scanner(string: bString).scanHexInt32(&b)
            
            var alpha: CUnsignedInt = 255
            
            return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(alpha) / 255.0)
        } else if cString.count == 8 {
            let aRange = cString.startIndex ..< cString.index(cString.startIndex, offsetBy: 2)
            let aString = cString.substring(with: aRange)
            
            let rRange = cString.index(cString.startIndex, offsetBy: 2) ..< cString.index(cString.startIndex, offsetBy: 4)
            let rString = cString.substring(with: rRange)

            let gRange = cString.index(cString.startIndex, offsetBy: 4) ..< cString.index(cString.startIndex, offsetBy: 6)
            let gString = cString.substring(with: gRange)

            let bRange = cString.index(cString.startIndex, offsetBy: 6) ..< cString.index(cString.startIndex, offsetBy: 8)
            let bString = cString.substring(with: bRange)

            
            var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0, a:CUnsignedInt = 0

            Scanner(string: rString).scanHexInt32(&r)

            Scanner(string: gString).scanHexInt32(&g)

            Scanner(string: bString).scanHexInt32(&b)
            
            Scanner(string: aString).scanHexInt32(&a)
            
            return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
        } else {
            return nil
        }
        
    }
}

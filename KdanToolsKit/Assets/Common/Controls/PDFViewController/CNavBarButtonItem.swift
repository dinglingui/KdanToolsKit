//
//  CNavBarButtonItem.swift
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

public enum CPDFViewBarLeftButtonItem: Int {
    case back = 1
    case thumbnail = 2
}

public enum CPDFViewBarRightButtonItem: Int {
    case search = 4
    case bota = 8
    case more = 16
}


public class CNavBarButtonItem: NSObject {
    
    public var leftBarItem:CPDFViewBarLeftButtonItem = .back
    public var rightBarItem:CPDFViewBarRightButtonItem = .search

    public init(viewLeftBarButtonItem: CPDFViewBarLeftButtonItem) {
        super.init()
        self.leftBarItem = viewLeftBarButtonItem
    }

    public init(viewRightBarButtonItem: CPDFViewBarRightButtonItem) {
        super.init()
        self.rightBarItem = viewRightBarButtonItem
    }

}

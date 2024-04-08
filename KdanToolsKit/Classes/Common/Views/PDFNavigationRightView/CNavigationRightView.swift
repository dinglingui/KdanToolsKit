//
//  CNavigationRightView.swift
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

enum CNavigationRightType: Int {
    case Search = 0
    case Bota
    case More
}

// MARK: - CNavigationRightAction
class CNavigationRightAction:NSObject {
    let image: UIImage?
    let tag: CNavigationRightType?
    
    init(image: UIImage, tag: CNavigationRightType) {
        self.image = image
        self.tag = tag
    }
    
    static func action(with image: UIImage, tag: CNavigationRightType) -> CNavigationRightAction {
        return CNavigationRightAction(image: image, tag: tag)
    }
}

// MARK: - CNavigationRightView

class CNavigationRightView: UIView {

    typealias Clickback = (CNavigationRightType) -> Void

    var clickBack: Clickback?

    var dataArray: [CNavigationRightAction]?
    
    init(rightActions: [CNavigationRightAction], clickBack: ((CNavigationRightType) -> Void)?) {
        super.init(frame: CGRect.zero)
        self.dataArray = rightActions
        
        configurationUI()
        self.clickBack = clickBack
    }

    init(defaultItemsClickBack clickBack: ((CNavigationRightType) -> Void)?) {
        super.init(frame: CGRect.zero)
        let nums = defaultItems()
        var actions = [CNavigationRightAction]()
        
        for num in nums {
            var imageName: String?
            
            switch num {
            case .Search:
                imageName = "CNavigationImageNameSearch"
            case .Bota:
                imageName = "CNavigationImageNameBota"
            case .More:
                imageName = "CNavigationImageNameMore"
            }
            
            if let imageName = imageName,
               let image = UIImage(named: imageName, in: Bundle(for: self.classForCoder), compatibleWith: nil) {
                let action = CNavigationRightAction(image: image, tag: num)
                actions.append(action)
            }
        }
        
        self.dataArray = actions
        configurationUI()
        self.clickBack = clickBack
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func defaultItems() -> [CNavigationRightType] {
        return [.Search, .Bota, .More]
    }
    
    private func configurationUI() {
        var offset: CGFloat = 20
        if UI_USER_INTERFACE_IDIOM() == .pad {
            offset = 20
        }
        var height: CGFloat = 0
        var width: CGFloat = offset

        for i in 0..<(dataArray?.count ?? 0) {
            let rightAction = dataArray?[i]
            let image = rightAction?.image
            if image != nil {
                height = max(height, image!.size.height)

                if i == 0 {
                    width = 0
                }

                let button = UIButton(frame: CGRect(x: width, y: 0, width: image!.size.width, height: image!.size.height))
                button.setImage(image, for: .normal)
                button.tag = (rightAction?.tag)?.rawValue ?? 0
                button.addTarget(self, action: #selector(buttonClickItem(_:)), for: .touchUpInside)
                addSubview(button)
                
                if i == (dataArray?.count ?? 0) - 1 {
                    width += 0
                } else {
                    width += (button.frame.size.width + offset)
                }
            }
        }
        
        self.bounds = CGRect(x: 0, y: 0, width: width + offset, height: height)
    }

    @IBAction private func buttonClickItem(_ sender: UIButton) {
        let tag = sender.tag
        
        if let clickBack = self.clickBack {
            clickBack(CNavigationRightType(rawValue: tag) ?? .Search)
        }
    }

}

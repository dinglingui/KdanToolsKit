//
//  CShapeSelectView.swift
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

enum CShapeSelectType: Int {
    case square = 0
    case circle
    case arrow
    case line
}

@objc protocol CShapeSelectViewDelegate: AnyObject {
    @objc optional func shapeSelectView(_ shapeSelectView: CShapeSelectView, tag: Int)
}

class CShapeSelectView: UIView {
    weak var delegate: CShapeSelectViewDelegate?
    
    private var buttonArray: [UIButton] = []
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let squareButton = UIButton()
        squareButton.setImage(UIImage(named: "CPDFShapeArrowImageSquare", in: Bundle(for: Self.self), compatibleWith: nil), for: .normal)
        squareButton.addTarget(self, action: #selector(buttonItemClicked(_:)), for: .touchUpInside)
        squareButton.tag = CShapeSelectType.square.rawValue
        addSubview(squareButton)
        buttonArray.append(squareButton)
        
        let circleButton = UIButton()
        circleButton.setImage(UIImage(named: "CPDFShapeArrowImageCircle", in: Bundle(for: Self.self), compatibleWith: nil), for: .normal)
        circleButton.addTarget(self, action: #selector(buttonItemClicked(_:)), for: .touchUpInside)
        circleButton.tag = CShapeSelectType.circle.rawValue
        addSubview(circleButton)
        buttonArray.append(circleButton)
        
        let arrowButton = UIButton()
        arrowButton.setImage(UIImage(named: "CPDFShapeArrowImageArrow", in: Bundle(for: Self.self), compatibleWith: nil), for: .normal)
        arrowButton.addTarget(self, action: #selector(buttonItemClicked(_:)), for: .touchUpInside)
        arrowButton.tag = CShapeSelectType.arrow.rawValue
        addSubview(arrowButton)
        buttonArray.append(arrowButton)
        
        let lineButton = UIButton()
        lineButton.setImage(UIImage(named: "CPDFShapeArrowImageLine", in: Bundle(for: Self.self), compatibleWith: nil), for: .normal)
        lineButton.addTarget(self, action: #selector(buttonItemClicked(_:)), for: .touchUpInside)
        lineButton.tag = CShapeSelectType.line.rawValue
        addSubview(lineButton)
        buttonArray.append(lineButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for (i, button) in buttonArray.enumerated() {
            button.frame = CGRect(x: (bounds.size.width - (bounds.size.height * 4))/5 * CGFloat(i+1) + bounds.size.height * CGFloat(i), y: 0, width: bounds.size.height, height: bounds.size.height)
        }
    }

    // MARK: - Action
    
    @objc func buttonItemClicked(_ button: UIButton) {
        for btn in buttonArray {
            btn.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        }
        buttonArray[button.tag].backgroundColor = CPDFColorUtils.CAnnotationBarSelectBackgroundColor()

        delegate?.shapeSelectView?(self, tag: button.tag)
    }
    
}
        
        
        

//
//  CWatermarkPreView.swift
//  PDFViewer-Swift
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import UIKit

@objc protocol CTextWatermarkPreViewDelegate: AnyObject {
    @objc optional func textWatermarkPreViewRotate(_ textWatermarkPreView: CTextWatermarkPreView)
}

class CTextWatermarkPreView: UIView {
    
    var documentSize: CGSize?
    var documentView: UIImageView?
    var textTileView: CTileWatermarkPreView?
    var preLabel: UILabel?
    var rotationBtn: UIButton?
    
    // MARK: - Action
    
    init(frame: CGRect, Image image: UIImage?) {
        super.init(frame: frame)
        
        documentView = UIImageView(image: image)
        if documentView != nil {
            addSubview(documentView!)
        }
        
        textTileView = CTileWatermarkPreView(frame: .zero)
        textTileView?.backgroundColor = .clear
        textTileView?.isUserInteractionEnabled = false
        textTileView?.isHidden = true
        if textTileView != nil {
            documentView?.addSubview(textTileView!)
        }
        
        rotationBtn = UIButton(type: .custom)
        rotationBtn?.translatesAutoresizingMaskIntoConstraints = false
        rotationBtn?.setImage(UIImage(named: "CWatermarkPreViewRatoteIamge", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        rotationBtn?.addTarget(self, action: #selector(buttonItemClicked_rotate), for: .touchUpInside)
        
        preLabel = UILabel()
        preLabel?.textAlignment = .center
        preLabel?.layer.borderWidth = 1.0
        preLabel?.layer.borderColor = UIColor.blue.cgColor
        preLabel?.font = UIFont.systemFont(ofSize: 24)
        preLabel?.text = NSLocalizedString("Watermark", comment: "")
        preLabel?.textColor = .black
        preLabel?.sizeToFit()
        preLabel?.backgroundColor = UIColor.white
        
        textTileView?.waterString = preLabel?.text
        textTileView?.setNeedsDisplay()
        
        if preLabel != nil {
            documentView?.addSubview(preLabel!)
        }
        
        if rotationBtn != nil {
            documentView?.addSubview(rotationBtn!)
        }
        
        backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = (bounds.size.width - (documentSize?.width ?? 0))/2
        let height = (bounds.size.height - (documentSize?.height ?? 0))/2
        documentView?.frame = CGRect(x: width, y: height, width: documentSize?.width ?? 0, height: (documentSize?.height ?? 0) - 20)
        let x = Int((documentView?.bounds.width ?? 100))/2
        let y = Int((documentView?.bounds.width ?? 50))/4
      
        preLabel?.center = CGPoint(x: x, y: y)
        rotationBtn?.size = CGSize(width: 20, height: 20)
        
        textTileView?.frame = documentView?.bounds ?? .zero
        textTileView?.centerPoint = preLabel?.center ?? .zero
        textTileView?.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        rotationBtn?.center = leftBottom(view: preLabel!)
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_rotate(_ sender: UIButton) {
        
    }
    
    func leftBottom(view: UIView) -> CGPoint {
        let transform = view.transform
        let scale = sqrt(transform.a * transform.a + transform.c * transform.c) // scaleX
        let angle = atan2(transform.b, transform.a)
        let originVector = CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2)
        let rotateVector = CGPoint(x: originVector.x * cos(angle) + originVector.y * sin(angle), y: originVector.y * cos(angle) - originVector.x * sin(angle))
        let scaleVector = CGPoint(x: rotateVector.x * scale, y: rotateVector.y * scale)
        return CGPoint(x: view.center.x - scaleVector.x, y: view.center.y + scaleVector.y)
    }
    
}

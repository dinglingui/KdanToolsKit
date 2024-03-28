//
//  CImageWatermarkPreView.swift
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

class CImageWatermarkPreView: UIView {

    var documentSize: CGSize?
    var documentView: UIImageView?
    var preImageView: UIImageView?
    var rotationBtn: UIButton?
    var preLayer: CALayer?
    var imageTileView: CTileWatermarkPreView?
    
    init(frame: CGRect, Image image: UIImage?) {
        super.init(frame: frame)
        
        documentView = UIImageView(image: image)
        if documentView != nil {
            addSubview(documentView!)
        }
        
        imageTileView = CTileWatermarkPreView(frame: .zero)
        imageTileView?.backgroundColor = .clear
        imageTileView?.isUserInteractionEnabled = false
        imageTileView?.isHidden = true
        if imageTileView != nil {
            documentView?.addSubview(imageTileView!)
        }
        
        rotationBtn = UIButton(type: .custom)
        rotationBtn?.translatesAutoresizingMaskIntoConstraints = false
        rotationBtn?.setImage(UIImage(named: "CWatermarkPreViewRatoteIamge", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        rotationBtn?.addTarget(self, action: #selector(buttonItemClicked_rotate), for: .touchUpInside)
   
        
        preImageView = UIImageView()
        preImageView?.layer.borderColor = UIColor.blue.cgColor
        preImageView?.layer.borderWidth = 1.0
        preImageView?.sizeToFit()
        preImageView?.backgroundColor = UIColor.white
        
        if preImageView != nil {
            documentView?.addSubview(preImageView!)
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
        let x = Int((documentView?.bounds.width ?? 60))/2
        let y = Int((documentView?.bounds.width ?? 60))/4
        preImageView?.center = CGPoint(x: x, y: y)
        
        rotationBtn?.size = CGSize(width: 20, height: 20)

        imageTileView?.frame = documentView?.bounds ?? .zero
        imageTileView?.centerPoint = preImageView?.center ?? .zero
        imageTileView?.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        rotationBtn?.center = leftBottom(view: preImageView!)
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

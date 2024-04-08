//
//  CPDFPageEditViewCell.swift
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

class CPDFPageEditViewCell: UICollectionViewCell {
    var textLabel: UILabel?
    var imageView: UIImageView?
    var imageSize: CGSize = CGSize.zero
    
    private var selectButton: UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView()
        imageView?.layer.borderWidth = 1.0
        imageView?.layer.borderColor = UIColor(red: 221/255.0, green: 233/255.0, blue: 255/255.0, alpha: 1.0).cgColor
        if(imageView != nil) {
            contentView.addSubview(imageView!)
        }
        textLabel = UILabel(frame: CGRect(x: 0, y: frame.size.height - 12, width: frame.size.width, height: 12))
        textLabel?.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        textLabel?.textAlignment = .center
        textLabel?.font = UIFont.systemFont(ofSize: 13)
        textLabel?.textColor = UIColor.black
        if(textLabel != nil) {
            contentView.addSubview(textLabel!)
        }
        
        selectButton = UIButton(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
        selectButton?.isSelected = isSelected
        selectButton?.setImage(UIImage(named: "CPageEditToolBarImageSelectOff", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        selectButton?.setImage(UIImage(named: "CPageEditToolBarImageSelectOn", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .selected)
        if(selectButton != nil) {
            imageView?.addSubview(selectButton!)
        }
        selectButton?.isHidden = true
        
        imageView?.isUserInteractionEnabled = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.frame = CGRect(x: (frame.size.width - imageSize.width)/2, y: (frame.size.height - 14 - imageSize.height) / 2, width: imageSize.width, height: imageSize.height)
        
        let startW = textLabel?.text?.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10)]).width ?? 0
        textLabel?.frame = CGRect(x: frame.size.width/2 - (startW + 20)/2, y: imageSize.height + (frame.size.height - 14 - imageSize.height) / 2, width: startW + 20, height: 12)
        
    }
    
    func setEdit(_ editing: Bool) {
        selectButton?.isHidden = !editing
        layoutSubviews()
    }
    
    func setPageRef(_ pageRef: CGPDFPage?) {
        var boxRect = CGRect.zero
        if let pageRef = pageRef {
            boxRect = pageRef.getBoxRect(.cropBox)
            let displayBounds = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height - 12)
            let transform = pageRef.getDrawingTransform(.cropBox, rect: displayBounds, rotate: 0, preserveAspectRatio: true)
            boxRect = boxRect.applying(transform)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            
            if isSelected {
                textLabel?.backgroundColor = UIColor(red: 20/255, green: 96/255, blue: 243/255, alpha: 1)
                textLabel?.textColor = UIColor.white
                imageView?.layer.borderColor = UIColor(red: 20/255, green: 96/255, blue: 243/255, alpha: 1).cgColor
                imageView?.layer.borderWidth = 2
                imageView?.layer.cornerRadius = 4
                imageView?.clipsToBounds = true
                
            } else {
                textLabel?.backgroundColor = UIColor.clear
                textLabel?.textColor = UIColor.black
                imageView?.layer.borderColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1).cgColor
                imageView?.layer.borderWidth = 1
            }
            
            selectButton?.isSelected = isSelected
            super.isSelected = isSelected
        }
    }
    
}

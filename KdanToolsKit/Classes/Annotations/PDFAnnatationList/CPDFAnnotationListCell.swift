//
//  CPDFAnnotationListCellTableViewCell.swift
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

class CPDFAnnotationListCell: UITableViewCell {
    
    var typeImageView:UIImageView?
    var dateLabel:UILabel?
    var contentLabel:UILabel?
    var annot:CPDFAnnotation?
    
    var pageNumber: Int = 0 {
        didSet {
            dateLabel?.text = NSLocalizedString("Loading…", comment: "")
            contentLabel?.text = ""
            typeImageView?.image = nil
        }
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clear
        typeImageView = UIImageView(frame: CGRect.zero)
        typeImageView?.frame = CGRect(x: 15.0, y: 18.0, width: 20, height: 20)
        typeImageView?.image = UIImage(named: "CImageNamePDFAnnotationShapeCircle", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        
        dateLabel = UILabel(frame: CGRect.zero)
        dateLabel?.font = UIFont.systemFont(ofSize: 12.0)
        if #available(iOS 13.0, *) {
            dateLabel?.textColor = UIColor.secondaryLabel
        } else {
            dateLabel?.textColor = UIColor.black
        }
        dateLabel?.minimumScaleFactor = 0.5
        dateLabel?.numberOfLines = 1
        dateLabel?.adjustsFontSizeToFitWidth = true
        dateLabel?.textAlignment = .left
        dateLabel?.backgroundColor = UIColor.clear
        
        contentLabel = UILabel(frame: CGRect.zero)
        if #available(iOS 13.0, *) {
            contentLabel?.textColor = UIColor.secondaryLabel
        } else {
            contentLabel?.textColor = UIColor.black
        }
        contentLabel?.lineBreakMode = .byTruncatingTail
        contentLabel?.numberOfLines = 3
        contentLabel?.font = UIFont.systemFont(ofSize: 15.0)
        contentLabel?.backgroundColor = UIColor.clear
        
        if(typeImageView != nil) {
            self.contentView.addSubview( typeImageView!)
        }
        if(dateLabel != nil) {
            self.contentView.addSubview( dateLabel!)
        }
        if(contentLabel != nil) {
            self.contentView.addSubview(contentLabel!)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dateLabel?.frame = CGRect(x: 43.0, y: 18, width: self.contentView.frame.size.width - 43 - 15.0, height: 20)
        
        contentLabel?.frame = CGRect(x: 15, y: 51, width: self.contentView.frame.size.width - 30, height: contentLabel?.frame.size.height ?? 0)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateCell(with annotation: CPDFAnnotation?) {
        self.annot = annotation
        
        guard let annotation = annotation else {
            return
        }
        
        setTypeImage(annotation)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        if let date = annotation.modificationDate() {
            dateLabel?.text = formatter.string(from: date)
        }
        
        if let markupAnnotation = annotation as? CPDFMarkupAnnotation {
            let text:String = markupAnnotation.markupText()
            if text.count > 0 {
                contentLabel?.isHidden = false
                contentLabel?.text = text
            } else {
                let page = annotation.page
                var exproString: String?
                if let points = markupAnnotation.quadrilateralPoints {
                    let count = 4
                    var i = 0
                    while i + count <= points.count {
                        let ptlt = points[i] as? CGPoint
                        let ptrt = points[i+1] as? CGPoint
                        let ptlb = points[i+2] as? CGPoint
                        let ptrb = points[i+3] as? CGPoint
                        
                        let rect = CGRect(x: ptlb?.x ?? 0, y: ptlb?.y ?? 0, width: (ptrt?.x ?? 0) - (ptlb?.x ?? 0), height: (ptrt?.y ?? 0) - (ptlb?.y ?? 0))
                        let tString = page?.string(for: rect)
                        if let tString = tString, !tString.isEmpty {
                            if exproString?.count ?? 0 > 0 {
                                exproString = "\(String(describing: exproString))\n\(tString)"
                            } else {
                                exproString = tString
                            }
                        }
                        
                        i += count
                    }
                }
                
                if let exproString = exproString, !exproString.isEmpty {
                    contentLabel?.isHidden = false
                    contentLabel?.text = exproString
                } else {
                    contentLabel?.isHidden = true
                }
            }
        } else {
            if let contents = annotation.contents, !contents.isEmpty {
                let contextArray = contents.components(separatedBy: "\n")
                if contextArray.count > 3 {
                    var newContents = ""
                    for i in 0..<2 {
                        newContents = "\(newContents)\(contextArray[i])\n"
                    }
                    contentLabel?.isHidden = false
                    contentLabel?.text = "\(newContents)..."
                } else {
                    contentLabel?.isHidden = false
                    contentLabel?.text = annotation.contents
                }
            } else {
                contentLabel?.isHidden = true
            }
        }
        
        contentLabel?.sizeToFit()
        dateLabel?.sizeToFit()
        
    }
    
    func setTypeImage(_ annot: CPDFAnnotation) {
        for subView in typeImageView?.subviews ?? [] {
            subView.removeFromSuperview()
        }
        if annot is CPDFCircleAnnotation {
            typeImageView?.image = UIImage(named: "CImageNamePDFAnnotationShapeCircle", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        } else if annot is CPDFFreeTextAnnotation {
            typeImageView?.image = UIImage(named: "CImageNamePDFAnnotationText", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        } else if annot is CPDFInkAnnotation {
            DispatchQueue.main.async {
                let color = annot.color
                let drawView = self.getTextMarkColorView(annotation: annot, size: self.typeImageView?.bounds.size ?? CGSize.zero, color: color ?? UIColor.clear)
                self.typeImageView?.addSubview(drawView)
                self.typeImageView?.image = UIImage(named: "CImageNamePDFAnnotationFreehand", in: Bundle(for: self.classForCoder), compatibleWith: nil)
            }
        } else if annot is CPDFLineAnnotation {
            if let lineAnnotation = annot as? CPDFLineAnnotation {
                if lineAnnotation.startLineStyle == .closedArrow || lineAnnotation.endLineStyle == .closedArrow {
                    typeImageView?.image = UIImage(named: "CImageNamePDFAnnotationShapeArrow", in: Bundle(for: self.classForCoder), compatibleWith: nil)
                } else {
                    typeImageView?.image = UIImage(named: "CImageNamePDFAnnotationShapeLine", in: Bundle(for: self.classForCoder), compatibleWith: nil)
                }
            }
        } else if annot is CPDFLinkAnnotation {
            // do nothing
        } else if annot is CPDFSoundAnnotation || annot is CPDFMovieAnnotation {
            typeImageView?.image = UIImage(named: "CImageNamePDFAnnotationRecord", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        } else if annot is CPDFTextAnnotation {
            typeImageView?.image = UIImage(named: "CImageNamePDFAnnotationNote", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        } else if annot is CPDFSquareAnnotation {
            typeImageView?.image = UIImage(named: "CImageNamePDFAnnotationShapeRectangle", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        } else if annot is CPDFStampAnnotation {
            if let stampAnnotation = annot as? CPDFStampAnnotation {
                if stampAnnotation.stampType() == .image {
                    typeImageView?.image = UIImage(named: "CImageNamePDFAnnotationPhoto", in: Bundle(for: self.classForCoder), compatibleWith: nil)
                } else {
                    typeImageView?.image = UIImage(named: "CImageNamePDFAnnotationStamp", in: Bundle(for: self.classForCoder), compatibleWith: nil)
                }
            }
        } else if annot is CPDFMarkupAnnotation {
            if let markupAnnotation = annot as? CPDFMarkupAnnotation {
                let color = markupAnnotation.color
                let markupType = markupAnnotation.markupType()
                switch markupType {
                case .highlight:
                    typeImageView?.image = UIImage(named: "CImageNamePDFAnnotationHighlight", in: Bundle(for: self.classForCoder), compatibleWith: nil)
                case .underline:
                    typeImageView?.image = UIImage(named: "CImageNamePDFAnnotationUnderline", in: Bundle(for: self.classForCoder), compatibleWith: nil)
                case .strikeOut:
                    typeImageView?.image = UIImage(named: "CImageNamePDFAnnotationStrikethrough", in: Bundle(for: self.classForCoder), compatibleWith: nil)
                case .squiggly:
                    typeImageView?.image = UIImage(named: "CImageNamePDFAnnotationUnderline", in: Bundle(for: self.classForCoder), compatibleWith: nil)
                default:
                    break
                }
                
                DispatchQueue.main.async {
                    if let annot = annot as? CPDFMarkupAnnotation {
                        let drawView = self.getTextMarkColorView(annotation: annot, size: self.typeImageView?.bounds.size ?? CGSize.zero, color: color ?? UIColor.clear)
                        self.typeImageView?.addSubview(drawView)
                    }
                }

            }
        } else if annot is CPDFSignatureAnnotation {
            self.typeImageView?.image = UIImage(named: "CImageNamePDFAnnotationSign", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        }
    }
    
    func getTextMarkColorView(annotation: CPDFAnnotation, size: CGSize, color: UIColor) -> CPDFAnnotionColorDrawView {
        var markupType: CPDFAnnotionMarkUpType = .highlight
        let drawView = CPDFAnnotionColorDrawView(frame: CGRect.zero)
        drawView.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        var tHeight: CGFloat = 20
        let tWidth: CGFloat = 20
        let tOffsetX = (size.width - tWidth) / 2
        
        if let markupAnnotation = annotation as? CPDFMarkupAnnotation {
            let type = markupAnnotation.markupType()
            switch type {
            case .highlight:
                markupType = .highlight
                drawView.frame = CGRect(x: tOffsetX, y: (size.height - tHeight) / 2, width: tWidth, height: tHeight)
            case .underline:
                markupType = .underline
                tHeight = 2.0
                drawView.frame = CGRect(x: tOffsetX, y: size.height - tHeight, width: tWidth, height: tHeight)
            case .strikeOut:
                markupType = .strikeout
                tHeight = 2.0
                drawView.frame = CGRect(x: tOffsetX, y: (size.height - tHeight) / 2, width: tWidth, height: tHeight)
            case .squiggly:
                markupType = .squiggly
                tHeight = 6.0
                drawView.frame = CGRect(x: tOffsetX, y: size.height - 2.0, width: tWidth, height: tHeight)
            default:
                break
            }
        } else if annotation is CPDFInkAnnotation {
            markupType = .freehand
            tHeight = 6.0
            drawView.frame = CGRect(x: tOffsetX, y: size.height - 2.0, width: tWidth, height: tHeight)
        } else {
            markupType = .freehand
            drawView.frame = CGRect.zero
        }
        drawView.markUpType = markupType
        drawView.lineColor = color
        drawView.setNeedsDisplay()
        
        return drawView
        
    }
    
}

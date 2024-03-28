//
//  CPDFArrowStyleTableView.swift
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

@objc protocol CPDFArrowStyleTableViewDelegate: AnyObject {
    @objc optional func setCPDFArrowStyleTableView(_ arrowStyleTableView: CPDFArrowStyleTableView, style widgetButtonStyle: CPDFWidgetButtonStyle)
}

class CPDFArrowStyleTableView: UIView, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: CPDFArrowStyleTableViewDelegate?
    
    private var backBtn: UIButton?
    private var titleLabel: UILabel?
    private var tableView: UITableView?
    private var headerView: UIView?
    
    var style: CPDFWidgetButtonStyle = .none {
        didSet {
           var titleString = ""
           switch style {
           case .circle:
               titleString = NSLocalizedString("Circles", comment: "")
           case .check:
               titleString = NSLocalizedString("Check", comment: "")
           case .cross:
               titleString = NSLocalizedString("Cross", comment: "")
           case .diamond:
               titleString = NSLocalizedString("Diamond", comment: "")
           case .star:
               titleString = NSLocalizedString("Star", comment: "")
           case .square:
               titleString = NSLocalizedString("Squares", comment: "")
           default:
               break
           }

           for model in dataArray {
               if model.title == titleString {
                   model.isSelected = true
               }
           }

           tableView?.reloadData()
        }
    }
    
    private lazy var dataArray: [CPDFFormArrowModel] = {
        var dataArray = [CPDFFormArrowModel]()
        
        let checkModel = CPDFFormArrowModel()
        checkModel.isSelected = false
        checkModel.iconImage = UIImage(named: "CPDFFormCheck", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        checkModel.title = NSLocalizedString("Check", comment: "")
        dataArray.append(checkModel)
        
        let roundModel = CPDFFormArrowModel()
        roundModel.isSelected = false
        roundModel.iconImage = UIImage(named: "CPDFFormCircle", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        roundModel.title = NSLocalizedString("Circles", comment: "")
        dataArray.append(roundModel)
        
        let forkModel = CPDFFormArrowModel()
        forkModel.isSelected = false
        forkModel.iconImage = UIImage(named: "CPDFFormCross", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        forkModel.title = NSLocalizedString("Cross", comment: "")
        dataArray.append(forkModel)
        
        let rhombusModel = CPDFFormArrowModel()
        rhombusModel.isSelected = false
        rhombusModel.iconImage = UIImage(named: "CPDFFormDiamond", in: Bundle(for: Self.self), compatibleWith: nil)
        rhombusModel.title = NSLocalizedString("Diamond", comment: "")
        dataArray.append(rhombusModel)
        
        let SsquareModel = CPDFFormArrowModel()
        SsquareModel.isSelected = false
        SsquareModel.iconImage = UIImage(named: "CPDFFormSquare", in: Bundle(for: Self.self), compatibleWith: nil)
        SsquareModel.title = NSLocalizedString("Squares", comment: "")
        dataArray.append(SsquareModel)
        
        let starModel = CPDFFormArrowModel()
        starModel.isSelected = false
        starModel.iconImage = UIImage(named: "CPDFFormStar", in: Bundle(for: Self.self), compatibleWith: nil)
        starModel.title = NSLocalizedString("Star", comment: "")
        dataArray.append(starModel)
        
        return dataArray
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: 50))
        headerView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        headerView?.layer.borderWidth = 1.0
        headerView?.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if(headerView != nil) {
            addSubview(headerView!)
        }
        
        titleLabel = UILabel(frame: CGRect(x: (frame.size.width - 120)/2, y: 0, width: 120, height: 50))
        titleLabel?.text = NSLocalizedString("Style", comment: "")
        titleLabel?.textAlignment = .center
        titleLabel?.autoresizingMask = .flexibleHeight
        if(titleLabel != nil) {
            headerView?.addSubview(titleLabel!)
        }
        
        backBtn = UIButton(frame: CGRect(x: 10, y: 0, width: 40, height: 50))
        backBtn?.autoresizingMask = .flexibleHeight
        backBtn?.setImage(UIImage(named: "CPFFormBack", in: Bundle(for: Self.self), compatibleWith: nil), for: .normal)
        backBtn?.addTarget(self, action: #selector(buttonItemClicked_back(_:)), for: .touchUpInside)
        if(backBtn != nil) {
            headerView?.addSubview(backBtn!)
        }
        
       tableView = UITableView(frame: CGRect(x: 0, y: 50, width: bounds.size.width, height: bounds.size.height), style: .plain)
//       tableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
       tableView?.delegate = self
       tableView?.dataSource = self
       tableView?.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
        if(tableView != nil) {
            addSubview(tableView!)
        }

       backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Action
    @objc func buttonItemClicked_back(_ button: UIButton) {
        self.removeFromSuperview()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CPDFFormArrowCell
        if(cell == nil) {
            cell = CPDFFormArrowCell.init(style: .default, reuseIdentifier: "cell")
        }
        cell!.contentView.backgroundColor = CPDFColorUtils.CAnnotationPropertyViewControllerBackgoundColor()
        if(headerView != nil) {
            addSubview(headerView!)
        }

        cell!.model = dataArray[indexPath.row]

        return cell!

    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataArray[indexPath.row]

        var style: CPDFWidgetButtonStyle = .none

        if model.title == NSLocalizedString("Circles",comment: "") {
            style = .circle
        } else if model.title == NSLocalizedString("Check",comment: "") {
            style = .check
        } else if model.title == NSLocalizedString("Cross",comment: "") {
            style = .cross
        } else if model.title == NSLocalizedString("Diamond",comment: "") {
            style = .diamond
        } else if model.title == NSLocalizedString("Star",comment: "") {
            style = .star
        } else if model.title == NSLocalizedString("Squares",comment: "") {
            style = .square
        }

        self.delegate?.setCPDFArrowStyleTableView?(self, style: style)

        for mModel in dataArray {
            if mModel.title == model.title {
                mModel.isSelected = true
            } else {
                mModel.isSelected = false
            }
        }

        tableView.reloadData()

    }
}

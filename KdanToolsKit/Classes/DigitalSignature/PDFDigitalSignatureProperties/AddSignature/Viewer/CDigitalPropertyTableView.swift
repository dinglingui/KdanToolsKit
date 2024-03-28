//
//  CDigitalPropertyTableView.swift
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

protocol CDigitalPropertyTableViewDelegate: AnyObject {
    func digitalPropertyTableViewSelect(_ digitalPropertyTableView: CDigitalPropertyTableView, text: String, index: Int)
}

class CDigitalPropertyTableView: UIView, UITableViewDataSource, UITableViewDelegate {
    weak var delegate: CDigitalPropertyTableViewDelegate?
    var tableView: UITableView?
    var dataArray: [String] = []
    var data: String = ""
    private var modelView: UIView?

    // MARK: - Initializers
    
    init(frame: CGRect, height: CGFloat) {
        super.init(frame: frame)
        self.modelView = UIView(frame: frame)
        self.modelView?.backgroundColor = UIColor.clear
        if modelView != nil {
            self.addSubview(self.modelView!)
        }

        self.tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 300, height: height), style: .plain)
        self.tableView?.layer.borderWidth = 0.5
        self.tableView?.layer.borderColor = UIColor.gray.cgColor
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        if tableView != nil {
            self.addSubview(self.tableView!)
        }

        self.backgroundColor = UIColor.clear

        createGestureRecognizer()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        self.tableView?.center = center
        self.modelView?.frame = frame
    }
    
    // MARK: - Pubulic Methods

    func showinView(_ superView: UIView?) {
        if let superView = superView {
            superView.addSubview(self)
            setNeedsLayout()
            layoutIfNeeded()
            tableView?.reloadData()
            setPageSizeRefresh()
        }
    }

    func setPageSizeRefresh() {
        if let index = dataArray.firstIndex(of: data) {
            let path = IndexPath(row: index, section: 0)
            tableView?.selectRow(at: path, animated: false, scrollPosition: .middle)
        }
    }
    
    // MARK: - Private Methods

    private func createGestureRecognizer() {
        modelView?.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapModelView(_:)))
        modelView?.addGestureRecognizer(tapRecognizer)
    }

    @objc private func tapModelView(_ gestureRecognizer: UIPanGestureRecognizer) {
        removeFromSuperview()
    }

    // MARK: - UITableViewDataSource & UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = dataArray[indexPath.row]
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            delegate?.digitalPropertyTableViewSelect(self, text: cell.textLabel?.text ?? "", index: indexPath.row)
        }
        removeFromSuperview()
    }
}


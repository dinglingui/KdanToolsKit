//
//  CPDFSearchResultsViewController.swift
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

protocol CPDFSearchResultsDelegate: AnyObject {
    func searchResultsView(_ resultVC: CPDFSearchResultsViewController, forSelection selection: CPDFSelection, indexPath: IndexPath)

    func searchResultsViewControllerDismiss(_ searchResultsViewController: CPDFSearchResultsViewController)
    
}

let kTextSearch_Content_Length_Max = 100

class CPDFSearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: CPDFSearchResultsDelegate?
    public var pdfListView:CPDFListView?
    public var searchString:String?

    private var resultArray: [Any]?
    private var keyword: String?
    private var document: CPDFDocument?
    private var tableView: UITableView?
    private var searchResultView: UIView?
    private var searchResultLabel: UILabel?
    private var pageLabel: UILabel?
    private var backBtn: UIButton?
    
    // MARK: - Initializers
    
    init(resultArray: [Any], keyword: String, document: CPDFDocument) {
        super.init(nibName: nil, bundle: nil)
        // Initialization code
        self.resultArray = resultArray
        self.keyword = keyword
        self.document = document
    }
    
    // MARK: - UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Results", comment: "")
        
        tableView = UITableView(frame: view.frame, style: .plain)
        tableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView?.delegate = self
        tableView?.dataSource = self
        view.backgroundColor = UIColor.white
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 60
        tableView?.tableFooterView = UIView()
        tableView?.separatorStyle = .none
        tableView?.register(CPDFSearchViewCell.self, forCellReuseIdentifier: "cell")
        if(tableView != nil) {
            view.addSubview(tableView!)
        }

        searchResultView = UIView()
        searchResultLabel = UILabel()
        pageLabel = UILabel()

        searchResultView?.backgroundColor = CPDFColorUtils.CAnnotationSampleBackgoundColor()
        pageLabel?.font = UIFont.systemFont(ofSize: 14)
        pageLabel?.text = NSLocalizedString("Page", comment: "")
        pageLabel?.textAlignment = .right
        pageLabel?.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        searchResultLabel?.font = UIFont.systemFont(ofSize: 14)
        searchResultLabel?.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        if(searchResultLabel != nil) {
            searchResultView?.addSubview(searchResultLabel!)
        }
        if(pageLabel != nil) {
            searchResultView?.addSubview(pageLabel!)
        }
        if(searchResultView != nil) {
            view.addSubview(searchResultView!)
        }

        updatePreferredContentSize(with: traitCollection)


        backBtn = UIButton()
        backBtn?.autoresizingMask = .flexibleLeftMargin
        backBtn?.setImage(UIImage(named: "CPDFViewImageBack", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        backBtn?.addTarget(self, action: #selector(buttonItemClicked_Back(_:)), for: .touchUpInside)
        backBtn?.sizeToFit()
        if(backBtn != nil) {
            let backItem = UIBarButtonItem(customView: backBtn!)
            self.navigationItem.leftBarButtonItems = [backItem];
        }
        
        view.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
        
        var datas: [CPDFSelection] = []
        if let resultArray = self.resultArray as? [[CPDFSelection]] {
            for results in resultArray {
                for selection in results {
                    datas.append(selection)
                }
            }
        }
        searchResultLabel?.text = "\(datas.count) \(NSLocalizedString("Resultss", comment: ""))"
        self.searchResultLabel?.sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_Back(_ sender: UIButton) {
        self.delegate?.searchResultsViewControllerDismiss(self)
    }
    
    @objc func textField_ShouldReturn(_ sender: UIButton) {
        self.resignFirstResponder()
    }

    // MARK: - Private Methods
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSize(with: newCollection)
    }

    func updatePreferredContentSize(with traitCollection: UITraitCollection) {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height

        let mWidth = min(width, height)
        let mHeight = max(width, height)
        let currentDevice = UIDevice.current
        if currentDevice.userInterfaceIdiom == .pad {
            // This is an iPad
            self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? mWidth * 0.7 : mHeight * 0.7)
        } else {
            // This is an iPhone or iPod touch
            self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? mWidth * 0.9 : mHeight * 0.9)
        }
    }
    
    private lazy var loadingView: CActivityIndicatorView = {
        if #available(iOS 13.0, *) {
             loadingView = CActivityIndicatorView(style: .large)
        } else {
             loadingView = CActivityIndicatorView(style: .gray)
        }
        loadingView.center = self.view?.center ?? CGPoint.zero
        loadingView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        return loadingView
    }()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if #available(iOS 11.0, *) {
            tableView?.frame = CGRect(x: view.safeAreaInsets.left, y: view.safeAreaInsets.top + 28, width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: view.frame.size.height - view.safeAreaInsets.bottom - view.safeAreaInsets.top-28)
            searchResultView?.frame = CGRect(x: view.safeAreaInsets.left, y: view.safeAreaInsets.top , width: view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: 28)
            searchResultLabel?.frame = CGRect(x: 20, y: 4, width: 200, height: 20)
            pageLabel?.frame = CGRect(x: view.frame.size.width - 50, y: 4, width: 40, height: 20)
        } else {
            searchResultView?.frame = CGRect(x: 20, y: self.navigationController?.navigationBar.frame.maxY ?? 0, width: view.frame.size.width - 20, height: 28)
            searchResultLabel?.frame = CGRect(x: 20, y: 4, width: 200, height: 20)
            pageLabel?.frame = CGRect(x: view.frame.size.width - 50, y: 4, width: 40, height: 20)
            tableView?.frame = CGRect(x: view.bounds.origin.x, y: 28, width: view.bounds.size.width, height: view.bounds.size.height-28)
        }
    }
    
    func trimMultipleSpaces(_ input: String) -> Int {
        let trimmedString = input.trimmingCharacters(in: .whitespacesAndNewlines)
        var count = trimmedString.count
        if input.hasPrefix(" ") {
            count += 1
        }
        if input.hasSuffix(" ") {
            count += 1
        }
        return count
    }
    
    @objc func getAttributedString(with selection: CPDFSelection?) -> NSMutableAttributedString? {
        guard let currentPage = selection?.page else {
            return nil
        }
        
        let range = selection?.range
        var startLocation: UInt = 0
        let maxLocation: UInt = 20
        var keyLocation = 0
        let maxEndLocation: UInt = 80
        
        if (range?.location ?? 0) > maxLocation {
            startLocation = UInt(range?.location ?? 0) - maxLocation
            keyLocation = Int(maxLocation)
        } else {
            startLocation = 0
            keyLocation = Int(range?.location ?? 0)
        }
        
        var endLocation: UInt = 0
        if UInt(range?.location ?? 0) + UInt(maxEndLocation) > currentPage.numberOfCharacters {
            endLocation = UInt(currentPage.numberOfCharacters)
        } else {
            endLocation = UInt(range?.location ?? 0) + maxEndLocation
        }
        
        var attributed: NSMutableAttributedString?
        
        if endLocation > startLocation {
            if let currentString = currentPage.string(for: NSRange(location: Int(startLocation), length: Int(endLocation - startLocation))) {
                let count = trimMultipleSpaces(self.keyword ?? "")
                let tRange = NSRange(location: keyLocation, length: count)
                
                if tRange.location != NSNotFound {
                    attributed = NSMutableAttributedString(string: currentString)
                    
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.firstLineHeadIndent = 10.0
                    paragraphStyle.headIndent = 10.0
                    paragraphStyle.lineBreakMode = .byCharWrapping
                    
                    let font = UIFont(name: "HelveticaNeue-Medium", size: 13.0)
                    let dic1: [NSAttributedString.Key: Any] = [.font: font ?? UIFont.systemFont(ofSize: 12), .paragraphStyle: paragraphStyle]
                    let range1 = (attributed?.string ?? "") as NSString
                    
                    attributed?.setAttributes(dic1, range: range1.range(of: range1 as String))
                    
                    let dic2: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(red: 102.0/255.0, green: 102.0/255.0, blue: 102.0/255.0, alpha: 1.0)]
                    attributed?.addAttributes(dic2, range: NSRange(location: 0, length: (attributed?.length ?? 0)))
                    
                    let dic3: [NSAttributedString.Key: Any] = [.backgroundColor: UIColor(red: 1.0, green: 220.0/255.0, blue: 27.0/255.0, alpha: 1.0)]
                    
                    if (attributed?.length ?? 0) >= (tRange.length + tRange.location) {
                        attributed?.addAttributes(dic3, range: tRange)
                    }
                }
            }
        }
        return attributed
    }

    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.resultArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array = self.resultArray?[section] as? NSArray
        return array?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CPDFSearchViewCell ?? CPDFSearchViewCell(style: .subtitle, reuseIdentifier: "cell")
        let selection = (self.resultArray?[indexPath.section] as? NSArray)?[indexPath.row]
        cell.contentLabel?.attributedText = getAttributedString(with: selection as? CPDFSelection)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let selection = (self.resultArray?[indexPath.section] as? NSArray)?[indexPath.row]
        guard let attributeText = getAttributedString(with: selection as? CPDFSelection) else {
            return 0
            
        }

        let cellWidth = tableView.frame.size.width
        let padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let framesetter = CTFramesetterCreateWithAttributedString(attributeText as CFAttributedString)
        let suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, CGSize(width: cellWidth - padding.left - padding.right, height: CGFloat.greatestFiniteMagnitude), nil)
        let cellHeight = suggestedSize.height + padding.top + padding.bottom
        return cellHeight
    }
        
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let array = self.resultArray?[section] as? [CPDFSelection], let selection = array.first, let pageIndex = self.document?.index(for: selection.page) else {
            return nil
        }

        let countStr = String(format: NSLocalizedString("%ld", comment: ""), pageIndex + 1)

        let view = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
        view.autoresizingMask = .flexibleWidth
        view.backgroundColor = UIColor(red: 250.0/255.0, green: 252.0/255.0, blue: 255.0/255.0, alpha: 1.0)

        let sublabel = UILabel()
        sublabel.font = UIFont.systemFont(ofSize: 14)
        sublabel.text = countStr
        sublabel.textColor = UIColor(red: 67.0/255.0, green: 71.0/255.0, blue: 77.0/255.0, alpha: 1.0)
        sublabel.sizeToFit()
        sublabel.frame = CGRect(x: view.bounds.size.width - sublabel.bounds.size.width - 10, y: 0,
                                width: sublabel.bounds.size.width, height: view.bounds.size.height)
        sublabel.autoresizingMask = .flexibleLeftMargin
        view.contentView.addSubview(sublabel)

        return view
    }
    
    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    
        dismiss(animated: true) {
            let selection = (self.resultArray?[indexPath.section] as? NSArray)?[indexPath.row]
            if(selection != nil && selection is CPDFSelection) {
                self.delegate?.searchResultsView(self, forSelection: selection as! CPDFSelection, indexPath: indexPath)
            }
        }
    }
    
}

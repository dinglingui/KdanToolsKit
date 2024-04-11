//
//  CSearchToolbar.swift
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

@objc public protocol CSearchToolbarDelegate: AnyObject {
    @objc optional func searchToolbar(_ searchToolbar: CSearchToolbar, onSearchQueryResults results: [Any])
    
    @objc optional func searchToolbarReplace(_ searchToolbar: CSearchToolbar)
    
    @objc optional func searchToolbarChangeSelection(_ searchToolbar: CSearchToolbar, changeSelection selection: CPDFSelection?)
}


public class CSearchToolbar: UIView, UISearchBarDelegate, UITextFieldDelegate {
    public var pdfView: CPDFListView?
    var resultArray: [[CPDFSelection]] = []
    public var parentVC: UIViewController?
    public var searchOption: CPDFSearchOptions = CPDFSearchOptions(rawValue: 0)

    
    public var searchTitleType: CSearchTitleType = .search {
           didSet {
               if(self.searchTitleType != .replace) {
                   self.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: 44)
                   replaceTextFied.isHidden = true
                   replaceButton.isHidden = true
                   self.searchButton.isHidden = true
                   
                   if self.resultArray.count > 0 {
                       searchListItem.isHidden = false
                       previousItem.isHidden = false
                       nextListItem.isHidden = false
                   } else {
                       searchListItem.isHidden = true
                       previousItem.isHidden = true
                       nextListItem.isHidden = true
                   }
               } else {
                   self.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: 91)
                   replaceTextFied.isHidden = false
                   replaceButton.isHidden = false
                   
                   searchListItem.isHidden = true
                   self.searchButton.isHidden = false
                   if self.resultArray.count > 0 {
                       searchButton.isHidden = true
                       replaceButton.isEnabled = true
                       replaceButton.setTitleColor(CPDFColorUtils.CPageEditToolbarFontColor(), for: .normal)
                       previousItem.isHidden = false
                       nextListItem.isHidden = false
                   } else {
                       searchButton.isHidden = false
                       replaceButton.isEnabled = false
                       replaceButton.setTitleColor(.gray, for: .normal)
                       previousItem.isHidden = true
                       nextListItem.isHidden = true
                   }
               }
               
               self.searchBar.becomeFirstResponder()
           }
       }

    public var searchKeyString: String {
       get {
           return self.searchBar.text ?? ""
       }
    }
    
    private var searchListItem = UIButton()
    private var nextListItem = UIButton()
    private var previousItem = UIButton()
    var searchBar = UISearchBar()
    public var replaceTextFied = UISearchBar()
    private var replaceButton = UIButton()
    var searchButton = UIButton()

    private var nowPageIndex: Int = 0
    private var nowNumber: Int = 0
    
    // MARK: - Accessors
    
    private lazy var loadingView: CActivityIndicatorView = {
        let loadingView = CActivityIndicatorView(style: .gray)
        loadingView.center = window?.center ?? CGPoint.zero
        loadingView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        return loadingView
    }()
    
    private var isSearched: Bool = false
    
    weak var delegate: CSearchToolbarDelegate?
    
    // MARK: - Initializers
    
    init(pdfView: CPDFListView) {
        self.pdfView = pdfView
        super.init(frame: .zero)
        self.commonInit()
        self.backgroundColor = CPDFColorUtils.CPDFViewControllerBackgroundColor()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let offset: CGFloat = 0.0
        let offsetX: CGFloat = 10.0
        
        var right:CGFloat = 0.0
        if #available(iOS 11.0, *) {
            right += self.superview?.safeAreaInsets.right ?? 0
        }

        let searchBarWidth: CGFloat
        if(self.searchTitleType != .replace) {
            if !isSearched {
                searchBarWidth = (bounds.size.width - right - offsetX * 2)
            } else {
                searchBarWidth = ((bounds.size.width - right - (offsetX * 2)) - (3 * offset) - 34.0 * 3)
            }
            let searchListItemX:CGFloat = self.bounds.size.width - right - offsetX - 34.0
            searchListItem.frame = CGRect(x: searchListItemX, y: 0, width: 34.0, height: 44)

            let nextListItemX:CGFloat = searchListItemX - offset - 34.0
            nextListItem.frame = CGRect(x: nextListItemX, y: 0, width: 34.0, height: 44)
            
            let previousItemX:CGFloat = nextListItemX - offset - 34.0
            previousItem.frame = CGRect(x: previousItemX, y: 0, width: 34.0, height: 44)
        } else {
            searchBarWidth = ((bounds.size.width - right - (offsetX * 2)) - (3 * offset) - 34.0 * 2)
            
            let nextListItemX:CGFloat = self.bounds.size.width - right - offsetX - 34.0
            nextListItem.frame = CGRect(x: nextListItemX, y: 0, width: 34.0, height: 44)
            
            let previousItemX:CGFloat = nextListItemX - offset - 34.0
            previousItem.frame = CGRect(x: previousItemX, y: 0, width: 34.0, height: 44)
            
            let replaceButtonWidth: CGFloat = self.bounds.size.width - previousItemX - offsetX
            self.searchButton.frame = CGRect(x: previousItemX, y: 5.0, width: replaceButtonWidth, height: 30.0)
            
            replaceTextFied.frame = CGRect(x: offsetX, y: 51.0, width: searchBarWidth, height: 36.0)
            self.replaceButton.frame = CGRect(x: previousItemX, y: 5.0, width: replaceButtonWidth, height: 30.0)
            replaceButton.centerY = replaceTextFied.centerY


        }
        searchBar.frame = CGRect(x: offsetX, y: 4.0, width: searchBarWidth, height: 36.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    public func clearDatas(_ isClearText: Bool) {
        self.resultArray = []
        if(self.searchTitleType == .replace) {
            self.pdfView?.document.cancelFindEditString()
        }
        self.isSearched = false
        
        if self.searchTitleType == .search {
            self.searchButton.isHidden = true
        } else if self.searchTitleType == .replace {
            self.searchButton.isHidden = false
        }
        self.previousItem.isHidden = true
        self.nextListItem.isHidden = true
        self.searchListItem.isHidden = true
        self.layoutSubviews()
        if isClearText {
            self.searchBar.text = ""
            self.replaceTextFied.text = ""
        }
        
        self.searchButton.setTitleColor(.gray, for: .normal)
        self.searchButton.isEnabled = false
        
        self.replaceButton.setTitleColor(.gray, for: .normal)
        self.replaceButton.isEnabled = false
        
        self.delegate?.searchToolbarChangeSelection?(self, changeSelection: nil)
    }
    
    func show(in subView: UIView) {
        subView.addSubview(self)
        if(self.searchTitleType != .replace) {
            self.frame = CGRect(x: 0, y: 0, width: subView.bounds.size.width, height: 44)
        } else {
            self.frame = CGRect(x: 0, y: 0, width: subView.bounds.size.width, height: 91)

        }
        self.autoresizingMask = [.flexibleWidth]
        
        self.searchBar.becomeFirstResponder()
    }
    
    func beganSearchText(_ searchText: String) {
        if searchText.isEmpty {
            return
        }
        
        if(self.pdfView?.toolModel == .edit) {
            conentEditSearch(searchText)
        } else {
            preViewSearch(searchText)
        }
    }
    
    func preViewSearch(_ searchText: String) {
        // The search for document characters cannot be repeated
        window?.isUserInteractionEnabled = false
        
        if loadingView.superview == nil {
            window?.addSubview(loadingView)
        }
        
        loadingView.startAnimating()
        
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let self = self else { return }
            
            let results = self.pdfView?.document.find(searchText,with:self.searchOption)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.window?.isUserInteractionEnabled = true
                
                self.loadingView.stopAnimating()
                self.loadingView.removeFromSuperview()
                
                if(results != nil) {
                    self.resultArray = results!
                    
                    if results!.count > 0 {
                        self.isSearched = true
                        self.previousItem.isHidden = false
                        self.nextListItem.isHidden = false
                        self.searchListItem.isHidden = false
                        self.layoutSubviews()
                    }
                } else {
                    self.resultArray = []
                }
            
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    if self.resultArray.count < 1 {
                        let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil)
                        let alert = UIAlertController(title: nil, message: NSLocalizedString("Text not found!", comment: ""), preferredStyle: .alert)
                        
                        let tRootViewControl = self.parentVC
                        
                        alert.addAction(cancelAction)
                        tRootViewControl?.present(alert, animated: true, completion: nil)
                    } else {
                        self.nowNumber = 0
                        self.nowPageIndex = 0
                        if self.resultArray.count > self.nowPageIndex {
                            let selections = self.resultArray[self.nowPageIndex]
                            if selections.count > self.nowNumber {
                                let selection = selections[self.nowNumber]
                                self.delegate?.searchToolbarChangeSelection?(self, changeSelection: selection)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func conentEditSearch(_ searchText: String) {
        // The search for document characters cannot be repeated
        window?.isUserInteractionEnabled = false
        
        if loadingView.superview == nil {
            window?.addSubview(loadingView)
        }
        
        loadingView.startAnimating()
        let page = self.pdfView?.document.page(at: 0)

        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let self = self else { return }
            let results = self.pdfView?.document.startFindEditText(from: page, with: searchText, options:self.searchOption)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.window?.isUserInteractionEnabled = true
                self.loadingView.stopAnimating()
                self.loadingView.removeFromSuperview()
                
                if(results != nil) {
                    self.resultArray = results!
                    
                    if results!.count > 0 {
                        self.isSearched = true
                        self.previousItem.isHidden = false
                        self.nextListItem.isHidden = false
                        if(self.searchTitleType == .search) {
                            self.searchListItem .isHidden = false;
                        }
                        self.searchButton.isHidden = true
                        self.layoutSubviews()
                    }
                } else {
                    self.resultArray = []
                }
            
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    if self.resultArray.count < 1 {
                        let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil)
                        let alert = UIAlertController(title: nil, message: NSLocalizedString("Text not found!", comment: ""), preferredStyle: .alert)
                                                
                        alert.addAction(cancelAction)
                        self.parentVC?.present(alert, animated: true, completion: nil)
                    } else {
                        
                        self.replaceButton.setTitleColor(CPDFColorUtils.CPageEditToolbarFontColor(), for: .normal)
                        self.replaceButton.isEnabled = true

                        self.nowNumber = 0
                        self.nowPageIndex = 0
                        if self.resultArray.count > self.nowPageIndex {
                            let selections = self.resultArray[self.nowPageIndex]
                            if selections.count > self.nowNumber {
                                let selection = selections[self.nowNumber]
                                self.delegate?.searchToolbarChangeSelection?(self, changeSelection: selection)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    func commonInit() {
        addSubview(searchBar)
        addSubview(replaceTextFied)
        addSubview(replaceButton)
        addSubview(searchButton)
        addSubview(searchListItem)
        addSubview(nextListItem)
        addSubview(previousItem)
        
        searchBar.placeholder = NSLocalizedString("Search", comment: "")
        replaceTextFied.placeholder = NSLocalizedString("Replace with", comment: "")
        
        previousItem.setImage(UIImage(named: "CPDFSearchImagePrevious", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        nextListItem.setImage(UIImage(named: "CPDFSearchImageNext", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        searchListItem.setImage(UIImage(named: "CPDFSearchImageList", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        previousItem.sizeToFit()
        nextListItem.sizeToFit()
        searchListItem.sizeToFit()
        
        previousItem.addTarget(self, action: #selector(buttonItemClicked_Previous(_:)), for: .touchUpInside)
        nextListItem.addTarget(self, action: #selector(buttonItemClicked_Next(_:)), for: .touchUpInside)
        searchListItem.addTarget(self, action: #selector(buttonItemClicked_SearchList(_:)), for: .touchUpInside)
        
        replaceButton.setTitle(NSLocalizedString("Replace All", comment: ""), for: .normal)
        replaceButton.titleLabel?.adjustsFontSizeToFitWidth = true
        replaceButton.addTarget(self, action: #selector(buttonItemClicked_ReplaceAll(_:)), for: .touchUpInside)
        
        searchButton.setTitle(NSLocalizedString("Search", comment: ""), for: .normal)
        searchButton.titleLabel?.adjustsFontSizeToFitWidth = true
        searchButton.addTarget(self, action: #selector(buttonItemClicked_Search(_:)), for: .touchUpInside)
        
        replaceButton.setTitleColor(.gray, for: .normal)
        replaceButton.isEnabled = false
        
        searchButton.setTitleColor(.gray, for: .normal)
        searchButton.isEnabled = false

        searchBar.delegate = self
        replaceTextFied.delegate = self
        
        previousItem.isHidden = true
        nextListItem.isHidden = true
        searchListItem.isHidden = true
        replaceTextFied.isHidden = true
        replaceButton.isHidden = true
        searchListItem.isHidden = true
        searchButton.isHidden = true
        
        searchBar.searchBarStyle = .minimal
        replaceTextFied.searchBarStyle = .minimal

        replaceTextFied.setImage(UIImage(), for: .search, state: .normal)
        replaceTextFied.returnKeyType = .done

    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_SearchList(_ sender: Any) {
        self.delegate?.searchToolbar?(self, onSearchQueryResults: self.resultArray)
    }
    
    @objc func buttonItemClicked_Next(_ sender: Any) {
        var selection:CPDFSelection?
        if(self.pdfView?.toolModel != .edit) {
            if nowNumber < (self.resultArray[nowPageIndex].count) - 1 {
                nowNumber += 1
            } else {
                if nowPageIndex >= (resultArray.count ) - 1 {
                    nowNumber = 0
                    nowPageIndex = 0
                } else {
                    nowPageIndex += 1
                    nowNumber = 0
                }
            }
             selection = resultArray[self.nowPageIndex][nowNumber]

        } else {
            selection = self.pdfView?.document.findBackwordEditText()
        }
        self.delegate?.searchToolbarChangeSelection?(self, changeSelection: selection)
    }
    
    @objc func buttonItemClicked_Previous(_ sender: Any) {
        var selection:CPDFSelection?
        if(self.pdfView?.toolModel != .edit) {
            
            if nowNumber > 0 {
                nowNumber -= 1
            } else {
                if nowPageIndex == 0 {
                    nowPageIndex = (resultArray.count) - 1
                    nowNumber = (resultArray[nowPageIndex].count ) - 1
                    
                } else {
                    nowPageIndex -= 1
                    nowNumber = (resultArray[nowPageIndex].count ) - 1
                    
                }
            }
            selection = resultArray[self.nowPageIndex][nowNumber]
        } else {
            selection = self.pdfView?.document.findForwardEditText()
        }
        self.delegate?.searchToolbarChangeSelection?(self, changeSelection: selection)

    }
    
    @objc func buttonItemClicked_ReplaceAll(_ sender: Any) {
        guard let replaceString = self.replaceTextFied.text else { return  }
        if self.loadingView.superview == nil {
            self.addSubview(self.loadingView)
        }
        self.loadingView.startAnimating()
        let searchString = self.searchKeyString
        self.parentVC?.navigationController?.view.isUserInteractionEnabled = false
        DispatchQueue.global(qos: .default).async {
            self.pdfView?.document?.replaceAllEditText(with:searchString, toReplace: replaceString)
            DispatchQueue.main.async {
                self.parentVC?.navigationController?.view.isUserInteractionEnabled = true
                self.loadingView.removeFromSuperview()
                self.delegate?.searchToolbarReplace?(self)

            }
        }
    }
    
    @objc func buttonItemClicked_Replace(_ sender: Any) {
    }
    
    @objc func buttonItemClicked_Search(_ sender: Any) {
        searchBar.resignFirstResponder()

        let string = searchBar.text
        if string?.isEmpty == true {
            return
        }
        
        self.beganSearchText(string ?? "")
    }
    
    // MARK: - UISearchBarDelegate
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if(self.searchBar == searchBar) {
            let string = searchBar.text
            if string?.isEmpty == true {
                return
            }
            
            self.beganSearchText(string ?? "")
        } else {
            if(self.resultArray.count > 0) {
                self.searchBar.resignFirstResponder()
            }
        }
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(self.searchBar == searchBar) {
            previousItem.isHidden = true
            nextListItem.isHidden = true
            searchListItem.isHidden = true
            
            isSearched = false
            self.resultArray = []
            if(self.searchTitleType == .replace) {
                self.pdfView?.document.cancelFindEditString()
                
                searchButton.isHidden = false
                if searchText.isEmpty {
                    self.searchButton.setTitleColor(.gray, for: .normal)
                    self.searchButton.isEnabled = false
                } else {
                    self.searchButton.setTitleColor(CPDFColorUtils.CPageEditToolbarFontColor(), for: .normal)
                    self.searchButton.isEnabled = true
                }
                
                self.replaceButton.setTitleColor(.gray, for: .normal)
                self.replaceButton.isEnabled = false
            }

            self.delegate?.searchToolbarChangeSelection?(self, changeSelection: nil)
            layoutSubviews()
        }
        
    }
    
    public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if (self.replaceTextFied == searchBar) {
            searchBar.setShowsCancelButton(false, animated: true)
        }
        return true
    }
    
}

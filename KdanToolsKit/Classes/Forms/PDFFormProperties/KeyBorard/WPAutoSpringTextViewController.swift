//
//  WPAutoSpringTextViewController.swift
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
import Foundation

class WPAutoSpringTextViewController: UIViewController,UIGestureRecognizerDelegate {

    var keyboardIsShowing:Bool = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.enableEditTextScroll()
        self.view.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewClicked))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func viewClicked() {
        if keyboardIsShowing {
            let responder = UIResponder.currentFirstResponder
            if responder is UIView || responder is UITextField {
                responder?.resignFirstResponder()
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if(touch.view != nil) {
            if NSStringFromClass(touch.view!.classForCoder) == "UITableViewCellContentView" {
                return false
            }
        }
        return true
    }

    
    func shouldScrollWithKeyboardHeight(_ keyboardHeight: CGFloat) -> CGFloat {
        let responder = UIResponder.currentFirstResponder

        if responder is UIView || responder is UITextField {
            let view = responder as? UIView
            let y:CGFloat = view?.convert(CGPoint.zero, to: UIApplication.shared.keyWindow).y ?? 0
            let bottom = y + (view?.frame.size.height ?? 0)
            if bottom > UIScreen.main.bounds.height - keyboardHeight {
                return bottom - (UIScreen.main.bounds.height - keyboardHeight)
            }
        }
        return 0
    }
    
    func enableEditTextScroll() {
        NotificationCenter.default.addObserver(self, selector: #selector(wpKeyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(wpKeyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(wpKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(wpKeyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    @objc func wpKeyboardDidShow() {
        keyboardIsShowing = true
    }

    @objc func wpKeyboardDidHide() {
        keyboardIsShowing = false
    }

    @objc func wpKeyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Float else {
            return
        }
        weak var weakSelf = self
        UIView.animate(withDuration: TimeInterval(duration)) {
            if let bounds = weakSelf?.view.bounds {
                weakSelf?.view.bounds = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
            }
        }
    }

    @objc func wpKeyboardWillShow(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Float,
              let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        let keyboardHeight = keyboardFrame.size.height
        let shouldScrollHeight = self.shouldScrollWithKeyboardHeight(keyboardHeight)
        if shouldScrollHeight == 0 {
            return
        }
        weak var weakSelf = self
        UIView.animate(withDuration: TimeInterval(duration)) {
            if let bounds = weakSelf?.view.bounds {
                weakSelf?.view.bounds = CGRect(x: 0, y: shouldScrollHeight + 10, width: bounds.size.width, height: bounds.size.height)
            }
        }
    }

}

//
//  AAPLCustomPresentationController.swift
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

@objc public protocol AAPLCustomPresentationControllerDelegate: AnyObject {
    
    @objc optional func AAPLCustomPresentationControllerTap(_ customPresentationController: AAPLCustomPresentationController)
}

public class AAPLCustomPresentationController: UIPresentationController,UIViewControllerTransitioningDelegate,UIViewControllerAnimatedTransitioning {
    
    public weak var tapDelegate: AAPLCustomPresentationControllerDelegate?
    
    var dimmingView:UIView?
    var presentationWrappingView:UIView?
    
    let CORNER_RADIUS: CGFloat = 16.0
    
    public init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        presentedViewController.modalPresentationStyle = .custom
    }
    
    public override var presentedView: UIView? {
        return presentationWrappingView
    }
    
    public override func presentationTransitionWillBegin() {
        guard let presentedViewControllerView = super.presentedView else { return }
        let presentationWrapperView = UIView(frame: frameOfPresentedViewInContainerView)
        presentationWrapperView.layer.shadowOpacity = 0.44
        presentationWrapperView.layer.shadowRadius = 13
        presentationWrapperView.layer.shadowOffset = CGSize(width: 0, height: -6)
        presentationWrappingView = presentationWrapperView
        
        let presentationRoundedCornerView = UIView(frame: presentationWrapperView.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: -CORNER_RADIUS, right: 0)))
        presentationRoundedCornerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        presentationRoundedCornerView.layer.cornerRadius = CORNER_RADIUS
        presentationRoundedCornerView.layer.masksToBounds = true
        
        let presentedViewControllerWrapperView = UIView(frame: presentationRoundedCornerView.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: CORNER_RADIUS, right: 0)))
        presentedViewControllerWrapperView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        presentedViewControllerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        presentedViewControllerView.frame = presentedViewControllerWrapperView.bounds
        presentedViewControllerWrapperView.addSubview(presentedViewControllerView)
        
        presentationRoundedCornerView.addSubview(presentedViewControllerWrapperView)
        presentationWrapperView.addSubview(presentationRoundedCornerView)
        
        if let containerView = self.containerView {
            let dimmingView = UIView(frame: containerView.bounds)
            dimmingView.backgroundColor = UIColor.black
            dimmingView.isOpaque = false
            dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped)))
            self.dimmingView = dimmingView
            containerView.addSubview(dimmingView)
            
            if let transitionCoordinator = presentingViewController.transitionCoordinator {
                self.dimmingView?.alpha = 0.0
                transitionCoordinator.animate(alongsideTransition: { (context) in
                    self.dimmingView?.alpha = 0.5
                }, completion: nil)
            }
        }
    }
    
    public override func presentationTransitionDidEnd(_ completed: Bool) {
        if completed == false {
            self.presentationWrappingView = nil
            self.dimmingView = nil
        }
    }
    
    public override func dismissalTransitionWillBegin() {
        guard let transitionCoordinator = presentingViewController.transitionCoordinator else { return }
        transitionCoordinator.animate(alongsideTransition: { (context) in
            self.dimmingView?.alpha = 0.0
        }, completion: nil)
        
    }
    
    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed == true {
            self.presentationWrappingView = nil
            self.dimmingView = nil
        }
    }
    
    // MARK: - Layout
    public override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        if container === presentedViewController {
            containerView?.setNeedsLayout()
        }
        
    }
        
    public override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        
        if container === presentedViewController {
            return presentedViewController.preferredContentSize
        } else {
            return super.size(forChildContentContainer: container, withParentContainerSize: parentSize)
        }
    }
    
    public override var frameOfPresentedViewInContainerView: CGRect {
        let containerViewBounds = containerView?.bounds ?? CGRect.zero
        let presentedViewContentSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerViewBounds.size)
        var presentedViewControllerFrame = containerViewBounds
        presentedViewControllerFrame.size.height = presentedViewContentSize.height
        presentedViewControllerFrame.origin.y = containerViewBounds.maxY - presentedViewContentSize.height
        return presentedViewControllerFrame
        
    }
    public override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        dimmingView?.frame = containerView?.bounds ?? CGRect.zero
        let width = min(containerView?.frame.size.width ?? 0, containerView?.frame.size.height ?? 0)
        presentationWrappingView?.frame = CGRect(x: (frameOfPresentedViewInContainerView.size.width - width)/2, y: frameOfPresentedViewInContainerView.origin.y, width: width, height: frameOfPresentedViewInContainerView.size.height)
        
    }
    
    // MARK: - Tap Gesture Recognizer
    @objc func dimmingViewTapped() {
        self.presentingViewController.dismiss(animated: true, completion: nil)
        self.tapDelegate?.AAPLCustomPresentationControllerTap?(self)
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionContext?.isAnimated ?? false ? 0.35 : 0
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
              let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let containerView = transitionContext.containerView
        
        let toView = transitionContext.view(forKey: .to)
        let fromView = transitionContext.view(forKey: .from)
        
        let isPresenting = (fromViewController == presentingViewController)
        
        var fromViewFinalFrame = transitionContext.finalFrame(for: fromViewController)
        var toViewInitialFrame = transitionContext.initialFrame(for: toViewController)
        let toViewFinalFrame = transitionContext.finalFrame(for: toViewController)
        
        if(toView != nil) {
            containerView.addSubview(toView!)
        }
        
        if isPresenting {
            toViewInitialFrame.origin = CGPoint(x: containerView.bounds.minX, y: containerView.bounds.maxY)
            toViewInitialFrame.size = toViewFinalFrame.size
            toView?.frame = toViewInitialFrame
        } else {
            fromViewFinalFrame = fromView!.frame.offsetBy(dx: 0, dy: fromView!.frame.height)
        }
        
        let transitionDuration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: transitionDuration, animations: {
            if isPresenting {
                toView?.frame = toViewFinalFrame
            } else {
                fromView?.frame = fromViewFinalFrame
            }
        }) { (finished) in
            let wasCancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!wasCancelled)

        }
    }
    
    
    // MARK: - UIViewControllerTransitioningDelegate
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        assert(self.presentedViewController == presented, "You didn’t initialize (self) with the correct presentedViewController. Expected (presented), got (self.presentedViewController)")
        return self
        
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
}

//
//  PopupAlert.swift
//  EStudyTool
//
//  Created by ngle on 2016. 9. 19..
//  Copyright © 2016년 tongchun. All rights reserved.
//

import Foundation

class ESTPopup: UIViewController {
    
    var overlayView: UIView!
    var alertView: UIView!
    var animator: UIDynamicAnimator!
    var attachmentBehavior: UIAttachmentBehavior!
    var snapBehavior: UISnapBehavior!
    
    func createOverlay() {
        // Create a gray view and set tis alpha to 0 so it isn't visible.
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.grayColor()
        overlayView.alpha = 0.0
        view.addSubview(overlayView)
    }
    
    func createAlert() {
        // Here the red alert view is created. It is created with reounded corners and a shadow around it
        let alertWidth: CGFloat = 250
        let alertHeight: CGFloat = 150
        let alertViewFrame: CGRect = CGRectMake(0, 0, alertWidth, alertHeight)
        
        alertView = UIView(frame: alertViewFrame)
        alertView.backgroundColor = UIColor.redColor()
        alertView.alpha = 0.0
        alertView.layer.cornerRadius = 10
        alertView.layer.shadowColor = UIColor.blackColor().CGColor
        alertView.layer.shadowOffset = CGSizeMake(0, 5)
        alertView.layer.shadowOpacity = 0.3
        alertView.layer.shadowRadius = 10.0
        
        // Create a button and set a listener on it for when it si tapped. Then the button is added to the alert view
        
        //let button = UIButton.buttonWithType(UIButtonType.System) as UIButton
        let button = UIButton(type: UIButtonType.System) as UIButton
        button.setTitle("Dismiss", forState: UIControlState.Normal)
        button.backgroundColor = UIColor.whiteColor()
        button.frame = CGRectMake(0, 0, alertWidth, 40.0)
        
        button.addTarget(self, action: #selector(ESTPopup.dismissAlert), forControlEvents: UIControlEvents.TouchUpInside)
        alertView.addSubview(button)
        view.addSubview(alertView)
    }
    
    func showAlert() {
        if (alertView == nil) {
            createAlert()
        }
        
        createGestureRecognizer()
        
        animator.removeAllBehaviors()
        
        UIView.animateWithDuration(0.4) {
            self.overlayView.alpha = 1.0
        }
        
        alertView.alpha = 1.0
        
        let snapBehavior: UISnapBehavior = UISnapBehavior(item: alertView, snapToPoint: view.center)
        animator.addBehavior(snapBehavior)
    }
    
    func dismissAlert() {
        
        animator.removeAllBehaviors()
        
        let gravityBehaviour: UIGravityBehavior = UIGravityBehavior(items: [alertView])
        gravityBehaviour.gravityDirection = CGVectorMake(0.0, 10.0)
        animator.addBehavior(gravityBehaviour)
        
        let itemBehaviour: UIDynamicItemBehavior = UIDynamicItemBehavior(items: [alertView])
        itemBehaviour.addAngularVelocity(CGFloat(-M_PI_2), forItem: alertView)
        animator.addBehavior(itemBehaviour)
        
        UIView.animateWithDuration(0.4, animations: {
            self.overlayView.alpha = 0.0
            }, completion: {
                (value: Bool) in
                self.alertView.removeFromSuperview()
                self.alertView = nil
        })
    }
    
    func createGestureRecognizer() {
        let panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ESTPopup.handlePan))
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        if (alertView != nil) {
            let panLocationInView = sender.locationInView(view)
            let panLocationInAlertview = sender.locationInView(view)
            
            if sender.state == UIGestureRecognizerState.Began {
                animator.removeAllBehaviors()
                
                let offset = UIOffsetMake(panLocationInAlertview.x - CGRectGetMidX(alertView.bounds), panLocationInAlertview.y - CGRectGetMidX(alertView.bounds))
                attachmentBehavior = UIAttachmentBehavior(item: alertView, offsetFromCenter: offset, attachedToAnchor: panLocationInView)
                animator.addBehavior(attachmentBehavior)
            } else if sender.state == UIGestureRecognizerState.Changed {
                attachmentBehavior.anchorPoint = panLocationInView
            } else if sender.state == UIGestureRecognizerState.Ended {
                animator.removeAllBehaviors()
                
                snapBehavior = UISnapBehavior(item: alertView, snapToPoint: view.center)
                animator.addBehavior(snapBehavior)
                
                if sender.translationInView(view).y > 100 {
                    dismissAlert()
                }
            }
        }
    }
}
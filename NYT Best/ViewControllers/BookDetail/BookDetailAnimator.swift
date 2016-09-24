//
//  BookDetailAnimator.swift
//  NYT Best
//
//  Created by Ishan Handa on 22/09/16.
//  Copyright © 2016 Ishan Handa. All rights reserved.
//

import UIKit
import AVFoundation

class BookDetailAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    /// Duration of presentation.
    let duration = 0.4
    
    /// Flag to check if Animator is presenting or dismissing
    var presenting = true
    
    /// The frame of the image in the Best sellers list table.
    var imageOriginFrame = CGRect.zero
    
    /// The index path of the book in the Best sellers list table
    var previousSelectedIndexPath: NSIndexPath!
    
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if presenting {
             presentingAnimation(transitionContext)
        } else {
            dismissingAnimation(transitionContext)
        }
    }
    
    
    /// Presentation for presenting the Detail view
    private func presentingAnimation(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! BookDetailViewController
        
        let fromVC = (transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! UINavigationController).viewControllers.last as! BestSellerBooksTableViewController
        
        let image = toVC.bookImage
        
        let imageRect = AVMakeRectWithAspectRatioInsideRect(toVC.bookImage.size, toVC.coverImageView.frame)
        var finalImageRect = toVC.coverImageView.superview!.convertRect(imageRect, toView: toVC.view)
        finalImageRect.origin.y += 70
        
        finalImageRect.origin.x = (UIScreen.mainScreen().bounds.width - finalImageRect.size.width) / 2
        let transitioningImageView = UIImageView(image: image)
        transitioningImageView.frame = imageOriginFrame
        
        toView.alpha = 0
        toVC.coverImageView.alpha = 0
        
        containerView.addSubview(toView)
        containerView.addSubview(transitioningImageView)
        let selectedCell = fromVC.tableView.cellForRowAtIndexPath(fromVC.tableView.indexPathForSelectedRow!) as! BestsellerTableViewCell
        selectedCell.coverImageView.alpha = 0
        
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            transitioningImageView.frame = finalImageRect
            toView.alpha = 1
            }, completion: { (finished) in
                if finished {
                    toVC.coverImageView.alpha = 1
                    selectedCell.coverImageView.alpha = 1
                    transitioningImageView.removeFromSuperview()
                    transitionContext.completeTransition(true)
                }
        })
    }
    
    
    /// Presentation for dismissing the Detail view
    private func dismissingAnimation(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        
        let toVC = (transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)  as! UINavigationController).viewControllers.last as! BestSellerBooksTableViewController
        
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! BookDetailViewController
        
        let image = fromVC.bookImage
        
        let imageRect = AVMakeRectWithAspectRatioInsideRect(fromVC.bookImage.size, fromVC.coverImageView.frame)
        let originImageRect = fromVC.coverImageView.superview!.convertRect(imageRect, toView: toVC.view)
        
        let transitioningImageView = UIImageView(image: image)
        transitioningImageView.frame = originImageRect
        
        toView.alpha = 0
        fromVC.coverImageView.alpha = 0
        
        containerView.addSubview(toView)
        containerView.addSubview(transitioningImageView)
        let selectedCell = toVC.tableView.cellForRowAtIndexPath(previousSelectedIndexPath) as! BestsellerTableViewCell
        selectedCell.coverImageView.alpha = 0
        
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            transitioningImageView.frame = self.imageOriginFrame
            toView.alpha = 1
        }) { (finished) in
            if finished {
                fromVC.coverImageView.alpha = 1
                selectedCell.coverImageView.alpha = 1
                transitioningImageView.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }
    }
}

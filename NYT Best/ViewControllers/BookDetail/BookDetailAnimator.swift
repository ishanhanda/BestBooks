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
    var previousSelectedIndexPath: IndexPath!
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if presenting {
             presentingAnimation(transitionContext)
        } else {
            dismissingAnimation(transitionContext)
        }
    }
    
    
    /// Presentation for presenting the Detail view
    fileprivate func presentingAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! BookDetailViewController
        
        let fromVC = (transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! UINavigationController).viewControllers.last as! BestSellerBooksTableViewController
        
        let image = toVC.bookImage
        
        let imageRect = AVMakeRect(aspectRatio: toVC.bookImage.size, insideRect: toVC.coverImageView.frame)
        var finalImageRect = toVC.coverImageView.superview!.convert(imageRect, to: toVC.view)
        finalImageRect.origin.y += 70
        
        finalImageRect.origin.x = (UIScreen.main.bounds.width - finalImageRect.size.width) / 2
        let transitioningImageView = UIImageView(image: image)
        transitioningImageView.frame = imageOriginFrame
        
        toView.alpha = 0
        toVC.coverImageView.alpha = 0
        
        containerView.addSubview(toView)
        containerView.addSubview(transitioningImageView)
        let selectedCell = fromVC.tableView.cellForRow(at: fromVC.tableView.indexPathForSelectedRow!) as! BestsellerTableViewCell
        selectedCell.coverImageView.alpha = 0
        
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(), animations: {
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
    fileprivate func dismissingAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        let toVC = (transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)  as! UINavigationController).viewControllers.last as! BestSellerBooksTableViewController
        toView.frame = containerView.frame
        
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! BookDetailViewController
        
        let image = fromVC.bookImage
        
        let imageRect = AVMakeRect(aspectRatio: fromVC.bookImage.size, insideRect: fromVC.coverImageView.frame)
        let originImageRect = fromVC.coverImageView.superview!.convert(imageRect, to: toVC.view)
        
        let transitioningImageView = UIImageView(image: image)
        transitioningImageView.frame = originImageRect
        
        toView.alpha = 0
        fromVC.coverImageView.alpha = 0
        
        containerView.addSubview(toView)
        containerView.addSubview(transitioningImageView)
        
        // Scroll table to selectedIndexPath so that the cellForRowAtIndexPath does not return nil
        toVC.tableView.scrollToRow(at: previousSelectedIndexPath, at: .top, animated: false)
        let selectedCell = toVC.tableView.cellForRow(at: previousSelectedIndexPath) as! BestsellerTableViewCell
        selectedCell.coverImageView.alpha = 0
        
        // Calculate final rect
        let cellImageRect = AVMakeRect(aspectRatio: (image?.size)!, insideRect: selectedCell.coverImageView.frame)
        let finalImageRect = selectedCell.contentView.convert(cellImageRect, to: toView)
            
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(), animations: {
            transitioningImageView.frame = finalImageRect
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

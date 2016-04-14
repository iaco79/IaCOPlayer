//
//  ICOInteractiveTransitioning.h
//  ICOPlayer
//
//  Created by Othon Cruz on 4/10/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICOInteractiveTransitioning : NSObject <UIViewControllerInteractiveTransitioning>



/** duration in seconds */
@property (nonatomic, readonly) CGFloat duration;

/** percent complete */
@property (nonatomic, assign) CGFloat percentComplete;

/** The animator to drive the transition */
@property (nonatomic, strong) id<UIViewControllerAnimatedTransitioning>animator;

/** animation speed factor to complete the remaining animation percent */
@property (nonatomic, assign) CGFloat completionSpeed;

- (instancetype)initWithAnimator:(id<UIViewControllerAnimatedTransitioning>)animator ;

/**
 * Updates the animation
 */
- (void)updateInteractiveTransition:(CGFloat)percentComplete;

/**
 * Cancels the interactive transition and reverses the percentComplete back to 0
 */
- (void)cancelInteractiveTransition;

/**
 * advances percentComplete to 100 and finishes the interactive transition
 */
- (void)finishInteractiveTransition;



@end

//
//  ICOInteractiveTransition.m
//  ICOPlayer
//
//  Created by Othon Cruz on 4/10/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//

#import "ICOInteractiveTransitioning.h"

@interface ICOInteractiveTransitioning ()

@end

@implementation ICOInteractiveTransitioning

{
    __weak id<UIViewControllerContextTransitioning> _transitionContext;
    BOOL _isInteracting;
    
    /** Completed / canceled animation timer */
    CADisplayLink *_displayLink;
}

#pragma mark - Initialization
- (instancetype)initWithAnimator:(id<UIViewControllerAnimatedTransitioning>)animator {
    
    self = [super init];
    if (self) {
        [self _commonInit];
        _animator = animator;
    }
    return self;
}
- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self _commonInit];
    }
    return self;
}
- (void)_commonInit {
    _completionSpeed = 1;
}

#pragma mark - Public methods
- (BOOL)isInteracting {
    return _isInteracting;
}
- (CGFloat)duration {
    return 1.0f;
}
- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    NSAssert(_animator, @"Animator must be set to animate the transition");
    
    _transitionContext = transitionContext;
    [_transitionContext containerView].superview.layer.speed = 0;
    
    [_animator animateTransition:_transitionContext];
}
- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    self.percentComplete = fmaxf(fminf(percentComplete, 1), 0); // Input validation
}
- (void)cancelInteractiveTransition {
    [_transitionContext cancelInteractiveTransition];
    [self _completeTransition];
}
- (void)finishInteractiveTransition {
    
    
    [_transitionContext finishInteractiveTransition];
    [self _completeTransition];
}
- (UIViewAnimationCurve)completionCurve {
    return UIViewAnimationCurveLinear;
}

#pragma mark - Private methods
- (void)setPercentComplete:(CGFloat)percentComplete {
    _percentComplete = percentComplete;
    
    
    
    [self _setTimeOffset:percentComplete * 0.5 ];//*[self duration]];
    [_transitionContext updateInteractiveTransition:percentComplete];
}
- (void)_setTimeOffset:(NSTimeInterval)timeOffset {
    [_transitionContext containerView].superview.layer.timeOffset = timeOffset;
}
- (void)_completeTransition {
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_tickAnimation)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
- (void)_tickAnimation {
    
    NSTimeInterval timeOffset = [self _timeOffset];
    NSTimeInterval tick = [_displayLink duration]*[self completionSpeed];
    timeOffset += [_transitionContext transitionWasCancelled] ? -tick : tick;
    
    if (timeOffset < 0 || timeOffset > ([self duration]/2.0)) {
        [self _transitionFinished];
    } else {
        [self _setTimeOffset:timeOffset];
    }
}
- (CFTimeInterval)_timeOffset {
    return [_transitionContext containerView].superview.layer.timeOffset;
}
- (void)_transitionFinished {
    [_displayLink invalidate];
    
    CALayer *layer = [_transitionContext containerView].superview.layer;
    layer.speed = 1;
    
    if (![_transitionContext transitionWasCancelled])
    {
        //this seems to work well
        layer.timeOffset = 0.0;
        layer.beginTime = 0.0;
        

        
    }
    else
    {
        
        //Fix for iOS 9.1 Flickering when cancelling transitions
        
        [CATransaction begin];
        [layer removeAllAnimations];
        
        for (CALayer* sublayer in [layer sublayers]) {
            [sublayer removeAllAnimations];
            
            for (CALayer* sublayer2 in [sublayer sublayers]) {
                [sublayer2 removeAllAnimations];
                
            }
        }
        
        
        layer.timeOffset=0;
        layer.speed=1;
        [CATransaction commit];
        [_animator animationEnded:false];
        
    }
    
    
}


@end

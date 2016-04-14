//
//  ICOBaseViewController.m
//  ICOPlayer
//
//  Created by Othon Cruz on 4/9/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//

#import "ICOBaseViewController.h"

#define kICOUINotificationName @"ICOUINotification"
#define kICOUINotificationParamId @"ICOEventId"

@interface ICOBaseViewController ()
@property (strong,nonatomic) NSMutableArray* animations;
@end

@implementation ICOBaseViewController
{

    CAShapeLayer *_shapeLayer;
    CATransformLayer *_transLayer;
    
}

-(ICOBaseViewController<ICONavigator>*) navigator
{
    ICOBaseViewController<ICONavigator>* parent;
    
    
    UIViewController *par = self.parentViewController;
    
    while (par!=nil)
    {
        if( [par isKindOfClass:ICOBaseViewController.class])
        {
            if( [par conformsToProtocol:@protocol(ICONavigator)])
            {
                parent = (ICOBaseViewController<ICONavigator>*)par;
                break;
            }
        }
        
        par = par.parentViewController;
    }
    
    return parent;
}





-(void) registerForUIEvents: (bool) enable;
{
    if(enable)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUIEventNotification:) name:kICOUINotificationName object:nil];
    else
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kICOUINotificationName object:nil];
    
}


-(void) postUIEvent: (ICOUIEvent) event;
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kICOUINotificationName
                                                        object:nil userInfo:@{kICOUINotificationParamId:[NSNumber numberWithInt:event]} ];
    
}
-(void) postUIEvent: (ICOUIEvent) event withParams: (NSDictionary*) params;
{
    NSMutableDictionary *par = [NSMutableDictionary dictionaryWithDictionary:params];
    [par setObject:[NSNumber numberWithInt:event] forKey:kICOUINotificationParamId];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kICOUINotificationName
                                                        object:nil userInfo: par ];
}

-(void) onUIEventNotification:(NSNotification*) notification
{
    NSNumber* evid = [[notification userInfo] objectForKey:kICOUINotificationParamId];
    ICOUIEvent ev = (ICOUIEvent)[evid integerValue];
    [self onUIEvent: ev withParams: [notification userInfo]];
    
}



-(void) onUIEvent:(ICOUIEvent) event withParams: (NSDictionary*) params;
{
    //optional: Implemented by subclasses
}

-(void) animateViewTap:(UIView *)animationView
{

  
        float destRadius=animationView.bounds.size.width;
    
    
        
        CGPoint center ;
        
        center = CGPointMake(animationView.frame.size.width/2, animationView.frame.size.height/2);
    
    
        // create the PathLayer
        if(_transLayer == nil)
        {
            _transLayer = [CATransformLayer layer];
            
        }
        
        if(_shapeLayer==nil)
        {
            UIColor* tintColor = [UIColor colorWithRed:102.0 / 255.0
                                                 green:166.0 / 255.0
                                                  blue:202.0 / 255.0 alpha:1.0];
            
            _shapeLayer = [CAShapeLayer layer];
            _shapeLayer.fillColor = [tintColor CGColor];
            _shapeLayer.strokeColor = [[[UIColor darkGrayColor] colorWithAlphaComponent:0.5] CGColor];
            _shapeLayer.lineWidth = 0.5;
            _shapeLayer.shadowColor = [[UIColor blackColor] CGColor];
            _shapeLayer.shadowOffset = CGSizeMake(0, 1);
            _shapeLayer.shadowOpacity = 0.4;
            _shapeLayer.shadowRadius = 0.5;
            
            [_transLayer addSublayer:_shapeLayer];
            _transLayer.transform = CATransform3DIdentity;
            [animationView.layer addSublayer:_transLayer];
            
            
        }
        
        
        //set orientation
        CGAffineTransform mixtrans = CGAffineTransformIdentity;
    
        mixtrans = CGAffineTransformIdentity;
    
    
        
        // Setup the Paths
        //Path0
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddArc(path, NULL, center.x, center.y, destRadius/4, 0, M_PI, YES);
        CGPathAddCurveToPoint(path, NULL,
                              center.x - destRadius/4, center.y,
                              center.x - destRadius/4, center.y,
                              center.x - destRadius/4, center.y);
        CGPathAddArc(path, NULL,  center.x , center.y, destRadius/4, M_PI, 0, YES);
        CGPathAddCurveToPoint(path, NULL,
                              center.x + destRadius/4, center.y,
                              center.x + destRadius/4, center.y,
                              center.x + destRadius/4, center.y);
        CGPathCloseSubpath(path);
        
        
        
        //Path50
        CGMutablePathRef path50 = CGPathCreateMutable();
        CGPathAddArc(path50, NULL, center.x, center.y, 2*(destRadius/3), 0, M_PI, YES);
        CGPathAddCurveToPoint(path50, NULL,
                              center.x - 2*(destRadius/3), center.y,
                              center.x - 2*(destRadius/3), center.y,
                              center.x - 2*(destRadius/3), center.y);
        CGPathAddArc(path50, NULL,  center.x , center.y, 2*(destRadius/3), M_PI, 0, YES);
        CGPathAddCurveToPoint(path50, NULL,
                              center.x + 2*(destRadius/3), center.y,
                              center.x + 2*(destRadius/3), center.y,
                              center.x + 2*(destRadius/3), center.y);
        CGPathCloseSubpath(path50);
        
        
        
    
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        _shapeLayer.path = path;
        _shapeLayer.hidden=FALSE;
        [_transLayer setAffineTransform: mixtrans];
        
    
        [CATransaction commit];
        
        
        
        // start the animatinos
        CABasicAnimation *anim50 = [CABasicAnimation animationWithKeyPath:@"path"];
        anim50.duration = 0.15;
        anim50.fillMode = kCAFillModeForwards;
        anim50.toValue = (__bridge id)path50;
        anim50.delegate=self;
        anim50.removedOnCompletion = NO;
    
        [self setAnimations:[NSMutableArray arrayWithArray: @[
                                                              anim50
                                                          
                                                              ] ]];
        
        [self applyNextAnimation];
    
        
        
    }
    

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished {
    [self applyNextAnimation];
}

- (void)applyNextAnimation {
    // Finish when there are no more animations to run
    if ([[self animations] count] == 0)
    {
        
        [_shapeLayer removeAllAnimations];
        _shapeLayer.hidden=true;
        
        return;
        
    }
    
    // Get the next animation and remove it from the "queue"
    CAPropertyAnimation * nextAnimation = [[self animations] objectAtIndex:0];
    [[self animations] removeObjectAtIndex:0];
    
    // Get the layer and apply the animation
    [_shapeLayer addAnimation:nextAnimation forKey:nil];

    


}






@end

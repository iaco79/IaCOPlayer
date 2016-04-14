//
//  ICOBaseViewController.h
//  ICOPlayer
//
//  Created by Othon Cruz on 4/9/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//

#import <UIKit/UIKit.h>




//UI Navigator actions
typedef enum
{
    ICONavigatorActionPresentLeft,
    ICONavigatorActionPresentRight,
    ICONavigatorActionPresentCenter,
    ICONavigatorActionDismissLeftRight
    
} ICONavigatorAction;



//UI Navigator events
typedef enum
{
    ICOUIEventBase,
    ICOUIEventPresentedLeft,
    ICOUIEventPresentedRight,
    ICOUIEventPresentedCenter,
    ICOUIEventDismissedLeftRight,
    ICOUIEventDrawerTapped
} ICOUIEvent;


/**
 * UI navigator interface
 */
@protocol ICONavigator

/**
 * perform a navigator action
 */
-(void) performNavigatorAction:(ICONavigatorAction)  action;


/**
 * perform a navigator action
 */
-(void) performNavigatorAction:(ICONavigatorAction)  action withParams : (NSDictionary*) params;


@end

@interface ICOBaseViewController : UIViewController



-(ICOBaseViewController<ICONavigator>*) navigator;


-(void) postUIEvent: (ICOUIEvent) event;

-(void) postUIEvent: (ICOUIEvent) event withParams: (NSDictionary*) params;

-(void) onUIEvent:(ICOUIEvent) event withParams: (NSDictionary*) params;

-(void) animateViewTap : (UIView*) animationView;


-(void) registerForUIEvents: (bool) enable;





@end

//
//  ICOContainerViewController.m
//  ICOPlayer
//
//  Created by Othon Cruz on 4/9/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//

#import "ICOContainerViewController.h"
#import "ICOInteractiveTransitioning.h"
#import "ICOMenuViewController.h"
#import "ICOPlayerViewController.h"
#import "ICOFavoritesViewController.h"
#import "ICOSearchViewController.h"


@interface ICOContainerViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIView *mainContainerView;
@property (weak, nonatomic) IBOutlet UIView *centerContainerView;

@property (strong, nonatomic) UIView *remoteContainerViewBlur;
@property (weak, nonatomic) IBOutlet UIButton *leftToggle;
@property (weak, nonatomic) IBOutlet UIButton *rightToggle;
@property (weak, nonatomic) IBOutlet UILabel *centerTitle;


@property (strong, nonatomic)  UIPanGestureRecognizer *topRightPanGesture; //dismiss right view
@property (strong, nonatomic)  UIPanGestureRecognizer *topLeftPanGesture; //dismiss left view
@property (strong, nonatomic)  UIScreenEdgePanGestureRecognizer *rightPanGesture; //drag right view controller
@property (strong, nonatomic)  UIScreenEdgePanGestureRecognizer *leftPanGesture; //drag left view controller

@property (strong, nonatomic)  UIViewController *rightController; //current right view controller
@property (strong, nonatomic)  UIViewController *centerController; //current center controller
@property (strong, nonatomic)  UIViewController *leftController; //current left view controller
@property (weak,   nonatomic)  UIViewController *topViewController; //active left / right view controller
@property (strong, nonatomic) ICOInteractiveTransitioning  *interactionController;

@property (assign, nonatomic) NSInteger topViewState;
@property (assign, nonatomic) BOOL topReveal;
- (IBAction)onToggleLeft:(id)sender;
- (IBAction)onToggleRight:(id)sender;

@end



@interface ICOContextTransitioning : NSObject <UIViewControllerContextTransitioning>

- (instancetype)initWithContainerController: (UIViewController*) containerController
                         nextViewController: (UIViewController*) nextViewController;

@property (nonatomic, copy) void (^completionBlock)(BOOL didComplete); /// A block of code we can set to execute after having received the completeTransition: message.
@property (nonatomic, assign, getter=isAnimated) BOOL animated; /// Private setter for the animated property.
@property (nonatomic, assign, getter=isInteractive) BOOL interactive; /// Private setter for the interactive property.

@end

@interface ICOAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, strong) ICOContextTransitioning *context;
@end





@implementation ICOContainerViewController
{
    NSInteger _lastTopViewState;
    NSInteger _nextInteractivetopViewState;
    NSInteger _lastRightKind;
    NSInteger _lastLeftKind;
    bool _nextInteractiveTopReveal;
    bool _topTransitionInProgress;
    bool _transitionCompleted;
    
    bool _firstTime;
    
    UIView* _view1; //center viewcontroller container (when appearing from left)
    UIView* _view2; //center viewcontroller container (when appearing from right)
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _firstTime=true;
    _transitionCompleted=true;
    _lastRightKind=1;
    _lastLeftKind=2;
    
    self.interactionController =[[ICOInteractiveTransitioning alloc] init];
 
    
    self.rightPanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
   [self.rightPanGesture setEdges:UIRectEdgeRight];
   [self.rightPanGesture setDelegate:self];
   [self.mainContainerView addGestureRecognizer:self.rightPanGesture];
    
    
    self.leftPanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
   [self.leftPanGesture setEdges:UIRectEdgeLeft];
   [self.leftPanGesture setDelegate:self];
   [self.mainContainerView addGestureRecognizer:self.leftPanGesture];
    
 
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self registerForUIEvents: true];
   
    
    if(_firstTime)
    {
        _firstTime=false;
        CGRect viewFrame = self.centerContainerView.bounds;
        
        
        _view1 = [[UIView alloc] initWithFrame:viewFrame];
        _view2 = [[UIView alloc] initWithFrame:viewFrame];
        [_view1 setClipsToBounds:YES];
        [_view2 setClipsToBounds:YES];
        
        [_view2 setAutoresizingMask:( UIViewAutoresizingFlexibleWidth |
                                                 UIViewAutoresizingFlexibleHeight )];
        
        
        [_view1 setAutoresizingMask:( UIViewAutoresizingFlexibleWidth |
                                     UIViewAutoresizingFlexibleHeight )];
        
        
        [self performNavigatorAction:ICONavigatorActionPresentCenter];
        
        
    }
    
    
    
}


-(void) viewWillDisappear:(BOOL)animated
{
    
    [self registerForUIEvents: false];
    
    [super viewWillDisappear:animated];
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewWillLayoutSubviews
{

    [super viewWillLayoutSubviews];
    
    
    _view1.frame = self.centerContainerView.bounds;
    _view2.frame = self.centerContainerView.bounds;
    
}


#pragma mark gesture recognizers



- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;
{
    
    if(_topTransitionInProgress || self.centerController==nil)
    {
        return FALSE;
    }
    else
    {
        
        if(self.centerController != nil && self.centerController.isFirstResponder)
        {
            return FALSE;
        }
    }
    
    UIPanGestureRecognizer* panGesture = (UIPanGestureRecognizer*) gestureRecognizer;
    
    
    CGPoint speed = [panGesture velocityInView:self.view];
    
    
    _lastTopViewState = _topViewState;
    
    
    
    if  ( gestureRecognizer==self.topRightPanGesture)
    {
        
        if(_topViewState == 2)
        {
            float speedy = fabsf((float)speed.y);
            if (  (speed.x > 50.0f &&   speedy<300.0)
                )
            {
                _nextInteractivetopViewState=_topViewState;
                _nextInteractiveTopReveal=false;
                return YES;
            }
            else
            {
                NSLog(@"speed x,y %.2f, %.2f",(float)speed.x ,  speedy);
                
            }
        }
    }
    else if  ( gestureRecognizer==self.topLeftPanGesture)
    {
        
        if(_topViewState == 1)
        {
            float speedy = fabsf((float)speed.y);
            
            if (  (speed.x < -50.0f) && (speedy<500.0)
                )
            {
                _nextInteractivetopViewState=_topViewState;
                _nextInteractiveTopReveal=false;
                return YES;
            }
            else
            {
                NSLog(@"speed x,y %.2f, %.2f",(float)speed.x ,  speedy);
                
            }
        }
    }
    else if (gestureRecognizer == self.rightPanGesture)
    {
        
        if(_topViewState ==0)
        {
            if (speed.x <= 0.0)
            {
                
                _nextInteractivetopViewState=2;
                _nextInteractiveTopReveal=true;
                
                
                return YES;
            }
        }
        
        
    }
    else if (gestureRecognizer == self.leftPanGesture)
    {
        
        if(_topViewState ==0)
        {
            if (speed.x >= 0.0f)            {
                
                
                _nextInteractivetopViewState=1;
                _nextInteractiveTopReveal=true;
                
                
                return YES;
            }
        }
        
    }
    
    
    
    
    
    
    
    return NO;
    
}

- (IBAction)onPanGesture:(id)sender {
    
    
    UIScreenEdgePanGestureRecognizer* recognizer = (UIScreenEdgePanGestureRecognizer*)sender;
    CGPoint speed = [recognizer velocityInView:self.view];
    
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        
        if (_nextInteractiveTopReveal)
        {
        
            if(_nextInteractivetopViewState==1)
                [self performNavigatorAction:ICONavigatorActionPresentLeft];
            else
                [self performNavigatorAction:ICONavigatorActionPresentRight];
            
            
        }
        else
        {
            
            [self dissmissTopViewControllerWithCompletion:nil];
            
        }
        
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        
        
        
        CGPoint translation = [recognizer translationInView: self.view];
        CGFloat d = translation.x / self.view.bounds.size.width ; //- self.rightHandle.bounds.size.width);
        
        d = fabs(d);
        
        if(recognizer == self.rightPanGesture)
        {
            if(_topReveal)
            {
                if(d>=0.1)
                {
                    d=0.25+ d;
                    
                    if(d > 1.0)
                        d=1.0f;
                    
                }
                else if (d <0.1)
                {
                    d=0.15+d*2.0;
                }
                
            }
        }
        
        [self.interactionController updateInteractiveTransition: 1.0*d];
    }
    
    
    
    else if (recognizer.state >= UIGestureRecognizerStateEnded) {
        
        CGPoint translation = [recognizer translationInView: self.view];
        CGFloat d = translation.x / self.view.bounds.size.width; // - self.rightHandle.bounds.size.width);
        
        d = fabs(d);
        
        
        if(  (_topViewState == 1 && _topReveal) || (_topViewState ==2 && !_topReveal))
        {
            
            if ((d > 0.4) ||  (speed.x>200.0f) )
            {
                [self.interactionController finishInteractiveTransition];
            } else
            {
                [self.interactionController cancelInteractiveTransition];
            }
            
        }
        else if ((_topViewState == 2 && _topReveal) || (_topViewState ==1 && !_topReveal))
        {
            if ((d > 0.4) ||  (speed.x<-200.0f) )
            {
                [self.interactionController finishInteractiveTransition];
            } else
            {
                [self.interactionController cancelInteractiveTransition];
            }
            
        }
        else
            [self.interactionController cancelInteractiveTransition];
        
    }
    
    
    
}



#pragma mark transitions and navigation
-(void) refreshHeader
{


    if(self.centerController !=nil)
    {
        ICOPlayerViewController* playerController = (ICOPlayerViewController*)self.centerController;
        
        if(playerController.videoLink!=nil)
            self.centerTitle.text =playerController.videoLink.linkDescription;
        
    }
    
    
    if(!_topReveal)
    {
        
        [self.rightToggle setImage:[UIImage imageNamed:@"ic_favs_menu_i"] forState:UIControlStateNormal];
        [self.rightToggle setImage:[UIImage imageNamed:@"ic_favs_menu"] forState:UIControlStateHighlighted];
        [self.leftToggle setImage:[UIImage imageNamed:@"ic_search_i"] forState:UIControlStateNormal];
        [self.leftToggle setImage:[UIImage imageNamed:@"ic_search"] forState:UIControlStateHighlighted];
        
        
    }
    else
    {
        if(_topViewState==2)
        {
            
            [self.rightToggle setImage:[UIImage imageNamed:@"ic_favs_menu"] forState:UIControlStateNormal];
            [self.rightToggle setImage:[UIImage imageNamed:@"ic_favs_menu_i"] forState:UIControlStateHighlighted];
            [self.leftToggle setImage:[UIImage imageNamed:@"ic_search_i"] forState:UIControlStateNormal];
            [self.leftToggle setImage:[UIImage imageNamed:@"ic_search"] forState:UIControlStateHighlighted];
            
        
        }
        else
        {
            [self.rightToggle setImage:[UIImage imageNamed:@"ic_favs_menu_i"] forState:UIControlStateNormal];
            [self.rightToggle setImage:[UIImage imageNamed:@"ic_favs_menu"] forState:UIControlStateHighlighted];
            [self.leftToggle setImage:[UIImage imageNamed:@"ic_search"] forState:UIControlStateNormal];
            [self.leftToggle setImage:[UIImage imageNamed:@"ic_search_i"] forState:UIControlStateHighlighted];
            
        
        }
    }

    
    
}


-(void) onUIEvent:(ICOUIEvent) event withParams: (NSDictionary*) params;
{

    switch (event) {
        case ICOUIEventPresentedCenter:
        case ICOUIEventDismissedLeftRight:
        case ICOUIEventPresentedRight:
        case ICOUIEventPresentedLeft:
        case ICOUIEventDrawerTapped:
            
            [self refreshHeader];
            
            break;
        default:
            break;
    }

}


- (IBAction)onToggleLeft:(id)sender {
   
    if(!_topReveal)
    {
        [self performNavigatorAction:ICONavigatorActionPresentLeft];
    }
    else
    {
        if(_topViewState==1)
            [self performNavigatorAction:ICONavigatorActionDismissLeftRight];
        else
            [self performNavigatorAction:ICONavigatorActionPresentLeft];
    
    }
    
}

- (IBAction)onToggleRight:(id)sender {
    
    
    if(!_topReveal)
    {
        [self performNavigatorAction:ICONavigatorActionPresentRight];
    }
    else
    {
        if(_topViewState==2)
            [self performNavigatorAction:ICONavigatorActionDismissLeftRight];
        else
            [self performNavigatorAction:ICONavigatorActionPresentRight];
        
    }

}

/**
 * perform a navigator action
 */
-(void) performNavigatorAction:(ICONavigatorAction)  action
{
    [self performNavigatorAction:action withParams:nil];
}


/**
 * perform a navigator action
 */
-(void) performNavigatorAction:(ICONavigatorAction)  action withParams : (NSDictionary*) params
{

    
    if(action == ICONavigatorActionPresentCenter)
    {
        
        UIViewController* playerController=nil;
        
        
        if(self.centerController != nil && params!=nil)
        {
            ICOPlayerViewController* icoPlayerController = (ICOPlayerViewController*) self.centerController;
            
            ICOVideoLink* videoLink = [params objectForKey:@"linkurl"];
            
          
            //video link hasn't changed
            if(icoPlayerController.videoLink!=nil && [icoPlayerController.videoLink.linkURL isEqualToString:videoLink.linkURL])
            {
                params=nil;
                
            }
        }
        
        
        if(self.centerController==nil || params!=nil)
        {
            
            
            ICOPlayerViewController* icoPlayerController = [ICOPlayerViewController alloc];
            
            if(params!=nil)
            {
                ICOVideoLink* videoLink = [params objectForKey:@"linkurl"];
                
                icoPlayerController.videoLink = videoLink;
                
            }
            
            icoPlayerController  = [icoPlayerController initWithNibName:@"ICOPlayerViewController" bundle:[NSBundle mainBundle]];
            [icoPlayerController.view setAutoresizingMask:( UIViewAutoresizingFlexibleWidth |
                                                    UIViewAutoresizingFlexibleHeight )];
            
            
            playerController= icoPlayerController;
            
            
        }
        else
            playerController= self.centerController;

       // [self dissmissTopViewControllerWithCompletion:^(bool result) {
              [self showCenterController:playerController animated:true completion:nil];
       // }];
        
    }
    else if (action == ICONavigatorActionPresentLeft)
    {
        UIViewController* leftViewController=nil;
        
        
        if(params!=nil)
        {
            NSNumber* controllerKind = (NSNumber*)[params objectForKey:@"controllerId"];
            
            
            if (_lastLeftKind != [controllerKind integerValue])
            {
                _lastLeftKind= [controllerKind integerValue];
                self.leftController=nil;
                
                
            }
            
            
        }
        
        if(self.leftController==nil)
        {
            leftViewController = [self _viewControllerForId:_lastLeftKind];
        }
        else
        {
            leftViewController= self.leftController;
            
        }
        
        float topY =  (self.view.frame.size.width*9.0/16.0);
        
        leftViewController.view.transform=CGAffineTransformIdentity;
        CGRect frame = CGRectMake(0.0f, topY,
                                    self.mainContainerView.bounds.size.width,
                                    self.mainContainerView.bounds.size.height-topY);

        
        leftViewController.view.frame = frame;
        
        leftViewController.view.transform=CGAffineTransformIdentity;
        
        
        
        
        if(self.topLeftPanGesture==nil)
        {
            self.topLeftPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
            [self.topLeftPanGesture setDelegate:self];
        }
        [leftViewController.view addGestureRecognizer:self.topLeftPanGesture];
        
        
        [self presentTopViewController:1 topViewController: leftViewController completion:^(bool result) {
            
        }];

        
    }
    else if (action == ICONavigatorActionPresentRight)
    {
        UIViewController* rightViewController=nil;
        
        
        if(params!=nil)
        {
            NSNumber* controllerKind = (NSNumber*)[params objectForKey:@"controllerId"];
            
            
            if (_lastRightKind != [controllerKind integerValue])
            {
                
                self.rightController=nil;
                _lastRightKind= [controllerKind integerValue];
            
            }
            
        
        }
        
        if(self.rightController==nil)
        {
            rightViewController = [self _viewControllerForId:_lastRightKind];

        }
        else
        {
            rightViewController= self.rightController;
            
        }
        
        float topY = (self.view.frame.size.width*9.0/16.0);
        

        rightViewController.view.transform=CGAffineTransformIdentity;
        
        CGRect frame = CGRectMake(0.0f, topY,
                                  self.mainContainerView.bounds.size.width,
                                  self.mainContainerView.bounds.size.height-topY);
        
        
        
        
        rightViewController.view.frame = frame;
        rightViewController.view.transform=CGAffineTransformIdentity;

        
        
        if(self.topRightPanGesture==nil)
        {
            self.topRightPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
            [self.topRightPanGesture setDelegate:self];
        }
        [rightViewController.view addGestureRecognizer:self.topRightPanGesture];
        
        
        
        [self presentTopViewController:2 topViewController: rightViewController completion:^(bool result) {
            
        }];

    }
    else if (action == ICONavigatorActionDismissLeftRight)
    {
        [self dissmissTopViewControllerWithCompletion:nil];
        
    
    }
    
    
    
}

-(UIViewController*) _viewControllerForId : (NSInteger) controllerId
{
    
    UIViewController* controller=nil;
    if(controllerId==1) //favorites
    {
        controller  = [[ICOFavoritesViewController alloc] initWithNibName:@"ICOFavoritesViewController" bundle:[NSBundle mainBundle]];
        
    }
    else if(controllerId==2) //search
    {
    
        controller  = [[ICOSearchViewController alloc] initWithNibName:@"ICOSearchViewController" bundle:[NSBundle mainBundle]];
        
    }
    else if(controllerId==3) //menu
    {
        
        controller  = [[ICOMenuViewController alloc] initWithNibName:@"ICOMenuViewController" bundle:[NSBundle mainBundle]];
        
    }


    return controller;
}


- (id<UIViewControllerInteractiveTransitioning>)_interactionControllerForAnimator:(id<UIViewControllerAnimatedTransitioning>)animator {
    
    if (
        ((self.topRightPanGesture!=nil)  && self.topRightPanGesture.state == UIGestureRecognizerStateBegan)
        || ((self.topLeftPanGesture!=nil)  && self.topLeftPanGesture.state == UIGestureRecognizerStateBegan)
        || (self.rightPanGesture.state == UIGestureRecognizerStateBegan)
        || (self.leftPanGesture.state == UIGestureRecognizerStateBegan)
        
        
        
        ) {
        
        self.interactionController.animator = animator;
        return self.interactionController;
    }
    else {
        
        return nil;
    }
}




-(void)showCenterController : (UIViewController*) newController
                   animated : (bool) animated
                  completion: (void (^) (bool result)) completionBlock  {
    
    if(self.centerController == newController)
        return;
    if (!_transitionCompleted)
        return;
    
    _transitionCompleted=false;
    
    UIViewController* oldController = self.centerController;
    
    
    
    if(oldController != nil)
    {
        [oldController willMoveToParentViewController:nil];
    }
  
    CGRect viewFrame = self.centerContainerView.bounds;
    
    
    
    float toAlpha = 1.0f;
    float fromAlpha= 0.0f;
    
    
    
    if ( [[self.centerContainerView subviews] containsObject: _view2])
    {
        
        
        newController.view.frame = viewFrame;
        
        [newController.view setAutoresizingMask:( UIViewAutoresizingFlexibleWidth |
                                                 UIViewAutoresizingFlexibleHeight )];
        
        [_view1 setAutoresizesSubviews:YES];
        [_view1 addSubview: newController.view];
        
        
        _view1.frame = viewFrame;
        _view1.alpha = 0.0f;
        
        
        //add tu view hierarchy
        [self.centerContainerView addSubview:_view1];
        [self.centerContainerView sendSubviewToBack:_view1];
        
        
        if(animated)
        {
            
            [UIView animateWithDuration:0.4 animations:^{
                _view1.frame = viewFrame;
                _view2.frame = viewFrame;
                
                
                _view1.alpha = toAlpha;
                _view2.alpha = fromAlpha;
                
                
            } completion:^(BOOL finished) {
                _view1.frame = viewFrame;
                _view1.alpha = toAlpha;
                
                [_view2 removeFromSuperview];
                
                
                if(oldController!= nil)
                {
                    [oldController.view removeFromSuperview];
                    [oldController removeFromParentViewController];
                    
                }
                
                self.centerController = newController;
                [self addChildViewController:newController];
                [newController didMoveToParentViewController:self];
                
                _transitionCompleted=true;
                
                [self postUIEvent:ICOUIEventPresentedCenter];
                
                if(completionBlock)
                    completionBlock(true);
                
                
            }];
            
        }
        else
        {
            _view1.frame = viewFrame;
            _view1.alpha = toAlpha;
            
            [_view2 removeFromSuperview];
            
            
            if(oldController!= nil)
            {
                [oldController.view removeFromSuperview];
                [oldController removeFromParentViewController];
                
            }
            
            self.centerController = newController;
            [self addChildViewController:newController];
            [newController didMoveToParentViewController:self];
            
            _transitionCompleted=true;
            [self postUIEvent:ICOUIEventPresentedCenter];
            
            
            if(completionBlock)
                completionBlock(true);
            
        }
        
        
        
        
    }
    else
    {
        
        _view2.alpha=0.0;
        
        
        newController.view.frame = viewFrame;
        [_view2 addSubview: newController.view];
        
        [newController.view setAutoresizingMask:( UIViewAutoresizingFlexibleWidth |
                                                 UIViewAutoresizingFlexibleHeight )];
        
        [_view2 setAutoresizesSubviews:YES];
        
        _view2.frame = viewFrame;
        
        //add tu view hierarchy
        [self.centerContainerView addSubview:_view2];
        [self.centerContainerView sendSubviewToBack:_view2];
        
        
        if(animated)
        {
            [UIView animateWithDuration:0.4 animations:^{
                _view2.frame = viewFrame;
                _view1.frame = viewFrame;
                
                _view1.alpha = fromAlpha;
                _view2.alpha = toAlpha;
                
                
                
                
                
            } completion:^(BOOL finished) {
                _view2.frame = viewFrame;
                [_view1 removeFromSuperview];
                
                _view1.alpha = fromAlpha;
                _view2.alpha = toAlpha;
                
                
                if(oldController!= nil)
                {
                    [oldController.view removeFromSuperview];
                    [oldController removeFromParentViewController];
                    
                }
                
                self.centerController = newController;
                [self addChildViewController:newController];
                [newController didMoveToParentViewController:self];
                
                _transitionCompleted=true;
                
                [self postUIEvent:ICOUIEventPresentedCenter];
                
                
                if(completionBlock)
                    completionBlock(true);
                
            }];
        }
        else
        {
            
            _view2.frame = viewFrame;
            [_view1 removeFromSuperview];
            
            _view1.alpha = fromAlpha;
            _view2.alpha = toAlpha;
            
            
            if(oldController!= nil)
            {
                [oldController.view removeFromSuperview];
                [oldController removeFromParentViewController];
                
            }
            
            self.centerController = newController;
            [self addChildViewController:newController];
            [newController didMoveToParentViewController:self];
            
            _transitionCompleted=true;
            
          
            [self postUIEvent:ICOUIEventPresentedCenter];
            
            
            
            if(completionBlock)
                completionBlock(true);
            
            
        }
        
    }

    
}






-(void) dissmissTopViewControllerWithCompletion: (void (^) (bool result)) completionBlock

{
    
    
    if (_topTransitionInProgress)
    {
        return;
    }
    else
    {
    
        if(_topReveal==false)
        {
            [self postUIEvent:ICOUIEventDismissedLeftRight];
            
            
            if(completionBlock!=nil)
            {
                
                
                completionBlock(true);
                
                
            }
            return;
        
        }
    
    }
    
    
    
    if (_topTransitionInProgress && !_topReveal)
    {
        if(completionBlock!=nil)
        {
            completionBlock(true);
        }
        return;
    }

    UIViewController* topViewController=nil;
    
   
    if(_topViewState==1)
       topViewController = self.leftController;
    else
        topViewController=self.rightController;
    
    
    if(topViewController == nil)
    {
        return;
        
    }
    
    
    _topTransitionInProgress = true;
    _topReveal=false;
    _lastTopViewState=_topViewState;
    
    if(topViewController.parentViewController==nil)
        [self addChildViewController:topViewController];
    
    
    
    // Animate the transition by calling the animator with our private transition context. If we don't have a delegate, or if it doesn't return an animated transitioning object, we will use our own, private animator.
    
    id<UIViewControllerAnimatedTransitioning>animator = nil;
    
    animator = [[ICOAnimatedTransitioning alloc] init];
    
    
    ICOContextTransitioning *transitionContext = [[ICOContextTransitioning alloc]
                                                  initWithContainerController:  self
                                                  nextViewController: topViewController
                                                  ];
    
    transitionContext.animated = YES;
    
    // At the start of the transition, we need to find out if it should be interactive or not. We do this by trying to fetch an interaction controller.
    ICOInteractiveTransitioning* interactionController =(ICOInteractiveTransitioning*) [self _interactionControllerForAnimator:animator];
    
    
    if(interactionController!=nil)
    {
        
        [self.interactionController setAnimator:animator];
    }
    
    
    transitionContext.interactive = (interactionController != nil);
    
    
    transitionContext.completionBlock = ^(BOOL didComplete) {
        
        _topTransitionInProgress = false;
        
        
        if (didComplete) {
            
            
            [topViewController.view removeFromSuperview];
            [topViewController removeFromParentViewController];
            
            [self _finishTransitionToChildViewController:nil];
            
            
            if(completionBlock!=nil)
            {
                completionBlock(true);
            }
            
            [self postUIEvent:ICOUIEventDismissedLeftRight];
            
            
        }
        else
        {
            _topReveal=true;
            
        }
        
        
        NSLog(@"Top transition completed");
        
    };

    
    
    
    if ([transitionContext isInteractive]) {
        [interactionController startInteractiveTransition:transitionContext];
    } else {
        [animator animateTransition:transitionContext];
        
        
    }
    
    
    
}

-(void) presentTopViewController: (NSInteger) topViewState
       topViewController: (UIViewController*) topViewController
       completion: (void (^) (bool result)) completionBlock
{
    
    
    if (_topTransitionInProgress)
    {
        return;
    }
    else
    {
        if(_topReveal &&  _topViewState == topViewState)
        {
            if(completionBlock!=nil)
            {
                completionBlock(true);
                
                
            }
            return;
        }
    }
    
    if(topViewState==1)
    {
        
        if(topViewController!=nil)
            self.leftController= topViewController;
        
    
        topViewController=self.leftController;
    }
    else
    if (topViewState==2)
    {
        
        if(topViewController!=nil)
            self.rightController=topViewController;
        
    
        topViewController=self.rightController;
        
    }
    
    
    
    if(topViewController == nil)
    {
        return;
        
    }
    
    _topTransitionInProgress = true;
    _topReveal=true;
    _lastTopViewState=_topViewState;
    _topViewState=topViewState;
    
    
    if(topViewController.parentViewController==nil)
        [self addChildViewController:topViewController];
    
    
    
    // Animate the transition by calling the animator with our private transition context. If we don't have a delegate, or if it doesn't return an animated transitioning object, we will use our own, private animator.
    
    id<UIViewControllerAnimatedTransitioning>animator = nil;
    
    animator = [[ICOAnimatedTransitioning alloc] init];
    
    
    ICOContextTransitioning *transitionContext = [[ICOContextTransitioning alloc]
                                                  initWithContainerController:  self
                                                  nextViewController: topViewController
                                                  ];
    
    transitionContext.animated = YES;
    
    // At the start of the transition, we need to find out if it should be interactive or not. We do this by trying to fetch an interaction controller.
    ICOInteractiveTransitioning* interactionController =(ICOInteractiveTransitioning*) [self _interactionControllerForAnimator:animator];
    
    
    if(interactionController!=nil)
    {
        
        [self.interactionController setAnimator:animator];
    }
    
    
    transitionContext.interactive = (interactionController != nil);
    
   
    transitionContext.completionBlock = ^(BOOL didComplete) {
        
        
        _topTransitionInProgress = false;
        
        if (didComplete) {
            
            [topViewController didMoveToParentViewController:self];
            
            
            //remove the old view controller
            if(self.topViewController!=nil)
            {
                [self.topViewController.view removeFromSuperview];
                [self.topViewController removeFromParentViewController];
             
                
            }
            
            [self _finishTransitionToChildViewController:topViewController];
            
            if(_topViewState==2)
                [self postUIEvent:ICOUIEventPresentedRight];
            else
                [self postUIEvent:ICOUIEventPresentedLeft];
            
            if(completionBlock!=nil)
            {
                completionBlock(true);
            }
            
            
        }
        else
        {
            _topViewState = _lastTopViewState;
            [self _finishTransitionToChildViewController: self.topViewController];
            
            [topViewController.view removeFromSuperview];
        }
        NSLog(@"Top transition completed");
        
    };
    
    

    if ([transitionContext isInteractive]) {
        [interactionController startInteractiveTransition:transitionContext];
    } else {
        [animator animateTransition:transitionContext];
        
        
    }
    
    
}

- (void)_finishTransitionToChildViewController:(UIViewController *)topViewController {
    self.topViewController = topViewController;
    
    if (topViewController == nil)
    {
        _topViewState=0;
        
    }
    
}



@end


#pragma mark Animated transitions implementation for Draggable Left / Right View controllers
@interface ICOContextTransitioning ()
@property (nonatomic, strong) NSDictionary *privateViewControllers;
@property (nonatomic, assign) CGRect privateAppearingFromRect;
@property (nonatomic, assign) CGRect privateAppearingToRect;
@property (nonatomic, assign) CGRect privateDisappearingFromRect;
@property (nonatomic, assign) CGRect privateDisappearingToRect;
@property (nonatomic, weak) UIViewController *containerController;
@property (nonatomic, weak) UIViewController *nextViewController;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, assign) UIModalPresentationStyle presentationStyle;
@property (nonatomic, assign) BOOL transitionWasCancelled;
@end

@implementation ICOContextTransitioning

- (instancetype)initWithContainerController:(UIViewController *)containerController
                         nextViewController:(UIViewController *)nextViewController

{
    NSAssert ([containerController isViewLoaded] , @"The fromViewController view must reside in the container view upon initializing the transition context.");
    
    
    
    
    if ((self = [super init])) {
        
        ICOContainerViewController* icoContainerController = (ICOContainerViewController*) containerController;
        
        self.presentationStyle = UIModalPresentationCustom;
        self.containerController = icoContainerController;
        self.nextViewController = nextViewController;
        self.containerView = icoContainerController.mainContainerView;
        _transitionWasCancelled = NO;
        self.privateViewControllers =
        [NSDictionary dictionaryWithObjectsAndKeys:self.containerController, UITransitionContextFromViewControllerKey,
                                                   self.nextViewController, UITransitionContextToViewControllerKey,nil];
        
        
        // Set the view frame properties which make sense in our specialized ContainerViewController context.
       
        CGFloat appearOffset = (icoContainerController.topViewState==1 ? //left
                                  -(nextViewController.view.bounds.size.width):
                                  nextViewController.view.bounds.size.width);
        
        if( icoContainerController.topReveal)
        {
           
            CGRect appearRect = nextViewController.view.frame;
            
            self.privateAppearingToRect = appearRect;
            self.privateAppearingFromRect = CGRectOffset (appearRect, appearOffset, 0);
            
                        
            
            if(icoContainerController.topViewController !=nil)
            {
                
                CGFloat dissapearOffset = (icoContainerController.topViewState==2) ? //left
                                           -(icoContainerController.topViewController.view.bounds.size.width):
                                           (icoContainerController.topViewController.view.bounds.size.width);
                
                CGRect disappearRect = icoContainerController.topViewController.view.frame;
                
                
                self.privateDisappearingFromRect = disappearRect;
                self.privateDisappearingToRect =CGRectOffset (disappearRect, dissapearOffset, 0);
              
            }
            
            
        }
        else
        {
           
            if(icoContainerController.topViewController !=nil)
            {
                
                CGFloat dissapearOffset = (icoContainerController.topViewState==1) ? //left
                -(icoContainerController.topViewController.view.bounds.size.width):
                (icoContainerController.topViewController.view.bounds.size.width);
                
                CGRect disappearRect = icoContainerController.topViewController.view.frame;
                
                
                self.privateDisappearingFromRect = disappearRect;
                self.privateDisappearingToRect =CGRectOffset (disappearRect, dissapearOffset, 0);

                
                
            }
            
        }
        
        
        
    }
    return self;
}

- (CGRect)initialFrameForViewController:(UIViewController *)viewController {
    if (viewController == [self viewControllerForKey:UITransitionContextToViewControllerKey]) {
        return self.privateAppearingFromRect;
    } else {
        return self.privateDisappearingFromRect;
    }
}

- (CGRect)finalFrameForViewController:(UIViewController *)viewController {
    if (viewController == [self viewControllerForKey:UITransitionContextToViewControllerKey]) {
        return self.privateAppearingToRect;
    } else {
        return self.privateDisappearingToRect;
    }
}

- (UIViewController *)viewControllerForKey:(NSString *)key {
    return self.privateViewControllers[key];
}

- (void)completeTransition:(BOOL)didComplete {
    if (self.completionBlock) {
        self.completionBlock (didComplete);
    }
}


- (UIView *)viewForKey:(NSString *)key
{
    return nil;
}

- (CGAffineTransform)targetTransform
{
    return CGAffineTransformIdentity;
    
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {}
- (void)finishInteractiveTransition {self.transitionWasCancelled = NO;}
- (void)cancelInteractiveTransition {self.transitionWasCancelled = YES;}

@end


@implementation ICOAnimatedTransitioning



- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    if([transitionContext isInteractive])
        return 0.5;
    else
        return 0.5;
}

/// Slide views horizontally, with a bit of space between, while fading out and in.



- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    
    self.context = (ICOContextTransitioning*) transitionContext;
    
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    ICOContainerViewController* backViewController =(ICOContainerViewController*) [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
   
    UIView* mainContainer = backViewController.mainContainerView;
    UIViewController* curViewController =  backViewController.topViewController;
    UIView* centerContainer = backViewController.centerContainerView;
    
    
    float backStartAlpha= centerContainer.alpha;
    float backEndAlpha= 1.0f;
    
    
    
    if(backViewController.topReveal == false)
    {
      
        toViewController=nil;
        
        backEndAlpha = 1.0f;
        
        
        
    }
    else  if(backViewController.topViewState ==1)
    {
        
        if(toViewController == curViewController)
            curViewController=nil;
        
        
        backEndAlpha=1.0;
        
        
    }
    else  if(backViewController.topViewState ==2)
    {
        
        if(toViewController == curViewController)
            curViewController=nil;
        
        
        backEndAlpha=1.0;
        
    }
    
    
    if(backViewController.topReveal)
    {
        
        CGRect appearRect = [transitionContext initialFrameForViewController:toViewController];
        CGAffineTransform toStart = CGAffineTransformMakeTranslation (appearRect.origin.x, 0);
        CGAffineTransform toEnd = CGAffineTransformIdentity;
        
        toViewController.view.transform =  toStart;
        
        
        [mainContainer addSubview:toViewController.view];
            
        
        CGAffineTransform curStart = CGAffineTransformIdentity;
        CGAffineTransform curEnd;
        
        
        
        CGAffineTransform centerStart = CGAffineTransformIdentity;
        CGAffineTransform centerEnd = CGAffineTransformIdentity;
        
        
       
        
        if(curViewController!=nil)
        {
            CGRect disappearRect = [transitionContext finalFrameForViewController: curViewController];
           
            curEnd = CGAffineTransformMakeTranslation (disappearRect.origin.x, 0);
            curStart=CGAffineTransformIdentity;
            
            curViewController.view.transform = curStart;
            
            
        }
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0
                            options:0x00
                         animations:^{
                             
                             
                             toViewController.view.transform = toEnd;
                            
                             mainContainer.transform = centerEnd;
                             centerContainer.alpha = backEndAlpha;
                             
                             if(curViewController!=nil)
                                 curViewController.view.transform = curEnd;
                             
                             
                             
                            
                             
                         } completion:^(BOOL finished) {
                             
                             if(![transitionContext transitionWasCancelled])
                             {
                                 
                                 toViewController.view.transform = toEnd;
                                 
                                 mainContainer.transform = centerEnd;
                                 centerContainer.alpha = backEndAlpha;
                                 
                                 if(curViewController!=nil)
                                     curViewController.view.transform = curEnd;
                             }
                             else
                             {
                                 
                                 
                                 toViewController.view.transform = toStart;
                                 
                                 mainContainer.transform = centerStart;
                                 centerContainer.alpha = backStartAlpha;
                                 
                                 if(curViewController!=nil)
                                     curViewController.view.transform = curStart;
                                 
                             }
                             
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }];
    }
    else
    {
        
        
        CGRect disappearRect = [transitionContext finalFrameForViewController: backViewController];
        
        CGAffineTransform curEnd = CGAffineTransformMakeTranslation (disappearRect.origin.x, 0);
        CGAffineTransform curStart=CGAffineTransformIdentity;
        
        curViewController.view.transform = curStart;
        
        
        
        CGAffineTransform centerStart = CGAffineTransformIdentity;
        CGAffineTransform centerEnd = CGAffineTransformIdentity;
  
        
        
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0
                            options:0x00 animations:^{
                                
                                mainContainer.transform = centerEnd;
                                centerContainer.alpha = backEndAlpha;
                                
                                if(curViewController!=nil)
                                    curViewController.view.transform = curEnd;
                                
                                
                            } completion:^(BOOL finished) {
                                
                                
                                
                                
                                if(![transitionContext transitionWasCancelled])
                                {
                                    
                                    mainContainer.transform = centerEnd;
                                    centerContainer.alpha = backEndAlpha;
                                    
                                    if(curViewController!=nil)
                                        curViewController.view.transform = curEnd;
                                    
                                   
                                }
                                else
                                {
                                    
                                    mainContainer.transform = centerStart;
                                    centerContainer.alpha =backStartAlpha;
                                    
                                    if(curViewController!=nil)
                                        curViewController.view.transform = curStart;
                                    
                                    
                                    
                                }
                                
                                
                                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                            }];
        
        
        
    }
    
}



- (void)animationEnded:(BOOL) transitionCompleted {
    
    
    ICOContextTransitioning* transitionContext =  self.context;
    
    
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    ICOContainerViewController* backViewController =(ICOContainerViewController*) [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView* mainContainer = backViewController.mainContainerView;
    UIViewController* curViewController =  backViewController.topViewController;
    UIView* centerContainer = backViewController.centerContainerView;
    
    
    float backStartAlpha= centerContainer.alpha;
    float backEndAlpha= 1.0f;
    
    
    
    if(backViewController.topReveal == false)
    {
        
        toViewController=nil;
        
        backEndAlpha = 1.0f;
        
        
        
    }
    else  if(backViewController.topViewState ==1)
    {
        
        if(toViewController == curViewController)
            curViewController=nil;
        
        
        backEndAlpha=1.0;
        
        
    }
    else  if(backViewController.topViewState ==2)
    {
        
        if(toViewController == curViewController)
            curViewController=nil;
        
        
        backEndAlpha=1.0;
        
    }
    
    NSInteger topViewState = backViewController.topViewState;
    

    
    if(backViewController.topReveal)
    {
        CGRect appearRect = [transitionContext initialFrameForViewController:toViewController];
        CGAffineTransform toStart = CGAffineTransformMakeTranslation (appearRect.origin.x, 0);
        CGAffineTransform toEnd = CGAffineTransformIdentity;
        
        toViewController.view.transform =  toStart;
        
        [mainContainer addSubview:toViewController.view];
        
        CGAffineTransform curStart = CGAffineTransformIdentity;
        CGAffineTransform curEnd;
        
        
        
        CGAffineTransform centerStart = CGAffineTransformIdentity;
        CGAffineTransform centerEnd = CGAffineTransformIdentity;
        
        
        
        if(curViewController!=nil)
        {
            CGRect disappearRect = [transitionContext finalFrameForViewController: curViewController];
            
            curEnd = CGAffineTransformMakeTranslation (disappearRect.origin.x, 0);
            curStart=CGAffineTransformIdentity;
            
            curViewController.view.transform = curStart;
            
            
        }

        if(transitionCompleted)
        {
        
            toViewController.view.transform = toEnd;
            
            mainContainer.transform = centerEnd;
            centerContainer.alpha = backEndAlpha;
            
            if(curViewController!=nil)
                curViewController.view.transform = curEnd;
            
        }
        else {
            
            mainContainer.transform = centerStart;
            centerContainer.alpha =backStartAlpha;
            
            if(curViewController!=nil)
                curViewController.view.transform = curStart;

        }
    }
    else
    {
        CGRect disappearRect = [transitionContext finalFrameForViewController: backViewController];
        
        CGAffineTransform curEnd = CGAffineTransformMakeTranslation (disappearRect.origin.x, 0);
        CGAffineTransform curStart=CGAffineTransformIdentity;
        
        curViewController.view.transform = curStart;
        
        
        
        CGAffineTransform centerStart = CGAffineTransformIdentity;
        CGAffineTransform centerEnd = CGAffineTransformIdentity;
        
        
        
        if(topViewState==1)
        {
            centerStart = CGAffineTransformInvert( curEnd);
            
        }
        
        
        if(transitionCompleted)
        {
            
            mainContainer.transform = centerEnd;
            centerContainer.alpha = backEndAlpha;
            
            if(curViewController!=nil)
                curViewController.view.transform = curEnd;
            

        }
        else
        {
            
            mainContainer.transform = centerStart;
            centerContainer.alpha =backStartAlpha;
            
            if(curViewController!=nil)
                curViewController.view.transform = curStart;
            
            

        }

        
        
    
    }
}







@end

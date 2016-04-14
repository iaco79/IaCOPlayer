//
//  ICOPlayerViewController.m
//  ICOPlayer
//
//  Created by Othon Cruz on 4/10/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//
#import "ICOVIdeoManager.h"
#import "ICODBManager.h"
#import "ICPlayerControl.h"
#import "ICOPlayerViewController.h"
#import "ICOInteractiveTransitioning.h"
#import "ICOFileHelper.h"

// transition context for the settings-drawer interactive transition.
@interface DrawerTransitionContext : NSObject <UIViewControllerContextTransitioning>

- (instancetype)initWithController: (ICOPlayerViewController*) remoteController;


@property (nonatomic, copy) void (^completionBlock)(BOOL didComplete);
@property (nonatomic, assign, getter=isAnimated) BOOL animated;
@property (nonatomic, assign, getter=isInteractive) BOOL interactive;

@end

@interface DrawerAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, strong) DrawerTransitionContext *privateContext;

@end



@interface ICOPlayerViewController () <UIGestureRecognizerDelegate, UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UIView *bottomPanel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDurationLabel;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UISlider *mediaProgressSlider;
@property (weak, nonatomic) IBOutlet UIView *settingsDrawer;
@property (weak, nonatomic) IBOutlet UIView *drawerHandler;
@property (weak, nonatomic) IBOutlet UIButton *setFavoriteButton;
@property (weak, nonatomic) IBOutlet UIImageView *screenShot;
@property (weak, nonatomic) IBOutlet UIImageView *handlerImage;
@property (weak, nonatomic) IBOutlet UIView *playpauseAnimationView;
@property (weak, nonatomic) IBOutlet UILabel *lblError;
@property (weak, nonatomic) IBOutlet UITextField *titleEdit;



- (IBAction)onClickPause:(id)sender;
- (IBAction)onClickPlay:(id)sender;
- (IBAction)didSliderTouchInside:(id)sender;
- (IBAction)didSliderTouchOutside:(id)sender;
- (IBAction)didSliderValueChange:(id)sender;
- (IBAction)didSliderTouchCancel:(id)sender;
- (IBAction)didSliderTouchDown:(id)sender;
- (IBAction)didTapSettingsDrawer:(id)sender;
- (IBAction)didToggleFavorite:(id)sender;
- (IBAction)didTapScreenshot:(id)sender;
- (IBAction)didTapMovie:(id)sender;


@property (strong, nonatomic) UIActivityIndicatorView  *indicator;

@property (strong, nonatomic) ICOInteractiveTransitioning *drawerInteractionController;
@property (strong, nonatomic)  UIPanGestureRecognizer *drawerPanGesture;
@property (weak, nonatomic) IBOutlet UIView *playerControl;
@property (assign, nonatomic) BOOL settingsActive;


@property (strong) ICPlayerControl* icoPlayer;

@end

@implementation ICOPlayerViewController
{
    BOOL _isMediaSliderBeingDragged;
      bool _drawerTransition;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _settingsActive=false;
    
    
    self.icoPlayer = [ICPlayerControl alloc];

    NSURL* url=nil;
    
    
    if(self.videoLink == nil)
    {
   
    
        ICOVideoManager* videoManager = [ICOVideoManager new];
       
        NSArray* links =[videoManager getFavorites];
        
        if(links.count>0)
        {
            self.videoLink = links[0];
            url=[NSURL URLWithString: self.videoLink.linkURL];
   
            
            
        }
    }
    else
    {
        url=[NSURL URLWithString: self.videoLink.linkURL];

    }
    
    
    if(self.videoLink!=nil)
    {
    
        self.titleEdit.text = self.videoLink.linkDescription;
        
    }
    
    self.icoPlayer.url = url;
    self.icoPlayer= [self.icoPlayer initWithFrame:self.playerControl.bounds];
    [self.playerControl addSubview: self.icoPlayer];
    
    
    self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicator.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
    [self.playerControl addSubview:self.indicator];
   
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlayerDidFinishNotification:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object: self.icoPlayer.player];
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlayBackStateNotification:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object: self.icoPlayer.player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoadStateNotification:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object: self.icoPlayer.player];
    
    

    
    //setup settings drawer gesture
    
    self.drawerInteractionController =[[ICOInteractiveTransitioning alloc] init];
    
    
    self.drawerPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
    [self.drawerPanGesture setDelegate:self];
    [self.drawerHandler addGestureRecognizer:self.drawerPanGesture];
   
    
    [self refreshLinkSettings];
    
    
}

-(void) refreshLinkSettings
{
    
    if(self.videoLink!=nil)
    {
        
    
        if(self.videoLink.linkFavorite)
        {
            [self.setFavoriteButton setImage: [UIImage imageNamed:@"ic_favs"] forState:UIControlStateNormal];
            [self.setFavoriteButton setImage:[UIImage imageNamed:@"ic_favs_inactive"] forState:UIControlStateHighlighted];
            
            
        }
        else
        {
            
            [self.setFavoriteButton setImage:[UIImage imageNamed:@"ic_favs_inactive"] forState:UIControlStateNormal];
            [self.setFavoriteButton setImage:[UIImage imageNamed:@"ic_fav"] forState:UIControlStateHighlighted];
            
        }
    }
    

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self registerForUIEvents: true];
   
    
    self.indicator.center = self.playerControl.center;
    
    [self.indicator startAnimating];

    [self.icoPlayer preparePlay];

    
}

-(void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self layoutDrawer:false withDuration:0.0f completion:nil];
    self.indicator.center = self.playerControl.center;
    
    [self refreshMediaControl];
    
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    
    [self registerForUIEvents: false];
   
    
    [self.icoPlayer.player shutdown];
    
    
    [super viewDidDisappear:animated];
    
}

#pragma mark media control




-(void) onPlayerDidFinishNotification :(NSNotification* ) notif
{
    
    IJKFFMoviePlayerController* player =  (IJKFFMoviePlayerController*) notif.object;
    
    
    if(player == self.icoPlayer.player)
    {
        
        NSDictionary* userInfo = notif.userInfo;
        
        
        NSNumber* reason = [userInfo objectForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
        
        if ([reason integerValue] == IJKMPMovieFinishReasonPlaybackError)
        {
            self.lblError.hidden=false;
            
            
            [self.indicator stopAnimating];

        }
        
    }
}

-(void) onLoadStateNotification :(NSNotification*) notif
{
    IJKFFMoviePlayerController* player =  (IJKFFMoviePlayerController*) notif.object;
    
    
    if(player == self.icoPlayer.player)
    {
        
        IJKMPMovieLoadState loadState =  [self.icoPlayer.player loadState];
        
        [self.indicator stopAnimating];
        
        
        if( (loadState & IJKMPMovieLoadStatePlayable)
           ||  (loadState & IJKMPMovieLoadStatePlaythroughOK)
           )
        {
            self.lblError.hidden=true;
            
            
        }
        else
        {
            self.lblError.hidden=false;
            
        }
        
    }

}
-(void) onPlayBackStateNotification :(NSNotification*) notif
{

    
    IJKFFMoviePlayerController* player =  (IJKFFMoviePlayerController*) notif.object;
    
    
    if(player == self.icoPlayer.player)
    {
        
        IJKMPMoviePlaybackState playState=  [self.icoPlayer.player playbackState];

        if(playState == IJKMPMoviePlaybackStatePlaying)
        {
            self.lblError.hidden=true;
            
            [self.indicator stopAnimating];

        }
        
        
    }

}

- (void)beginDragMediaSlider
{
    _isMediaSliderBeingDragged = YES;
}

- (void)endDragMediaSlider
{
    _isMediaSliderBeingDragged = NO;
}

- (void)continueDragMediaSlider
{
    [self refreshMediaControl];
}


- (void)refreshMediaControl
{
    
    // duration
    NSTimeInterval duration = self.icoPlayer.player.duration;
    NSInteger intDuration = duration + 0.5;
    if (intDuration > 0) {
        self.mediaProgressSlider.maximumValue = duration;
        self.totalDurationLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(intDuration / 60), (int)(intDuration % 60)];
    } else {
        self.totalDurationLabel.text = @"--:--";
        self.mediaProgressSlider.maximumValue = 1.0f;
    }
    
    
    // position
    NSTimeInterval position;
    if (_isMediaSliderBeingDragged) {
        position = self.mediaProgressSlider.value;
    } else {
        position = self.icoPlayer.player.currentPlaybackTime;
    }
    NSInteger intPosition = position + 0.5;
    if (intDuration > 0) {
        self.mediaProgressSlider.value = position;
    } else {
        self.mediaProgressSlider.value = 0.0f;
    }
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(intPosition / 60), (int)(intPosition % 60)];
    
    
    // status
    BOOL isPlaying = [self.icoPlayer.player isPlaying];
    self.playButton.hidden = isPlaying;
    self.pauseButton.hidden = !isPlaying;
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshMediaControl) object:nil];
    //if (!self.overlayPannel.hidden) {
        [self performSelector:@selector(refreshMediaControl) withObject:nil afterDelay:0.5];
    //}
    
}




-(IBAction)onClickPlay:(id)sender {
    
    [self animateViewTap: self.playpauseAnimationView];
    
    
    [self.icoPlayer.player play];
    [self refreshMediaControl];
    
}


- (IBAction)onClickPause:(id)sender {
    
    
    [self animateViewTap: self.playpauseAnimationView];
    
    
    
    [self.icoPlayer.player pause];
    [self refreshMediaControl];
}


- (IBAction)didSliderTouchInside:(id)sender {
    
    self.icoPlayer.player.currentPlaybackTime = self.mediaProgressSlider.value;
    [self endDragMediaSlider];
    
}

- (IBAction)didSliderTouchOutside:(id)sender {
    
    [self  endDragMediaSlider];
}

- (IBAction)didSliderValueChange:(id)sender {
    [self  continueDragMediaSlider];
    
}

- (IBAction)didSliderTouchCancel:(id)sender {
    
    [self endDragMediaSlider];
}

- (IBAction)didSliderTouchDown:(id)sender {
    
    [self beginDragMediaSlider];
    
}

- (IBAction)didTapSettingsDrawer:(id)sender {
    
    
    if(!_settingsActive)
    {
        _settingsActive=true;
        
    //   [self layoutDrawer:true withDuration:0.5f  completion:nil];
        [self transitionDrawer:nil];
        
        
    }
    else
    {
        _settingsActive=false;
        
        [self transitionDrawer:nil];
        
    }

    
}

- (IBAction)didToggleFavorite:(id)sender {
    
    
    if(self.videoLink!=nil)
    {
    
        
        
        if(self.videoLink.linkFavorite == 1)
        {
            self.videoLink.linkFavorite=0;
        }
        else
        {
            
            self.videoLink.linkFavorite=1;
        }
        
        [self.videoLink update];
        [[ICODBManager sharedInstance] saveContext];
        
        
        [self refreshLinkSettings];
    }
    
    
    
}

- (IBAction)didTapScreenshot:(id)sender {
    
    //take a screen shot
    CGRect imageRect = CGRectMake(0.0, 0.0, 160.0, 90.0f);
    CGSize imageSize = imageRect.size;
    
    UIGraphicsBeginImageContextWithOptions(imageSize, self.playerControl.opaque, 0.0f);
    [self.playerControl drawViewHierarchyInRect:imageRect afterScreenUpdates:NO];
    UIImage * vwImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    NSData *data=UIImagePNGRepresentation(vwImage);
    
    
    if(self.videoLink!=nil)
    {
       [self.videoLink updateImage:data completion:^(bool result) {
    
           [self animateScreenShot];
           
       
       }];
    }
    
    
}

- (IBAction)didTapMovie:(id)sender {
    
    [[self navigator] performNavigatorAction:ICONavigatorActionDismissLeftRight];
    
}



-(void) animateScreenShot
{
    
    
    if(self.videoLink!=nil)
    {
        self.screenShot.transform = CGAffineTransformIdentity;
        CGAffineTransform trans = CGAffineTransformMakeTranslation(0.0, self.screenShot.frame.size.height);
        
        NSString* iconimage = [NSString stringWithFormat:@"%@", self.videoLink.linkIcon];
        
        if ([iconimage hasPrefix:@"ICOIMG"])
        {
            ICOFileHelper* fh = [ICOFileHelper new];
            NSString* imagePath = [fh getFilePath:iconimage];
            
            [self.screenShot setImage: [UIImage imageWithContentsOfFile: imagePath]];
            
            
            self.screenShot.alpha=1.0f;
            self.screenShot.hidden=false;
            
            
            [UIView animateWithDuration:1.0f
                             animations:^{
                                 
                                 self.screenShot.transform = trans;
                                 self.screenShot.alpha=0.0f;
                                 
                                 
                             }
                             completion:^(BOOL finished){
                                 self.screenShot.transform = trans;
                                 
                                 self.screenShot.hidden=true;
                                 
                             }
             ];
            
            
        }
    }
    

}




-(void) onUIEvent:(ICOUIEvent) event withParams: (NSDictionary*) params;
{
    
    if([self.titleEdit isFirstResponder])
        [self.titleEdit resignFirstResponder];
    
    if(event == ICOUIEventDismissedLeftRight)
    {
        _settingsActive=false;
        [self transitionDrawer:nil];
    
    }
    
    
}


#pragma mark text edit

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{

    if(self.videoLink!=nil)
    {
        
        NSString* text = textField.text;
        
       text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if(text.length > 0)
        {
        
            self.videoLink.linkDescription =text;
            [self.videoLink update];
         
            [textField resignFirstResponder];
            
            
        }
        
        
    }

    
    return YES;
    
}


#pragma mark settings Drawer


- (id<UIViewControllerInteractiveTransitioning>)_interactionControllerForAnimator:(id<UIViewControllerAnimatedTransitioning>)animator {
    
    if (self.drawerPanGesture!=nil  && self.drawerPanGesture.state == UIGestureRecognizerStateBegan)
    {
        self.drawerInteractionController.animator = animator;
        return self.drawerInteractionController;
    }
    else {
        
        return nil;
    }
}



-(void) transitionDrawer : (void (^) (bool result)) completionBlock
{
    
    if (_drawerTransition)
    {
        
        return;
    }
    _drawerTransition=true;
    
    
    id<UIViewControllerAnimatedTransitioning>animator = nil;
    
    animator = [[DrawerAnimatedTransition alloc] init];
    
    
    DrawerTransitionContext *transitionContext = [[DrawerTransitionContext alloc]
                                                  initWithController:self ];
    
    
    transitionContext.animated = YES;
    
    ICOInteractiveTransitioning* interactionController =(ICOInteractiveTransitioning*) [self _interactionControllerForAnimator:animator];
    
    
    if(interactionController!=nil)
    {
        
        [self.drawerInteractionController setAnimator:animator];
    }
    
    
    transitionContext.interactive = (interactionController != nil);
    
    if(_settingsActive)
    {
        
        
        transitionContext.completionBlock = ^(BOOL didComplete) {
            
            
            [[self navigator] postUIEvent:ICOUIEventDrawerTapped];
            
            if(!didComplete)
            {
            
                _settingsActive=false;
                
            }
            
            
            _drawerTransition = false;
    
            
        };
        
        
        
    }
    else
    {
        transitionContext.completionBlock = ^(BOOL didComplete) {
            [[self navigator] postUIEvent:ICOUIEventDrawerTapped];
            
            
            if(!didComplete)
            {
                
                _settingsActive=true;
                
            }
            

            
            _drawerTransition = false;
            
            
        };
        
        
    }
    
    if ([transitionContext isInteractive]) {
        [interactionController startInteractiveTransition:transitionContext];
    } else {
        [animator animateTransition:transitionContext];
        
        
    }
    
    
}




- (IBAction)onPanGesture:(id)sender {
    
    
    UIScreenEdgePanGestureRecognizer* recognizer = (UIScreenEdgePanGestureRecognizer*)sender;
    CGPoint speed = [recognizer velocityInView:self.view];
    
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint speed = [self.drawerPanGesture velocityInView:self.drawerHandler];
        
        
        if(speed.y >30 && !_settingsActive)
        {
            _settingsActive=true;        }
        else if(speed.y < -30 && _settingsActive)
        {
            _settingsActive=false;
        }
        
        
        
        [self transitionDrawer: nil];
        
        
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        
        
        
        if (_settingsActive)
        {
            CGPoint translation = [recognizer translationInView: self.view];
            CGFloat d = translation.y / (self.settingsDrawer.frame.size.height - self.drawerHandler.frame.size.height);
            
            
            if(d <0.0)
                d=0.0f;
            
            if( d>1.0f)
                d= 1.0f;
            
            
            [self.drawerInteractionController updateInteractiveTransition: 1.0*d];
            
            
            
            
        }
        else
        {
            CGPoint translation = [recognizer translationInView: self.view];
            CGFloat d = translation.y / (self.settingsDrawer.frame.size.height - self.drawerHandler.frame.size.height);
            
            d= -d;
            
            
            if(d <0.0)
                d=0.0f;
            
            if( d>1.0f)
                d= 1.0f;
            
            
            [self.drawerInteractionController updateInteractiveTransition: 1.0*d];
            
            
        }
    }
    else if (recognizer.state >= UIGestureRecognizerStateEnded) {
        
        if (_settingsActive)
        {
            CGPoint translation = [recognizer translationInView: self.view];
            CGFloat d = translation.y / (self.settingsDrawer.frame.size.height - self.drawerHandler.frame.size.height);
            
            
            if(d <0.0)
                d=0.0f;
            
            if( d>1.0f)
                d= 1.0f;
            
            if ((d > 0.4 && speed.y>=0) ||  (speed.y>100.0f) )
            {
                [self.drawerInteractionController finishInteractiveTransition];
            } else
            {
                [self.drawerInteractionController cancelInteractiveTransition];
            }
            
            
        }
        else
        {
            CGPoint translation = [recognizer translationInView: self.view];
            CGFloat d = translation.y / (self.settingsDrawer.frame.size.height - self.drawerHandler.frame.size.height);
            
            d= -d;
            
            
            if(d <0.0)
                d=0.0f;
            
            if( d>1.0f)
                d= 1.0f;
            
            if ((d > 0.4 && speed.y<=0) ||  (speed.y<-100.0f) )
            {
                [self.drawerInteractionController finishInteractiveTransition];
            } else
            {
                [self.drawerInteractionController cancelInteractiveTransition];
            }
            
            
            
        }
    }
    
    
    
}



- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    
    if (gestureRecognizer == self.drawerPanGesture)
    {
        CGPoint location = [gestureRecognizer locationInView:self.drawerHandler];
        
        CGPoint speed = [self.drawerPanGesture velocityInView:self.drawerHandler];
        
        
        if ((location.x> 50) && (location.x < (self.drawerHandler.frame.size.width-50)))
        {
            if(speed.y >30 && !_settingsActive)
            {
                return YES;
            }
            else if(speed.y < -30 && _settingsActive)
            {
                return YES;
            }
        }
        return NO;
    }
    
    
    return YES;
    
}






-(void) layoutDrawer: (BOOL) animated
        withDuration : (NSTimeInterval)
        duration completion: (void (^) (bool result)) completionBlock

{

    CGAffineTransform drawerTrans= CGAffineTransformIdentity;
    CGAffineTransform handlerImageTrans = CGAffineTransformIdentity;
    
    
    
    if(_settingsActive)
    {
        drawerTrans = CGAffineTransformMakeTranslation(0.0f,
                                                       self.settingsDrawer.frame.size.height- self.drawerHandler.frame.size.height );
        
        handlerImageTrans = CGAffineTransformMakeRotation(3.1416);
        
        
    }
    
    if(animated)
    {
        
        
        [UIView animateWithDuration:duration
                         animations:^{
                             
                             self.settingsDrawer.transform = drawerTrans;
                             self.handlerImage.transform = handlerImageTrans;
                             
                             
                         }
                         completion:^(BOOL finished){
                             self.settingsDrawer.transform = drawerTrans;
                             self.handlerImage.transform = handlerImageTrans;
                             
                             if (completionBlock)
                                 completionBlock (true);
                             
                         }
         ];
    }
    else
    {
        self.settingsDrawer.transform = drawerTrans;
        self.handlerImage.transform = handlerImageTrans;

        if (completionBlock)
            completionBlock (true);
        
        
        
    }

    
}




@end


@interface DrawerTransitionContext ()
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) UIViewController *mainController;
@property (nonatomic, assign) UIModalPresentationStyle presentationStyle;
@property (nonatomic, assign) BOOL transitionWasCancelled;

@end

@implementation DrawerTransitionContext

- (instancetype)initWithController: (ICOPlayerViewController*) remoteController
{
    
    if ((self = [super init])) {
        self.mainController= remoteController;
        self.containerView = remoteController.settingsDrawer;
        
        
    }
    return self;
}

- (CGRect)initialFrameForViewController:(UIViewController *)viewController {
    if (viewController == [self viewControllerForKey:UITransitionContextToViewControllerKey]) {
        return  self.mainController.view.frame;
    } else {
        return  self.mainController.view.frame;
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


- (CGRect)finalFrameForViewController:(UIViewController *)viewController {
    return self.mainController.view.frame;
}


- (UIViewController *)viewControllerForKey:(NSString *)key {
    return self.mainController;
}

- (void)completeTransition:(BOOL)didComplete {
    if (self.completionBlock) {
        self.completionBlock (didComplete);
    }
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {}
- (void)finishInteractiveTransition {self.transitionWasCancelled = NO;}
- (void)cancelInteractiveTransition {self.transitionWasCancelled = YES;}

@end




@implementation DrawerAnimatedTransition



- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    if([transitionContext isInteractive])
        return 0.5;
    else
        return 0.5;
}


- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    
    self.privateContext = (DrawerTransitionContext*) transitionContext;
    ICOPlayerViewController* controller = (ICOPlayerViewController*) self.privateContext.mainController;
    
    
    
    if (controller.settingsActive)
    {
        
        [controller layoutDrawer: true withDuration:[self transitionDuration:transitionContext] completion:^(bool result) {
            
            
            if([transitionContext transitionWasCancelled])
            {
                
                [controller layoutDrawer:false withDuration:0.0f completion:nil];
                
            }
            
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            
        }];
        
    }
    else
    {
        
        [controller layoutDrawer: true withDuration:[self transitionDuration:transitionContext] completion:^(bool result) {
            
            
            if([transitionContext transitionWasCancelled])
            {
                
                [controller layoutDrawer:false withDuration:0.0f completion:nil];
                
            }
            
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            
        }];
        
        
    }
}



- (void)animationEnded:(BOOL) transitionCompleted {
    
    ICOPlayerViewController* controller = (ICOPlayerViewController*) self.privateContext.mainController;
    
    if (controller.settingsActive)
    {
        controller.settingsActive=false;
        
        [controller layoutDrawer:false withDuration:0.0f completion:nil];
    }
    else
    {
        
        controller.settingsActive=true;
        
        [controller layoutDrawer:false withDuration:0.0f completion:nil];
    }
    
}
@end




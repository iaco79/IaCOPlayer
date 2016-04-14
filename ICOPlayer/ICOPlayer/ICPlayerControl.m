//
//  ICPlayerControl.m
//  ICOPlayer
//
//  Created by Othon Cruz on 4/10/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//

#import "ICPlayerControl.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
@interface ICPlayerControl ()

@property(strong) UIView* mainView;

@property (weak, nonatomic) IBOutlet UIView *movieView;


@end



@implementation ICPlayerControl
{
    BOOL _isMediaSliderBeingDragged;

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        
#ifdef DEBUG
        [IJKFFMoviePlayerController setLogReport:YES];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
        [IJKFFMoviePlayerController setLogReport:NO];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif
        
        
        [self setAutoresizingMask:( UIViewAutoresizingFlexibleWidth |
                                  UIViewAutoresizingFlexibleHeight )];
        
        
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"ICOPlayerControl" owner:self options:nil];
        self.mainView = [subviewArray objectAtIndex:0];
        self.mainView.frame = self.bounds;
        [self.mainView setAutoresizingMask:( UIViewAutoresizingFlexibleWidth |
                                          UIViewAutoresizingFlexibleHeight )];
        

        
        
        IJKFFOptions *options = [IJKFFOptions optionsByDefault];
        self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.url withOptions:options];
        self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.player.view.frame = self.bounds;
        self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
        self.player.shouldAutoplay = true;
        [self.player.view setAutoresizingMask:( UIViewAutoresizingFlexibleWidth |
                                   UIViewAutoresizingFlexibleHeight )];
        
        
        [self.movieView addSubview: self.player.view];
        [self addSubview:self.mainView];
        
        
        
        
    }
    return self;
    
}



-(void) preparePlay
{
    
    [self.player prepareToPlay];
}

-(void) layoutSubviews
{
    
    self.mainView.frame = self.bounds;
    self.player.view.frame = self.movieView.bounds;
    
    
    [super layoutSubviews];
    
    
}


@end

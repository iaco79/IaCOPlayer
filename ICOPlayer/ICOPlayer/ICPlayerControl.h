//
//  ICPlayerControl.h
//  ICOPlayer
//
//  Created by Othon Cruz on 4/10/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IJKMediaFramework/IJKMediaFramework.h>
@interface ICPlayerControl : UIControl



@property(atomic,strong) NSURL *url;
- (id)initWithFrame:(CGRect)frame;

@property(atomic, strong) id<IJKMediaPlayback> player;

-(void) preparePlay;

@end

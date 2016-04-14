//
//  ICOVideoLink.h
//  ICOPlayer
//
//  Created by Othon Cruz on 4/11/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//

#import <Foundation/Foundation.h>


@class VideoLink;

@interface ICOVideoLink : NSObject


@property (assign) NSInteger linkOrder;

@property (assign) NSInteger linkFavorite;

@property NSString* linkDescription;

@property NSString* linkURL;

@property NSString* linkIcon;


/** initialize with title **/
-(id) initWithLink: (NSString*) linkURL andTitle: linkTitle;



/** Get the associated managed object */
@property (readonly) VideoLink* videoObject;

/** Initialize with NSManagedobject */
-(id) initWithVideoObject: (VideoLink*) videoObject;

/** Update the NSManagedobject*/
-(void) update;

-(void) updateImage :( NSData*) imgData  completion : (void (^) (bool)) completionBlock;



@end

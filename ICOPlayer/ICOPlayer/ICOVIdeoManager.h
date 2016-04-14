//
//  VIdeoManager.h
//  ICOPlayer
//
//  Created by Othon Cruz on 4/11/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICOVideoLink.h"


typedef enum : NSUInteger {
    
    ICOFLag_Sync=0x01
    
} ICOFlags;


@interface ICOVideoManager : NSObject



-(NSArray*) getFavorites;

-(void) initTestLinks;

-(void) clearAll;


-(void) getLinksFromURL :(NSString* )url completion : (void (^) (NSArray* links)) completionBlock;

-(void) searchLinksWithFilter :(NSString* )filter completion : (void (^) (NSArray* links)) completionBlock;


//NSUserDefaults flags
-(void) setFlag : (ICOFlags) flag value:(bool) value;
-(void) clearFlags;
-(bool) getFlag : (ICOFlags) flag;



@end

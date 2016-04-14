//
//  ICOVideoLinkRequest.h
//  ICOPlayer
//
//  Created by Othon Cruz on 4/12/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICOURLRequest : NSObject 


-(void) requestDataFromURL :(NSString*) dataUrl completionHandler: (void (^)(NSData* data))  completionHandler;

@end

//
//  ICOVideoLink.m
//  ICOPlayer
//
//  Created by Othon Cruz on 4/11/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//

#import "ICOVideoLink.h"
#import "VideoLink.h"
#import "ICODBManager.h"
#import "ICOFileHelper.h"


@interface ICOVideoLink ()

@property (weak) VideoLink* videoLinkDbo;


@end

@implementation ICOVideoLink


-(id) initWithVideoObject: (VideoLink*) videoObject
{

    self = [super init];

    if(self)
    {
        self.videoLinkDbo = videoObject;
        self.linkDescription = videoObject.videoDescription;
        self.linkFavorite = [videoObject.videoFavorite integerValue];
        self.linkOrder = [videoObject.videoOrder integerValue];
        self.linkURL = videoObject.videoUrl;
        self.linkIcon = videoObject.videoIcon;
        
    }

    return self;

}

-(id) initWithLink: (NSString*) linkURL andTitle: linkTitle
{
    self = [super init];
    
    if(self)
    {
        self.videoLinkDbo = nil;
        self.linkDescription = linkTitle;
        self.linkFavorite = 0;
        self.linkOrder = 0;
        self.linkURL = linkURL;
        self.linkIcon = @"Icon000";
        
        
    }
    
    return self;

}


-(void) update
{
    if( (self.videoLinkDbo== nil) || (self.videoLinkDbo.managedObjectContext == nil))
    {
       NSPredicate* pred = [NSPredicate predicateWithFormat:@"videoUrl=%@", self.linkURL ];
       NSArray* found = [[ICODBManager sharedInstance] findAllWithPredicate:[VideoLink class] withPredicate:pred];
        
       if(found.count>0)
       {
           self.videoLinkDbo = found[0];
            
       }
       else
       {
           self.videoLinkDbo = [[ICODBManager sharedInstance] createObject: [VideoLink class]];
       }
        
    }
    
    [self.videoLinkDbo updateWithICOVideoLink: self];
    
}

-(VideoLink*) videoObject
{
    
    return self.videoLinkDbo;;
}


-(void) updateImage :(NSData*) imgData completion : (void (^) (bool)) completionBlock
{

    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        bool needsImageName =true;
        NSString* imageName = self.linkIcon;
        ICOFileHelper* fileHelper = [ICOFileHelper new];
        
       
        if(self.linkIcon !=nil)
        {
            
            if([imageName hasPrefix:@"ICOIMG"])
                needsImageName=false;
        }
        
        
        if(needsImageName)
        {
            imageName = [fileHelper genFileName];
            
        }
        
        bool result = [fileHelper saveFile:imgData withFileName: imageName];
        self.linkIcon = imageName;
        [self update];
        
        [[ICODBManager sharedInstance] saveContext];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            completionBlock(result);
            
        });

    
        
        
    });

    
   
}







@end

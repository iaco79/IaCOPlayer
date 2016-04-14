//
//  VIdeoManager.m
//  ICOPlayer
//
//  Created by Othon Cruz on 4/11/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//
#import "ICODBManager.h"
#import "VideoLink.h"
#import "ICOVIdeoManager.h"
#import "ICOVideoLink.h"
#import "ICOURLRequest.h"
#import "ICOLinkScrapper.h"

#define kICOFlagKey @"ICOPlayerFlags"


//TODO: define the web page link containing public m3u8 links
#define kICOLINKSUrl  @""



@implementation ICOVideoManager


-(NSArray*) getFavorites
{
    NSPredicate* pred =[NSPredicate predicateWithFormat:@"videoFavorite=1"];
    
    NSArray* videoObjects = [[ICODBManager sharedInstance] findAllWithPredicate: [VideoLink class] withPredicate: pred];
    
    
    NSMutableArray* array = [NSMutableArray new];
    
    for(VideoLink* videoObject in videoObjects)
    {
        ICOVideoLink* icoLink = [[ICOVideoLink alloc] initWithVideoObject:videoObject];
        
        [array addObject:icoLink];
        
    }
    
    return [array copy];
    
}

-(void) clearAll
{
    NSArray* videoObjects = [[ICODBManager sharedInstance] findAll :[VideoLink class] ];
  
    for(VideoLink* videoObject in videoObjects)
    {
        [[ICODBManager sharedInstance] deleteObject: videoObject];
        
    }
    
    [[ICODBManager sharedInstance] saveContext];
    
    
}



-(void) getLinksFromURL :(NSString* )url completion : (void (^) (NSArray* links)) completionBlock
{
    //perform async request to scrap web page
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        ICOURLRequest* icoRequest = [ICOURLRequest new];
        
        [icoRequest requestDataFromURL:url completionHandler:^(NSData *data) {
            
            NSArray* links=nil;
            
            
            if(data!=nil)
            {
            
                ICOLinkScrapper* parser = [ICOLinkScrapper new];
                
                links = [parser getLinksFromHTMLData:data];
            
            }
            
        
           dispatch_async(dispatch_get_main_queue(), ^{
               
               completionBlock(links);
               
           });
            
            
            
        }];
        
        
    });
    
    

}


-(void) searchLinksWithFilter :(NSString* )filter completion : (void (^) (NSArray* links)) completionBlock
{
    
    bool hasSync= [self getFlag: ICOFLag_Sync];
    
    if (!hasSync)
    {
        
        [self _syncLinksWithCompletion:^{
            NSArray* filteredLinks = [self _searchLinksWithFilter : filter];
            completionBlock(filteredLinks);

        }];
        
    }
    else
    {
        
        NSArray* filteredLinks = [self _searchLinksWithFilter : filter];
        
        completionBlock(filteredLinks);
        
    }
    
}


-(void) _syncLinksWithCompletion: (void (^) (void)) completionBlock
{

    [self getLinksFromURL: kICOLINKSUrl completion:^(NSArray *links) {
        
        
        if(links!=nil && links.count>0)
        {
            //reload but keep favorites
            
            
            NSMutableArray* favs = [NSMutableArray arrayWithArray:[self getFavorites]];
            
            
            
            [self clearAll];
            
            
            
            for (ICOVideoLink* link  in links)
            {
                NSPredicate* pred = [NSPredicate predicateWithFormat:@"linkURL=%@", link.linkURL ];
                NSArray* favFound  = [favs filteredArrayUsingPredicate:pred];
                
                if(favFound.count>0)
                {
                    
                    ICOVideoLink* favorite = favFound[0];
                    link.linkFavorite=1;
                    link.linkOrder= favorite.linkOrder;
                    link.linkIcon = favorite.linkIcon;
                    
                    [favs removeObject:favorite];
                    
                }
                
                [link update];
            };
            
            for (ICOVideoLink* link  in favs)
            {
                [link update];
            }
            
            
            [[ICODBManager sharedInstance] saveContext];
         
            [self setFlag:ICOFLag_Sync value:true];
            
            
        }
        
        completionBlock();
        

        
    }];

    
    
    
}	

-(NSArray*) _searchLinksWithFilter : (NSString*) filter
{

    NSString* searchString = [filter stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
   
    NSArray* videoObjects=nil;
    
    if(searchString!=nil && searchString.length>0)
    {
        NSPredicate* pred = [NSPredicate predicateWithFormat:@"(videoDescription CONTAINS[cd] %@) OR (videoUrl CONTAINS[cd] %@) ", searchString, searchString];
        videoObjects = [[ICODBManager sharedInstance] findAllWithPredicate: [VideoLink class] withPredicate: pred];
        
    }
    else
    {
        videoObjects = [[ICODBManager sharedInstance] findAll:[VideoLink class]];
    
    }
    
    
    NSMutableArray* array = [NSMutableArray new];
    
    for(VideoLink* videoObject in videoObjects)
    {
        ICOVideoLink* icoLink = [[ICOVideoLink alloc] initWithVideoObject:videoObject];
        
        [array addObject:icoLink];
        
    }
    
    return [array copy];

    
    
}


-(void) setFlag : (ICOFlags) flag value:(bool) value
{
    
    NSInteger flags = [[NSUserDefaults standardUserDefaults] integerForKey:kICOFlagKey];
    
    if(value)
        flags = flags | flag;
    else
        flags = flags & (~flag);
    
    [[NSUserDefaults standardUserDefaults] setInteger:flags forKey:kICOFlagKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    
}

-(bool) getFlag : (ICOFlags) flag
{
    
    NSInteger flags = [[NSUserDefaults standardUserDefaults] integerForKey:kICOFlagKey];
    bool flagValue = (flags & flag)>0;
    
    return flagValue;
    
    
}

-(void) clearFlags
{
    NSInteger flags =0;
    
    
    [[NSUserDefaults standardUserDefaults] setInteger:flags forKey:kICOFlagKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void) initTestLinks
{

    
    VideoLink* first = [[ICODBManager sharedInstance] findFirst: [VideoLink class]];
    
    
    if(first==nil)
    {
        
        NSLog(@"Adding some test links");
        
    
        ICOVideoLink* link1= [ICOVideoLink new];
        link1.linkOrder=1;
        link1.linkURL=@"http://iphone-streaming.ustream.tv/uhls/6540154/streams/live/iphone/playlist.m3u8";
        link1.linkFavorite=1;
        link1.linkDescription= @"NASA CHANNEL";
        link1.linkIcon=@"icon001";
        
        ICOVideoLink* link2= [ICOVideoLink new];
        link2.linkOrder=2;
        link2.linkURL=@"http://74.63.97.188:1935/c7/videoc7/live.m3u8";
        link2.linkFavorite=1;
        link2.linkDescription= @"Guadalajara";
        link2.linkIcon=@"icon002";
        
        ICOVideoLink* link3= [ICOVideoLink new];
        link3.linkOrder=3;
        link3.linkURL=@"http://video.gvstream.net:1935/e-tv-video/default.stream/live.m3u8";
        link3.linkFavorite=1;
        link3.linkDescription= @"Monterrey";
        link3.linkIcon=@"icon003";
        
        
        [link1 update];
        [link2 update];
        [link3 update];
        
        [[ICODBManager sharedInstance] saveContext];
   
        
    }
    else
    {
        
        NSLog(@"Links in DB ready");
       
    
    }
}


@end

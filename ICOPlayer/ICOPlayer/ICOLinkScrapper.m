//
//  ICOLinkScrapper.m
//  ICOPlayer
//
//  Created by Othon Cruz on 4/12/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//

#import "ICOLinkScrapper.h"
#import "ICOVideoLink.h"

@implementation ICOLinkScrapper



-(NSString*) reverseString : (NSString*) string
{

    NSInteger len = [string length];
    NSMutableString *reversed = [[NSMutableString alloc] initWithCapacity:len];
    
    for(NSInteger i=len-1;i>=0;i--)
    {
        unichar c = [string characterAtIndex:i];
        
        [reversed appendFormat:@"%c", c];
        
    }
    
    return reversed;
    
}

-(NSArray*) getLinksFromHTMLData : (NSData*) data
{
    NSMutableArray* links = [NSMutableArray new];
    
    
    NSString *token = [self reverseString: @"EXTINF:"];
    
    
    //regexp for finding the title
    NSString *titlePattern = [NSString stringWithFormat:@"(%@)", token];
    
    
    //regexp for finding the links
    NSString *linkPattern = @"http(s)?://([\\w-]+\\.)+[\\w-]+(/[\\w- ./?%&amp;=]*)?";

    
    NSRegularExpression* titleRegex = [NSRegularExpression regularExpressionWithPattern:titlePattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:linkPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *reversed = [self reverseString:string];
    
    //find the first link
    NSTextCheckingResult* match = [regex firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
    
    
    //how many links to test
    int maxMatch=1000;
    
    NSInteger stringLength = [string length];
    
    
    while(maxMatch>0)
    {
        if(match==nil)
            break;
        
        NSRange matchRange = [match range];
        
        NSString* matchedString = [string substringWithRange: matchRange];
        
        //found link
        if ([matchedString hasSuffix:@".m3u8"])
        {
            NSLog(@"** MATCHED : %@", matchedString);
            
            //try to find the description
            NSString* titleString = nil;
            
            
            NSInteger titleSearchStart = stringLength - matchRange.location;
            NSTextCheckingResult* titleMatch = [titleRegex firstMatchInString:reversed options:0 range:NSMakeRange( titleSearchStart, [reversed length]- titleSearchStart)];
            
            if(titleMatch !=nil)
            {
              
                
                NSRange titleMatchRange = [titleMatch range];
                NSInteger ts = stringLength - titleMatchRange.location;
                NSInteger lenght =matchRange.location -ts;
                
                if(lenght>0)
                {
                    NSRange finalRange = NSMakeRange(ts, matchRange.location -ts );
                    
                    NSString *rawTitle = [string substringWithRange: finalRange];

                    NSRange cleanRange = [rawTitle rangeOfString:@"<br"];
                    
                    
                    if( cleanRange.location != NSNotFound)
                    {
                        
                        cleanRange.length = MIN(40, cleanRange.length);
                    
                        titleString = [rawTitle substringWithRange: NSMakeRange(0, cleanRange.location)];
                  
                        NSLog(@">>>* WITH title : %@", titleString);
                    
                    }
                    
                }
                
            
            }
            
            
            if( titleString==nil)
            {
                NSLog(@">>>* NO title : %@", titleString);
                
                titleString = @"No Description";
                
            }
            
        
            
            ICOVideoLink* link= [[ICOVideoLink alloc] initWithLink: matchedString andTitle: titleString];
            
            [links addObject:link];
            
            
            
            maxMatch= maxMatch+10;
            
        }
        
        NSInteger nextStart = matchRange.location+matchRange.length;
        
        if(nextStart < [string length])
        {
            match = [regex firstMatchInString:string options:0 range:NSMakeRange( nextStart, stringLength-nextStart)];
        
        }
        else
        {
            break;
        }
    
    
        maxMatch--;
    }
    
  
    
    return [links copy];
    
}


@end

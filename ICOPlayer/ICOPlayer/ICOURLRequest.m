//
//  ICOVideoLinkRequest.m
//  ICOPlayer
//
//  Created by Othon Cruz on 4/12/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//

#import "ICOURLRequest.h"



@implementation ICOURLRequest

-(void) requestDataFromURL :(NSString*) dataUrl completionHandler: (void (^)(NSData* data))  completionHandler
{
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:dataUrl]];
                             
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData * _Nullable data,
                                                                    NSURLResponse * _Nullable response,
                                                                    NSError * _Nullable error) {
       
        if(completionHandler !=nil)
            completionHandler(data);
        
    }];
    
    
    [dataTask resume];
    
    
}


@end

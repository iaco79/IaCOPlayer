//
//  ICOFileHelper.m
//  ICOPlayer
//
//  Created by Othon Cruz on 4/13/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//

#import "ICOFileHelper.h"

@implementation ICOFileHelper


-(NSString*) genFileName
{
    
    NSString *prefixString = @"ICOIMG";
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@", prefixString, guid];
    return uniqueFileName;
    
   
}

-(NSString*) getFilePath :(NSString*) fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *strPath = [documentsDirectory stringByAppendingPathComponent:fileName];

    return strPath;
    

}

-(bool) saveFile: (NSData*) fileData withFileName: (NSString*) fileName
{
    NSString* strPath = [self getFilePath:fileName];
    [fileData writeToFile:strPath atomically:YES];

    
    return  true;
    
}


@end

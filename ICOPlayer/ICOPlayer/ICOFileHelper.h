//
//  ICOFileHelper.h
//  ICOPlayer
//
//  Created by Othon Cruz on 4/13/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICOFileHelper : NSObject

-(NSString*) genFileName;
-(bool) saveFile: (NSData*) fileData withFileName: (NSString*) fileName;
-(NSString*) getFilePath :(NSString*) fileName;

@end

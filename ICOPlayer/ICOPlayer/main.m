//
//  main.m
//  ICOPlayer
//
//  Created by Othon Cruz on 4/9/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


#if defined(DEBUG)
    #import "QTouchposeApplication.h"
#endif



int main(int argc, char * argv[]) {
    @autoreleasepool {
        
        
#if defined(DEBUG)
        
    //Touchpose is a set of classes for iOS that renders screen touches when a device is connected to a mirrored display
    //Use only for Debug builds when presenting using webex
        
        
#if defined(USETOUCHPOSE) 
        return UIApplicationMain(argc, argv,
                                 NSStringFromClass([QTouchposeApplication class]),
                                 NSStringFromClass([AppDelegate class]));

#else
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
#endif
        
        
#else
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        
#endif
        
      }
}

//
//  RainbowAppDelegate.h
//  Rainbow
//
//  Created by John Heaton on 5/29/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RainbowAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end

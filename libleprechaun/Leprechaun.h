//
//  Leprechaun.h
//  Rainbow
//
//  Created by John Heaton on 5/30/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDListener.h"


@interface LeprechaunModule : NSObject {
@private
    NSNumber *_loaded;
    NSBundle *_currentBundle;
}

- (void)setup; // do basic setup here
- (void)tearDown; // get cleaned up before killed

- (void)start;

- (NSString *)userPresentableName;

- (void)sendLogMessage:(NSString *)message;
- (void)sendErrorLogMessage:(NSString *)message;

- (NSSize)requiredViewSize; // how big the view needs to be
- (NSView *)rootView;

- (BOOL)shouldUnloadOnDeselection; // default = YES

- (void)lockModuleSelector; // locks the selection list so that a user may not leave/unload the current module while it's operating... could be hazardous to device
- (void)unlockModuleSelector;

- (BOOL)isLoaded; // Used only by loader. DO NOT OVERRIDE

@property (readonly) NSBundle *currentBundle;

@end

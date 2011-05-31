//
//  Leprechaun.m
//  Rainbow
//
//  Created by John Heaton on 5/30/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import "Leprechaun.h"
#import "RainbowAppDelegate.h"

#define UserPresentableLogMessage(message) message

@implementation LeprechaunModule

@synthesize currentBundle=_currentBundle;

- (id)init {
    if((self = [super init]) != nil) {
        _loaded = [[NSNumber numberWithBool:NO] retain];
    }
    
    return self;
}

- (void)setup {
    
}

- (void)start {
    
}

- (void)tearDown {
    
}

- (NSString *)userPresentableName {
    return nil;
}

- (void)sendLogMessage:(NSString *)message {
    [((RainbowAppDelegate *)[NSApp delegate]) logStringSimple:UserPresentableLogMessage(message) senderName:[self userPresentableName]];
}

- (void)sendErrorLogMessage:(NSString *)message {
    [((RainbowAppDelegate *)[NSApp delegate]) logErrorString:UserPresentableLogMessage(message) senderName:[self userPresentableName]];
}

- (BOOL)isLoaded {
    return [_loaded boolValue];
}

- (void)dealloc {
    [_loaded release];
    [_currentBundle release];
    [super dealloc];
}

- (BOOL)enableProgressBarAtStart {
    return NO;
}

- (BOOL)shouldUnloadOnDeselection {
    return YES;
}

- (NSSize)requiredViewSize {
    return NSMakeSize(500, 500);
}

- (void)lockModuleSelector {
    [((RainbowAppDelegate *)[NSApp delegate]) setModuleSelectorLocked:YES];
}

- (void)unlockModuleSelector {
    [((RainbowAppDelegate *)[NSApp delegate]) setModuleSelectorLocked:NO];
}

- (NSView *)rootView {
    return nil;
}

@end
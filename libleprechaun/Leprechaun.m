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

@implementation LeprechaunSimpleModule 

@synthesize delegate=_delegate, currentBundle;

- (id)init {
    if((self = [super init]) != nil) {
        _loaded = [[NSNumber numberWithBool:NO] retain];
    }
    
    return self;
}

- (void)setup {
    [_loaded release];
    _loaded = [[NSNumber numberWithBool:YES] retain];
}

- (void)start {
    
}

- (void)tearDown {
    [_loaded release];
    _loaded = [[NSNumber numberWithBool:NO] retain];
}

- (BOOL)shouldUnloadOnDeselection {
    return YES;
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
    [currentBundle release];
    [super dealloc];
}

@end


@implementation LeprechaunUIModule

- (BOOL)enableProgressBarAtStart {
    return NO;
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
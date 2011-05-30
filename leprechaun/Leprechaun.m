//
//  Leprechaun.m
//  Rainbow
//
//  Created by John Heaton on 5/30/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import "Leprechaun.h"
#import "RainbowAppDelegate.h"


@implementation LeprechaunSimpleModule 

@synthesize delegate=_delegate;

- (id)initWithDelegate:(id<LeprechaunModuleDelegate>)delegate {
    if(!delegate) return nil;
    
    if((self = [super init]) != nil) {
        _delegate = delegate;
    }
    
    return self;
}

- (void)setup {
    
}

- (void)unload {
    
}

- (void)sendLogMessage:(NSString *)message {
    [((RainbowAppDelegate *)NSApp) logStringSimple:message];
}

- (void)sendErrorLogMessage:(NSString *)message {
    [((RainbowAppDelegate *)NSApp) logString:message color:[NSColor redColor] fontSize:12];
}

@end


@implementation LeprechaunUIModule

- (BOOL)enableProgressBarAtStart {
    return NO;
}

- (NSSize)requiredViewSize {
    return NSMakeSize(500, 500);
}

- (void)setProgressBarVisible:(BOOL)visible animated:(BOOL)animated {
    [((RainbowAppDelegate *)NSApp) showProgressBar:visible animated:animated];
}

- (void)setProgressBarIsIndeterminate:(BOOL)indeterminate {
    [((RainbowAppDelegate *)NSApp).progressBar setIndeterminate:indeterminate];
}

- (void)updateProgressTitle:(NSString *)title {
    [((RainbowAppDelegate *)NSApp).progressLabel setStringValue:title];
}

- (void)updateProgress:(CGFloat)percent {
    [((RainbowAppDelegate *)NSApp).progressBar setDoubleValue:percent];
}

- (void)lockModuleSelector {
    [((RainbowAppDelegate *)NSApp) setModuleSelectorLocked:YES];
}

- (void)unlockModuleSelector {
    [((RainbowAppDelegate *)NSApp) setModuleSelectorLocked:NO];
}

@end
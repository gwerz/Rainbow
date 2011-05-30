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
    NSTextView *logView;
    NSDrawer *logDrawer;
    BOOL progressBarVisible;
    NSProgressIndicator *progressBar;
    NSTextField *progressLabel;
    IBOutlet NSTableView *tableScrollView;
}

- (void)logString:(NSString *)string color:(NSColor *)color fontSize:(CGFloat)size;
- (void)logStringSimple:(NSString *)string;

- (void)showProgressBar:(BOOL)show animated:(BOOL)animated;
- (void)setModuleSelectorLocked:(BOOL)locked;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextView *logView;
@property (assign) IBOutlet NSDrawer *logDrawer;
@property (assign) IBOutlet NSProgressIndicator *progressBar;
@property (assign) IBOutlet NSTextField *progressLabel;

@end

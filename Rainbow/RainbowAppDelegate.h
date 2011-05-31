//
//  RainbowAppDelegate.h
//  Rainbow
//
//  Created by John Heaton on 5/29/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MDListener.h"


@interface RainbowAppDelegate : NSObject <NSApplicationDelegate, MDListener, NSTableViewDataSource> {
@private
    NSWindow *window;
    NSTextView *logView;
    NSDrawer *logDrawer;
    IBOutlet NSTableView *tableScrollView;
    IBOutlet NSImageView *statusOrbView;
    IBOutlet NSTextField *connectedDeviceLabel;
    IBOutlet NSBox *moduleView;
    id _currentModuleView;
}

- (void)logString:(NSString *)string color:(NSColor *)color fontSize:(CGFloat)size senderName:(NSString *)name;
- (void)logErrorString:(NSString *)string senderName:(NSString *)name;
- (void)logStringSimple:(NSString *)string senderName:(NSString *)name;

- (void)setModuleSelectorLocked:(BOOL)locked;
- (BOOL)resizeModuleViewToSize:(NSSize)size;

- (void)setCurrentModuleView:(NSView *)view;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextView *logView;
@property (assign) IBOutlet NSDrawer *logDrawer;
@property (assign) IBOutlet NSProgressIndicator *progressBar;
@property (assign) IBOutlet NSTextField *progressLabel;
@property (assign) NSBox *moduleView;
@property (assign) id _currentModuleView;

@end

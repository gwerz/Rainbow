//
//  RainbowAppDelegate.h
//  Rainbow
//
//  Created by John Heaton on 5/29/11.
//  Copyright 2011 GJB Software. All rights reserved.
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
    NSInteger previousCell;
    BOOL hasReloadedTable;
    IBOutlet NSView *noModuleView;
}

- (void)logString:(NSString *)string color:(NSColor *)color fontSize:(CGFloat)size senderName:(NSString *)name;
- (void)logErrorString:(NSString *)string senderName:(NSString *)name;
- (void)logStringSimple:(NSString *)string senderName:(NSString *)name;

- (void)setModuleSelectorLocked:(BOOL)locked;
- (BOOL)resizeModuleViewToSize:(NSSize)size;

- (void)setCurrentModuleView:(NSView *)view;
- (void)reloadTable;

- (void)centerWindow;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextView *logView;
@property (assign) IBOutlet NSDrawer *logDrawer;
@property (assign) NSBox *moduleView;
@property (assign) id _currentModuleView;

@end

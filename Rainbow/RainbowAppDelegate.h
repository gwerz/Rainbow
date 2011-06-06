//
//  RainbowAppDelegate.h
//  Rainbow
//
//  Created by John Heaton on 5/29/11.
//  Copyright 2011 GJB Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LogTableHelper.h"
#import "MDListener.h"


@interface RainbowAppDelegate : NSObject <NSApplicationDelegate, MDListener, NSTableViewDataSource> {
@private
    IBOutlet NSWindow *window;
    IBOutlet NSDrawer *logDrawer;
    IBOutlet NSTableView *tableScrollView;
    IBOutlet NSImageView *statusOrbView;
    IBOutlet NSTextField *connectedDeviceLabel;
    IBOutlet NSBox *moduleView;
    IBOutlet NSView *noModuleView;
    IBOutlet LogTableHelper *logTableHelper;
    id _currentModuleView;
    NSInteger deselectedCell;
}

- (void)setModuleSelectorLocked:(BOOL)locked;
- (BOOL)resizeModuleViewToSize:(NSSize)size;

- (void)setCurrentModuleView:(NSView *)view;
- (void)reloadTable;
- (void)selectModuleAtIndex:(NSInteger)index;

- (void)centerWindow;

- (IBAction)addNewModule:(id)sender;

@property (nonatomic, readonly) LogTableHelper *logTableHelper;

@end

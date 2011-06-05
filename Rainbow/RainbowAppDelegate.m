//
//  RainbowAppDelegate.m
//  Rainbow
//
//  Created by John Heaton on 5/29/11.
//  Copyright 2011 GJB Software. All rights reserved.
//

#import "RainbowAppDelegate.h"
#import "MDNotificationCenter.h"
#import "LeprechaunPuncher.h"

@implementation RainbowAppDelegate

@synthesize logTableHelper;

static NSImage *redOrbImage = nil;
static NSImage *greenOrbImage = nil;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    redOrbImage = [[NSImage imageNamed:@"red-orb.png"] retain];
    greenOrbImage = [[NSImage imageNamed:@"green-orb.png"] retain];
    
    _currentModuleView = nil;
    
    [window setContentBorderThickness:25.0 forEdge:NSMinYEdge];
    [window setMovableByWindowBackground:YES];
    
    [connectedDeviceLabel setStringValue:@"No Device Connected"];
    [logTableHelper appendLogMessage:@"Welcome to Rainbow, the modular iDevice utility for OS X" fromSender:@"Rainbow"];
    
    [statusOrbView setImage:redOrbImage];
    [[MDNotificationCenter sharedInstance] addListener:self];
    
    deselectedCell = -1;
    
    [self centerWindow];
    
    [[LeprechaunPuncher sharedInstance] loadAllModules];
    [tableScrollView reloadData];
    
    NSLog(@"%@", [self tableView:nil objectValueForTableColumn:nil row:0]);
    
    [window makeKeyAndOrderFront:nil];
    
    [logDrawer open:self];
    [self selectModuleAtIndex:-1];
}

- (void)reloadTable {
    [tableScrollView reloadData];
    
    if([[LeprechaunPuncher sharedInstance] moduleCount] != 0) 
        [self selectModuleAtIndex:0];
    else
        [self selectModuleAtIndex:-1];
}

- (BOOL)resizeModuleViewToSize:(NSSize)size {
    BOOL animate = NO;
    
    if(_currentModuleView) {
        [_currentModuleView removeFromSuperview];
        animate = YES;
    }
    
    NSRect frame = [window frame];
    NSRect mFrame = [moduleView frame];
    NSRect sFrame = [[NSScreen mainScreen] visibleFrame];
    
    CGFloat viewWidthRatio = (frame.size.width / mFrame.size.width);
    CGFloat viewHeightRatio = (frame.size.height / mFrame.size.height);
    
    CGFloat xDelta = (size.width - (frame.size.width / viewWidthRatio));
    CGFloat yDelta = (size.height - (frame.size.height / viewHeightRatio));
    
    frame.origin.y -= yDelta;
    frame.size.width += xDelta;
    frame.size.height += yDelta;
    
    if(frame.size.height > (sFrame.size.height - [[NSStatusBar systemStatusBar] thickness]) 
       || frame.size.width > sFrame.size.width) {
        return NO;
    }
    
    [window setFrame:frame display:YES animate:animate];
    [logTableHelper reloadTable];
    
    return YES;
}

- (void)setModuleSelectorLocked:(BOOL)locked {
    [tableScrollView setEnabled:!locked];
}

- (void)labelDeviceAs:(NSString *)name {
    [connectedDeviceLabel setStringValue:name];
}

- (void)updateDeviceLabelForDetachedDevice {
    [statusOrbView setImage:redOrbImage];
    [self labelDeviceAs:@"No Device Connected"];
}

- (void)updateDeviceLabelForProductID:(uint16_t)pid deviceID:(uint32_t)did isRestore:(BOOL)isRestore {
    [statusOrbView setImage:greenOrbImage];
    [self labelDeviceAs:iOSGetDeviceConnectionType(pid, did, isRestore)];
}

- (void)normalDeviceAttached:(AMDeviceRef)device {
    [self updateDeviceLabelForProductID:AMDeviceUSBProductID(device) deviceID:0 isRestore:NO];
}

- (void)normalDeviceDetached:(AMDeviceRef)device {
    [self updateDeviceLabelForDetachedDevice];
}

- (void)normalDeviceConnectionError {
    [self updateDeviceLabelForDetachedDevice];
}

- (void)restoreDeviceAttached:(AMRestoreModeDeviceRef)device {
    [self updateDeviceLabelForProductID:AMDeviceUSBProductID((AMDeviceRef)device) deviceID:0 isRestore:YES];
}

- (void)restoreDeviceDetached:(AMRestoreModeDeviceRef)device {
    [self updateDeviceLabelForDetachedDevice];
}

- (void)recoveryDeviceAttached:(AMRecoveryModeDeviceRef)device {
    [self updateDeviceLabelForProductID:AMRecoveryModeDeviceGetProductID(device) deviceID:AMRecoveryModeDeviceGetProductType(device) isRestore:NO];
}

- (void)recoveryDeviceDetached:(AMRecoveryModeDeviceRef)device {
    [self updateDeviceLabelForDetachedDevice];
}

- (void)dfuDeviceAttached:(AMDFUModeDeviceRef)device {
    [self updateDeviceLabelForProductID:AMDFUModeDeviceGetProductID(device) deviceID:AMDFUModeDeviceGetProductType(device) isRestore:NO];
}

- (void)dfuDeviceDetached:(AMDFUModeDeviceRef)device {
    [self updateDeviceLabelForDetachedDevice];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [[MDNotificationCenter sharedInstance] removeListener:self];
    [[LeprechaunPuncher sharedInstance] unloadAllModules];
}

- (void)setCurrentModuleView:(NSView *)view {
    if([_currentModuleView isEqual:view]) return;
    
    [self resizeModuleViewToSize:[view frame].size];
    [moduleView addSubview:view];
    
    _currentModuleView = view;
}

- (void)centerWindow {
    [window setFrameOrigin:NSMakePoint(([[NSScreen mainScreen] visibleFrame].size.width / 2) - ([window frame].size.width / 2), ([[NSScreen mainScreen] visibleFrame].size.height / 2) - ([window frame].size.height / 2) + ([[NSScreen mainScreen] visibleFrame].size.height / 8))];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[LeprechaunPuncher sharedInstance] moduleCount];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if([[LeprechaunPuncher sharedInstance] moduleCount] != 0)
        return [[[LeprechaunPuncher sharedInstance] moduleNames] objectAtIndex:row];
    
    return nil;
}

- (void)selectModuleAtIndex:(NSInteger)index {
    if(index == -1) {
        [tableScrollView deselectRow:[tableScrollView selectedRow]];
        
        [self setCurrentModuleView:noModuleView];
    } else {
        [tableScrollView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    NSString *currentModuleName = ([tableScrollView selectedRow] != -1 ? [[[LeprechaunPuncher sharedInstance] moduleNames] objectAtIndex:[tableScrollView selectedRow]] : nil);
    
    // handle deselection of cell
    if(deselectedCell != -1 && [[LeprechaunPuncher sharedInstance] moduleCount] > deselectedCell) {
        NSString *previousModuleName = [[[LeprechaunPuncher sharedInstance] moduleNames] objectAtIndex:deselectedCell];
        
        if([[LeprechaunPuncher sharedInstance] moduleExistsNamed:previousModuleName]) {
            if([[LeprechaunPuncher sharedInstance] moduleWantsTearDownOnDeselection:previousModuleName]) {
                [[LeprechaunPuncher sharedInstance] tearDownModuleNamed:previousModuleName];
            } else {
                [[LeprechaunPuncher sharedInstance] pauseModuleNamed:previousModuleName];
            }
        }
    }
    
    if([tableScrollView selectedRow] == -1) {
        [self setCurrentModuleView:noModuleView];
    } else {
        if([[LeprechaunPuncher sharedInstance] moduleIsStartedNamed:currentModuleName]) {
            [[LeprechaunPuncher sharedInstance] resumeModuleNamed:currentModuleName];
        } else {
            [[LeprechaunPuncher sharedInstance] startModuleNamed:currentModuleName];
        }
        
        [self setCurrentModuleView:[[[LeprechaunPuncher sharedInstance] instanceForModuleNamed:currentModuleName] rootView]];
    }
    
    deselectedCell = [tableScrollView selectedRow];
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    [cell setEditable:NO];
}

- (IBAction)addNewModule:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanCreateDirectories:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"bundle"]];
    
    [panel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
        if(result == NSOKButton) {
            NSString *filename = [[[panel URL] relativePath] lastPathComponent];
            NSString *newPath = [NSString stringWithFormat:@"%@/Contents/PlugIns/%@", [[NSBundle mainBundle] bundlePath], filename];
            
            [[NSFileManager defaultManager] copyItemAtPath:[[panel URL] relativePath] toPath:newPath error:nil];
            [[LeprechaunPuncher sharedInstance] loadModuleFromBundle:[NSBundle bundleWithPath:newPath]];
            [self reloadTable];
        }
    }];
}

- (IBAction)removeSelectedModule:(id)sender {
    [[LeprechaunPuncher sharedInstance] removeModuleNamed:[[[LeprechaunPuncher sharedInstance] moduleNames] objectAtIndex:[tableScrollView selectedRow]] permanently:YES];
    
    NSInteger nextIndex = [tableScrollView selectedRow] - [[LeprechaunPuncher sharedInstance] moduleCount];
    BOOL hasAnotherAvailableModule = ([[LeprechaunPuncher sharedInstance] moduleCount] > 0);
    
    nextIndex += (nextIndex == -1 ? 1 : 0);
    nextIndex += (hasAnotherAvailableModule ? 0 : -1);
    
    BOOL mustManuallySendChangeEvent = (nextIndex == [tableScrollView selectedRow]);

    [tableScrollView reloadData];
    
    if(mustManuallySendChangeEvent) {
        [self tableViewSelectionDidChange:nil];
    }
}

@end

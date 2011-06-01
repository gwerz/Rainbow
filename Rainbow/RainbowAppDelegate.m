//
//  RainbowAppDelegate.m
//  Rainbow
//
//  Created by John Heaton on 5/29/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import "RainbowAppDelegate.h"
#import "MDNotificationCenter.h"
#import "LeprechaunPuncher.h"

#define MODULE_VIEW_TAG 0xFADA

@implementation RainbowAppDelegate

static NSImage *redOrbImage = nil;
static NSImage *greenOrbImage = nil;

@synthesize window, logView, logDrawer, progressBar, progressLabel, moduleView, _currentModuleView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    (void)[LeprechaunPuncher sharedInstance];
    
    redOrbImage = [[NSImage imageNamed:@"red-orb.png"] retain];
    greenOrbImage = [[NSImage imageNamed:@"green-orb.png"] retain];
    
    _currentModuleView = nil;
    
    [window setContentBorderThickness:25.0 forEdge:NSMinYEdge];
    [window setMovableByWindowBackground:YES];
    
    [connectedDeviceLabel setStringValue:@"No Device Connected"];
    
    [statusOrbView setImage:redOrbImage];
    [[MDNotificationCenter sharedInstance] addListener:self];
    
    [self logString:@"Welcome to Rainbow, the most powerful iDevice utility!" color:[NSColor blueColor] fontSize:16 senderName:@"Rainbow"];
    
    [tableScrollView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    
    [self centerWindow];
    [window makeKeyAndOrderFront:nil];
    
    [logView setEditable:NO];
    [logDrawer open:self];
}

- (void)logString:(NSString *)string color:(NSColor *)color fontSize:(CGFloat)size senderName:(NSString *)name {
    NSMutableAttributedString *title = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%@] ", name]] autorelease];
    NSMutableAttributedString *msg = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", string]] autorelease];
    
    [title addAttribute:NSForegroundColorAttributeName value:[NSColor darkGrayColor] range:NSMakeRange(0, [title length])];
    [msg addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [msg length])];
    
    [title addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:size] range:NSMakeRange(0, [title length])];
    [msg addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:size] range:NSMakeRange(0, [msg length])];
    
    NSTextStorage *storage = [logView textStorage];
    [storage beginEditing];
    [storage appendAttributedString:title];
    [storage appendAttributedString:msg];
    [storage endEditing];
    
    [logView scrollToEndOfDocument:nil];
}

- (void)logStringSimple:(NSString *)string senderName:(NSString *)name {
    NSMutableAttributedString *title = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%@] ", name]] autorelease];
    NSMutableAttributedString *msg = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", string]] autorelease];
    
    [title addAttribute:NSForegroundColorAttributeName value:[NSColor darkGrayColor] range:NSMakeRange(0, [title length])];
    
    NSTextStorage *storage = [logView textStorage];
    [storage beginEditing];
    [storage appendAttributedString:title];
    [storage appendAttributedString:msg];
    [storage endEditing];
    
    [logView scrollToEndOfDocument:nil];
}

- (void)logErrorString:(NSString *)string senderName:(NSString *)name {
    NSMutableAttributedString *title = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%@] ", name]] autorelease];
    NSMutableAttributedString *msg = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"ERROR: %@\n", string]] autorelease];
    
    [title addAttribute:NSForegroundColorAttributeName value:[NSColor darkGrayColor] range:NSMakeRange(0, [title length])];
    [msg addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0, [msg length])];
    
    NSTextStorage *storage = [logView textStorage];
    [storage beginEditing];
    [storage appendAttributedString:title];
    [storage appendAttributedString:msg];
    [storage endEditing];
    
    [logView scrollToEndOfDocument:nil];
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
    [moduleView addSubview:view];
    
    _currentModuleView = view;
}

- (void)centerWindow {
    [window setFrameOrigin:NSMakePoint(([[NSScreen mainScreen] visibleFrame].size.width / 2) - ([window frame].size.width / 2), ([[NSScreen mainScreen] visibleFrame].size.height / 2) - ([window frame].size.height / 2) + ([[NSScreen mainScreen] visibleFrame].size.height / 8))];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[[LeprechaunPuncher sharedInstance] moduleNames] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [[[LeprechaunPuncher sharedInstance] moduleNames] objectAtIndex:row];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    [[LeprechaunPuncher sharedInstance] runModuleNamed:[[[LeprechaunPuncher sharedInstance] moduleNames] objectAtIndex:[tableScrollView selectedRow]]];
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    [cell setEditable:NO];
}

@end

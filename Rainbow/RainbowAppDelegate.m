//
//  RainbowAppDelegate.m
//  Rainbow
//
//  Created by John Heaton on 5/29/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import "RainbowAppDelegate.h"
#import "MobileDevice.h"
#import "MDNotificationCenter.h"
#import "LeprechaunPuncher.h"

#define ONE_CLICK_MODULE_TAG 8888
#define UI_MODULE_TAG 9999

@implementation RainbowAppDelegate

static NSImage *redOrbImage = nil;
static NSImage *greenOrbImage = nil;

@synthesize window, logView, logDrawer, progressBar, progressLabel, moduleView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    (void)[LeprechaunPuncher sharedInstance];
    
    redOrbImage = [[NSImage imageNamed:@"red-orb.png"] retain];
    greenOrbImage = [[NSImage imageNamed:@"green-orb.png"] retain];
    
    [logView setEditable:NO];
    [logDrawer open:self];
    
    [window setContentBorderThickness:25.0 forEdge:NSMinYEdge];
    [window setMovableByWindowBackground:YES];
    
    [connectedDeviceLabel setStringValue:@"No Device Connected"];
    
    [statusOrbView setImage:redOrbImage];
    [[MDNotificationCenter sharedInstance] addListener:self];
    
    [self logString:@"Welcome to Rainbow, the most powerful iDevice utility!" color:[NSColor blueColor] fontSize:16 senderName:@"Rainbow"];
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
    
    [window setFrame:frame display:YES animate:YES];
    
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

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    switch([tableView tag]) {
        case ONE_CLICK_MODULE_TAG:
            return [[LeprechaunPuncher sharedInstance] oneClickModules];
            break;
        case UI_MODULE_TAG:
            return [[LeprechaunPuncher sharedInstance] uiModules];
            break;
    }
    
    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSInteger skipped = 0;
    
    switch([tableView tag]) {
        case ONE_CLICK_MODULE_TAG:
            for(NSString *name in [[LeprechaunPuncher sharedInstance] moduleNames]) {
                if([[LeprechaunPuncher sharedInstance] moduleIsOneClickNamed:name])
                    if(skipped == row)
                        return name;
                    else 
                        skipped++;
            }
            break;
        case UI_MODULE_TAG:
            for(NSString *name in [[LeprechaunPuncher sharedInstance] moduleNames]) {
                if(![[LeprechaunPuncher sharedInstance] moduleIsOneClickNamed:name])
                    if(skipped == row)
                        return name;
                    else 
                        skipped++;
            }
            break;
    }
    
    return nil;
}

@end

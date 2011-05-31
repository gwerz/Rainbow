//
//  Module.m
//  Rainbow
//
//  Created by John Heaton on 5/30/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import "Module.h"
#import "MDNotificationCenter.h"

@implementation EnterRecovery

@synthesize goButton;

-(id)init {
    if(![NSBundle loadNibNamed:nil owner:self]) {
        return nil;
    }
    
    return self;
}

- (void)setup {
    [goButton removeFromSuperview];
    
    nDevice = nil;
    rDevice = nil;
    [[MDNotificationCenter sharedInstance] addListener:self];
}

- (void)tearDown {
    [[MDNotificationCenter sharedInstance] removeListener:self];
}

- (void)normalDeviceAttached:(AMDeviceRef)dev {
    [self sendLogMessage:[NSString stringWithFormat:@"Device found: AMDeviceRef @ %p", dev]];
    nDevice = dev;
    
    [goButton setTitle:@"Enter Recovery"];
    [rootViewController.view addSubview:goButton];
    [statusField setStringValue:@"Normal device Found."];
}

- (void)normalDeviceDetached:(AMDeviceRef)dev {
    nDevice = NULL;
    
    [statusField setStringValue:@"Waiting for device..."];
    [goButton removeFromSuperview];
}

- (void)recoveryDeviceAttached:(AMRecoveryModeDeviceRef)device {
    rDevice = device;
    
    [self sendLogMessage:[NSString stringWithFormat:@"Device found: AMRecoveryModeDeviceRef @ %p", device]];

    [goButton setEnabled:YES];
    [goButton setTitle:@"Exit Recovery"];
    [rootViewController.view addSubview:goButton];
    
    [statusField setStringValue:@"Recovery device Found."];
}

- (void)recoveryDeviceDetached:(AMRecoveryModeDeviceRef)device {
    rDevice = NULL;
    
    [goButton removeFromSuperview];
    [statusField setStringValue:@"Waiting for device..."];
}

- (IBAction)enterRecovery:(id)sender {
    if(nDevice != NULL) {
        NSInteger status = AMDeviceEnterRecovery(nDevice);
        [self sendLogMessage:[NSString stringWithFormat:@"AMDeviceEnterRecovery: %d\n", status]];
        
        if(status == kAMStatusSuccess)
            [goButton removeFromSuperview];
    } else if(rDevice != NULL) {
        NSInteger status = AMRecoveryModeDeviceSendCommandToDevice(rDevice, CFSTR("setenv auto-boot true"));
        [self sendLogMessage:[NSString stringWithFormat:@"\"setenv auto-boot true\": %d", status]];
        
        status = AMRecoveryModeDeviceSendCommandToDevice(rDevice, CFSTR("saveenv"));
        [self sendLogMessage:[NSString stringWithFormat:@"\"saveenv\": %d", status]];
        
        status = AMRecoveryModeDeviceSendBlindCommandToDevice(rDevice, CFSTR("reboot"));
        [self sendLogMessage:[NSString stringWithFormat:@"\"reboot\": %d", status]];
        
        if(status == kAMStatusSuccess)
            [goButton removeFromSuperview];
    }
}

- (BOOL)shouldUnloadOnDeselection {
    return YES;
}

- (NSSize)requiredViewSize {
    return [rootViewController.view frame].size;
}

- (NSView *)rootView {
    return rootViewController.view;
}

- (NSString *)userPresentableName {
    return @"Enter Recovery";
}

@end

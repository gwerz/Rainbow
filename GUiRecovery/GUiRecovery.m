//
//  GUiRecovery.m
//  GUiRecovery
//
//  Created by John Heaton on 6/4/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import "GUiRecovery.h"

int device_connected(irecv_client_t client, const irecv_event_t* event) {
    NSLog(@"Connected: %@", (id)event->data);
    
    return 0;
}

@implementation GUiRecovery

@synthesize rootViewController;

- (id)init {
    if(![NSBundle loadNibNamed:@"GUiRecovery" owner:self])
        return nil;
    
    return self;
}

- (void)setup {
    irecv_init();
}

- (void)tearDown {
    irecv_exit();
}

- (void)start {
}

- (NSString *)userPresentableName {
    return @"GUiRecovery";
}

- (NSView *)rootView {
    return rootViewController.view;
}

- (BOOL)shouldTearDownOnDeselection {
    return NO;
}

- (void)dealloc {
    [super dealloc];
}

@end

//
//  Module.h
//  Rainbow
//
//  Created by John Heaton on 5/30/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import "MDListener.h"
#import "Leprechaun.h"


@interface EnterRecovery : NSObject <MDListener, Leprechaun> {
@private
    AMDeviceRef nDevice;
    AMRecoveryModeDeviceRef rDevice;
    IBOutlet NSTextField *statusField;
    IBOutlet NSViewController *rootViewController;
    NSButton *goButton;
}

- (IBAction)enterRecovery:(id)sender;

@property (nonatomic, retain) IBOutlet NSButton *goButton;

@end

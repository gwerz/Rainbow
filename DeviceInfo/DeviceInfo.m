//
//  DeviceInfo.m
//  Rainbow
//
//  Created by John Heaton on 6/6/11.
//  Copyright 2011 GJB Software. All rights reserved.
//

#import "DeviceInfo.h"
#import "MDNotificationCenter.h"


@implementation DeviceInfo

@synthesize rootViewController, infoTable;

- (id)init {
    if(![NSBundle loadNibNamed:@"DeviceInfo" owner:self])
        return nil;
    
    return self;
}

- (void)setup {

}

- (void)start {
    populatedData = NO;
    [[MDNotificationCenter sharedInstance] addListener:self];
}

- (void)tearDown {
    populatedData = NO;
    [[MDNotificationCenter sharedInstance] removeListener:self];
}

- (void)normalDeviceAttached:(AMDeviceRef)device {
    LMLogMessage(self, @"Getting device info");
    [[[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(getDeviceInfo:) object:(id)device] autorelease] start];
}

- (void)getDeviceInfo:(id)device {
    if(deviceInfo != nil)
        [deviceInfo release];
    
    deviceInfo = (NSDictionary *)AMDeviceCopyValue((AMDeviceRef)device, NULL, NULL);
    [infoTable reloadData];
}

- (NSString *)userPresentableName {
    return @"Device Info";
}

- (NSView *)rootView {
    return rootViewController.view;
}

- (BOOL)shouldTearDownOnDeselection {
    return YES;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[deviceInfo allKeys] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    switch([[tableColumn identifier] intValue]) {
        case 1: {
            return [[deviceInfo allKeys] objectAtIndex:row];
        } break;
        case 2: {
            return [deviceInfo objectForKey:[[deviceInfo allKeys] objectAtIndex:row]];
        } break;
    }
    
    return nil;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    [cell setEditable:NO];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return [[infoTable preparedCellAtColumn:1 row:row] cellSizeForBounds:NSMakeRect(0, 0, [[[infoTable tableColumns] objectAtIndex:1] width], NSIntegerMax)].height;
}

- (void)dealloc {
    [deviceInfo release];
    [super dealloc];
}

@end

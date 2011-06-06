//
//  DeviceInfo.h
//  Rainbow
//
//  Created by John Heaton on 6/6/11.
//  Copyright 2011 GJB Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Leprechaun.h"
#import "MDListener.h"


@interface DeviceInfo : NSObject <Leprechaun, MDListener, NSTableViewDelegate, NSTableViewDataSource> {
@private
    NSViewController *rootViewController;
    NSTableView *infoTable;
    NSDictionary *deviceInfo;
    BOOL populatedData;
}

@property (nonatomic, assign) IBOutlet NSViewController *rootViewController;
@property (nonatomic, assign) IBOutlet NSTableView *infoTable;

@end

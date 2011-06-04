//
//  LogTableHelper.h
//  Rainbow
//
//  Created by John Heaton on 6/4/11.
//  Copyright 2011 GJB Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LogTableHelper : NSObject <NSTableViewDelegate, NSTableViewDataSource> {
@private
    NSMutableArray *logMessages;
    IBOutlet NSTableView *table;
}

- (void)reloadTable;
- (void)appendLogMessage:(NSString *)message fromSender:(NSString *)sender;

@end

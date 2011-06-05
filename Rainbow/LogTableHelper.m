//
//  LogTableHelper.m
//  Rainbow
//
//  Created by John Heaton on 6/4/11.
//  Copyright 2011 GJB Software. All rights reserved.
//

#import "LogTableHelper.h"

#define SENDER_NAME_KEY @"Sender"
#define MESSAGE_KEY @"Message"
#define TIME_KEY @"Time"

@implementation LogTableHelper

- (id)init {
    if((self = [super init]) != nil) {
        logMessages = [[NSMutableArray arrayWithCapacity:0] retain];
    }
    
    return self;
}

- (void)reloadTable {
    [table reloadData];
    
    NSRect rect = [table rectOfRow:[logMessages count]-1];
    [table scrollRectToVisible:rect];
}

- (void)appendLogMessage:(NSString *)message fromSender:(NSString *)sender {
    [logMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:message, MESSAGE_KEY, sender, SENDER_NAME_KEY, [NSDate date], TIME_KEY, nil]];
    [self reloadTable];
}

- (NSString *)_senderOfMessageAtIndex:(NSInteger)index {
    return [[logMessages objectAtIndex:index] objectForKey:SENDER_NAME_KEY];
}

- (NSString *)_contentsOfMessageAtIndex:(NSInteger)index {
    return [[logMessages objectAtIndex:index] objectForKey:MESSAGE_KEY];
}

- (NSString *)_dateStringOfMessageAtIndex:(NSInteger)index {
    return [NSDateFormatter localizedStringFromDate:[[logMessages objectAtIndex:index] objectForKey:TIME_KEY] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
}

// tableview stuff

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [logMessages count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    switch([[tableColumn identifier] intValue]) {
        case 0: {
            return [[[NSAttributedString alloc] initWithString:[self _senderOfMessageAtIndex:row] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Monaco" size:10], NSFontAttributeName, nil]] autorelease];
        } break;
        case 1: {
            return [[[NSAttributedString alloc] initWithString:[self _contentsOfMessageAtIndex:row] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Monaco" size:10], NSFontAttributeName, nil]] autorelease];
        } break;
        case 3: {
            return [[[NSAttributedString alloc] initWithString:[self _dateStringOfMessageAtIndex:row] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Monaco" size:10], NSFontAttributeName, nil]] autorelease];
        } break;
    }
    
    return nil;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    [cell setEditable:NO];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return [[table preparedCellAtColumn:2 row:row] cellSizeForBounds:NSMakeRect(0, 0, [[[table tableColumns] objectAtIndex:2] width], NSIntegerMax)].height;
}

- (void)dealloc {
    [logMessages release];
    [super dealloc];
}

@end

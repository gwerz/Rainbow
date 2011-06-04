//
//  Leprechaun.h
//  Rainbow
//
//  Created by John Heaton on 5/30/11.
//  Copyright 2011 GJB Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Leprechaun <NSObject>

@required
- (void)setup;
- (void)tearDown;
- (void)start;

- (NSString *)userPresentableName;
- (NSView *)rootView;

- (BOOL)shouldBeKilledOnDeselection;

@end

/* Helper Functions */
void LMLogMessage(id<Leprechaun> module, NSString *message);
void LMSetModuleSelectorLocked(id<Leprechaun> module, BOOL locked);
NSBundle *LMGetBundle(id<Leprechaun> module);

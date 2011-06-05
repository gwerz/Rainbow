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
- (void)setup; // called ONCE. load resources here

- (void)start; // called on the initial selection.
- (void)tearDown; // called when the module instance is about to be killed. clean up here

- (NSString *)userPresentableName;
- (NSView *)rootView;

- (BOOL)shouldTearDownOnDeselection; // call -tearDown instead of -handleDeselectionByUser on deselection 

@optional
- (void)handleDeselectionByUser;
- (void)handleReselectionByUser;

@end

/* Helper Functions */
void LMLogMessage(id<Leprechaun> module, NSString *message);
void LMSetModuleSelectorLocked(id<Leprechaun> module, BOOL locked);
NSBundle *LMGetBundle(id<Leprechaun> module);

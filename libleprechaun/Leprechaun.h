//
//  Leprechaun.h
//  Rainbow
//
//  Created by John Heaton on 5/30/11.
//  Copyright 2011 Springfield High School. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDListener.h"

@protocol LeprechaunModuleDelegate;

@interface LeprechaunSimpleModule : NSObject {
@private
    id<LeprechaunModuleDelegate> _delegate;
    NSBundle *currentBundle;
    NSNumber *_loaded;
}

- (void)setup; // do basic setup here
- (void)tearDown; // get cleaned up before killed

- (void)start;

- (BOOL)shouldUnloadOnDeselection; // default = YES

- (NSString *)userPresentableName;

- (void)sendLogMessage:(NSString *)message;
- (void)sendErrorLogMessage:(NSString *)message;

- (BOOL)isLoaded;

@property (assign) id<LeprechaunModuleDelegate> delegate;
@property (getter=getBundle, readonly) NSBundle *currentBundle;

@end

@interface LeprechaunUIModule : LeprechaunSimpleModule {
@private
    
}

- (NSSize)requiredViewSize; // how big the view needs to be
- (NSView *)rootView;

- (void)lockModuleSelector; // locks the selection list so that a user may not leave/unload the current module while it's operating... could be hazardous to device
- (void)unlockModuleSelector;

@end

@protocol LeprechaunModuleDelegate <NSObject>

@required
- (void)leprechaunModuleFinished:(id)module;

@end

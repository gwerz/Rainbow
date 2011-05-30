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
}

- (id)initWithDelegate:(id<LeprechaunModuleDelegate>)delegate;

- (void)setup; // do basic setup here
- (void)unload; // get cleaned up

- (void)sendLogMessage:(NSString *)message;
- (void)sendErrorLogMessage:(NSString *)message;

@property (assign) id<LeprechaunModuleDelegate> delegate;

@end

@interface LeprechaunUIModule : LeprechaunSimpleModule <MDListener> {
@private
    
}

- (BOOL)enableProgressBarAtStart; // Default = NO
- (NSSize)requiredViewSize; // how big the view needs to be

// UI module progress bar -- is hidden and shown at bottom of window
- (void)setProgressBarVisible:(BOOL)visible animated:(BOOL)animated; // will set the unified progress bar visible
- (void)setProgressBarIsIndeterminate:(BOOL)indeterminate;
- (void)updateProgressTitle:(NSString *)title; // sets the label text
- (void)updateProgress:(CGFloat)percent; // sets on progress bar

- (void)lockModuleSelector; // locks the selection list so that a user may not leave/unload the current module while it's operating... could be hazardous to device
- (void)unlockModuleSelector;

@end

@protocol LeprechaunModuleDelegate <NSObject>

@required
- (void)leprechaunModuleFinished:(id)module;

@end
